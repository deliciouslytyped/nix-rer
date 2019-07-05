#TODO output to stdout unless specifically told to overwrite file
#TODO cross mode cache?
#TODO should I just scrap this whole thing, dump to json, and add the hash adding step?
#TODO go back through r issues filed in nixpkgs and related commits and see if i still address them
#TODO create a generalized tooling pipeline shceme for this 

#nix format support is for interim backwards compatibility and verification, the json format is now the preferred version
#Ghidra needed a plugins argument because the files had to be part of the derivation, r has rwrapper because env vars suffice. how should i integrate this into rootedoverlay?

#Docu: r-pkgs.had.co.nz/description.html - consider writing somehting in Nix for the debian control format?
# use dcf stuff?: https://stat.ethz.ch/R-manual/R-devel/RHOME/library/tools/html/writePACKAGES.html
# !!!! probably should use https://github.com/r-lib/desc
#TODO consider ifelse in parts (how is it different from if expressions?)
# ! https://github.com/r-lib/desc/blob/c860e7b2c42a00e43195d86215b081a2dac1805a/R/deps.R#L82
#TODO generator wrapper script: since we query the environment we need to use the proper version of r to generate things? -> TODO document what parts of the env we query, so far its just this?
#TODO add tpye signature -ish comments
#TODO separate config (forgot what this means)

#!/usr/bin/env Rscript
options(warn=5) #TODO docs say this only goes up to 2?

library(data.table)
library(jsonlite) #For databases
library(desc) #For parsing deps
#TODO test errythin

##########################################3

library(utils)
sourceDir <- getSrcDirectory(function(dummy) {dummy}) # man what a mess https://stackoverflow.com/a/36276269
source(sprintf("%s/nix.r", sourceDir))
source(sprintf("%s/json.r", sourceDir))

commandLine <- commandArgs()

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

#main function
#lst <- loadMirrorList(); m <- chooseMirror(c("","cran"), lst); ww <- getManifests(m, lst); xxx <- genNix(m, ww$these[1:1,], ww$known, "cran-packages.nix") ; cat(xxx)
generateDB <- function(mode="nix"){
  #commandArgs() %>%
  #  chooseMirror(loadMirrorList()) %>%
  #  getManifests(mirrors) %>% 
  #  addHashes(mirror) %>% #TODO map over getmanifests
  #  writeDB(mode="nix")

  commandLine <- c("", "cran")
  
  mirrors <- loadMirrorList()
  mirror <- chooseMirror(commandLine, mirrors)
  packagesFile <- sprintf("%s/%s-packages.%s", sourceDir, mirror$name, mode) #TODO change dir
  pkgs <- getManifests(mirror, mirrors) #TODO this looks weird because youd think getmanifests should be getmanifest and only needs to look at one package set instead of theentire mirrors structure. the question is how do names interact across r package sets?
  gen <- function(a,b,c,d,e) {(if(e == "nix") {genNix} else {genJSON})(a,b,c,d)}
  result <- gen(mirror, pkgs$these, pkgs$known, packagesFile,mode)
  write(result, packagesFile) #TODO periodic update so you can interrupt it
}

#Load mirror tuples from file
loadMirrorList <- function(){
  data <- jsonlite::fromJSON(sprintf("%s/mirrors.json", sourceDir))
  data$mirrors <- lapply(data$mirrors, function(e){ sprintf(e, data$biocVersion, data$snapshotDate) }) #Poor mans simple substitution, uses %num$s
  data
}

#process commandline args
chooseMirror <- function(args, data){
  mirrorName <- args[[2]]
  stopifnot(mirrorName %in% names(data$mirrors))
  #TODO haven't thought of a non-awkward way to handle $version that doesn't make the code a lot bigger
  list(name=mirrorName, url=data$mirrors[[mirrorName]], version=ifelse(mirrorName == "cran", data$snapshotDate, data$biocVersion))
}

