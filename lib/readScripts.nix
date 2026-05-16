{ dir, prefix ? "" }:
let
  entries = builtins.readDir dir;
  scriptName = name:
    let
      m = builtins.match "(.*)\\.sh" name;
    in
    prefix + (if m == null then name else builtins.elemAt m 0);
in
builtins.foldl'
  (acc: name:
  let
    type = entries.${name};
  in
  if type == "regular" then
    acc // {
      ${scriptName name}.exec = builtins.readFile "${dir}/${name}";
    }
  else
    acc)
{ }
  (builtins.attrNames entries)
