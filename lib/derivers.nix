# Generates package templates given per-repository settings
#
# some packages, e.g. cncaGUI, require X running while installation,
# so that we use xvfb-run if requireX is true.
{ R, pkgs, lib, buildRPackage }:
rec {
  mkDerive =
    {mkHomepage, mkUrls}:
    args:
    lib.makeOverridable (
      { name, version, sha256
      , depends ? []
      , doCheck ? true
      , requireX ? false
      , broken ? false
      , hydraPlatforms ? R.meta.hydraPlatforms
      }:
        buildRPackage {
          name = "${name}-${version}";
          src = fetchurl {
            inherit sha256;
            urls = mkUrls (args // { inherit name version; });
            };

          inherit doCheck requireX;

          propagatedBuildInputs = depends;
          nativeBuildInputs = depends;

          meta = {
            homepage = mkHomepage (args // { inherit name; });
            platforms = R.meta.platforms;
            hydraPlatforms = hydraPlatforms;
            inherit broken;
            };
          }
      );

  # Templates for generating Bioconductor and CRAN packages
  # from the name, version, sha256, and optional per-package arguments above
  #
  deriveBioc = mkDerive {
    mkHomepage = {name, biocVersion, ...}:
      "https://bioconductor.org/packages/${biocVersion}/bioc/html/${name}.html";
    mkUrls = {name, version, biocVersion}: [
      "mirror://bioc/${biocVersion}/bioc/src/contrib/${name}_${version}.tar.gz"
      "mirror://bioc/${biocVersion}/bioc/src/contrib/Archive/${name}_${version}.tar.gz"
      ];
    };

  deriveBiocAnn = mkDerive {
    mkHomepage = {name, ...}:
      "http://www.bioconductor.org/packages/${name}.html";
    mkUrls = {name, version, biocVersion}: [
      "mirror://bioc/${biocVersion}/data/annotation/src/contrib/${name}_${version}.tar.gz"
      ];
    };

  deriveBiocExp = mkDerive {
    mkHomepage = {name, ...}:
      "http://www.bioconductor.org/packages/${name}.html";
    mkUrls = {name, version, biocVersion}: [
      "mirror://bioc/${biocVersion}/data/experiment/src/contrib/${name}_${version}.tar.gz"
      ];
    };

  deriveCran = mkDerive {
    mkHomepage = {name, snapshot, ...}:
      "http://mran.revolutionanalytics.com/snapshot/${snapshot}/web/packages/${name}/";
    mkUrls = {name, version, snapshot}: [
      "http://mran.revolutionanalytics.com/snapshot/${snapshot}/src/contrib/${name}_${version}.tar.gz"
      ];
    };
  }
