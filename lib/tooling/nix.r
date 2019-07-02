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


genNix <- function(mirror, mirrors, snapshotDate, biocVersion, pkgs, knownPackages){
  mode <- "nix"
  if (mirror == "cran") {
    deriveStr <- paste0(' snapshot = "', paste(snapshotDate), '"; ')
  } else if (mirror == "irkernel") {
    deriveStr <- ""
  } else {
    deriveStr <- paste0(' biocVersion = "', biocVersion, '"; ') #TODO put the mirror file in the output as well
  }
  
  pkgs <- genAllHashes(pkgs, mirror, mirrors)
  
  nix <- datmap(pkgs, function(p) { formatPackageNix(p$Package, p$Version, p$sha256, p$Depends, p$Imports, p$LinkingTo, knownPackages) })
  wat <- sprintf("%s\n", paste(nix, collapse="\n")) #TODO fix indentation #TODO unfuck
  
  template <- readFile(paste0(sourceDir, "/packages-template.txt"))
  #Use %1$ style formatters to access the arguments.
  command <- paste0(commandArgs(), collapse=" ") #TODO escaping?
  packagesFile <- sprintf("%s-packages.%s", mirror, mode)
  sprintf(template, command, packagesFile, deriveStr, wat)
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