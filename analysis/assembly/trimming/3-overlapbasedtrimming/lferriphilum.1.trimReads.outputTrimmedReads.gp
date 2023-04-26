set title 'outputTrimmedReads'
set xlabel 'length, bin width = 250'
set ylabel 'number'

binwidth=250
set boxwidth binwidth
bin(x,width) = width*floor(x/width) + binwidth/2.0

set terminal png size 1024,1024
set output './lferriphilum.1.trimReads.outputTrimmedReads.png'
plot [] [0:] './lferriphilum.1.trimReads.outputTrimmedReads.dat' using (bin($1,binwidth)):(1.0) smooth freq with boxes title ''
