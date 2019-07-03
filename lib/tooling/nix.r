# TODO Ok so i really do need to have recurive dependency handling, is my stuff sufficient, or do i need to pivot to makescope?
formatPackageNix <- function(name, version, sha256, deps) {
  renameKeywords <- function(d) ifelse(d == "import", "r_import", d)
  
  name <- renameKeywords(name) #TODO instances of this need to be tested #TODO is this special cased - oh, its probably because import is a keyword - fix this by storing json and document it as a breaking fix
  attr <- gsub(".", "_", name, fixed=TRUE) #we operate using the original names until this point in the file. #Todo what about collisions? use a proper prefix code #TODO nix_escape_attr function? #TODO is this necessary if i use quoted stuff?
  
  known <- paste(deps$known, collapse = " ")
  unknown <- sprintf('"%s"', paste0(deps$unknown, collapse='" "')) #double "paste" because recycling
  unknown <- ifelse(unknown == '""', "", unknown)
  sprintf('    %s = derive2 { name = "%s"; version = "%s"; sha256 = "%s"; depends = [ %s ]; unknown = [ %s ]; };', attr, name, version, sha256, known, unknown)
}

#TODO missing irkernel?? , how was the old code even supposed to get to irkernel, it would have errored on setting mirrorType?
genNix <- function(mirror, pkgs, knownPackages){ #TODO should mirror and pkgs be merged?
  deriveStr <- if (mirror$name == "cran") { #TODO move this code to data in the database and have Nix handle it
      sprintf('snapshot = "%s";', paste(mirror$version))
    } else if (startsWith(mirror$name, "bioc")) {
      sprintf('biocVersion = "%s";', mirror$version) #TODO put the mirror file in the output as well
    } else {""} #TODO actually probably error if no deriver attrs get set, are there any defalts? - might become unnecessary when i fix derivers to use the json db as well though?, remove mirror url generation complexity from here to separate url updater tool? -> leads to too much static exteralized state and needs more pipelining? -> ehh unix philoshopy?
  
  pkgs <- addHashes(pkgs, mirror)
  
  wat <- datmap(pkgs, function(p) {
    deps <- toDeps(p[c("Depends", "Imports", "LinkingTo")], knownPackages);
    formatPackageNix(p$Package, p$Version, p$sha256, deps)
    })
  entries <- sprintf("%s\n", paste(wat, collapse="\n")) #TODO fix indentation #TODO unfuck
  
  mode <- "nix"
  packagesFile <- sprintf("%s-packages.%s", mirror$name, mode)
  
  template <- readFile(paste0(sourceDir, "/packages-template.txt"))
  command <- paste0(commandLine, collapse=" ") #TODO escaping? 
  #Use %1$ style formatters to access the arguments.
  sprintf(template, command, packagesFile, deriveStr, entries)
}

nixprefetchcached <- function(name, version, packagesFile){ #But why #TODO but why what
  readFormatted <- as.data.table(read.table(skip=8, sep='"', text=head(readLines(packagesFile), -1)))
  result <- as.character(readFormatted$V6[ readFormatted$V2 == name & readFormatted$V4 == version ])
}