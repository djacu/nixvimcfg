inputs:
inputs.nixpkgs.lib.genAttrs
  [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ]
  (system: {
    default = inputs.nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule {
      pkgs = inputs.self.legacyPackages.${system};
      module = import ../config;
    };
  })
