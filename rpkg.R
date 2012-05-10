#!/usr/bin/env Rscript

library(getopt);

codename  <- system("lsb_release -c|awk {'print $2'}", intern=TRUE);
site_lib  <- paste(sep='/', '/home/software', codename, 'R', getRversion(), 'site-library');

.libPaths(site_lib);
options(repos='http://cran.mtu.edu/');

opt <- getopt(matrix(c(
  'help',         'h', 0, "logical",   "Usage information",
  'package',      'p', 1, "character", "Package name to install"
),ncol=5,byrow=TRUE));

if (!is.null(opt$help)) {
  writeLines("Usage: test.R [options]");
  writeLines("\t--help,h\t\tPrint usage options");
  writeLines("\t--package,p\t\tPackage name to install");
  q(status=1);
}

options(warn=-1);
install.packages(opt$package, dependencies=TRUE);
if (!suppressWarnings(require(opt$package, quietly=TRUE))) {
  source("http://www.bioconductor.org/biocLite.R");
  biocLite(opt$package);
}

if (!suppressWarnings(require(opt$package, quietly=TRUE))) {
  writeLines(paste(sep=" ", "\nUnable to find package", opt$package, "in cran or bioconductor"));
  q(status=1);
}

q(status=0);
