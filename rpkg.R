#!/usr/bin/env Rscript

library(getopt);

codename  <- system("lsb_release -c|awk {'print $2'}", intern=TRUE);
site_lib  <- paste(sep='/', '/home/software', codename, 'R', getRversion(), 'site-library');

.libPaths(site_lib);
options(repos='http://cran.mtu.edu/');

opt <- getopt(matrix(c(
  'help',         'h', 0, "logical",   "Usage information",
  'package',      'p', 1, "character", "Package name to install",
  'bioconductor', 'b', 0, "logical",   "Package is in the bioconductor repo"
),ncol=5,byrow=TRUE));

if (!is.null(opt$help)) {
  writeLines("Usage: test.R [options]");
  writeLines("\t--help,h\t\tPrint usage options");
  writeLines("\t--package,p\t\tPackage name to install");
  writeLines("\t--bioconductor,b\t\tPackage is in the bioconductor repo");
  q(status=1);
}

if (is.null(opt$bioconductor)) {
  install.packages(opt$package, dependencies=TRUE);
} else {
  source("http://www.bioconductor.org/biocLite.R");
  biocLite(opt$package);
}

q(status=0);
