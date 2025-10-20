{ ... }:
let
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  imports = builtins.filter (filePath: filePath != ./default.nix) (filesIn ./.);
in
{
  imports = [ ] ++ imports;
}
