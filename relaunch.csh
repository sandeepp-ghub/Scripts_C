#!/bin/tcsh

# max 15 iterations
set max_iter=`seq 0 15`

# current dir
set current_dir=`pwd`



# make sure we're in an innovus session dir
# NOTE: adding qrc.signoff* as well since it crashes a bunch
if ($current_dir !~ /proj/cayman/extvols/wa_005/seth/impl/*/track*/invcui* \
    && $current_dir !~ /proj/cayman/extvols/wa_005/seth/impl/*/track*/qrc.signoff*) then
    echo "EXITING: not in /proj/cayman/wa/seth/impl/*/track*/invcui*"
    echo "             or /proj/cayman/wa/seth/impl/*/track*/qrc.signoff*"
    exit
else
    echo "current dir: $current_dir ... proceeding to launch"
endif

# launch mfw run -term until dataout/HANDOFF exists, max 15 times
foreach iter ($max_iter)
    if (-f dataout/HANDOFF) then
        break
    else
        # if no dataout/HANDOFF, re-run mfw run -term <sgq_options>
        rm .m1dp/session.lock
        mfw run -clean
        mfw run -term $1
    endif
end

