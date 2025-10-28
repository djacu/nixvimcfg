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
    ;

in
mapAttrs (const (pkgs: rec {
  default = neovim;
  inherit (pkgs.nixvimcfg)
    neovim
    ;
})) inputs.self.legacyPackages
