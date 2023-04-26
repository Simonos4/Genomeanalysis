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




/sw/bioinfo/canu/2.2/rackham/bin/meryl -C k=16 threads=4 memory=12 \
  count segment=1/01 ../../lferriphilum.seqStore \
> lferriphilum.ms16.config.01.out 2>&1
/sw/bioinfo/canu/2.2/rackham/bin/meryl -C k=16 threads=4 memory=12 \
  count segment=1/02 ../../lferriphilum.seqStore \
> lferriphilum.ms16.config.02.out 2>&1
/sw/bioinfo/canu/2.2/rackham/bin/meryl -C k=16 threads=4 memory=12 \
  count segment=1/04 ../../lferriphilum.seqStore \
> lferriphilum.ms16.config.04.out 2>&1
exit 0
