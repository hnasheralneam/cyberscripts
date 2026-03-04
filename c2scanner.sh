#!/bin/sh

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
        fi

        FNAME_LAST=$FNAME

        sleep .5
done
