#ok so what seems to be going on here is this uses the transpose approach of a attrib-[package],
#as opposed the usual package-[attribs]
{lib}: rec {
  defaultOverrides = overrides: old:
    let
      oa = s: overrides: old: overrideDerivationsByAttr s overrides old;
      ob = s: v: packageNames: old: overrideFunctionsByArgument s v packageNames old;

      update = (f: o: o // f o);
      compose = (a: b: (update a) b);
      result = lib.foldr compose old [
        #Note these are 1 parameter functions taking the previous old set
        (ob "requireX" true overrides.requireX) #TODO this is the lowest layer, is the fold correct?
        (ob "doCheck" false overrides.skipCheck)
        (oa "nativeBuildInputs" overrides.pkgsNativeBuildInputs)
        (oa "buildInputs" overrides.pkgsBuildInputs)
        (ob "broken" true overrides.broken)
        ] old;
    in
      result // (otherOverrides result);

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

/*
  #TODO hopefully this actually works
  #(overrideRDepends packagesWithRDepends)
  overrideRDepends = overrides: old: #TODO the entrries here were hanging off self thoug or something so this might otherwise be unnecessarry but i didnt really get what was going on there
      overrideDerivationsByAttr "propagatedNativeBuildInputs" overrides (
      overrideNativeBuildInputs overrides old
      );
*/
