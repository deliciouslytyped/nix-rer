#TODO how the fuck do i get the things working that i had trouble with last time
{ stdenv, R, libcxx, xvfb_run, utillinux, Cocoa, Foundation, gettext, gfortran }:

{ name, buildInputs ? [], requireX ? false, ... } @ attrs:
let
  wrapHook = p: s: ''
    runHook pre${p}
    ${s}
    runHook post${p}
    ''
in
stdenv.mkDerivation ({
  buildInputs = buildInputs ++ [R gettext] ++
                stdenv.lib.optionals requireX [utillinux xvfb_run] ++
                stdenv.lib.optionals stdenv.isDarwin [Cocoa Foundation gfortran];

  NIX_CFLAGS_COMPILE =
    stdenv.lib.optionalString stdenv.isDarwin "-I${libcxx}/include/c++/v1";

  configurePhase = ''
    runHook preConfigure
    export R_LIBS_SITE="$R_LIBS_SITE''${R_LIBS_SITE:+:}$out/library"
    runHook postConfigure
  '';

  buildPhase = wrapHook "Build";

  installFlags = if attrs.doCheck or true then
    []
  else
    [ "--no-test-load" ];

  rCommand = if requireX then
    # Unfortunately, xvfb-run has a race condition even with -a option, so that
    # we acquire a lock explicitly.
    "flock ${xvfb_run} xvfb-run -a -e xvfb-error R"
  else
    "R";

  installPhase = wrapHook "Install" ''
    mkdir -p $out/library
    $rCommand CMD INSTALL $installFlags --configure-args="$configureFlags" -l $out/library .
  '';

  postFixup = ''
    if test -e $out/nix-support/propagated-build-inputs; then
        ln -s $out/nix-support/propagated-build-inputs $out/nix-support/propagated-user-env-packages
    fi
  '';

  checkPhase = '' #TODO can I null this
    # noop since R CMD INSTALL tests packages
  '';
} // attrs // {
  name = "r-" + name;
})
