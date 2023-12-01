#!/bin/csh
zgrep -B 1 "data arrival time" $1 | egrep "out|/| slack" | awk '{print $1}' > end 
zgrep "Startpoint" $1 | awk '{print $2}' > start
zgrep "slack (" $1 | grep -v "slack (w" | awk '{print $NF}' > slack 

paste start end slack > $1.sum 

