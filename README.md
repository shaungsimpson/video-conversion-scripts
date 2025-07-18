# Video Conversion Scripts

This repository contains bash scripts for converting MP4 videos to web-optimized H.265 MP4 and VP9 WebM formats.

## Scripts

### `convert-videos.sh`
Basic video conversion script that processes all MP4 files in the current directory with fixed 450p output resolution.

### `improved-convert.sh`
Enhanced version with configurable options, organized output structure, and flexible quality settings.

## Features

### `improved-convert.sh` Features:
- **Flexible directory selection**: Choose input directory or use current directory
- **Configurable video size**: Set output resolution (default: 450p)
- **Quality presets**: Choose from low/medium/high compression levels
- **Custom CRF values**: Specify exact compression values for fine control
- **Organized output**: Creates structured folders with date and format information
- **Dry-run mode**: Preview operations without executing
- **Verbose output**: See detailed ffmpeg commands and configuration
- **Comprehensive help**: Built-in usage documentation

### Output Organization
The improved script creates an organized folder structure:
```
{input-directory}-converted/
├── 2025-07-18-h265-450p-medium/
│   ├── video1_450p_h265.mp4
│   └── video2_450p_h265.mp4
└── 2025-07-18-vp9-450p-medium/
    ├── video1_450p_vp9.webm
    └── video2_450p_vp9.webm
```

### Quality Settings

#### Presets
- **Low**: Higher compression, smaller files
  - H.265: CRF 32
  - VP9: CRF 35
- **Medium**: Balanced quality and file size (default)
  - H.265: CRF 28
  - VP9: CRF 25
- **High**: Lower compression, larger files, better quality
  - H.265: CRF 23
  - VP9: CRF 20

#### Custom CRF Values
You can also specify exact CRF values:
- **H.265**: Range 18-35 (lower = better quality)
- **VP9**: Range 20-40 (lower = better quality)

## Usage Examples

### Basic Usage
```bash
# Convert all MP4s in current directory with defaults (450p, medium quality)
./improved-convert.sh

# Show help
./improved-convert.sh --help
```

### Directory Selection
```bash
# Convert videos from a specific directory
./improved-convert.sh -d /path/to/videos

# Convert videos from relative path
./improved-convert.sh -d ./my-videos
```

### Size Configuration
```bash
# Convert to 720p
./improved-convert.sh -s 720

# Convert to 1080p
./improved-convert.sh -s 1080

# Convert to 360p for smaller files
./improved-convert.sh -s 360
```

### Quality Settings
```bash
# Use quality presets
./improved-convert.sh -q low     # Higher compression
./improved-convert.sh -q medium  # Balanced (default)
./improved-convert.sh -q high    # Lower compression

# Use custom CRF values
./improved-convert.sh -q 25      # Custom compression level
./improved-convert.sh -q 30      # Higher compression
./improved-convert.sh -q 20      # Lower compression
```

### Shorthand Presets
```bash
# Use homepage promo settings (450p, CRF 28 - matches original script)
./improved-convert.sh --homepagepromo
```

### Combined Options
```bash
# Convert specific directory to 720p with high quality
./improved-convert.sh -d ./videos -s 720 -q high

# Convert to 1080p with custom CRF, show verbose output
./improved-convert.sh -s 1080 -q 22 --verbose

# Preview what would be converted without executing
./improved-convert.sh -d ./videos -s 720 --dry-run
```

### Advanced Examples
```bash
# High quality 1080p conversion with verbose output
./improved-convert.sh -d ./source-videos -s 1080 -q high --verbose

# Quick preview of batch conversion
./improved-convert.sh -d ./raw-footage --dry-run

# Small file size conversion for web streaming
./improved-convert.sh -s 360 -q low

# Custom compression with dry-run preview
./improved-convert.sh -s 720 -q 28 --dry-run --verbose

# Use homepage promo settings (matches original script)
./improved-convert.sh --homepagepromo
```

## Command Line Options

```
Usage: ./improved-convert.sh [OPTIONS]

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
    --homepagepromo           Shorthand for homepage promo settings (450p, CRF 28)
    -h, --help                Show this help message
```

## Requirements

- **ffmpeg**: Must be installed and available in PATH
- **bash**: Compatible with bash 3.0+
- **File permissions**: Scripts must be executable (`chmod +x script-name.sh`)

## Installation

1. Make the script executable:
```bash
chmod +x improved-convert.sh
```

2. Run the script:
```bash
./improved-convert.sh
```

## Output Formats

The script generates two optimized formats for each input video:

### H.265 MP4 (.mp4)
- **Codec**: libx265
- **Preset**: veryslow (best compression)
- **Tag**: hvc1 (for better compatibility)
- **Pixel Format**: yuv420p

### VP9 WebM (.webm)
- **Codec**: libvpx-vp9
- **Bitrate**: Variable (CRF-based)
- **Pixel Format**: yuv420p

Both formats maintain aspect ratio and are optimized for web delivery.