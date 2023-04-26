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




#  Discover the job ID to run, from either a grid environment variable and a
#  command line offset, or directly from the command line.
#
if [ x$SLURM_ARRAY_TASK_ID = x -o x$SLURM_ARRAY_TASK_ID = xundefined -o x$SLURM_ARRAY_TASK_ID = x0 ]; then
  baseid=$1
  offset=0
else
  baseid=$SLURM_ARRAY_TASK_ID
  offset=$1
fi
if [ x$offset = x ]; then
  offset=0
fi
if [ x$baseid = x ]; then
  echo Error: I need SLURM_ARRAY_TASK_ID set, or a job index on the command line.
  exit
fi
jobid=`expr -- $baseid + $offset`
if [ x$baseid = x0 ]; then
  echo Error: jobid 0 is invalid\; I need SLURM_ARRAY_TASK_ID set, or a job index on the command line.
  exit
fi
if [ x$SLURM_ARRAY_TASK_ID = x ]; then
  echo Running job $jobid based on command line options.
else
  echo Running job $jobid based on SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID and offset=$offset.
fi

if [ $jobid -gt 01 ]; then
  echo Error: Only 01 jobs, you asked for $jobid.
  exit 1
fi

jobid=`printf %02d $jobid`

#  If the meryl database exists, we're done.

if [ -e ./lferriphilum.$jobid.meryl/merylIndex ] ; then
  echo Kmers for batch $jobid exist.
  exit 0
fi

#  If the meryl output exists in the object store, we're also done.


if [ -e lferriphilum.$jobid.meryl.tar.gz ]; then
  exist1=true
else
  exist1=false
fi
if [ $exist1 = true ] ; then
  echo Kmers for batch $jobid exist in the object store.
  exit 0
fi

#  Nope, not done.  Fetch the sequence store.


#  And compute.

/sw/bioinfo/canu/2.2/rackham/bin/meryl k=16 threads=4 memory=3 \
  count \
    segment=$jobid/01 ../../lferriphilum.seqStore \
    output ./lferriphilum.$jobid.meryl.WORKING \
&& \
mv -f ./lferriphilum.$jobid.meryl.WORKING ./lferriphilum.$jobid.meryl


exit 0
