#TODO regenerate with knownPakcages only being the local package set, probably import from self? how does R resolve this stuff?
{lib, callPackage, pkgs, buildRPackage}:
let
  jsonPackages = (lib.importJSON ./json/cran-packages.json).packages; #TODO get mirror or something
  getMirror = name: #TODO meh
    let
      data = (lib.importJSON ./json/mirrors.json)."${name}";
    in {
      genUrls = packageName: packageVersion: data.urls; #TODO substitutions
      genHomepage = packageName: data.homepage;
      };
  wrapDeps = json: json // ({
    deps = json.deps // {
      known = map toPackage json.deps.known;
      };
    });#wrap the deps in toPackage
  deriver = callPackage ../../lib/derivers3.nix {inherit buildRPackage;};
  simpleOverrides = (callPackage ../../lib/overriders.nix {}).defaultOverrides;
  #These todos apply to the json stuff:
  #TODO sort tool?
  #TODO im not super happy with this, maybe the old way was better, or make everything have to use a full-on override?
  #TODO split on remotes
  overridesDB = lib.importJSON ./json/cran-simple-overrides.json;
  getPatch = n: if (builtins.hasAttr n (builtins.readDir ./patches)) then { patches = [ ./patches + ("/${n}.patch") ]; } else {};
  toPackage = n: obj: deriver (getMirror "cran") {
    name = n;
    inherit (builtins.trace obj obj) sha256 version;
    depends = map (n: toPackage n jsonPackages."${n}") obj.deps.known; #TODO make a util function that turns the json format into a proper n,v pair as opposed to an object and unfuck this
    } // (getPatch n);
in
  simpleOverrides overridesDB (builtins.mapAttrs (n: v: toPackage n v) jsonPackages)
