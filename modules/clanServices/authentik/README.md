# Authentik Clan Service

[Authentik](https://goauthentik.io/) is an identity provider and single sign-on (SSO) solution,
designed as a modern alternative to solutions like Keycloak.

## Features

- Single Sign-On (SSO) with SAML and OAuth2/OIDC support
- User authentication and management
- LDAP and SCIM integration
- Modern web-based admin interface
- Self-hosted and open source

## Usage

Example configuration in your inventory:

```nix
instances = {
  authentik = {
    roles.default.machines."my-machine".settings = {
      domain = "auth.example.com";
      email = "admin@example.com";
      image = "ghcr.io/goauthentik/server";
      tag = "2024.10.2";
      externalPort = 9000;
    };
  };
};
```
