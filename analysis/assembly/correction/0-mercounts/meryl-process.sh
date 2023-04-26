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

if [ $jobid -gt 1 ]; then
  echo Error: Only 1 job, you asked for $jobid.
  exit 1
fi

#  If the meryl ignore files exst, then we're done.

if [ -e ./lferriphilum.ms16.histogram -a -e ./lferriphilum.ms16.dump -a -e ./lferriphilum.ms16.ignore.gz ] ; then
  exit 0
fi

#  If those exist in the object store, we're also done.


if [ -e lferriphilum.ms16.histogram ]; then
  exists1=true
else
  exists1=false
fi

if [ -e lferriphilum.ms16.dump ]; then
  exists2=true
else
  exists2=false
fi

if [ -e lferriphilum.ms16.ignore.gz ]; then
  exists3=true
else
  exists3=false
fi
if [ $exists1 = true -a $exists2 = true -a $exists3 = true ] ; then
  echo "Output files 'lferriphilum.ms16.histogram', 'lferriphilum.ms16.dump' and 'lferriphilum.ms16.ignore.gz' exist in 'correction/0-mercounts'."
  exit 0
fi


#  Nope, not done.  Fetch all the intermediate meryl databases.


#
#  Merge counting jobs, strip out unique kmers.
#

if [ ! -e ./lferriphilum.ms16/merylIndex ] ; then
  /sw/bioinfo/canu/2.2/rackham/bin/meryl threads=4 memory=3 \
    greater-than 1 \
      output lferriphilum.ms16.WORKING \
      union-sum  \
        ./lferriphilum.01.meryl \
  && \
  mv -f ./lferriphilum.ms16.WORKING ./lferriphilum.ms16

  #  Fail if there is no meryl database.
  if [ ! -e ./lferriphilum.ms16/merylIndex ] ; then
    echo meryl merge failed.
    exit 1
  fi

  #  Remove meryl intermediate files.
  rm -rf ./lferriphilum.01.meryl ./lferriphilum.01.meryl.err
fi

#
#  Dump a histogram, 'cause they're useful.
#

if [ ! -e ./lferriphilum.ms16.histogram ] ; then
  /sw/bioinfo/canu/2.2/rackham/bin/meryl threads=1 memory=1 \
    statistics ./lferriphilum.ms16 \
  > ./lferriphilum.ms16.histogram.WORKING \
  && \
  mv ./lferriphilum.ms16.histogram.WORKING ./lferriphilum.ms16.histogram
fi

#
#  Dump frequent mers.
#
#  The indenting of the at-least options is misleading.  'print'
#  takes input from the first 'at-least', which that takes input from
#  the second 'at-least'.  The effect is the same as taking the
#  'intersection' of all the 'at-least' filters -- logically, it is
#  doing 'at-least X AND at-least Y AND at-least Z'.
#

if [ ! -e ./lferriphilum.ms16.dump ] ; then
  /sw/bioinfo/canu/2.2/rackham/bin/meryl threads=4 memory=3 \
    print ./lferriphilum.ms16.##.dump \
      at-least threshold=1000 \
      at-least word-frequency=0.0000001 \
        ./lferriphilum.ms16

  cat ./lferriphilum.ms16.??.dump > ./lferriphilum.ms16.dump
  rm -f ./lferriphilum.ms16.??.dump
fi

#
#  Convert the dumped kmers into a mhap ignore list.
#
#    numKmers - number of kmers we're filtering
#    totKmers - total number of kmers in the dataset

if [ ! -e ./lferriphilum.ms16.ignore.gz ] ; then
  numKmers=`wc -l < ./lferriphilum.ms16.dump`
  totKmers=`/sw/bioinfo/canu/2.2/rackham/bin/meryl statistics ./lferriphilum.ms16 | grep present | awk '{ print $2 }'`


  ./meryl-make-ignore.pl $numKmers $totKmers < ./lferriphilum.ms16.dump | gzip -1c > ./lferriphilum.ms16.ignore.gz
fi


exit 0
