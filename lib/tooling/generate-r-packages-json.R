#!/usr/bin/env Rscript
library(data.table)
library(jsonlite)
#TODO "unknownPackages"
#TODO test errythin

##########################################3

library(utils)
#man what a mess https://stackoverflow.com/a/36276269
sourceDir <- getSrcDirectory(function(dummy) {dummy})
source(paste0(sourceDir, "/nix.r"))

#TODO This is pretty shitty
# A function for mapping over a data frame such that you can
# use column names to address a row cell as opposed to indices.
# `apply` just gives you a vector.
# Maybe I should just use adply from plyr?
datmap <- function(df, f){
  cn <- colnames(df)
  apply(df, 1, function(d){
    d <- as.list(d)
    names(d) <- cn
    f(d)
  })
}

readFile <- function(fileName){
  readChar(fileName, file.info(fileName)$size)
}

##########################################3

#TODO separate config (forgot what this means)

#main function
generateDB <- function(mirror){
  chooseMirror(mirror, loadMirrors()) %>%
    getManifests(mirrors) %>% 
    addHashes(mirror, mirrors) %>%
    writeDB(mode="nix")
}

#Load mirror tuples from file
loadMirrors <- function(){
  snapshotDate <- Sys.Date() - 1
  data <- jsonlite::fromJSON(paste0(sourceDir, "/mirrors.json"))
  # Variable substitution like this is kind of bad, but I didnt want to make
  # it so complicated that its not worth putting this in an external file
  lapply(data$mirrors, function(e){ sprintf(e, data$biocVersion, snapshotDate) })
}

#process commandline args
chooseMirror <- function(mirror, mirrors){
  #mirrorType <- "cran"# commandArgs(trailingOnly=TRUE)[1]
  stopifnot(mirror %in% names(mirrors))
  mirror
}

#TODO split knownpackages pipeline (is it even necessary) and the remote stuff
#TODO what is the relationship between pkgs and knownpackages
getManifests <- function(mirror, mirrors){
  #man i have no idea wtf is going on in this part
  write(paste("downloading package lists"), stderr())
  #TODO why are you downloading them all if you only use one? (or does it actually use more than one?) <- i.e. knownpackages
  #TODO rbind these here into knwnpackages and do the filter to a column afterwards?
  l <- function(url) as.data.table(available.packages(url, filters=c("R_version", "OS_type", "duplicates"), method="libcurl"))
  allPackages <- lapply(mirrors, l)
  
  thesePkgs <- allPackages[[mirror]][order(Package)] #data.table magic, knows Package is a column of...
  setkey(thesePkgs, Package) #this makes no sense...?
  
  nixEscapeAttr <- function(x) gsub(pattern=".", replacement="_", x, fixed=TRUE)
  knownPackages <- unique(rbindlist(allPackages)$Package) #maybe knownpackages shouldnt look at the global set?, how can we hadle individual package sets on the nix side if yet
  knownPackages <- sapply(knownPackages, nixEscapeAttr) #only seems to be used for depends?
  
  list(allPackages = allPackages, thesePkgs = thesePkgs, knownPackages = knownPackages)
}

#TODO return type is weird
genAllHashes <- function(pkgs, mirror, mirrors){ #Todo create packages list object tuple to pass around
  write(paste("updating", mirror, "packages"), stderr())
  pkgs$sha256 <- datmap(pkgs, function(p) nixprefetchcached(p$Package, p$Version, mirror, mirrors))
  write("done", stderr())  
  pkgs
}

#TODO use a temporary store ?
genNixHash <- function(name, version, mirror, mirrors) {
  write(sprintf("fetching %s : %s", name, version), stderr())
  
  # TODO "avoid nix-prefetch-url because it often fails to fetch/hash large files" is this still true, also jeez how big can R stuff be?
  url <- sprintf("%s%s_%s.tar.gz", mirrors[[mirror]], name, version)
  tmp <- tempfile(pattern = sprintf("%s_%s", name, version), fileext=".tar.gz")
  
  wget <-    "wget -q -O '%1$s' '%2$s'" # tmp, url
  hash <- "&& nix-hash --type sha256 --base32 --flat '%1$s'" # tmp
  echo <- "&& echo >&2 ' added %3$s v%4$s'" # name, version
  rm <-    "; rm -rf '%1$s'" # tmp
  cmd <- sprintf(paste(wget, hash, echo, rm, collapse=" "), tmp, url, name, version)
  system(cmd, intern=TRUE)
}