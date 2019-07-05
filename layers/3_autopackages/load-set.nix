#TODO regenerate with knownPakcages only being the local package set, probably import from self? how does R resolve this stuff?
{config, lib, callPackage, pkgs, buildRPackage}:
let
  inherit (pkgs.lib) importJSON;
  jsonPackages = (importJSON ./json/cran-packages.json).packages; #TODO get mirror or something

  #These todos apply to the json stuff:
  #TODO sort tool? -> just import and export again with nix (attrsets are sorted), pipe through jq for pretty?
  #TODO im not super happy with this, maybe the old way was better, or make everything have to use a full-on override?
  #TODO split on remotes
  overridesDB = importJSON ./json/cran-simple-overrides.json;
  toPackage = n: obj: deriver (getMirror "cran") {
    name = n;
    inherit (builtins.trace obj obj) sha256 version;
    depends = map (n: toPackage n jsonPackages."${n}") obj.deps.known; #TODO make a util function that turns the json format into a proper n,v pair as opposed to an object and unfuck this
    } // (getPatch ./. n);
in
  simpleOverrides overridesDB (builtins.mapAttrs (n: v: toPackage n v) jsonPackages)
