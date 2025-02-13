inputs: {
  nixvimcfg = final: prev: {
    nixvimcfg.neovim = final.nixvim.makeNixvimWithModule {
      pkgs = final;
      module = inputs.self.nixvimConfigurations.default;
    };
  };
}
