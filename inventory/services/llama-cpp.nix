_: {
  instances.llama-cpp = {
    module.name = "@tyclan/llama-cpp";
    module.input = "self";
    roles.server.machines = {
      # ncvps01.settings = {
      #   model = {
      #     name = "phi3:mini";
      #     url = "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf?download=true";
      #     hash = "sha256:8a83c7fb9049a9b2e92266fa7ad04933bb53aa1e85136b7b30f1b8000ff2edef";
      #   };

      # };
      ltc01.settings = {
        threads = 2;
        batchSize = 128;
        model = {
          name = "qwen2.5-7B-Instruct:Q4_K_M";
          url = "https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf?download=true";
          hash = "sha256:65b8fcd92af6b4fefa935c625d1ac27ea29dcb6ee14589c55a8f115ceaaa1423";
        };
        # model = {
        #   name = "phi3:mini";
        #   url = "https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf?download=true";
        #   hash = "sha256:8a83c7fb9049a9b2e92266fa7ad04933bb53aa1e85136b7b30f1b8000ff2edef";
        # };
      };
    };
  };
}
