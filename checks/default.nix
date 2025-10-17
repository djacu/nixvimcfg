inputs:
let

  inherit (inputs.nixpkgs)
    lib
    ;

  inherit (lib.attrsets)
    mapAttrs
    ;

  inherit (lib.trivial)
    const
    flip
    ;

in
mapAttrs (flip (
  const (system: {
    default = inputs.nixvim.lib.${system}.check.mkTestDerivationFromNixvimModule {
      pkgs = inputs.self.legacyPackages.${system};
      module = inputs.self.nixvimConfigurations.default;
    };
  })
)) inputs.self.legacyPackages
