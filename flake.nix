{
  description = "A nixvim configuration";

  inputs = {
    flake-parts.follows = "nixvim/flake-parts";
    nixpkgs.follows = "nixvim/nixpkgs";
    nixvim.inputs.nuschtosSearch.follows = "";
    nixvim.url = "github:nix-community/nixvim";
    systems.follows = "nixvim/systems";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs: {
    checks = import ./checks inputs;
    formatter = import ./formatter inputs;
    formatterModule = import ./formatter-module inputs;
    legacyPackages = import ./legacy-packages inputs;
    nixvimModules = import ./nixvim-modules inputs;
    nixvimConfigurations = import ./nixvim-configurations inputs;
    overlays = import ./overlays inputs;
    packages = import ./packages inputs;
  };
}
