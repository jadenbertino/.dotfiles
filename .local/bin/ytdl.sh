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

# Get output filename
base_with_ext=$(yt-dlp --get-filename -o "%(title)s.%(ext)s" "$url")
base_title="${base_with_ext%.*}"  # strip the extension
if [[ "$format_choice" == "mp3" ]]; then
    predicted_path="$output_dir/${base_title}.mp3"
else
    predicted_path="$output_dir/${base_title}.mp4"
fi
echo "Predicted path: $predicted_path"

# If MP3, loop until valid bitrate choice
if [[ "$format_choice" == "mp3" ]]; then
    while true; do
        read -p "Choose audio quality: High (~320 kbps), Medium (~128 kbps), Small (~64 kbps) [h/m/s]: " quality_choice
        quality_choice=${quality_choice,,}
        case "$quality_choice" in
            h) audio_quality=0; break ;;  # Best
            m) audio_quality=5; break ;;  # Medium
            s) audio_quality=7; break ;;  # Small
            *) echo "Invalid choice. Please enter 'h', 'm', or 's'." ;;
        esac
    done
fi

# Confirm overwrite or skip download if file already exists
if [[ -f "$predicted_path" ]]; then
    while true; do
        read -p "File already exists: $filename. Overwrite or skip? [o/s]: " choice
        choice=${choice,,}
        if [[ "$choice" == "o" ]]; then
            echo "Overwriting file..."
            rm -f "$filename"
            break
        elif [[ "$choice" == "s" ]]; then
            echo "Skipping download."
            exit 0
        else
            echo "Invalid choice. Please enter 'o' or 's'."
        fi
    done
fi

# Run yt-dlp based on choice
if [[ "$format_choice" == "mp3" ]]; then
  yt-dlp -x --audio-format mp3 \
    --audio-quality $audio_quality \
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