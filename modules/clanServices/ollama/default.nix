{
  ...
}:
{
  _class = "clan.service";

  manifest = {
    name = "ollama";
    description = "Local AI runner";
    categories = [
      "AI"
    ];
    readme = builtins.readFile ./README.md;
  };

  roles.server = {
    description = "The node running the ollama inference engine.";
    interface =
      { lib, ... }:
      {
        options = {
          models = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "phi3:mini" ];
            description = "List of models to download and keep available.";
          };
          acceleration = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "cuda"
                "rocm"
              ]
            );
            default = null;
            description = "Hardware acceleration. Set to null for CPU-only";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 11434;
            description = "The port Ollama will listen on.";
          };
        };
      };

    perInstance =
      {
        settings,
        ...
      }:
      {
        nixosModule =
          {
            pkgs,
            ...
          }:
          {
            services.ollama = {
              enable = true;
              package = pkgs.ollama;
              acceleration = settings.acceleration;
              loadModels = settings.models;
              host = "0.0.0.0";
              port = settings.port;
            };

            # Optimization for 8GB RAM and 4 CPU cores
            systemd.services.ollama.serviceConfig = {
              Environment = [
                "OLLAMA_NUM_PARALLEL=1" # Reduce memory overhead by processing one request at a time
                "OLLAMA_MAX_LOADED_MODELS=1" # Ensure only one model stays in RAM
              ];
            };

            # Open the firewall for the API if needed
            networking.firewall.allowedTCPPorts = [ settings.port ];

            # Add the ollama binary to the system path for CLI use
            environment.systemPackages = [ pkgs.ollama ];
          };
      };
  };
}
