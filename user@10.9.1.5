#!/bin/sh
# Like c2scanner but ANGRY

mkdir -p scans


FNAME="$(date +%s)"
FNAME_LAST="$(date +%s)ProMax"

while true
do
        FNAME="$(date +%s)"
        ss -tupn > "scans/$FNAME"

        DIFF=$(diff "scans/$FNAME" "scans/$FNAME_LAST")
        if [ "$DIFF" != "" ];
        then
                echo "====== NEW STUFF HAPPENING ======"
                echo "event at $(date)"
                diff "scans/$FNAME" "scans/$FNAME_LAST"

                echo "====== COMMITING MURDER ======"
                ss -tpn | grep -Po 'pid=\K[0-9]+' > hitlist
                while IFS= read -r line; do
                   sudo kill -9 "$line"
                   echo "done murding $line"
                done < hitlist
        fi

        FNAME_LAST=$FNAME

        sleep .5
done
