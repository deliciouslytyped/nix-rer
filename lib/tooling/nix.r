# TODO Ok so i really do need to have recurive dependency handling, is my stuff sufficient, or do i need to pivot to makescope?
formatPackageNix <- function(name, version, sha256, deps) {
  renameKeywords <- function(d) ifelse(d == "import", "r_import", d)
  #TODO make sure i didnt break this
  listToNixList <- function(l) { x <- sprintf('"%s"', paste0(l, collapse='" "')); ifelse(x == '""', "", x) } #double "paste" because recycling, see help
  
  #we operate using the original names until this point
  attr <- renameKeywords(name) #TODO instances of this need to be tested
  #this substitution doesn't use a prefix code, therefore the inverse is ambiguous
  attr <- gsub("_", "__", attr, fixed=TRUE)
  attr <- gsub(".", "_", attr, fixed=TRUE)
  
  known <- paste(deps$known, collapse = " ") #These are passed as names
  unknown <- listToNixList(deps$unknown) #These are passed as quoted strings
  sprintf('%s = derive2 { name = "%s"; version = "%s"; sha256 = "%s"; depends = [ %s ]; unknown = [ %s ]; };', attr, name, version, sha256, known, unknown)
}

#TODO missing irkernel?? , how was the old code even supposed to get to irkernel, it would have errored on setting mirrorType?
genNix <- function(mirror, pkgs, knownPackages, packagesFile){ #TODO should mirror and pkgs be merged?
  #TODO try to move to having the nix stuff handle this using json dbs <- i.e. feed the arguments to derive from nix, using a json db of mirrors, requires nix rewrite
  deriveStr <- sprintf('name = "%s"; version = "%s";', mirror$name, mirror$version) 
  
  pkgs <- addHashes(pkgs, mirror)
  
  wat <- datmap(pkgs, function(p) {
    deps <- toDeps(p[c("Depends", "Imports", "LinkingTo")], knownPackages);
    formatPackageNix(p$Package, p$Version, p$sha256, deps)
    })
  indent <- "    "
  entries <- paste0(indent, wat, collapse="\n")
  
  template <- readFile(paste0(sourceDir, "/packages-template.txt"))
  command <- paste0(commandLine, collapse=" ")
  #Use %1$ style formatters to access the arguments.
  sprintf(template, command, packagesFile, deriveStr, entries)
}

nixfetchcached <- function(name, version, packagesFile){
  readFormatted <- as.data.table(read.table(skip=8, sep='"', text=head(readLines(packagesFile), -2))) #Pretty crap way to do it but its not like we have a full parser
  result <- as.character(readFormatted$V6[ readFormatted$V2 == name & readFormatted$V4 == version ])
}