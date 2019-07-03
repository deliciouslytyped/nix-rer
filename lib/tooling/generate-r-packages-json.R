#!/usr/bin/env Rscript
library(data.table)
library(jsonlite)
#TODO "unknownPackages"
#TODO test errythin

root <- "/bakery2/oven1/personal/projects/nixapps/nix-rer/lib/tooling/"

#TODO separate config

#Load mirror tuples from file
loadMirrors <- function(){
  snapshotDate <- Sys.Date() - 1
  data <- jsonlite::fromJSON(paste0(root, "mirrors.json"))
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

#main function
generateDB <- function(mirror){
  chooseMirror(mirror, loadMirrors()) %>%
    getPackages() %>% a
}


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
prefetchAllHashes <- function(pkgs, mirror, mirrors){ #Todo create packages list object tuple to pass around
  write(paste("updating", mirror, "packages"), stderr())
  pkgs$sha256 <- datmap(pkgs, function(p) nixprefetchcached(p$Package, p$Version, mirror, mirrors))
  write("done", stderr())  
  pkgs
}

nixprefetchcached <- function(name, version, mirror, mirrors, mode="nix"){ #But why
  getCached <- function(name, version, mirror, mirrors){
    packagesFile <- sprintf("%s-packages.%s", mirror, mode)
    if (file.exists(packagesFile)){
      readFormatted <- as.data.table(read.table(skip=8, sep='"', text=head(readLines(packagesFile), -1)))
      result <- as.character(readFormatted$V6[ readFormatted$V2 == name & readFormatted$V4 == version ])
    }
  }
  
  result <- getCached(name, version, mirror, mirrors)
  if (length(result) == 0){ 
    result <- genNixHash(name, version, mirror, mirrors)
  }
  result
}

# TODO Ok so i really do need to have recurive dependency handling, is my stuff sufficient, or do i need to pivot to makescope?
# TODO wtf is going on here
formatPackageNix <- function(name, version, sha256, depends, imports, linkingTo, knownPackages) {
  strip <- function(s) { if (is.na(s)) "" else gsub("[ \t\n]+", "", s) }
  mkDepStr <- function(depends, imports, linkingTo, knownPackages){
    depends <- paste( strip(depends), strip(imports), strip(linkingTo), sep=",")
    depends <- unlist(strsplit(depends, split=",", fixed=TRUE))
    depends <- lapply(depends, gsub, pattern="([^ \t\n(]+).*", replacement="\\1")
    depends <- lapply(depends, gsub, pattern=".", replacement="_", fixed=TRUE)
    depends <- depends[depends %in% knownPackages] #TODO probably need to run a bootstrap step - but actually that should be unnecessary since i just need to query names???
    depends <- lapply(depends, function(d) ifelse(d == "import", "r_import", d))#TODO
    depends <- paste(depends)
    depends <- paste(sort(unique(depends)), collapse=" ")
  }
  
  name <- ifelse(name == "import", "r_import", name) #TODO is this special cased - oh, its probably because import is a keyword - fix this by storing json and document it as a breaking fix
  attr <- gsub(".", "_", name, fixed=TRUE) #TODO nix_escape_attr function? #TODO is this necessary if i use quoted stuff?
  options(warn=5) #TODO docs say this only goes up to 2?
  
  depends <- mkDepStr(depends, imports, linkingTo, knownPackages)
  sprintf('    %s = derive2 { name = "%s"; version = "%s"; sha256 = "%s"; depends = [ %s ]; };', attr, name, version, sha256, depends)
}


genNix <- function(mirror, mirrors, packagesFile, snapshotDate, biocVersion, pkgs, knownPackages){
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

  template <- readFile(paste0(root, "packages-template.txt"))
  #Use %1$ style formatters to access the arguments.
  sprintf(template, mirror, packagesFile, deriveStr, wat)
}

genJSON <- function(){
  #TODO
}

readFile <- function(fileName){
  readChar(fileName, file.info(fileName)$size)
}