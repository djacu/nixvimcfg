{
  description = "A nixvim configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
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
