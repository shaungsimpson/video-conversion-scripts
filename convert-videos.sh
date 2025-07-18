#!/bin/bash

INPUT_DIR="."
OUTPUT_DIR="$INPUT_DIR/converted"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.mp4; do
  filename=$(basename "$file" .mp4)

  # Convert to H.265 .mp4
  ffmpeg -i "$file" \
    -vf "scale=-2:450" \
    -c:v libx265 \
    -preset veryslow \
    -crf 28 \
    -tag:v hvc1 \
    -pix_fmt yuv420p \
    "$OUTPUT_DIR/${filename}_450p_h265.mp4"

  # Convert to VP9 .webm
  ffmpeg -i "$file" \
    -vf "scale=-2:450" \
    -c:v libvpx-vp9 \
    -pix_fmt yuv420p \
    -crf 25 \
    -b:v 0 \
    "$OUTPUT_DIR/${filename}_450p_vp9.webm"
done
