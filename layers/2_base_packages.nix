#TODO make sure all the things point in the right places
self: super: {
  buildRPackage = super.nixpkgs.callPackage ../lib/generic-builder.nix {
    R = super.nixpkgs.R;
    inherit (super.nixpkgs.darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (super.nixpkgs) gettext gfortran;
  };

  #TODO figure out an acceptable casing of this
  rWrapper = super.nixpkgs.pkgs.callPackage ((super.nixpkgs.callPackage (import ../lib/R/rtool-wrapper.nix) {}).r) (with super.nixpkgs; { #TODO wrapper
    recommendedPackages = with rPackages; [
      boot class cluster codetools foreign KernSmooth lattice MASS
      Matrix mgcv nlme nnet rpart spatial survival
      ];
    # Override this attribute to register additional libraries.
    packages = [];
    });

  rstudioWrapper = super.nixpkgs.libsForQt5.callPackage ../lib/wrappers.nix (with super.nixpkgs; { #TODO wrapper
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

  rstudio = super.nixpkgs.libsForQt5.callPackage ../lib/rstudio (with super.nixpkgs; {
    boost = boost166;
    llvmPackages = llvmPackages_7;
    });

  tempWrapper = super.nixpkgs.lib.makeOverridable ({plugins ? []}: self.rWrapper.override { packages = plugins; }) {};
  }

/*
  rPackages = dontRecurseIntoAttrs (callPackage ../development/r-modules { #TODO add recursible to rootedoverlay
    overrides = (config.rPackageOverrides or (p: {})) pkgs;
  });
where does rstudio-preview come from?
*/
