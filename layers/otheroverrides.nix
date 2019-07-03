#TODO Alphabetical sort script
self: super: {
  stringi =  super.stringi.overrideDerivation (attrs: {
    postInstall = let
      icuName = "icudt52l";
      icuSrc = pkgs.fetchzip {
        url = "http://static.rexamine.com/packages/${icuName}.zip";
        sha256 = "0hvazpizziq5ibc9017i1bb45yryfl26wzfsv05vk9mc1575r6xj";
        stripRoot = false;
      };
      in ''
        ${attrs.postInstall or ""}
        cp ${icuSrc}/${icuName}.dat $out/library/stringi/libs
      '';
  });

  xml2 = super.xml2.overrideDerivation (attrs: {
    preConfigure = ''
      export LIBXML_INCDIR=${pkgs.libxml2.dev}/include/libxml2
      patchShebangs configure
      '';
  });

  Cairo = super.Cairo.overrideDerivation (attrs: {
    NIX_LDFLAGS = "-lfontconfig";
  });

  curl = super.curl.overrideDerivation (attrs: {
    preConfigure = "patchShebangs configure";
  });

  RcppArmadillo = super.RcppArmadillo.overrideDerivation (attrs: {
    patchPhase = "patchShebangs configure";
  });

  data_table = super.data_table.overrideDerivation (attrs: {
    NIX_CFLAGS_COMPILE = attrs.NIX_CFLAGS_COMPILE
      + lib.optionalString stdenv.isDarwin " -fopenmp";
  });

  rpf = super.rpf.overrideDerivation (attrs: {
    patchPhase = "patchShebangs configure";
  });

  BayesXsrc = super.BayesXsrc.overrideDerivation (attrs: {
    patches = [ ./patches/BayesXsrc.patch ];
  });

  Rhdf5lib = super.Rhdf5lib.overrideDerivation (attrs: {
    patches = [ ./patches/Rhdf5lib.patch ];
  });

  rJava = super.rJava.overrideDerivation (attrs: {
    preConfigure = ''
      export JAVA_CPPFLAGS=-I${pkgs.jdk}/include/
      export JAVA_HOME=${pkgs.jdk}
    '';
  });

  JavaGD = super.JavaGD.overrideDerivation (attrs: {
    preConfigure = ''
      export JAVA_CPPFLAGS=-I${pkgs.jdk}/include/
      export JAVA_HOME=${pkgs.jdk}
    '';
  });

  JuniperKernel = super.JuniperKernel.overrideDerivation (attrs: {
    postPatch = lib.optionalString stdenv.isDarwin ''
      for file in {R,src}/*.R; do
          sed -i 's#system("which \(otool\|install_name_tool\)"[^)]*)#"${pkgs.darwin.cctools}/bin/\1"#g' $file
      done
    '';
    preConfigure = ''
      patchShebangs configure
    '';
  });

  jqr = super.jqr.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  pbdZMQ = super.pbdZMQ.overrideDerivation (attrs: {
    postPatch = lib.optionalString stdenv.isDarwin ''
      for file in R/*.{r,r.in}; do
          sed -i 's#system("which \(\w\+\)"[^)]*)#"${pkgs.darwin.cctools}/bin/\1"#g' $file
      done
    '';
  });

  qtbase = super.qtbase.overrideDerivation (attrs: {
    patches = [ ./patches/qtbase.patch ];
  });

  Rmpi = super.Rmpi.overrideDerivation (attrs: {
    configureFlags = [
      "--with-Rmpi-type=OPENMPI"
    ];
  });

  Rmpfr = super.Rmpfr.overrideDerivation (attrs: {
    configureFlags = [
      "--with-mpfr-include=${pkgs.mpfr.dev}/include"
    ];
  });

  RVowpalWabbit = super.RVowpalWabbit.overrideDerivation (attrs: {
    configureFlags = [
      "--with-boost=${pkgs.boost.dev}" "--with-boost-libdir=${pkgs.boost.out}/lib"
    ];
  });

  RAppArmor = super.RAppArmor.overrideDerivation (attrs: {
    patches = [ ./patches/RAppArmor.patch ];
    LIBAPPARMOR_HOME = "${pkgs.libapparmor}";
  });

  RMySQL = super.RMySQL.overrideDerivation (attrs: {
    MYSQL_DIR="${pkgs.mysql.connector-c}";
    preConfigure = ''
      patchShebangs configure
    '';
  });

  devEMF = super.devEMF.overrideDerivation (attrs: {
    NIX_CFLAGS_LINK = "-L${pkgs.xorg.libXft.out}/lib -lXft";
    NIX_LDFLAGS = "-lX11";
  });

  slfm = super.slfm.overrideDerivation (attrs: {
    PKG_LIBS = "-L${pkgs.openblasCompat}/lib -lopenblas";
  });

  SamplerCompare = super.SamplerCompare.overrideDerivation (attrs: {
    PKG_LIBS = "-L${pkgs.openblasCompat}/lib -lopenblas";
  });

  EMCluster = super.EMCluster.overrideDerivation (attrs: {
    patches = [ ./patches/EMCluster.patch ];
  });

  spMC = super.spMC.overrideDerivation (attrs: {
    patches = [ ./patches/spMC.patch ];
  });

  openssl = super.openssl.overrideDerivation (attrs: {
    PKGCONFIG_CFLAGS = "-I${pkgs.openssl.dev}/include";
    PKGCONFIG_LIBS = "-Wl,-rpath,${pkgs.openssl.out}/lib -L${pkgs.openssl.out}/lib -lssl -lcrypto";
  });

  Rserve = super.Rserve.overrideDerivation (attrs: {
    patches = [ ./patches/Rserve.patch ];
    configureFlags = [
      "--with-server" "--with-client"
    ];
  });

  nloptr = super.nloptr.overrideDerivation (attrs: {
    # Drop bundled nlopt source code. Probably unnecessary, but I want to be
    # sure we're using the system library, not this one.
    preConfigure = "rm -r src/nlopt_src";
  });

  V8 = super.V8.overrideDerivation (attrs: {
    preConfigure = ''
      export INCLUDE_DIR=${pkgs.v8_3_14}/include
      export LIB_DIR=${pkgs.v8_3_14}/lib
      patchShebangs configure
      '';
  });

  acs = super.acs.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  gdtools = super.gdtools.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
    NIX_LDFLAGS = "-lfontconfig -lfreetype";
  });

  magick = super.magick.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  protolite = super.protolite.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  rpanel = super.rpanel.overrideDerivation (attrs: {
    preConfigure = ''
      export TCLLIBPATH="${pkgs.bwidget}/lib/bwidget${pkgs.bwidget.version}"
    '';
    TCLLIBPATH = "${pkgs.bwidget}/lib/bwidget${pkgs.bwidget.version}";
  });

  RPostgres = super.RPostgres.overrideDerivation (attrs: {
    preConfigure = ''
      export INCLUDE_DIR=${pkgs.postgresql}/include
      export LIB_DIR=${pkgs.postgresql.lib}/lib
      patchShebangs configure
      '';
  });

  OpenMx = super.OpenMx.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  odbc = super.odbc.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  x13binary = super.x13binary.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
  });

  geojsonio = super.geojsonio.overrideDerivation (attrs: {
    buildInputs = [ cacert ] ++ attrs.buildInputs;
  });

  rstan = super.rstan.overrideDerivation (attrs: {
    NIX_CFLAGS_COMPILE = "${attrs.NIX_CFLAGS_COMPILE} -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION";
  });

  mongolite = super.mongolite.overrideDerivation (attrs: {
    preConfigure = ''
      patchShebangs configure
      '';
    PKGCONFIG_CFLAGS = "-I${pkgs.openssl.dev}/include -I${pkgs.cyrus_sasl.dev}/include -I${pkgs.zlib.dev}/include";
    PKGCONFIG_LIBS = "-Wl,-rpath,${pkgs.openssl.out}/lib -L${pkgs.openssl.out}/lib -L${pkgs.cyrus_sasl.out}/lib -L${pkgs.zlib.out}/lib -lssl -lcrypto -lsasl2 -lz";
  });

  ps = super.ps.overrideDerivation (attrs: {
    preConfigure = "patchShebangs configure";
  });

  rlang = super.rlang.overrideDerivation (attrs: {
    preConfigure = "patchShebangs configure";
  });

  littler = super.littler.overrideAttrs (attrs: with pkgs; {
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
