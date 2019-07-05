#TODO packages that have an override here should not have a "simple" override TODO: enforce this
#TODO ???no idea whats going on here
#TODO Alphabetical sort script
/*
#TODO i dont get what this is for
{pkgs, self, lib, super.nixpkgs.stdenv}: {
packagesWithRDepends = {
  FactoMineR = [ self.car ];
  pander = [ self.codetools ];
};
*/
self: super: {
  cran = super.cran // {
    stringi = super.cran.stringi.overrideDerivation (attrs: {
      postInstall = let
        icuName = "icudt52l";
        icuSrc = super.nixpkgs.fetchzip {
          url = "http://static.rexamine.com/packages/${icuName}.zip";
          sha256 = "0hvazpizziq5ibc9017i1bb45yryfl26wzfsv05vk9mc1575r6xj";
          stripRoot = false;
        };
        in ''
          ${attrs.postInstall or ""}
          cp ${icuSrc}/${icuName}.dat $out/library/stringi/libs
        '';
    });

    xml2 = super.cran.xml2.overrideDerivation (attrs: {
      nativeBuildInputs = attrs.nativeBuildInputs ++ (super.nixpkgs.lib.optionals super.nixpkgs.stdenv.isDarwin [ super.nixpkgs.perl ]); #TODO test
      preConfigure = ''
        export LIBXML_INCDIR=${super.nixpkgs.libxml2.dev}/include/libxml2
        patchShebangs configure
        '';
    });

    Cairo = super.cran.Cairo.overrideDerivation (attrs: {
      NIX_LDFLAGS = "-lfontconfig";
    });

    curl = super.cran.curl.overrideDerivation (attrs: {
      preConfigure = "patchShebangs configure";
    });

    RcppArmadillo = super.cran.RcppArmadillo.overrideDerivation (attrs: {
      patchPhase = "patchShebangs configure";
    });

    data_table = super.cran.data_table.overrideDerivation (attrs: {
      nativeBuildInputs = attrs.nativeBuildInputs ++ (super.nixpkgs.lib.optional super.nixpkgs.stdenv.isDarwin [ super.nixpkgs.which ]); #TODO test
      NIX_CFLAGS_COMPILE = attrs.NIX_CFLAGS_COMPILE
        + super.nixpkgs.lib.optionalString super.nixpkgs.stdenv.isDarwin " -fopenmp";
    });

    rpf = super.cran.rpf.overrideDerivation (attrs: {
      patchPhase = "patchShebangs configure";
    });

    rJava = super.cran.rJava.overrideDerivation (attrs: {
      preConfigure = ''
        export JAVA_CPPFLAGS=-I${super.nixpkgs.jdk}/include/
        export JAVA_HOME=${super.nixpkgs.jdk}
      '';
    });

    JavaGD = super.cran.JavaGD.overrideDerivation (attrs: {
      preConfigure = ''
        export JAVA_CPPFLAGS=-I${super.nixpkgs.jdk}/include/
        export JAVA_HOME=${super.nixpkgs.jdk}
      '';
    });

    JuniperKernel = super.cran.JuniperKernel.overrideDerivation (attrs: {
      buildInputs = attrs.buildInputs ++ (super.nixpkgs.lib.optionals super.nixpkgs.stdenv.isDarwin [ super.nixpkgs.darwin.binutils ]); #TODO test this
      postPatch = super.nixpkgs.lib.optionalString super.nixpkgs.stdenv.isDarwin ''
        for file in {R,src}/*.R; do
            sed -i 's#system("which \(otool\|install_name_tool\)"[^)]*)#"${super.nixpkgs.darwin.cctools}/bin/\1"#g' $file
        done
      '';
      preConfigure = ''
        patchShebangs configure
      '';
    });

    jqr = super.cran.jqr.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    pbdZMQ = super.cran.pbdZMQ.overrideDerivation (attrs: {
      buildInputs = attrs.buildInputs ++ (super.nixpkgs.lib.optionals super.nixpkgs.stdenv.isDarwin [ super.nixpkgs.darwin.binutils ]); #TODO test this
      nativeBuildInputs = attrs.nativeBuildInputs ++ (super.nixpkgs.super.nixpkgs.lib.optionals super.nixpkgs.stdenv.isDarwin [ super.nixpkgs.which ]);

      postPatch = super.nixpkgs.lib.optionalString super.nixpkgs.stdenv.isDarwin ''
        for file in R/*.{r,r.in}; do
            sed -i 's#system("which \(\w\+\)"[^)]*)#"${super.nixpkgs.darwin.cctools}/bin/\1"#g' $file
        done
      '';
    });

    Rmpi = super.cran.Rmpi.overrideDerivation (attrs: {
      configureFlags = [
        "--with-Rmpi-type=OPENMPI"
      ];
    });

    Rmpfr = super.cran.Rmpfr.overrideDerivation (attrs: {
      configureFlags = [
        "--with-mpfr-include=${super.nixpkgs.mpfr.dev}/include"
      ];
    });

    RVowpalWabbit = super.cran.RVowpalWabbit.overrideDerivation (attrs: {
      configureFlags = [
        "--with-boost=${super.nixpkgs.boost.dev}" "--with-boost-libdir=${super.nixpkgs.boost.out}/lib"
      ];
    });

    RAppArmor = super.cran.RAppArmor.overrideDerivation (attrs: {
      LIBAPPARMOR_HOME = "${super.nixpkgs.libapparmor}";
    });

    RMySQL = super.cran.RMySQL.overrideDerivation (attrs: {
      MYSQL_DIR="${super.nixpkgs.mysql.connector-c}";
      preConfigure = ''
        patchShebangs configure
      '';
    });

    devEMF = super.cran.devEMF.overrideDerivation (attrs: {
      NIX_CFLAGS_LINK = "-L${super.nixpkgs.xorg.libXft.out}/lib -lXft";
      NIX_LDFLAGS = "-lX11";
    });

    slfm = super.cran.slfm.overrideDerivation (attrs: {
      PKG_LIBS = "-L${super.nixpkgs.openblasCompat}/lib -lopenblas";
    });

    SamplerCompare = super.cran.SamplerCompare.overrideDerivation (attrs: {
      PKG_LIBS = "-L${super.nixpkgs.openblasCompat}/lib -lopenblas";
    });

    openssl = super.cran.openssl.overrideDerivation (attrs: {
      PKGCONFIG_CFLAGS = "-I${super.nixpkgs.openssl.dev}/include";
      PKGCONFIG_LIBS = "-Wl,-rpath,${super.nixpkgs.openssl.out}/lib -L${super.nixpkgs.openssl.out}/lib -lssl -lcrypto";
    });

    Rserve = super.cran.Rserve.overrideDerivation (attrs: {
      configureFlags = [
        "--with-server" "--with-client"
      ];
    });

    nloptr = super.cran.nloptr.overrideDerivation (attrs: {
      # Drop bundled nlopt source code. Probably unnecessary, but I want to be
      # sure we're using the system library, not this one.
      preConfigure = "rm -r src/nlopt_src";
    });

    V8 = super.cran.V8.overrideDerivation (attrs: {
      preConfigure = ''
        export INCLUDE_DIR=${super.nixpkgs.v8_3_14}/include
        export LIB_DIR=${super.nixpkgs.v8_3_14}/lib
        patchShebangs configure
        '';
    });

    acs = super.cran.acs.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    gdtools = super.cran.gdtools.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
      NIX_LDFLAGS = "-lfontconfig -lfreetype";
    });

    magick = super.cran.magick.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    protolite = super.cran.protolite.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    rpanel = super.cran.rpanel.overrideDerivation (attrs: {
      preConfigure = ''
        export TCLLIBPATH="${super.nixpkgs.bwidget}/lib/bwidget${super.nixpkgs.bwidget.version}"
      '';
      TCLLIBPATH = "${super.nixpkgs.bwidget}/lib/bwidget${super.nixpkgs.bwidget.version}";
    });

    RPostgres = super.cran.RPostgres.overrideDerivation (attrs: {
      preConfigure = ''
        export INCLUDE_DIR=${super.nixpkgs.postgresql}/include
        export LIB_DIR=${super.nixpkgs.postgresql.lib}/lib
        patchShebangs configure
        '';
    });

    OpenMx = super.cran.OpenMx.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    odbc = super.cran.odbc.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    x13binary = super.cran.x13binary.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
    });

    geojsonio = super.cran.geojsonio.overrideDerivation (attrs: {
      buildInputs = [ super.nixpkgs.cacert ] ++ attrs.buildInputs;
    });

    rstan = super.cran.rstan.overrideDerivation (attrs: {
      NIX_CFLAGS_COMPILE = "${attrs.NIX_CFLAGS_COMPILE} -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION";
    });

    mongolite = super.cran.mongolite.overrideDerivation (attrs: {
      preConfigure = ''
        patchShebangs configure
        '';
      PKGCONFIG_CFLAGS = "-I${super.nixpkgs.openssl.dev}/include -I${super.nixpkgs.cyrus_sasl.dev}/include -I${super.nixpkgs.zlib.dev}/include";
      PKGCONFIG_LIBS = "-Wl,-rpath,${super.nixpkgs.openssl.out}/lib -L${super.nixpkgs.openssl.out}/lib -L${super.nixpkgs.cyrus_sasl.out}/lib -L${super.nixpkgs.zlib.out}/lib -lssl -lcrypto -lsasl2 -lz";
    });

    ps = super.cran.ps.overrideDerivation (attrs: {
      preConfigure = "patchShebangs configure";
    });

    rlang = super.cran.rlang.overrideDerivation (attrs: {
      preConfigure = "patchShebangs configure";
    });

    littler = super.cran.littler.overrideAttrs (attrs: with super.nixpkgs; {
      buildInputs = [ pcre lzma zlib bzip2 icu which ] ++ attrs.buildInputs;
      postInstall = ''
        install -d $out/bin $out/share/man/man1
        ln -s ../library/littler/bin/r $out/bin/r
        ln -s ../library/littler/bin/r $out/bin/lr
        ln -s ../../../library/littler/man-page/r.1 $out/share/man/man1
        # these won't run without special provisions, so better remove them
        rm -r $out/library/littler/script-tests
      '';
    });
  };
}
