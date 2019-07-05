#TODO move to lib
# Generates package templates given per-repository settings
#
# some packages, e.g. cncaGUI, require X running while installation,
# so that we use xvfb-run if requireX is true.

# (mirror, (mirror->pkgdesc)(mirror) -> builder

#            urls = mkUrls (args // { inherit name version; });
#            homepage = mkHomepage (args // { inherit name; });
{ R, pkgs, lib, buildRPackage, fetchurl }:
#    {mkHomepage, mkUrls}:
#    args:
mirror:
  lib.makeOverridable #TODO i dont like how this pattern is used here
  ({ name, version, sha256
  , depends ? []
  , doCheck ? true
  , requireX ? false
  , broken ? false
  , hydraPlatforms ? R.meta.hydraPlatforms
  , ...
  }@args:
    buildRPackage {
      name = "${name}-${version}";
      src = fetchurl {
        inherit sha256;
        urls = mirror.genUrls name version; #TODO meh
        };

      inherit doCheck requireX;

      propagatedBuildInputs = depends;
      nativeBuildInputs = depends;

      meta = {
        homepage = mirror.genHomepage name; #TODO meh
        platforms = R.meta.platforms;
        hydraPlatforms = hydraPlatforms;
        inherit broken;
        };
      } // (builtins.removeAttrs args ["name" "version" "sha256" "depends" "doCheck" "requireX" "broken" "hydraPlatforms"]))
