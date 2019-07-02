library(jsonlite)

genJSON <- function(mirror, mirrors, snap){
  #TODO
}

{
  "comment":"This file can be generated ..."
}

genNix <- function(mirror, mirrors, snapshotDate, biocVersion, pkgs, knownPackages){
  if (mirror == "cran") {
    deriveStr <- paste0(' snapshot = "', paste(snapshotDate), '"; ')
  } else if (mirror == "irkernel") {
    deriveStr <- ""
  } else {
    deriveStr <- paste0(' biocVersion = "', biocVersion, '"; ')
  }
  
  pkgs <- prefetchAllHashes(pkgs, mirror, mirrors)
  
  nix <- datmap(pkgs, function(p) { formatPackageNix(p$Package, p$Version, p$sha256, p$Depends, p$Imports, p$LinkingTo, knownPackages) })
  wat <- sprintf("%s\n", paste(nix, collapse="\n")) #TODO fix indentation #TODO unfuck
  
  template <- readFile(paste0(sourceDir, "packages-template.txt"))
  #Use %1$ style formatters to access the arguments.
  command <- paste0(commandArgs())
  packagesFile <- sprintf("%s-packages.%s", mirror, mode)
  sprintf(template, command, packagesFile, deriveStr, wat)
}