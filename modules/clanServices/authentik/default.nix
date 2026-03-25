{ lib, ... }:
{
  _class = "clan.service";
  manifest.name = "authentik";
  manifest.description = "Authentik identity provider and SSO solution";
  manifest.categories = [
    "Security"
    "Identity"
  ];
  manifest.readme = builtins.readFile ./README.md;

  roles.default = {
    description = "Authentik server instance";
    interface =
      { lib, ... }:
      {
        options = {
          image = lib.mkOption {
            type = lib.types.str;
            default = "ghcr.io/goauthentik/server";
            description = "The docker image to use for authentik";
          };

          tag = lib.mkOption {
            type = lib.types.str;
            default = "2026.2.1";
            description = "The tag/version of the authentik image";
          };

          externalPort = lib.mkOption {
            type = lib.types.port;
            default = 9000;
            description = "External HTTP port to expose authentik on";
          };

          domain = lib.mkOption {
            type = lib.types.str;
            example = "auth.example.com";
            description = "The domain where authentik will be accessible";
          };

          email = lib.mkOption {
            type = lib.types.str;
            example = "admin@example.com";
            description = "Admin email address for letsencrypt certificates";
          };
        };
      };

    perInstance =
      {
        settings,
        instanceName,
        ...
      }:
      {
        nixosModule =
          {
            pkgs,
            config,
            lib,
            ...
          }:
          {
            imports = [ ];

            # Enable docker service
            virtualisation.docker.enable = lib.mkDefault true;
            # Generate required secrets
            clan.core.vars.generators.authentik-secrets = {
              files.AUTHENTIK_SECRET_KEY = { };
              files.PG_PASS = { };
              runtimeInputs = with pkgs; [
                coreutils
                openssl
              ];
              script = ''
                # Generate secret key (60 characters, base64 encoded)
                openssl rand -base64 60 | tr -d '\n' > "$out"/AUTHENTIK_SECRET_KEY
                # Generate postgres password (99 char max for pg)
                openssl rand -base64 33 | tr -d '\n' | head -c 99 > "$out"/PG_PASS
              '';
            };

            # Create .env file for authentik
            environment.etc."authentik/.env".text = ''
              AUTHENTIK_SECRET_KEY=${lib.fileContents config.clan.core.vars.generators.authentik-secrets.files.AUTHENTIK_SECRET_KEY.path}
              PG_PASS=${lib.fileContents config.clan.core.vars.generators.authentik-secrets.files.PG_PASS.path}
              AUTHENTIK_ERROR_REPORTING__ENABLED=true
              COMPOSE_PORT_HTTP=${toString settings.externalPort}
            '';

            # Create docker compose file for authentik
            environment.etc."authentik/docker-compose.yml".text = ''
              services:
                postgresql:
                  image: docker.io/library/postgres:16-alpine
                  container_name: authentik_postgresql
                  restart: unless-stopped
                  env_file:
                    - .env
                  environment:
                    POSTGRES_DB: authentik
                    POSTGRES_USER: authentik
                  volumes:
                    - database:/var/lib/postgresql/data
                  healthcheck:
                    test: ["CMD-SHELL", "pg_isready -d $$POSTGRES_DB -U $$POSTGRES_USER"]
                    interval: 30s
                    retries: 5
                    start_period: 20s
                    timeout: 5s

                server:
                  command: server
                  image: ${settings.image}:${settings.tag}
                  container_name: authentik_server
                  restart: unless-stopped
                  env_file:
                    - .env
                  environment:
                    AUTHENTIK_POSTGRESQL__HOST: postgresql
                    AUTHENTIK_POSTGRESQL__NAME: authentik
                    AUTHENTIK_POSTGRESQL__USER: authentik
                  ports:
                    - "${toString settings.externalPort}:9000"
                    - "9443:9443"
                  volumes:
                    - ./data:/data
                    - ./custom-templates:/templates
                  depends_on:
                    postgresql:
                      condition: service_healthy
                  shm_size: 512mb

                worker:
                  command: worker
                  image: ${settings.image}:${settings.tag}
                  container_name: authentik_worker
                  restart: unless-stopped
                  env_file:
                    - .env
                  environment:
                    AUTHENTIK_POSTGRESQL__HOST: postgresql
                    AUTHENTIK_POSTGRESQL__NAME: authentik
                    AUTHENTIK_POSTGRESQL__USER: authentik
                  volumes:
                    - /var/run/docker.sock:/var/run/docker.sock
                    - ./data:/data
                    - ./certs:/certs
                    - ./custom-templates:/templates
                  depends_on:
                    postgresql:
                      condition: service_healthy
                  shm_size: 512mb
                  user: root

              volumes:
                database:
                  driver: local
            '';

            # Systemd service to manage authentik via docker compose
            systemd.services.authentik = {
              wantedBy = [ "multi-user.target" ];
              after = [
                "docker.service"
                "network.target"
              ];
              description = "Authentik Identity Provider";

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                WorkingDirectory = "/etc/authentik";
                ExecStart = "${pkgs.docker}/bin/docker compose up -d";
                ExecStop = "${pkgs.docker}/bin/docker compose down";
                TimeoutStartSec = 300;
                TimeoutStopSec = 60;
                Restart = "on-failure";
                RestartSec = "5s";
              };

              # Pre-pull images before starting
              preStart = ''
                ${pkgs.docker}/bin/docker compose pull
              '';
            };

            # Ensure data directory exists
            systemd.tmpfiles.rules = [
              "d /etc/authentik/data 0755 root root"
              "d /etc/authentik/custom-templates 0755 root root"
              "d /etc/authentik/certs 0755 root root"
            ];
          };
      };
  };
}
