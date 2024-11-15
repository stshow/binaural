{
  description = "Binaural Wave Generator Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          numpy
          scipy
          matplotlib
          soundfile
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core audio tools
            ffmpeg
            sox
            flac
            parallel

            # Shell utilities
            bc
            bash

            # Python environment with required packages
            pythonEnv
            audacity # for viewing/analyzing the generated waves
          ];

          shellHook = ''
            echo "Binaural Wave Generator Development Environment"
            echo "Available tools:"
            echo "  - ffmpeg: $(ffmpeg -version | head -n1)"
            echo "  - sox: $(sox --version)"
            echo "  - bc: $(bc --version | head -n1)"
            echo "  - python: $(python3 --version)"
            echo "  - flac: $(flac --version | head -n1)"
            echo "  - parallel: $(parallel --version | head -n1)"
            echo ""
            echo "Usage:"
            echo "1. Save your wave generation script as 'generate_binaural.sh'"
            echo "2. Make it executable: chmod +x generate_binaural.sh"
            echo "3. Run it: ./generate_binaural.sh"
            echo "4. Select the desired brainwave type from the menu"
            echo "5. Analyze the output: python3 analyze_binaural.py <filename.flac>"
          '';
        };
      }
    );
}
