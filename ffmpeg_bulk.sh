#!/bin/bash

for i in *.ogg;
  do name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" "${name}.wav"
done
