#!/usr/bin/env Rscript

# Perform McNemar's test (actually, an exact binomial variant)
# on two CoNLL-formatted tagging files of format:
#  token \t tag
# (and we skip blank lines.)

# Usage:
#  scripts/paired_stats.r GoldDataFile Preds1 Preds2
#
# For example: make taggings from two different models, then evaluate the paired test.
#  scripts/java.sh cmu.arktweetnlp.RunTagger --input-format conll data/twpos-data-v0.3/daily547.conll --model model1 > preds1
#  scripts/java.sh cmu.arktweetnlp.RunTagger --input-format conll data/twpos-data-v0.3/daily547.conll --model model2 > preds2
#  scripts/paired_stats.r data/twpos-data-v0.3/daily547.conll preds1 preds2
#
# Or you could just edit this file if you don't want to use the commandline.

read.tsv = function(f) read.table(f,sep='\t',quote='',comment='',na.strings='',stringsAsFactors=FALSE)

# gold = read.tsv(pipe("grep . conll/daily547.all"))
# gold = read.tsv(pipe("grep . conll/random.test"))
# gold = read.tsv(pipe("grep . conll/daily547.test"))
# gold = read.tsv(pipe("grep . conll/acl11.test"))

args = commandArgs(trailingOnly=T)
goldfile = args[1]
predfile1 = args[2]
predfile2 = args[3]

gold = read.tsv(pipe(sprintf("grep . %s", goldfile)))
d1 = read.tsv(pipe(sprintf("grep . %s", predfile1)))
d2 = read.tsv(pipe(sprintf("grep . %s", predfile2)))
stopifnot(all(d1$V1==d2$V1) && all(d1$V1==gold$V1))

cat("Accuracy rates\n")
cat(sprintf("ACC\t%s\t%s\n", predfile1, mean(d1$V2==gold$V2)))
cat(sprintf("ACC\t%s\t%s\n", predfile2, mean(d2$V2==gold$V2)))

cat("\nContingency table of system correctness indicators")
# print(mcnemar.test(d1$V2==gold$V2, d2$V2==gold$V2))
t = table(d1$V2==gold$V2, d2$V2==gold$V2)
print(t)
cat("\nExact McNemar: proportion of time one system is better than the other, when they disagree (and excluding cases where both are wrong):")
print(binom.test(t[1,2], t[1,2]+t[2,1]))

cat("System agreement with each other\n")
print(table(d1$V2==d2$V2))
print(table(d1$V2==d2$V2) / nrow(d1))
