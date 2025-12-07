# This is defined in the roster as a shared module, the modules imported here WILL be added to ALL hosts. Intended for custom options.
{ ... }:
let
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  imports = builtins.filter (filePath: filePath != ./default.nix) (filesIn ./.);
in
{
  imports = [ ] ++ imports;
}
