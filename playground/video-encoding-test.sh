#!/bin/sh

INPUT="../video/The.Walking.Dead.S05E01.720p.HDTV.x264-KILLERS.mkv"
TMP="/tmp/tmp.mkv"
ffmpeg -i ${INPUT} -ss 00:00:00 -t 00:01:00 -acodec copy -vcodec copy -async 1 -y ${TMP}

#veryslow time x 10
#fast time 1000k         43m54s -> 107m35.660s ~8mb/min   354m
#fast time 600k + resize 43m54s ->  54m49.578s ~5.1mb/min 225m

#VIDEO_OPTS="-vcodec libx264 -preset veryslow -b:v 1000k"
#VIDEO_OPTS="-vcodec libx264 -preset faster -b:v 600k -vf scale=746:480"
VIDEO_OPTS="-vcodec libx264 -preset faster -b:v 550k"
AUDIO_OPTS="-c:a libfdk_aac -b:a 96k -ar 44100 -ac 2"
COMMON="-y -i ${INPUT} -threads 0"


time ffmpeg ${COMMON} -pass 1 ${VIDEO_OPTS}  -f mp4 -an /dev/null;
time ffmpeg ${COMMON} -pass 2 ${VIDEO_OPTS} ${AUDIO_OPTS} "${INPUT}.mp4"


#ffmpeg -i "${INPUT}" -f image2 -vf fps=fps=1/60 "${INPUT}-thumb-%03d.jpg"
