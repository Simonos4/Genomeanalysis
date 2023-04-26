#!/bin/sh


#  Path to Canu.

bin="/sw/bioinfo/canu/2.2/rackham/bin"

#  Report paths.

echo ""
echo "Found perl:"
echo "  " `which perl`
echo "  " `perl --version | grep version`
echo ""
echo "Found java:"
echo "  " `which /sw/comp/java/x86_64/sun_jdk1.8.0_151/bin/java`
echo "  " `/sw/comp/java/x86_64/sun_jdk1.8.0_151/bin/java -showversion 2>&1 | head -n 1`
echo ""
echo "Found canu:"
echo "  " $bin/canu
echo "  " `$bin/canu -version`
echo ""


#  Environment for any object storage.

export CANU_OBJECT_STORE_CLIENT=
export CANU_OBJECT_STORE_CLIENT_UA=
export CANU_OBJECT_STORE_CLIENT_DA=
export CANU_OBJECT_STORE_NAMESPACE=
export CANU_OBJECT_STORE_PROJECT=





/sw/bioinfo/canu/2.2/rackham/bin/sqStoreCreate \
  -o ./lferriphilum.seqStore.BUILDING \
  -minlength 1000 \
  -genomesize 2400000 \
  -coverage   200 \
  -bias       0 \
  -raw -pacbio ERR2028502 /crex/proj/genomeanalysis2023/Genome_Analysis/2_Christel_2017/DNA_raw_data/ERR2028502.fastq.gz \
&& \
mv ./lferriphilum.seqStore.BUILDING ./lferriphilum.seqStore \
&& \
exit 0

exit 1
