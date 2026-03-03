ALERT_KEY1="recon"
ALERT_KEY2="susp_activity"
webhook="https://discord.com/api/webhooks/1475853787406143551/WktnCqT0mRF6qez5biL7fguzgzA1_Yt7PWQ__oDa_VxstC8lZhERXzExKl2MgJiFGso4"

PID=12
COMM="hi"
PPID=10
UID=5346
	    JSON='{"embeds":[{"title":"'$ALERT_KEY1'", "fields": [{"name": "PID", "value": "'$PID'"}]}]}'
	    echo "$PID"

            echo "--- ALERT TRIGGERED ---"
	    curl -H "Content-Type: application/json" -d '{"embeds":[{"title":"'$ALERT_KEY1'","fields":[{"name":"COMM","value":"'$COMM'"},{"name":"PID","value":"'$PID'"},{"name":"PPID","value":"'$PPID'"},{"name":"UID","value":"'$UID'"}]}]}' "$webhook" 
