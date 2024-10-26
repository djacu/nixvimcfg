inputs:
inputs.nixpkgs.lib.genAttrs
  [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ]
  (system: rec {
    default = neovim;
    inherit (inputs.self.legacyPackages.${system}.nixvimcfg) neovim;
  })
