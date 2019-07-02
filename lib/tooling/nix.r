# TODO Ok so i really do need to have recurive dependency handling, is my stuff sufficient, or do i need to pivot to makescope?
formatPackageNix <- function(name, version, sha256, deps) {
  name <- ifelse(name == "import", "r_import", name) #TODO instances of this need to be tested #TODO is this special cased - oh, its probably because import is a keyword - fix this by storing json and document it as a breaking fix
  attr <- gsub(".", "_", name, fixed=TRUE) #we operate using the original names until this point in the file. #Todo what about collisions? use a proper prefix code #TODO nix_escape_attr function? #TODO is this necessary if i use quoted stuff?
  options(warn=5) #TODO docs say this only goes up to 2?
  
  known <- paste(deps$known, collapse = " ")
  unknown <- sprintf('"%s"', paste0(deps$unknown, collapse='" "')) #because recycling
  unknown <- ifelse(unknown == '""', "", unknown)
  sprintf('    %s = derive2 { name = "%s"; version = "%s"; sha256 = "%s"; depends = [ %s ]; unknown = [ %s ]; };', attr, name, version, sha256, known, unknown)
}

#TODO missing irkernel?? , how was the old code even supposed to get to irkernel, it would have errored on setting mirrorType
genNix <- function(mirror, snapshotDate, biocVersion, pkgs, knownPackages){  mode <- "nix"
  deriveStr <- if (mirror$name == "cran") {
      sprintf('snapshot = "%s";', paste(snapshotDate))
    } else if (startsWith(mirror$name, "bioc")) {
      sprintf('biocVersion = "%s";', biocVersion) #TODO put the mirror file in the output as well
    } else {""} #TODO actually probably error if no deriver attrs get set, are there any defalts? - might become unnecessary when i fix derivers to use the json db as well though?, remove mirror url generation complexity from here to separate url updater tool? -> leads to too much static exteralized state and needs more pipelining? -> ehh unix philoshopy?
  
  pkgs <- addHashes(pkgs, mirror)
  
  wat <- datmap(pkgs, function(p) {
    deps <- toDeps(p[c("Depends", "Imports", "LinkingTo")], knownPackages);
    formatPackageNix(p$Package, p$Version, p$sha256, deps)
    })
  entries <- sprintf("%s\n", paste(wat, collapse="\n")) #TODO fix indentation #TODO unfuck
  
  command <- paste0(commandArgs(), collapse=" ") #TODO escaping? #TODO get tihs from a var since the beginning uses it too?
  packagesFile <- sprintf("%s-packages.%s", mirror$name, mode)
  
  template <- readFile(paste0(sourceDir, "/packages-template.txt"))
  #Use %1$ style formatters to access the arguments.
  sprintf(template, command, packagesFile, deriveStr, entries)
}

nixprefetchcached <- function(name, version, mirror){ #But why #TODO but why what
  mode <- "nix"
  packagesFile <- sprintf("%s-packages.%s", mirror$name, mode)
  if (file.exists(packagesFile)){
    readFormatted <- as.data.table(read.table(skip=8, sep='"', text=head(readLines(packagesFile), -1)))
    result <- as.character(readFormatted$V6[ readFormatted$V2 == name & readFormatted$V4 == version ])
  }
}