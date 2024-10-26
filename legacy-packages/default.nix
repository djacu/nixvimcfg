inputs:
inputs.nixpkgs.lib.genAttrs
  [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ]
  (
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = [
        inputs.nixvim.overlays.default
        inputs.self.overlays.bounds-check-patch
        inputs.self.overlays.nixvimcfg
      ];
    }
  )
