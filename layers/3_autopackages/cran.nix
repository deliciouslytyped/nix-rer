#TODO how did i break curl?!
#TODO regenerate with knownPakcages only being the local package set, probably import from self? how does R resolve this stuff?
{lib, pkgs}:
let
  inherit (pkgs.lib) importJSON;
  jsonPackages = (importJSON ./json/cran-packages.json).packages; #TODO get mirror or something

  #These todos apply to the json stuff:
  #TODO sort tool? -> just import and export again with nix (attrsets are sorted), pipe through jq for pretty?
  #TODO im not super happy with this, maybe the old way was better, or make everything have to use a full-on override?
  #TODO split on remotes
  #TODO the duplicated bioc versions are ehhhh...
  overridesDB = importJSON ./json/cran-simple-overrides.json;
  toPackage = n: obj: lib.deriver (lib.getMirror "cran") {
    name = n;
    inherit (obj) sha256 version;
    #TODO this needs to be the FINAL depends stuff so that propagated shit can work peoperly
    depends = map (n: toPackage n jsonPackages."${n}") obj.deps.known; #TODO make a util function that turns the json format into a proper n,v pair as opposed to an object and unfuck this
    } // (lib.getPatch n ./.);
in
  lib.simpleOverrides overridesDB (builtins.mapAttrs (n: v: toPackage n v) jsonPackages)

#TODO: Example where its necessary to search the global namespace: aroma.light
