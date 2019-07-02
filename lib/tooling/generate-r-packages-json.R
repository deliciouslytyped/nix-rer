#Ghidra needed a plugins argument because the files had to be part of the derivation, r has rwrapper because env vars suffice. how should i integrate this into rootedoverlay?

#Docu: r-pkgs.had.co.nz/description.html - consider writing somehting in Nix for the debian control format?
# use dcf stuff?: https://stat.ethz.ch/R-manual/R-devel/RHOME/library/tools/html/writePACKAGES.html
# !!!! probably should use https://github.com/r-lib/desc
#lst <- loadMirrorList(); m <- chooseMirror("cran", lst); ww <- getManifests(m, lst); genNix(m, Sys.Date()-1, "3.8", ww$these[1:1,], ww$known) 
#TODO consider ifelse in parts (how is it different from if expressions?)
# ! https://github.com/r-lib/desc/blob/c860e7b2c42a00e43195d86215b081a2dac1805a/R/deps.R#L82

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
  commandArgs(trailingOnly=TRUE) %>%
    chooseMirror(loadMirrorList()) %>%
    getManifests(mirrors) %>% 
    addHashes(mirror) %>%
    writeDB(mode="nix")
}

#Load mirror tuples from file
loadMirrorList <- function(){
  snapshotDate <- Sys.Date() - 1
  data <- jsonlite::fromJSON(paste0(sourceDir, "/mirrors.json"))
  # Variable substitution like this is kind of bad, but I didnt want to make
  # it so complicated that its not worth putting this in an external file
  lapply(data$mirrors, function(e){ sprintf(e, data$biocVersion, snapshotDate) })
}

#process commandline args
chooseMirror <- function(args, mirrors){
  mirrorName <- args[1]
  stopifnot(mirrorName %in% names(mirrors))
  list(name=mirrorName, url=mirrors[[mirrorName]])
}

#TODO split knownpackages pipeline (is it even necessary) and the remote stuff
#TODO what is the relationship between pkgs and knownpackages
getManifests <- function(mirror, mirrors){ #TODO
  #man i have no idea wtf is going on in this part
  write(paste("downloading package lists"), stderr())
  #TODO why are you downloading them all if you only use one? (or does it actually use more than one?) <- i.e. knownpackages
  #TODO rbind these here into knwnpackages and do the filter to a column afterwards?
  l <- function(url) as.data.table(available.packages(url, filters=c("R_version", "OS_type", "duplicates"), method="libcurl"))
  allPackages <- lapply(mirrors, l)
  
  thesePkgs <- allPackages[[mirror$name]][order(Package)] #data.table magic, knows Package is a column of...
  setkey(thesePkgs, Package) #this makes no sense...?
  
  knownPackages <- unique(rbindlist(allPackages)$Package) #maybe knownpackages shouldnt look at the global set?, how can we hadle individual package sets on the nix side if yet
  #knownPackages <- sapply(knownPackages, nixEscapeAttr) #only seems to be used for depends? #TODO wtf this uses escapeattr but is thesepackages not escaped when i use it in the other place?
  
  list(allPackages = all, these = thesePkgs, known = knownPackages)
}

#TODO return type is weird
addHashes <- function(pkgs, mirror, mode="nix"){ #Todo create packages list object tuple to pass around
  write(paste("updating", mirror$name, "packages"), stderr())

  cacheFetcher <- if (mode == "nix"){ nixprefetchcached } else { jsonprefetchcached }
  
  lambda <- function(p) {
    result <- cacheFetcher(p$Package, p$Version, mirror) #TODO just try all modes? what if theres multiple successful? - no tthat that will ever happen right -- hm, so error., ! also add script version to output format_semver
    if (rlang::is_empty(result)){ 
      result <- genHash(p$Package, p$Version, mirror)
    }
    result
  }
  pkgs$sha256 <- datmap(pkgs, lambda)
  write("done", stderr())  
  pkgs
}

#TODO use a temporary store ?
genHash <- function(name, version, mirror) {
  write(sprintf("fetching %s : %s", name, version), stderr())
  
  # TODO "avoid nix-prefetch-url because it often fails to fetch/hash large files" is this still true, also jeez how big can R stuff be?
  url <- sprintf("%s%s_%s.tar.gz", mirror$url, name, version)
  tmp <- tempfile(pattern = sprintf("%s_%s", name, version), fileext=".tar.gz")
  
  wget <-    "wget -q -O '%1$s' '%2$s'" # tmp, url
  hash <- "&& nix-hash --type sha256 --base32 --flat '%1$s'" # tmp
  echo <- "&& echo >&2 ' added %3$s v%4$s'" # name, version
  rm <-    "; rm -rf '%1$s'" # tmp
  cmd <- sprintf(paste(wget, hash, echo, rm, collapse=" "), tmp, url, name, version)
  system(cmd, intern=TRUE)
}

#used by toDeps
#not sure which answer here we need https://stackoverflow.com/questions/21567057/programmatically-get-list-of-base-packages
getKnownBasePackages <- function() {
  #TODO well, R usually has a version constraint when its mentioned in deps
  c("R", rownames(installed.packages(priority="base")))
}

#TODO generator wrapper script: since we query the environment we need to use the proper version of r to generate things? -> TODO document what parts of the env we query, so far its just this?
#TODO add tpye signature -ish comments


#TODO todo consider figuring out how to call idesc_get_deps, it sets the first ("type") argument parse_deps properly
#TODO consider handling version range assertions
toDeps <- function(deps, knownPackages){
  fromNA <- function(s) ifelse(is.na(s), "",s)
  renameKeywords <- function(d) ifelse(d == "import", "r_import", d)
  
  packages <- desc:::parse_deps("wat", paste(lapply(deps, fromNA), collapse=","))$package
  
  #TODO probably need to run a bootstrap step - but actually that should be unnecessary since i just need to query names??? (?? what did i mean by this)
  known <- packages[packages %in% knownPackages & packages != "*"]
  known <- lapply(known, renameKeywords) #TODO remove in JSON version
  
  whitelist <- getKnownBasePackages()
  unknown <- packages[!(packages %in% knownPackages) & packages != "*" & !(packages %in% whitelist)]
  
  list(known = known, unknown = unknown)
}