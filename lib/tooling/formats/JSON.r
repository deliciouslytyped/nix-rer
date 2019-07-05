library(jsonlite)
# TODO Ok so i really do need to have recurive dependency handling, is my stuff sufficient, or do i need to pivot to makescope?
formatPackageJSON <- function(name, version, sha256, deps) {
  r <- list() #TODO meh
  r[[name]] <- list(version=unbox(version), sha256=unbox(sha256),deps=deps)
  r
}

genJSON <- function(mirror, pkgs, knownPackages, packagesFile){ #TODO should mirror and pkgs be merged? #TODO should the json ref the mirror db or just embed - should embed
  pkgs <- addHashes(pkgs, mirror, mode="json")
  
  wat <- datmap(pkgs, function(p) {
    deps <- toDeps(p[c("Depends", "Imports", "LinkingTo")], knownPackages);
    formatPackageJSON(p$Package, p$Version, p$sha256, deps)
  })
  
  #TODO template json for comments and crap?
  command <- paste0(commandLine, collapse=" ")
  #Use %1$ style formatters to access the arguments.
  
  result <- list(
    #comment = paste(
    #  "This file is generated from generate-r-packages.R. DO NOT EDIT.",
    #  "Execute the following command to update the file: (It will be wrong if this file was generated with an interactive REPL.)\n",
    #  command, packagesFile,
    #  sep="\n"),
    packages = do.call(c, wat),
    mirror = unbox(mirror$name)
  )
  toJSON(result, pretty=TRUE)
}

jsonfetchcached <- function(name, version, packagesFile){ #TODO is this called once or for every single entry
  #readFormatted <- as.data.table(read.table(skip=8, sep='"', text=head(readLines(packagesFile), -2))) #Pretty crap way to do it but its not like we have a full parser
  #result <- as.character(readFormatted$V6[ readFormatted$V2 == name & readFormatted$V4 == version ])
  db <- jsonlite::read_json(packagesFile)
}