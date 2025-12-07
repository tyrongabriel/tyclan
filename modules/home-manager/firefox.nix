{ pkgs, config, ... }:

{
  # Import Firefox theme if desired (optional)
  programs.firefox = {
    enable = true;
    # Use Firefox for default browser
    package = pkgs.firefox;

    # Firefox profile settings
    profiles = {
      privacy-profile = {
        isDefault = true;

        # Essential extensions
        # extensions = with pkgs.nur.repos.firefox-addons; [
        #   # Primary ad/tracker blocker
        #   ublock-origin
        #   # Complementary tracker blocker
        #   privacybadger
        #   # Advanced script control
        #   noscript
        #   # Canvas fingerprinting protection
        #   canvasblocker
        #   # Cookie management
        #   cookie-autodelete
        #   # Local resource protection
        #   decentraleyes
        #   # Additional tracker blocking
        #   privacy-possum
        #   # Enhanced HTTPS enforcement
        #   https-everywhere
        #   # Ghostery (optional alternative/additional protection)
        #   ghostery
        #   # Bitwarden password manager
        #   bitwarden
        # ];

        # Firefox preferences for privacy
        settings = {
          # Enhanced Tracking Protection settings
          "browser.contentblocking.category" = "strict";
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.cryptomining.enabled" = true;
          "privacy.trackingprotection.fingerprinting.enabled" = true;

          # Disable telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;

          # Disable Firefox studies
          "extensions.systemAddon.update.enabled" = false;

          # Disable password saving and form autofill
          "signon.rememberSignons" = false;
          "browser.formfill.enable" = false;

          # Disable location access
          "browser.geo.enabled" = false;

          # Disable WebRTC leak protection
          "media.peerconnection.ice.default_address_only" = true;

          # Disable Pocket
          "extensions.pocket.enabled" = false;

          # Configure HTTPS-Only mode
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_upgrades" = true;

          # Enable resist fingerprinting
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;

          # Disable WebRTC
          #"media.peerconnection.enabled" = false;

          # Disable WebGL
          #"webgl.disabled" = true;

          # Disable automatic updates
          "app.update.auto" = false;
          "app.update.enabled" = false;

          # Disable new tab page sponsored content
          "browser.newtabpage.enabled" = false;

          # Enable DNS over HTTPS
          "network.trr.mode" = 2;
        };

        # Search engine configuration
        search = {
          force = true;
          default = "ddg";
          engines = {
            "ddg".urls = [
              {
                template = "https://duckduckgo.com/?q={searchTerms}&t=h_&ia=web";
              }
            ];
            "spg".urls = [
              {
                template = "https://startpage.com/do/search?query={searchTerms}";
              }
            ];
          };
        };
      };
    };
  };

  # Optional: Configure DNSCrypt for system-wide privacy
  # services.dnscrypt-proxy2 = {
  #   enable = true;
  #   settings = {
  #     require_dnssec = true;
  #     require_nolog = true;
  #     server_names = [
  #       "cloudflare"
  #       "cloudflare-ipv6"
  #       "google"
  #       "google-ipv6"
  #     ];
  #   };
  # };
}
