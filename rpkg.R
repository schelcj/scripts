#!/usr/bin/env Rscript

library(getopt);

mirror    <- 'http://cran.mtu.edu/';
base_repo <- '/home/software';
codename  <- system("lsb_release -c|awk {'print $2'}", intern=TRUE);
site_lib  <- paste(sep='/', base_repo, codename, 'R', getRversion(), 'site-library');

.libPaths(site_lib);

opt <- getopt(matrix(c(
  'help',         'h', 0, "logical",   "Usage information",
  'package',      'p', 1, "character", "Package name to install",
  'bioconductor', 'b', 0, "logical",   "Package is a bioconductor package"
),ncol=5,byrow=TRUE));

if (!is.null(opt$help)) {
  writeLines("Usage: test.R [options]");
  writeLines("\t--help,h\t\tPrint usage options");
  writeLines("\t--package,p\t\tPackage name to install");
  writeLines("\t--bioconductor,b\tPackage to install is in the Bioconductor repo");
  q(status=1);
}

if (is.null(opt$bioconductor)) {
  install.packages(opt$package, dependencies=TRUE, repos=mirror);
} else {
  source("http://www.bioconductor.org/biocLite.R");
  biocLite(opt$package);
}