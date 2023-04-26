#!/bin/bash -l

#SBATCH -A uppmax2023-2-3 -M snowy
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 01:00:00
#SBATCH -J sort
#SBATCH --mail-type=ALL
#SBATCH --mail-user simon.oscarson.2633@student.uu.se

module load bioinfo-tools
module load samtools


for f in /home/simonos/Genomeanalysis/anlysis/mapped_RNA/*.gz
do
 filename="${f%%.*}"
 samtools sort ${filename}.gz
done
