#!/bin/bash
# Render GTA 6 clip: 6.9s trailer + 6s pitch
# 1080x1920

mkdir -p ./clip ./frames

# Part A (6.9s, 00:02:18.2 - 00:02:25.1)
timeout 100 ffmpeg -y -ss 00:02:18.2 -i /downloads/makefun/clipper-footage/GTAVI_Trailer_2.mp4 \
-t 6.9 -r 30 \
-filter_complex "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,boxblur=20[bg];[0:v]scale=1080:-1,setsar=1[fg];[bg][fg]overlay=0:(H-h)/2[v1]" \
-map "[v1]" -map 0:a -c:v libx264 -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k -r 30 -s 1080x1920 ./clip/partA.mp4

# Extract verification frames
timeout 100 ffmpeg -y -ss 00:02:24.5 -i /downloads/makefun/clipper-footage/GTAVI_Trailer_2.mp4 -frames:v 1 -vf scale=480:-1 ./frames/verify_6_3.jpg
timeout 100 ffmpeg -y -ss 00:02:25.0 -i /downloads/makefun/clipper-footage/GTAVI_Trailer_2.mp4 -frames:v 1 -vf scale=480:-1 ./frames/verify_6_8.jpg

# Part B (6s) - Pitch text
# Background: single frame from 00:02:24.6
timeout 100 ffmpeg -y -ss 00:02:24.6 -i /downloads/makefun/clipper-footage/GTAVI_Trailer_2.mp4 -frames:v 1 ./clip/last_frame.jpg

timeout 100 ffmpeg -y -loop 1 -i ./clip/last_frame.jpg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 -r 30 \
-filter_complex "[0:v]scale=1080:1920,setsar=1,boxblur=20,eq=brightness=-0.2[vB_bg];[vB_bg]drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='Make clips with AI,':fontsize=64:fontcolor=white:x=(w-text_w)/2:y=720:box=1:boxcolor=black@0.6:boxborderw=20,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='earn money on make.fun':fontsize=64:fontcolor=white:x=(w-text_w)/2:y=830:box=1:boxcolor=black@0.6:boxborderw=20,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='make.fun/bounty/gta6-clipper-01':fontsize=50:fontcolor=white:x=(w-text_w)/2:y=940:box=1:boxcolor=black@0.6:boxborderw=20[vB]" \
-map "[vB]" -map 1:a -t 6 -c:v libx264 -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k -r 30 -s 1080x1920 ./clip/partB.mp4

# Concatenate and add hook text
timeout 100 ffmpeg -y -i ./clip/partA.mp4 -i ./clip/partB.mp4 -filter_complex "[0:v]fps=30,setsar=1,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='GTA 6 IS HERE':fontsize=96:fontcolor=white:x=(w-text_w)/2:y=300:box=1:boxcolor=black@0.6:boxborderw=24:enable='between(t,0,3)'[a];[1:v]fps=30,setsar=1[b];[0:a]aresample=48000[aa];[1:a]aresample=48000[ba];[a][aa][b][ba]concat=n=2:v=1:a=1[v][a0];[a0]afade=t=out:st=11:d=2[a1]" -map "[v]" -map "[a1]" -t 14 -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k ./clip/final.mp4
