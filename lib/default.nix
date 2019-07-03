/* This file defines the composition for CRAN (R) packages. */

{ R, pkgs, overrides }:

let
  inherit (pkgs) cacert fetchurl stdenv lib;

  buildRPackage = pkgs.callPackage ./generic-builder.nix {
    inherit R;
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa Foundation;
    inherit (pkgs) gettext gfortran;
  };

  ###TODO DERIVERS TODO###

  ###TODO OVERRIDERS TODO###

  ####TODO RECURSION TODO###

  ###WARN TODO CUT A LOT OF CONSTANTS AND PACKAGE SPECIFIC STUFF OUT OF HERE TODO WARN###

in
  self

derivers
constants
overriders
recursion
