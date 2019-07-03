self: super: {
 #TODO figure out an acceptable casing of this
 rWrapper =
 rStudioWrapper = 
 r = super.nixpkgs.callPackage ../lib/r.nix;
 rStudio = super.nixpkgs.rstudio ../lib/rstudio.nix;
 }
