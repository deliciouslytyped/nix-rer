#TODO make sure all the things point in the right places
self: super: {
  #TODO figure out an acceptable casing of this
  rWrapper = callPackage ../lib/wrapper.nix (with super.nixpkgs; { #TODO wrapper
    recommendedPackages = with rPackages; [
      boot class cluster codetools foreign KernSmooth lattice MASS
      Matrix mgcv nlme nnet rpart spatial survival
      ];
    # Override this attribute to register additional libraries.
    packages = [];
    });

  rstudioWrapper = libsForQt5.callPackage ../lib/wrappers.nix (with super.nixpkgs; { #TODO wrapper
    recommendedPackages = with rPackages; [
      boot class cluster codetools foreign KernSmooth lattice MASS
      Matrix mgcv nlme nnet rpart spatial survival
      ];
    # Override this attribute to register additional libraries.
    packages = [];
    });

  r = super.nixpkgs.callPackage ../lib/R (with super.nixpkgs; {
    # TODO: split docs into a separate output
    texLive = texlive.combine {
      inherit (texlive) scheme-small inconsolata helvetic texinfo fancyvrb cm-super;
      };
    openblas = openblasCompat;
    withRecommendedPackages = false;
    inherit (darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (darwin) libobjc;
    });

  rstudio = super.nixpkgslibsForQt5.callPackage ../lib/rstudio (with super.nixpkgs; {
    boost = boost166;
    llvmPackages = llvmPackages_7;
    });
  }

/*
  rPackages = dontRecurseIntoAttrs (callPackage ../development/r-modules { #TODO add recursible to rootedoverlay
    overrides = (config.rPackageOverrides or (p: {})) pkgs;
  });
where does rstudio-preview come from?
*/