#TODO split knownpackages pipeline (is it even necessary) and the remote stuff
#TODO what is the relationship between pkgs and knownpackages
#TODO split this into a map-able over package sets updater and make it just generate everyhting (+ choice)
getManifests <- function(mirror, data){ #TODO
  write(paste("downloading package lists"), stderr())
  #TODO why are you downloading them all if you only use one? (or does it actually use more than one?) <- i.e. knownpackages
  #TODO rbind these here into knwnpackages and do the filter to a column afterwards?
  l <- function(url) as.data.table(available.packages(url, filters=c("R_version", "OS_type", "duplicates"), method="libcurl"))
  allPackages <- lapply(data$mirrors, l)
  knownPackages <- unique(rbindlist(allPackages)$Package) #maybe knownpackages shouldnt look at the global set?, how can we hadle individual package sets on the nix side if yet
  
  oneSet <- function(mirror, allPackages){
    thesePkgs <- allPackages[[mirror$name]][order(Package)] #data.table magic, knows Package is a column of...
    setkey(thesePkgs, Package) #this makes no sense...?
  }
  
  list(these = oneSet(mirror, allPackages), known = knownPackages)
}

#TODO return type is weird
addHashes <- function(pkgs, mirror, mode){ #TODO should pkgs and mirror really be separate?
  write(paste("updating", mirror$name, "packages"), stderr())

  cacheFetcher <- if (mode == "nix"){ nixfetchcached } else { jsonfetchcached } #TODO i really dont understand what the cache fetcher is supposed to be for, its not like it updates an outdate entry or anything !?
  packagesFile <- sprintf("%s-packages.%s", mirror$name, mode)
  
  lambda <- function(p) {
    result <- if (file.exists(packagesFile)){
      cacheFetcher(p$Package, p$Version, packagesFile)  #TODO rename to dbfile or something #TODO just try all modes? what if theres multiple successful? - no tthat that will ever happen right -- hm, so error., ! also add script version to output format_semver
    }
    if (rlang::is_empty(result)){ 
      result <- genHash(p$Package, p$Version, mirror)
    }
    result
  }
  pkgs$sha256 <- datmap(pkgs, lambda)
  write("done", stderr())  
  pkgs
}

genHash <- function(name, version, mirror) {
  write(sprintf("fetching %s : %s", name, version), stderr())
  
  # TODO "avoid nix-prefetch-url because it often fails to fetch/hash large files" is this still true, also jeez how big can R stuff be?
  url <- sprintf("%s%s_%s.tar.gz", mirror$url, name, version)
  cmd <- sprintf("set -o pipefail; wget -q -O - '%1$s' | nix-hash --type sha256 --base32 --flat /dev/stdin", url) #TODO meh
  result <- try(system2("/usr/bin/env", c("bash","-c", shQuote(cmd)), stdout=TRUE))
  ifelse(is.null(attr(result, "status")), result, stop(sprintf("'%s' failed.", cmd))) #TODO ugh this is fucked
}

#not sure which answer here we need https://stackoverflow.com/questions/21567057/programmatically-get-list-of-base-packages
getKnownBasePackages <- function() {
  #TODO well, R usually has a version constraint when its mentioned in deps
  c("R", rownames(installed.packages(priority="base"))) #TODO save this to the database as well
}

#TODO todo consider figuring out how to call idesc_get_deps, it sets the first ("type") argument parse_deps properly
#TODO consider handling version range assertions
#TODO how can i use multiple orthogonal repositiories and have them depend on eachother?
toDeps <- function(deps, knownPackages){
  fromNA <- function(s) ifelse(is.na(s), "",s)
  
  packages <- desc:::parse_deps("wat", paste(lapply(deps, fromNA), collapse=","))$package
  
  #TODO probably need to run a bootstrap step - but actually that should be unnecessary since i just need to query names??? (?? what did i mean by this)
  known <- packages[packages %in% knownPackages & packages != "*"]
  
  #TODO split on package set, so known should be split as well...?
  #basically theres multiple package sets and the generation of one package set should not be influenced by the others.
  #however if something is in knownpackages then you need the provenance information of where its from so that you can do
  #self.otherpackageset.thepackage. alternatively, keeping everythng in a global namespace is probably simpler...or necessary? ..need to think more
  whitelist <- getKnownBasePackages()
  unknown <- packages[!(packages %in% knownPackages) & packages != "*" & !(packages %in% whitelist)] 
  
  list(known = known, unknown = unknown)
}
