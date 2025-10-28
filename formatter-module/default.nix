inputs:
inputs.nixpkgs.lib.attrsets.mapAttrs (
  system: pkgs:
  (inputs.treefmt-nix.lib.evalModule pkgs (
    { ... }:
    {
      config = {
        enableDefaultExcludes = true;
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
        };
        settings.global.excludes = [
          "*.gitignore"
          ".git-blame-ignore-revs"
        ];
      };
    }
  ))
) inputs.self.legacyPackages
