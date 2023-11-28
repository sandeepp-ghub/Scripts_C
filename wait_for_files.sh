#!/bin/tcsh

# Define a default time interval in seconds
set default_time_interval=60

# User will pass in:
# - 1st token: email address
# - 2nd token: 'wait_for_arrival' or 'wait_for_removal'
# - 3rd token: the file to wait on as 1st token 
# - 4th token: (optional) Specify how often to check for condition in seconds (default=60)
set email_address=$1
set condition=$2
set fname=$3
set time_interval=$4
set send_mail=1

if ( $time_interval == "" ) then
    set time_interval=$default_time_interval
endif

# ---------------------------------------------------    
echo "-------------------------------------------------------------------------------------------"
echo "condition = '$condition'"
echo "The $0 command is called with $#argv parameters"
echo "  email_address = $1"
echo "      condition = $2"
echo "          fname = $3"
echo "  time_interval = $time_interval seconds"
echo ""
echo "-------------------------------------------------------------------------------------------"
if ( `echo $email_address | sed -n '/@marvell\.com/p'` == "" ) then
    echo "(E): 1st token must specify <user>@marvell.com email address" 

else if ( $condition != "wait_for_arrival" && $condition != "wait_for_removal" ) then
    echo "(E): 2nd token must be either 'wait_for_arrival' or 'wait_for_removal'"

else if ( $fname == "" ) then
    echo "(E): 3rd token must be the filename to trigger off."

else if ( $condition == "wait_for_removal" ) then
    echo "`date`: Waiting for removal of '$fname' ... Condition checked every $time_interval seconds."
    while ( -e "$fname" );
	sleep $time_interval
    end
    echo "`date`: Condition met: '$fname' no longer exists."
    set email_subject = "$fname REMOVED as of `date`"
    set send_mail = 1

else if ( $condition == "wait_for_arrival" ) then
    echo "`date`: Waiting for arrival of '$fname' ... Condition checked every $time_interval seconds."
    while ( ! -e "$fname" );
	# Check every
	sleep $time_interval
    end
    echo "`date`: Condition met: '$fname' exists."
    set email_subject = "$fname ARRIVED as of `date`"
    set send_mail = 1

endif

if ( $send_mail == "1" ) then
    echo "`date`: Sending email to $email_address"
    mail -s "$email_subject" $email_address < /dev/null
endif
