#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE);

a <- read.table(args[1], quote="\"", comment.char="");
b <- read.table(args[2], quote="\"", comment.char="");
m <- setdiff(a$V1, b$V1);

write.table(m, file=args[3], quote=F, col.names=F, row.names=F);
