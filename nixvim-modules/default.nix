inputs:
let

  inherit (builtins)
    map
    readDir
    ;

  inherit (inputs.nixpkgs)
    lib
    ;

  inherit (lib.attrsets)
    attrNames
    filterAttrs
    ;

  inherit (lib.trivial)
    const
    ;

in
{
  default =
    { ... }:
    {
      imports =
        [
        ]
        ++ map (directory: ./${directory}) (
          attrNames (filterAttrs (const (entryType: entryType == "directory")) (readDir ./.))
        );
    };
}
