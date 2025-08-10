#!/bin/bash

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
  echo "yt-dlp not found. Installing..."
  sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp
  sudo chmod a+rx /usr/local/bin/yt-dlp
  echo "yt-dlp installed successfully."
fi

# Auto-install ffmpeg if not found (needed for merging)
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg not found. Installing..."
    sudo apt update && sudo apt install -y ffmpeg
    echo "ffmpeg installed successfully."
fi

# Prompt for URL
read -p "Enter YouTube URL: " url

# Prompt for output directory with default
read -p "Enter output directory [/mnt/c/Users/jaden/Downloads]: " output_dir
output_dir=${output_dir:-/mnt/c/Users/jaden/Downloads}

# Get output format
while true; do
    read -p "Download as MP4 video or MP3 audio? [mp4/mp3]: " format_choice
    format_choice=${format_choice,,} # lowercase
    if [[ "$format_choice" == "mp4" || "$format_choice" == "mp3" ]]; then
        break
    else
        echo "Invalid choice. Please enter 'mp4' or 'mp3'."
    fi
done

# Run yt-dlp based on choice
if [[ "$format_choice" == "mp3" ]]; then
  yt-dlp -x --audio-format mp3 --audio-quality 0 \
    -o "$output_dir/%(title)s.%(ext)s" \
    --embed-metadata \
    --concurrent-fragments 4 \
    "$url"
fi

if [[ "$format_choice" == "mp4" ]]; then
  yt-dlp -f "bv*+ba/b" \
    --merge-output-format mp4 \
    -o "$output_dir/%(title)s.%(ext)s" \
    --embed-metadata \
    --concurrent-fragments 4 \
    "$url"
fi

# Find newest file in output directory
final_file=$(find "$output_dir" -type f -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

echo "Download complete. File saved to: $final_file"