#!/bin/bash

mkdir /data/tmp
convertCurrentFile() {
    logger "Starting convertation for $1"
    fullPath="$1"
    fileName=$(basename "$fullPath")
    fileNameOnly="${fileName%.*}"
    tmpFileName="/data/tmp/$fileNameOnly.mp4"
    outFileName="/data/output/$fileNameOnly.mp4"
    logFileName="/data/output/$fileNameOnly.log"
    nice /data/bin/timeout.sh -t 7200 HandBrakeCLI --encoder x264 --encopts cabac=1:me=umh:subq=8:trellis=2 --two-pass --maxWidth 640 --maxHeight 480 --vb 525 --ab 96 --optimize -i "$fullPath" -o "$tmpFileName" > $logFileName 2>&1
    chown --reference="$fullPath" "$tmpFileName"
    chmod --reference="$fullPath" "$tmpFileName"

    ffmpeg -ss 3 -i "$tmpFileName" -vf "select=gt(scene\,0.3)" -frames:v 5 -vsync vfr -vf fps=fps=1/600 "/data/output/img${fileNameOnly}_%01d.jpg"

    chown --reference="$fullPath" /data/output/img${fileNameOnly}_*.jpg
    chmod --reference="$fullPath" /data/output/img${fileNameOnly}_*.jpg

    if [ -f "$tmpFileName" ]; then
        mv "$tmpFileName" "$outFileName"
        rm "$fullPath"
        logger "Finished convertation for $1"
    else
        rm "$fullPath"
        touch "$logFileName"
        mv "$logFileName" "/data/output/$fileNameOnly.failed"
    fi
}

while true; do
    for f in /data/input/*.video; do
        if [ -f "$f" ]; then
            convertCurrentFile "$f"
        fi
    done
    inotifywait -r -e close_write -e moved_to -t 60 /data/input
done
