# tweaks for the individual packages and "in self" follow
{pkgs, self, lib, stdenv}: {
packagesWithRDepends = {
  FactoMineR = [ self.car ];
  pander = [ self.codetools ];
};

packagesWithNativeBuildInputs = {
  abn = [ pkgs.gsl_1 ];
  adimpro = [ pkgs.imagemagick ];
  animation = [ pkgs.which ];
  audio = [ pkgs.portaudio ];
  BayesSAE = [ pkgs.gsl_1 ];
  BayesVarSel = [ pkgs.gsl_1 ];
  BayesXsrc = [ pkgs.readline.dev pkgs.ncurses ];
  bigGP = [ pkgs.openmpi ];
  bio3d = [ pkgs.zlib ];
  BiocCheck = [ pkgs.which ];
  Biostrings = [ pkgs.zlib ];
  bnpmr = [ pkgs.gsl_1 ];
  cairoDevice = [ pkgs.gtk2.dev ];
  Cairo = [ pkgs.libtiff pkgs.libjpeg pkgs.cairo.dev pkgs.x11 pkgs.fontconfig.lib ];
  Cardinal = [ pkgs.which ];
  chebpol = [ pkgs.fftw ];
  ChemmineOB = [ pkgs.openbabel pkgs.pkgconfig ];
  cit = [ pkgs.gsl_1 ];
  curl = [ pkgs.curl.dev ];
  data_table = lib.optional stdenv.isDarwin pkgs.llvmPackages.openmp;
  devEMF = [ pkgs.xorg.libXft.dev pkgs.x11 ];
  diversitree = [ pkgs.gsl_1 pkgs.fftw ];
  EMCluster = [ pkgs.liblapack ];
  fftw = [ pkgs.fftw.dev ];
  fftwtools = [ pkgs.fftw.dev ];
  Formula = [ pkgs.gmp ];
  geoCount = [ pkgs.gsl_1 ];
  gdtools = [ pkgs.cairo.dev pkgs.fontconfig.lib pkgs.freetype.dev ];
  git2r = [ pkgs.zlib.dev pkgs.openssl.dev pkgs.libssh2.dev pkgs.libgit2 pkgs.pkgconfig ];
  GLAD = [ pkgs.gsl_1 ];
  glpkAPI = [ pkgs.gmp pkgs.glpk ];
  gmp = [ pkgs.gmp.dev ];
  graphscan = [ pkgs.gsl_1 ];
  gsl = [ pkgs.gsl_1 ];
  h5 = [ pkgs.hdf5-cpp pkgs.which ];
  haven = [ pkgs.libiconv pkgs.zlib.dev ];
  h5vc = [ pkgs.zlib.dev ];
  HiCseg = [ pkgs.gsl_1 ];
  imager = [ pkgs.x11 ];
  iBMQ = [ pkgs.gsl_1 ];
  igraph = [ pkgs.gmp pkgs.libxml2.dev ];
  JavaGD = [ pkgs.jdk ];
  jpeg = [ pkgs.libjpeg.dev ];
  jqr = [ pkgs.jq.dev ];
  KFKSDS = [ pkgs.gsl_1 ];
  kza = [ pkgs.fftw.dev ];
  libamtrack = [ pkgs.gsl_1 ];
  magick = [ pkgs.imagemagick.dev ];
  mvabund = [ pkgs.gsl_1 ];
  mwaved = [ pkgs.fftw.dev ];
  ncdf4 = [ pkgs.netcdf ];
  nloptr = [ pkgs.nlopt pkgs.pkgconfig ];
  odbc = [ pkgs.unixODBC ];
  outbreaker = [ pkgs.gsl_1 ];
  pander = [ pkgs.pandoc pkgs.which ];
  pbdMPI = [ pkgs.openmpi ];
  pbdNCDF4 = [ pkgs.netcdf ];
  pbdPROF = [ pkgs.openmpi ];
  pbdZMQ = lib.optionals stdenv.isDarwin [ pkgs.which ];
  pdftools = [ pkgs.poppler.dev ];
  phytools = [ pkgs.which ];
  PKI = [ pkgs.openssl.dev ];
  png = [ pkgs.libpng.dev ];
  PopGenome = [ pkgs.zlib.dev ];
  proj4 = [ pkgs.proj ];
  protolite = [ pkgs.protobuf ];
  qtbase = [ pkgs.qt4 ];
  qtpaint = [ pkgs.qt4 ];
  R2SWF = [ pkgs.zlib pkgs.libpng pkgs.freetype.dev ];
  RAppArmor = [ pkgs.libapparmor ];
  rapportools = [ pkgs.which ];
  rapport = [ pkgs.which ];
  readxl = [ pkgs.libiconv ];
  rcdd = [ pkgs.gmp.dev ];
  RcppCNPy = [ pkgs.zlib.dev ];
  RcppGSL = [ pkgs.gsl_1 ];
  RcppZiggurat = [ pkgs.gsl_1 ];
  reprex = [ pkgs.which ];
  rgdal = [ pkgs.proj pkgs.gdal ];
  rgeos = [ pkgs.geos ];
  rggobi = [ pkgs.ggobi pkgs.gtk2.dev pkgs.libxml2.dev ];
  rgl = [ pkgs.libGLU_combined pkgs.xlibsWrapper ];
  Rglpk = [ pkgs.glpk ];
  RGtk2 = [ pkgs.gtk2.dev ];
  rhdf5 = [ pkgs.zlib ];
  Rhdf5lib = [ pkgs.zlib ];
  Rhpc = [ pkgs.zlib pkgs.bzip2.dev pkgs.icu pkgs.lzma.dev pkgs.openmpi pkgs.pcre.dev ];
  Rhtslib = [ pkgs.zlib.dev pkgs.automake pkgs.autoconf ];
  RJaCGH = [ pkgs.zlib.dev ];
  rjags = [ pkgs.jags ];
  rJava = [ pkgs.zlib pkgs.bzip2.dev pkgs.icu pkgs.lzma.dev pkgs.pcre.dev pkgs.jdk pkgs.libzip ];
  Rlibeemd = [ pkgs.gsl_1 ];
  rmatio = [ pkgs.zlib.dev ];
  Rmpfr = [ pkgs.gmp pkgs.mpfr.dev ];
  Rmpi = [ pkgs.openmpi ];
  RMySQL = [ pkgs.zlib pkgs.mysql.connector-c pkgs.openssl.dev ];
  RNetCDF = [ pkgs.netcdf pkgs.udunits ];
  RODBCext = [ pkgs.libiodbc ];
  RODBC = [ pkgs.libiodbc ];
  rpanel = [ pkgs.bwidget ];
  rpg = [ pkgs.postgresql ];
  rphast = [ pkgs.pcre.dev pkgs.zlib pkgs.bzip2 pkgs.gzip pkgs.readline ];
  Rpoppler = [ pkgs.poppler ];
  RPostgreSQL = [ pkgs.postgresql pkgs.postgresql ];
  RProtoBuf = [ pkgs.protobuf ];
  rPython = [ pkgs.python ];
  RSclient = [ pkgs.openssl.dev ];
  Rserve = [ pkgs.openssl ];
  Rssa = [ pkgs.fftw.dev ];
  rtfbs = [ pkgs.zlib pkgs.pcre.dev pkgs.bzip2 pkgs.gzip pkgs.readline ];
  rtiff = [ pkgs.libtiff.dev ];
  runjags = [ pkgs.jags ];
  RVowpalWabbit = [ pkgs.zlib.dev pkgs.boost ];
  rzmq = [ pkgs.zeromq3 ];
  SAVE = [ pkgs.zlib pkgs.bzip2 pkgs.icu pkgs.lzma pkgs.pcre ];
  sdcTable = [ pkgs.gmp pkgs.glpk ];
  seewave = [ pkgs.fftw.dev pkgs.libsndfile.dev ];
  seqinr = [ pkgs.zlib.dev ];
  seqminer = [ pkgs.zlib.dev pkgs.bzip2 ];
  sf = [ pkgs.gdal pkgs.proj pkgs.geos ];
  showtext = [ pkgs.zlib pkgs.libpng pkgs.icu pkgs.freetype.dev ];
  simplexreg = [ pkgs.gsl_1 ];
  spate = [ pkgs.fftw.dev ];
  ssanv = [ pkgs.proj ];
  stsm = [ pkgs.gsl_1 ];
  stringi = [ pkgs.icu.dev ];
  survSNP = [ pkgs.gsl_1 ];
  sysfonts = [ pkgs.zlib pkgs.libpng pkgs.freetype.dev ];
  TAQMNGR = [ pkgs.zlib.dev ];
  tesseract = [ pkgs.tesseract pkgs.leptonica ];
  tiff = [ pkgs.libtiff.dev ];
  TKF = [ pkgs.gsl_1 ];
  tkrplot = [ pkgs.xorg.libX11 pkgs.tk.dev ];
  topicmodels = [ pkgs.gsl_1 ];
  udunits2 = [ pkgs.udunits pkgs.expat ];
  units = [ pkgs.udunits ];
  V8 = [ pkgs.v8_3_14 ];
  VBLPCM = [ pkgs.gsl_1 ];
  WhopGenome = [ pkgs.zlib.dev ];
  XBRL = [ pkgs.zlib pkgs.libxml2.dev ];
  xml2 = [ pkgs.libxml2.dev ] ++ lib.optionals stdenv.isDarwin [ pkgs.perl ];
  XML = [ pkgs.libtool pkgs.libxml2.dev pkgs.xmlsec pkgs.libxslt ];
  affyPLM = [ pkgs.zlib.dev ];
  bamsignals = [ pkgs.zlib.dev ];
  BitSeq = [ pkgs.zlib.dev ];
  DiffBind = [ pkgs.zlib ];
  ShortRead = [ pkgs.zlib.dev ];
  oligo = [ pkgs.zlib.dev ];
  gmapR = [ pkgs.zlib.dev ];
  Rsubread = [ pkgs.zlib.dev ];
  XVector = [ pkgs.zlib.dev ];
  Rsamtools = [ pkgs.zlib.dev ];
  rtracklayer = [ pkgs.zlib.dev ];
  affyio = [ pkgs.zlib.dev ];
  VariantAnnotation = [ pkgs.zlib.dev ];
  snpStats = [ pkgs.zlib.dev ];
};

packagesWithBuildInputs = {
  # sort -t '=' -k 2
  svKomodo = [ pkgs.which ];
  nat = [ pkgs.which ];
  nat_nblast = [ pkgs.which ];
  nat_templatebrains = [ pkgs.which ];
  pbdZMQ = lib.optionals stdenv.isDarwin [ pkgs.darwin.binutils ];
  RMark = [ pkgs.which ];
  RPushbullet = [ pkgs.which ];
  qtpaint = [ pkgs.cmake ];
  qtbase = [ pkgs.cmake pkgs.perl ];
  RcppEigen = [ pkgs.libiconv ];
  RCurl = [ pkgs.curl.dev ];
  R2SWF = [ pkgs.pkgconfig ];
  rggobi = [ pkgs.pkgconfig ];
  RGtk2 = [ pkgs.pkgconfig ];
  RProtoBuf = [ pkgs.pkgconfig ];
  Rpoppler = [ pkgs.pkgconfig ];
  XML = [ pkgs.pkgconfig ];
  cairoDevice = [ pkgs.pkgconfig ];
  chebpol = [ pkgs.pkgconfig ];
  fftw = [ pkgs.pkgconfig ];
  geoCount = [ pkgs.pkgconfig ];
  gdtools = [ pkgs.pkgconfig ];
  JuniperKernel = lib.optionals stdenv.isDarwin [ pkgs.darwin.binutils ];
  jqr = [ pkgs.jq.lib ];
  kza = [ pkgs.pkgconfig ];
  magick = [ pkgs.pkgconfig ];
  mwaved = [ pkgs.pkgconfig ];
  odbc = [ pkgs.pkgconfig ];
  openssl = [ pkgs.pkgconfig ];
  pdftools = [ pkgs.pkgconfig ];
  sf = [ pkgs.pkgconfig ];
  showtext = [ pkgs.pkgconfig ];
  spate = [ pkgs.pkgconfig ];
  stringi = [ pkgs.pkgconfig ];
  sysfonts = [ pkgs.pkgconfig ];
  tesseract = [ pkgs.pkgconfig ];
  Cairo = [ pkgs.pkgconfig ];
  Rsymphony = [ pkgs.pkgconfig pkgs.doxygen pkgs.graphviz pkgs.subversion ];
  tcltk2 = [ pkgs.tcl pkgs.tk ];
  tikzDevice = [ pkgs.which pkgs.texlive.combined.scheme-medium ];
  rPython = [ pkgs.which ];
  gridGraphics = [ pkgs.which ];
  adimpro = [ pkgs.which pkgs.xorg.xdpyinfo ];
  PET = [ pkgs.which pkgs.xorg.xdpyinfo pkgs.imagemagick ];
  dti = [ pkgs.which pkgs.xorg.xdpyinfo pkgs.imagemagick ];
  mzR = [ pkgs.netcdf ];
  cluster = [ pkgs.libiconv ];
  KernSmooth = [ pkgs.libiconv ];
  nlme = [ pkgs.libiconv ];
  Matrix = [ pkgs.libiconv ];
  mgcv = [ pkgs.libiconv ];
  igraph = [ pkgs.libiconv ];
  ape = [ pkgs.libiconv ];
  expm = [ pkgs.libiconv ];
  mnormt = [ pkgs.libiconv ];
  phangorn = [ pkgs.libiconv ];
  quadprog = [ pkgs.libiconv ];
};

packagesRequireingX = [
  "accrual"
  "ade4TkGUI"
  "analogue"
  "analogueExtra"
  "AnalyzeFMRI"
  "AnnotLists"
  "AnthropMMD"
  "aplpack"
  "aqfig"
  "arf3DS4"
  "asbio"
  "AtelieR"
  "BAT"
  "bayesDem"
  "BCA"
  "BEQI2"
  "betapart"
  "BiodiversityR"
  "bio_infer"
  "bipartite"
  "biplotbootGUI"
  "blender"
  "cairoDevice"
  "CCTpack"
  "cncaGUI"
  "cocorresp"
  "CommunityCorrelogram"
  "confidence"
  "constrainedKriging"
  "ConvergenceConcepts"
  "cpa"
  "DALY"
  "dave"
  "Deducer"
  "DeducerPlugInExample"
  "DeducerPlugInScaling"
  "DeducerSpatial"
  "DeducerSurvival"
  "DeducerText"
  "Demerelate"
  "detrendeR"
  "dgmb"
  "DivMelt"
  "dpa"
  "DSpat"
  "dynamicGraph"
  "dynBiplotGUI"
  "EasyqpcR"
  "EcoVirtual"
  "ENiRG"
  "exactLoglinTest"
  "fat2Lpoly"
  "fbati"
  "FD"
  "feature"
  "FeedbackTS"
  "FFD"
  "fgui"
  "fisheyeR"
  "fit4NM"
  "forams"
  "forensim"
  "FreeSortR"
  "fscaret"
  "fSRM"
  "gcmr"
  "GeoGenetix"
  "geomorph"
  "geoR"
  "geoRglm"
  "georob"
  "GGEBiplotGUI"
  "gnm"
  "GPCSIV"
  "GrammR"
  "GrapheR"
  "GroupSeq"
  "gsubfn"
  "GUniFrac"
  "gWidgets2RGtk2"
  "gWidgets2tcltk"
  "gWidgetsRGtk2"
  "gWidgetstcltk"
  "HH"
  "HiveR"
  "HomoPolymer"
  "ic50"
  "iDynoR"
  "in2extRemes"
  "iplots"
  "isopam"
  "IsotopeR"
  "JGR"
  "KappaGUI"
  "likeLTD"
  "logmult"
  "LS2Wstat"
  "MareyMap"
  "memgene"
  "MergeGUI"
  "metacom"
  "Meth27QC"
  "MetSizeR"
  "MicroStrategyR"
  "migui"
  "miniGUI"
  "MissingDataGUI"
  "mixsep"
  "mlDNA"
  "MplusAutomation"
  "mpmcorrelogram"
  "mritc"
  "MTurkR"
  "multgee"
  "multibiplotGUI"
  "nodiv"
  "OligoSpecificitySystem"
  "onemap"
  "OpenRepGrid"
  "paleoMAS"
  "pbatR"
  "PBSadmb"
  "PBSmodelling"
  "PCPS"
  "pez"
  "phylotools"
  "picante"
  "PKgraph"
  "plotSEMM"
  "plsRbeta"
  "plsRglm"
  "PopGenReport"
  "poppr"
  "powerpkg"
  "PredictABEL"
  "prefmod"
  "PrevMap"
  "ProbForecastGOP"
  "qtbase"
  "qtpaint"
  "r4ss"
  "RandomFields"
  "rareNMtests"
  "rAverage"
  "Rcmdr"
  "RcmdrPlugin_coin"
  "RcmdrPlugin_depthTools"
  "RcmdrPlugin_DoE"
  "RcmdrPlugin_EACSPIR"
  "RcmdrPlugin_EBM"
  "RcmdrPlugin_EcoVirtual"
  "RcmdrPlugin_EZR"
  "RcmdrPlugin_FactoMineR"
  "RcmdrPlugin_HH"
  "RcmdrPlugin_IPSUR"
  "RcmdrPlugin_KMggplot2"
  "RcmdrPlugin_lfstat"
  "RcmdrPlugin_MA"
  "RcmdrPlugin_mosaic"
  "RcmdrPlugin_MPAStats"
  "RcmdrPlugin_orloca"
  "RcmdrPlugin_plotByGroup"
  "RcmdrPlugin_pointG"
  "RcmdrPlugin_qual"
  "RcmdrPlugin_ROC"
  "RcmdrPlugin_sampling"
  "RcmdrPlugin_SCDA"
  "RcmdrPlugin_SLC"
  "RcmdrPlugin_sos"
  "RcmdrPlugin_steepness"
  "RcmdrPlugin_survival"
  "RcmdrPlugin_TeachingDemos"
  "RcmdrPlugin_temis"
  "RcmdrPlugin_UCA"
  "recluster"
  "relimp"
  "RenextGUI"
  "reportRx"
  "reshapeGUI"
  "rgl"
  "RHRV"
  "rich"
  "RNCEP"
  "RQDA"
  "RSDA"
  "rsgcc"
  "RSurvey"
  "RunuranGUI"
  "sharpshootR"
  "simba"
  "Simile"
  "SimpleTable"
  "SOLOMON"
  "soundecology"
  "SPACECAP"
  "spacodiR"
  "spatsurv"
  "sqldf"
  "SRRS"
  "SSDforR"
  "statcheck"
  "StatDA"
  "STEPCAM"
  "stosim"
  "strvalidator"
  "stylo"
  "svDialogstcltk"
  "svIDE"
  "svSocket"
  "svWidgets"
  "SYNCSA"
  "SyNet"
  "tcltk2"
  "TED"
  "TestScorer"
  "TIMP"
  "titan"
  "tkrgl"
  "tkrplot"
  "tmap"
  "tspmeta"
  "TTAinterfaceTrendAnalysis"
  "twiddler"
  "vcdExtra"
  "VecStatGraphs3D"
  "vegan"
  "vegan3d"
  "vegclust"
  "VIMGUI"
  "WMCapacity"
  "x12GUI"
  "xergm"
];

packagesToSkipCheck = [
  "Rmpi"     # tries to run MPI processes
  "pbdMPI"   # tries to run MPI processes
];

# Packages which cannot be installed due to lack of dependencies or other reasons.
brokenPackages = [
];
}
