{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
      #system,
      ...
    }:
    let
      sopsDecrypt = pkgs.writeShellScriptBin "sops-decrypt" ''
        #!/usr/bin/env bash
        set -euo pipefail

        if [[ $# -ne 1 ]]; then
          echo "Usage: sops-decrypt <input-file>"
          exit 1
        fi

        INPUT_FILE="$1"
        OUTPUT_FILE="decrypted.$INPUT_FILE"

        echo "Decrypting $INPUT_FILE..."
        sops decrypt "$INPUT_FILE" --output "$OUTPUT_FILE"
        echo "Decryption complete. Output saved to: $OUTPUT_FILE"
      '';

      kDecryptApply = pkgs.writeShellScriptBin "k-decrypt-apply" ''
        #!/usr/bin/env bash
        set -euo pipefail

        if [[ $# -ne 1 ]]; then
          echo "Usage: k-decrypt-apply <input-file>"
          exit 1
        fi

        INPUT_FILE="$1"

        echo "Decrypting $INPUT_FILE and piping to 'kubectl apply'..."
        sops decrypt "$INPUT_FILE" | kubectl apply -f -
        echo "Kubernetes apply complete for $INPUT_FILE."
      '';

      # Combine both commands into one "package"
      customScripts = pkgs.symlinkJoin {
        name = "decrypt-tools";
        paths = [
          sopsDecrypt
          kDecryptApply
        ];
      };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          inputs'.clan-core.packages.clan-cli
          sops
          age
          ssh-to-age
          nh
          just
          customScripts
          cloudflared
        ];
      };
    };
}
