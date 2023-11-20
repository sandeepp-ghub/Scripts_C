set block=cpt_rxc
set total=0
foreach stage ( dc.syn invcui.pre.fp invcui.pre.place invcui.cts invcui.post.route invcui.post.opt)
    if (-e $stage/report/${stage}.proc_time.csv) then
    #echo $stage/report/${block}.${stage}.proc_time.csv
    set tim = `cat $stage/report/${stage}.proc_time.csv | grep write_grid_token | cut -d , -f 3 `
    echo "$stage = $tim"
    set hh = `echo $tim | cut -d ":" -f 1`
    set mm = `echo $tim | cut -d ":" -f 2`
    set ss = `echo $tim | cut -d ":" -f 3`
    set total = `echo "$total + ( $hh * 60 ) + $mm + ($ss / 60 )" | bc -l `
    endif
end
echo "total : $total"
set thh = `echo "$total / 60 " | bc -l `
echo "total hour : $thh"
