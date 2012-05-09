#!/usr/bin/env Rscript

library(getopt);

opt <- getopt(matrix(c(
'help',         'h', 0, "logical",   "Usage information",
'package',      'p', 1, "character", "Package name to install",
'bioconductor', 'b', 0, "logical",   "Package is a bioconductor package"
),ncol=5,byrow=TRUE));

site_lib <- paste(sep='/', '/home/software/lucid/R', paste(sep='.', R.version$major, R.version$minor), 'site-library')

if (!is.null(opt$help)) {
  writeLines("Usage: test.R [options]");
  writeLines("\t--help,h\t\tPrint usage options");
  writeLines("\t--package,p\t\tPackage name to install");
  writeLines("\t--bioconductor,b\tPackage to install is in the Bioconductor repo");
  q(status=1);
}

if (!is.null(opt$bioconductor)) {
  source("http://www.bioconductor.org/biocLite.R")
  biocLite(opt$package, lib=site_lib)
} else {
  install.packages(opt$package, dependencies=TRUE, lib=site_lib, repos='http://cran.mtu.edu/');
}
