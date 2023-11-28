# This command is used to parse the Innovus timing reports to return the:
#  SLACK | STARTPOINT_EDGE, STARTPOINT_PIN, STARTPOINT_CLK ==> ENDPOINT_EDGE, ENDPOINT_PIN, ENDPOINT_CLK
zcat $1 | sed -n -e '/Startpoint/p' -e '/Endpoint/p' -e '/Clock: /p' -e '/Slack:=/p' \
    | awk '{if ($0~/Slack/){printf ", %s\n", $NF} else if ($0~/Clock:/){printf ", %s ==> ", $NF} else {printf "%s, %s", $2, $3}}' \
    | awk '{printf "%10s | %s %s %s ==> %s %s %s\n", $NF, $1, $2, $3, $5, $6, $7}'
