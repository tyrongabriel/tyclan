{ lib, ... }:
with lib;
with lib.types;
let
  myLib = (import ./default.nix) { inherit inputs; };
  outputs = inputs.self.outputs;
in
rec {
  # ================================================================ #
  # =                            My Lib                            = #
  # ================================================================ #

  # ======================= Package Helpers ======================== #

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

  # ========================== Buildables ========================== #

  mkIso =
    sys: config: extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      system = sys;
      specialArgs = {
        inherit inputs outputs myLib;
        pkgs-stable = import inputs.nixpkgs-stable {
          system = sys;
          config.allowUnfree = true;
        };
      };
      modules = [
        config
        {
          nixpkgs.hostPlatform = sys; # That way we dont need it in every iso
        }
      ]
      ++ extraModules;
    };

  mkSystem =
    sys: config: extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      system = sys;
      specialArgs = {
        inherit inputs outputs myLib;
        pkgs-stable = import inputs.nixpkgs-stable {
          system = sys;
          config.allowUnfree = true;
        };
      };
      modules = [
        config
        outputs.nixosModules.default
        # Extra config to use global and user packages
        {
          home-manager.useGlobalPkgs = true; # Tells Home-Manager to use systems nixpkgs
          home-manager.useUserPackages = true; # Allows home-manager to install to /etc/profiles
        }
      ]
      ++ extraModules;
    };

  mkHome =
    sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { system = sys; }; # pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs myLib outputs;
        pkgs-stable = import inputs.nixpkgs-stable {
          system = pkgsFor sys;
          config.allowUnfree = true;
        };
      };
      modules = [
        config
        outputs.homeManagerModules.default
        # Extra config to use global and user packages
        #{
        #  home-manager.useGlobalPkgs = true;
        #  home-manager.useUserPackages = true;
        #}
      ];
    };

  # =========================== Helpers ============================ #

  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  # Somehow fucked in clan
  dirsIn = dir: lib.filterAttrs (name: value: value == "directory") (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  # ========================== Extenders =========================== #

  # Evaluates nixos/home-manager module and extends it's options / config
  extendModule =
    { path, ... }@args:
    { pkgs, ... }@margs:
    let
      eval = if (builtins.isString path) || (builtins.isPath path) then import path margs else path margs;
      evalNoImports = builtins.removeAttrs eval [
        "imports"
        "options"
      ];

      extra =
        if (builtins.hasAttr "extraOptions" args) || (builtins.hasAttr "extraConfig" args) then
          [
            (
              { ... }:
              {
                options = args.extraOptions or { };
                config = args.extraConfig or { };
              }
            )
          ]
        else
          [ ];
    in
    {
      imports = (eval.imports or [ ]) ++ extra;

      options =
        if builtins.hasAttr "optionsExtension" args then
          (args.optionsExtension (eval.options or { }))
        else
          (eval.options or { });

      config =
        if builtins.hasAttr "configExtension" args then
          (args.configExtension (eval.config or evalNoImports))
        else
          (eval.config or evalNoImports);
    };

  # Applies extendModules to all modules
  # modules can be defined in the same way
  # as regular imports, or taken from "filesIn"
  extendModules =
    extension: modules:
    map (
      f:
      let
        name = fileNameOf f;
      in
      (extendModule ((extension name) // { path = f; }))
    ) modules;

  # ============================ Shell ============================= #
  forAllSystems =
    pkgs:
    inputs.nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system: pkgs inputs.nixpkgs.legacyPackages.${system});

  # ============================ NIX Config ======================= #
  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  ## Create a package NixOS module option.
  ##
  ## ```nix
  ## lib.mkPackageOpt pkgs.rofi-wayland "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkPackageOpt = mkOpt types.package;

  ## Create a package NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkPackageOpt' pkgs.rofi-wayland
  ## ```
  ##
  #@ Type -> Any -> String
  mkPackageOpt' = mkOpt types.package;

  enabled = {
    ## Quickly enable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ true
    enable = true;
  };

  disabled = {
    ## Quickly disable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ false
    enable = false;
  };

  ## Shortened syntax for if then else
  ifThenElse =
    condition: thenCase: elseCase:
    if condition then thenCase else elseCase;
}
