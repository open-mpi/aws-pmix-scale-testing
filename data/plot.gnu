# Get Stats on file
stats datapoints skip 1 nooutput

# Tell gnuplot that you want a line graph
set style data lines
set title plottitle

# Set the X and Y axis label
set xlabel "Number Of Processes"
set ylabel "Memory Usage (Pages)"

# Make the X and Y axes be logrithmic
set nologscale x
set nologscale y

#set xtics 0,1

# Set the key to be in the top right of the graph
# set key top right
set key top left title "Legend" box 3

# Output to a png file
set terminal pdf
set output out

# Plot the data:
plot for [col=2:STATS_columns:2] datapoints using 1:col with lines title columnheader #, for [col=2:STATS_columns:2] "" using 1:col:col+1 with errorbars notitle

# Quit gnuplot
exit
