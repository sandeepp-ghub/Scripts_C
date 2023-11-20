
set id =  $1
set job = 1
while ( $job )

    set job = `mystat | grep $id |wc -l`
    if ( $job ) then
       echo "Waiting for job $id"
       sleep 15m
    else
        echo "Done"
    endif

end

sleep 60
