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
        inputs.self.overlays.nixvimcfg
      ];
      # WHY: nixpkgs marks vimPlugins.neotest-vitest as unfree (the
      # auto-generator picked up an unfree license tag upstream). The
      # neotest module's vitest adapter pulls this in. Allow only this
      # specific package by predicate rather than blanket allowUnfree.
      config.allowUnfreePredicate =
        pkg: inputs.nixpkgs.lib.getName pkg == "neotest-vitest";
    }
  )
