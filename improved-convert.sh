#!/bin/bash

# Default values
INPUT_DIR="."
SIZE="450"
QUALITY="medium"
VERBOSE=false
DRY_RUN=false
NO_AUDIO=false

# Quality presets - function to get CRF values
get_h265_crf() {
    case "$1" in
        "low") echo "32" ;;
        "medium") echo "28" ;;
        "high") echo "23" ;;
        *) echo "" ;;
    esac
}

get_vp9_crf() {
    case "$1" in
        "low") echo "35" ;;
        "medium") echo "25" ;;
        "high") echo "20" ;;
        *) echo "" ;;
    esac
}

# Check if video has audio streams
has_audio() {
    local file="$1"
    ffprobe -v quiet -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$file" 2>/dev/null | grep -q "audio"
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Convert MP4 videos to H.265 MP4 and VP9 WebM formats with organized output.

OPTIONS:
    -d, --directory <path>    Input directory (default: current directory)
    -s, --size <height>       Video height in pixels (default: 450)
                              Common values: 360, 450, 720, 1080
    -q, --quality <preset|number>
                              Quality preset or CRF value:
                              Presets: low (H.265: 32, VP9: 35)
                                      medium (H.265: 28, VP9: 25) [default]
                                      high (H.265: 23, VP9: 20)
                              Or specify CRF directly:
                              H.265: 18-35 (lower = better quality)
                              VP9: 20-40 (lower = better quality)
    -v, --verbose             Show detailed output
    --dry-run                 Preview operations without executing
    --no-audio                Force disable audio encoding (add -an flag)
    --homepagepromo           Shorthand for homepage promo settings (450p, CRF 28)
    -h, --help                Show this help message

EXAMPLES:
    $0                        Convert current directory with defaults
    $0 -d /path/to/videos     Convert specific directory
    $0 -s 720 -q high         Convert to 720p with high quality
    $0 -q 25                  Convert with custom CRF value
    $0 --no-audio             Convert without audio (smaller files for silent videos)
    $0 --homepagepromo        Use homepage promo settings (450p, CRF 28)

OUTPUT:
    Creates '{input-dir}/converted/' with subfolders:
    '{datetime}-{size}p-{quality}/'
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            INPUT_DIR="$2"
            shift 2
            ;;
        -s|--size)
            SIZE="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-audio)
            NO_AUDIO=true
            shift
            ;;
        --homepagepromo)
            SIZE="450"
            QUALITY="28"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate and sanitize input directory
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist"
    exit 1
fi

# Remove trailing slash if present
INPUT_DIR="${INPUT_DIR%/}"

# Validate size
if ! [[ "$SIZE" =~ ^[0-9]+$ ]]; then
    echo "Error: Size must be a number"
    exit 1
fi

# Determine CRF values
if [[ "$QUALITY" =~ ^[0-9]+$ ]]; then
    # Numerical CRF value provided
    H265_CRF="$QUALITY"
    VP9_CRF="$QUALITY"
    QUALITY_LABEL="$QUALITY"
else
    # Preset provided
    H265_CRF=$(get_h265_crf "$QUALITY")
    VP9_CRF=$(get_vp9_crf "$QUALITY")
    if [[ -z "$H265_CRF" ]]; then
        echo "Error: Invalid quality preset '$QUALITY'. Use: low, medium, high, or a number"
        exit 1
    fi
    QUALITY_LABEL="$QUALITY"
fi

# Create output directory structure
INPUT_BASENAME=$(basename "$INPUT_DIR")
OUTPUT_BASE="$INPUT_DIR/converted"
DATETIME=$(date +%Y-%m-%d-%H%M%S)
OUTPUT_DIR="$OUTPUT_BASE/$DATETIME-${SIZE}p-$QUALITY_LABEL"

if [[ "$VERBOSE" == true ]]; then
    echo "Configuration:"
    echo "  Input directory: $INPUT_DIR"
    echo "  Size: ${SIZE}p"
    echo "  Quality: $QUALITY_LABEL (H.265 CRF: $H265_CRF, VP9 CRF: $VP9_CRF)"
    echo "  Output directory: $OUTPUT_DIR"
    echo ""
fi

# Create output directory
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Process videos
count=0
for file in "$INPUT_DIR"/*.mp4; do
    if [[ ! -f "$file" ]]; then
        echo "No MP4 files found in $INPUT_DIR"
        exit 0
    fi
    
    filename=$(basename "$file" .mp4)
    ((count++))
    
    echo "Processing ($count): $filename"
    
    # Check for audio and set audio flag
    audio_flag=""
    if [[ "$NO_AUDIO" == true ]] || ! has_audio "$file"; then
        audio_flag="-an"
        if [[ "$VERBOSE" == true ]]; then
            if [[ "$NO_AUDIO" == true ]]; then
                echo "  Audio disabled by --no-audio flag"
            else
                echo "  No audio detected, adding -an flag"
            fi
        fi
    fi
    
    # H.265 conversion
    h265_output="$OUTPUT_DIR/${filename}_${SIZE}p_h265.mp4"
    h265_cmd="ffmpeg -i \"$file\" -vf \"scale=-2:$SIZE\" -c:v libx265 -preset veryslow -crf $H265_CRF -tag:v hvc1 -pix_fmt yuv420p $audio_flag \"$h265_output\""
    
    if [[ "$VERBOSE" == true ]]; then
        echo "  H.265: $h265_cmd"
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        eval "$h265_cmd"
    fi
    
    # VP9 conversion
    vp9_output="$OUTPUT_DIR/${filename}_${SIZE}p_vp9.webm"
    vp9_cmd="ffmpeg -i \"$file\" -vf \"scale=-2:$SIZE\" -c:v libvpx-vp9 -pix_fmt yuv420p -crf $VP9_CRF -b:v 0 $audio_flag \"$vp9_output\""
    
    if [[ "$VERBOSE" == true ]]; then
        echo "  VP9: $vp9_cmd"
    fi
    
    if [[ "$DRY_RUN" == false ]]; then
        eval "$vp9_cmd"
    fi
done

echo "Conversion complete! Output directory:"
echo "  $OUTPUT_DIR"
