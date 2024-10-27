inputs: {
  default =
    { ... }:
    {
      imports = [
        ./cmp.nix
        ./conform-nvim.nix
        ./coq-nvim.nix
        ./fugitive.nix
        ./lsp.nix
        ./render-markdown.nix
        ./telescope.nix
        ./treesitter.nix
        ./which-key.nix
      ];
    };
}
