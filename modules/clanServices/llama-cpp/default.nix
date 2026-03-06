{
  ...
}:
{
  _class = "clan.service";

  manifest = {
    name = "llama-cpp";
    description = "Local AI runner using llama.cpp";
    categories = [
      "AI"
    ];
    readme = builtins.readFile ./README.md;
  };

  roles.server = {
    description = "The node running the llama.cpp inference engine.";
    interface =
      { lib, ... }:
      {
        options = {
          model = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "phi3-mini-gguf";
              description = "The internal name of the model.";
            };
            url = lib.mkOption {
              type = lib.types.str;
              description = "The direct download URL for the .gguf model file.";
            };
            hash = lib.mkOption {
              type = lib.types.str;
              default = lib.fakeHash;
              description = "The SRI hash of the downloaded model. On the first build, Nix will fail and tell you the correct hash to place here.";
            };
          };
          threads = lib.mkOption {
            type = lib.types.int;
            default = 2;
            description = "equivalent to num_thread: Number of threads to use during generation.";
          };
          batchSize = lib.mkOption {
            type = lib.types.int;
            default = 64;
            description = "equivalent to num_batch: Batch size for prompt processing.";
          };
          contextSize = lib.mkOption {
            type = lib.types.int;
            default = 4096;
            description = "equivalent to num_ctx: Size of the prompt context / context window.";
          };
          gpuLayers = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "equivalent to num_gpu: Number of layers to offload to VRAM. 0 means CPU-only.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8080; # llama.cpp default, but you can change it to 11434 for ollama compatibility
            description = "The port the llama-cpp server will listen on.";
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
          let
            # Nix fixed-output derivation to fetch the GGUF model at build time
            downloadedModel = pkgs.fetchurl {
              url = settings.model.url;
              hash = settings.model.hash;
            };
          in
          {
            services.llama-cpp = {
              enable = true;
              package = pkgs.llama-cpp;
              host = "0.0.0.0";
              port = settings.port;

              # Absolute path to the model in the Nix store
              model = "${downloadedModel}";

              # Manually configure the parameters you used in the Ollama Modelfile
              extraFlags = [
                "--threads"
                (toString settings.threads)
                "--batch-size"
                (toString settings.batchSize)
                "--ctx-size"
                (toString settings.contextSize)
                "--n-gpu-layers"
                (toString settings.gpuLayers)
              ];
            };

            # Open the firewall for the API if needed
            networking.firewall.allowedTCPPorts = [ settings.port ];

            # Add the llama-cpp binary to the system path for CLI use
            environment.systemPackages = [ pkgs.llama-cpp ];
          };
      };
  };
}
