#!/bin/sh

sbatch \
  --cpus-per-task=4 --mem-per-cpu=768m -o meryl-count.%A_%a.out \
  -D `pwd` -J "meryl_lferriphilum" \
  -a 1-1 \
  `pwd`/meryl-count.sh 0 \
> ./meryl-count.jobSubmit-01.out 2>&1
