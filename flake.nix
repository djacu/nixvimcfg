{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.inputs.devshell.follows = "";
    nixvim.inputs.flake-compat.follows = "";
    nixvim.inputs.git-hooks.follows = "";
    nixvim.inputs.home-manager.follows = "";
    nixvim.inputs.nix-darwin.follows = "";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.nuschtosSearch.follows = "";
    nixvim.inputs.treefmt-nix.follows = "";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = inputs: {
    checks = import ./checks inputs;
    formatter = import ./formatter inputs;
    legacyPackages = import ./legacy-packages inputs;
    nixvimModules = import ./nixvim-modules inputs;
    nixvimConfigurations = import ./nixvim-configurations inputs;
    overlays = import ./overlays inputs;
    packages = import ./packages inputs;
  };
}
