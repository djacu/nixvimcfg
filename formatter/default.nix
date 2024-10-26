inputs:
inputs.nixpkgs.lib.genAttrs [
  "x86_64-linux"
  "aarch64-linux"
  "x86_64-darwin"
  "aarch64-darwin"
] (system: inputs.self.legacyPackages.${system}.nixfmt-rfc-style)
