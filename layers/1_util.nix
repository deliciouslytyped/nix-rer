self: super: {
  config = {
    #TODO is this really the appropriate place for these?

    };

  lib = {
    #TODO is this really the appropriate place for these?
    deriver = super.callPackage ../lib/derivers3.nix { buildRPackage = self.buildRPackage;};
    simpleOverrides = (super.callPackage ../lib/overriders.nix {}).defaultOverrides self.nixpkgs; #TODO this self is not great but i dont see how else to do it right now
    /*
    wrapDeps = json: toPackage: json // ({
      deps = json.deps // {
        known = map toPackage json.deps.known;
        };
      });#wrap the deps in toPackage
    */
    getPatch = n: root:
      let
        patchDir = root + "/patches";
      in
        (if (builtins.hasAttr n (builtins.readDir patchDir))
          then { patches = [ (patchDir + ("/${n}.patch")) ]; }
          else {});

    getMirror = name: #TODO meh
      let
        data = (super.nixpkgs.lib.importJSON ./3_autopackages/json/mirrors.json)."${name}";
        pversion = data.version;
      in {
        genUrls = packageName: packageVersion: map (u: builtins.replaceStrings ["\${pversion}" "\${name}" "\${version}"] [ pversion packageName packageVersion ] u) data.urls; #TODO substitutions
        genHomepage = packageName: builtins.replaceStrings [ "\${pversion}" "\${name}" ] [ pversion name ] data.homepage;
        };

    };

  }
