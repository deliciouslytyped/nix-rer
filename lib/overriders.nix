#ok so what seems to be going on here is this uses the transpose approach of a attrib-[package],
#as opposed the usual package-[attribs]
{lib}: rec {
  defaultOverrides = old: new:
    let
      oa = s: overrides: old: overrideDerivationsByAttr s overrides old;
      ob = s: v: packageNames: old: overrideFunctionsByArgument s v packageNames old;

      update = (f: o: o // f o);
      compose = (a: b: (update a) b);
      result = lib.foldr compose old [
        #Note these are 1 parameter functions taking the previous old set
        (ob "requireX" true packagesRequireingX) #TODO this is the lowest layer, is the fold correct?
        (ob "doCheck" false packagesToSkipCheck)
        (overrideRDepends packagesWithRDepends)
        (oa "nativeBuildInputs" packagesWithNativeBuildInputs)
        (oa "buildInputs" packagesWithBuildInputs)
        (ob "broken" true brokenPackages)
        ] old;
    in
      result // (otherOverrides result new);

  overrideDerivationsByAttr = attr: overrides: old:
    let
      lookup = a: old.${a}; #look up an attr in the old set
      update = new: old: {${attr} = old.${attr} ++ new;}; #cumulative update of attr

      #For (name, new) in overrides, return the updated derivation
      override = n: new: (lookup n).overrideDerivation (update new);
    in
      builtins.mapAttrs override overrides;

  overrideFunctionsByArgument = update: packageNames: old:
    let
      lookup = a: old.${a};
      override = n: (lookup n).override update;
      genPair = n: lib.nameValuePair n (override n);
    in
      builtins.listToAttrs (map genPair packageNames);

  ####################
  #  overrideDerivationsByAttr "nativeBuildInputs" overrides old;
  #  overrideDerivationsByAttr "buildInputs" overrides old;

  #TODO hopefully this actually works
  overrideRDepends = overrides: old:
      overrideDerivationsByAttr "propagatedNativeBuildInputs" overrides (
      overrideNativeBuildInputs overrides old
      );

  ####################
  #  overrideFunctionsByArgument "requireX" true packageNames old;
  #  overrideFunctionsByArgument "doCheck" false packageNames old;
  #  overrideFunctionsByArgument "broken" true packageNames old;
  }
