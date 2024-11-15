# Binaural Beat Generator

A script for generating and analyzing binaural beats across different brainwave frequencies.

![Binaural Beat Generator](image.jpg)

## Overview

This project provides tools to generate binaural beats - audio signals that can potentially influence brainwave patterns. It creates stereo audio files where each channel plays a slightly different frequency, creating a perceived beat frequency equal to the difference between the channels.

## Features

- Generate binaural beats across five brainwave categories:
  - Delta (0.5-4 Hz) - Deep sleep, healing
  - Theta (4-8 Hz) - Meditation, creativity
  - Alpha (8-13 Hz) - Relaxed focus, learning
  - Beta (13-30 Hz) - Active thinking, concentration
  - Gamma (30-50 Hz) - Peak awareness
- High-quality FLAC audio output with metadata
- Parallel processing for efficient generation
- Analysis tools to verify frequency accuracy

## Requirements

- Python 3.x with:
  - numpy
  - scipy
  - matplotlib
  - soundfile
- Audio tools:
  - sox
  - ffmpeg
  - flac
- Other utilities:
  - GNU parallel
  - bc
  - bash

## Usage

1. Generate binaural beats:
   ```bash
   chmod +x generate_binaural.sh
   ./generate_binaural.sh
   ```
   Follow the menu prompts to select your desired brainwave category.

2. Analyze generated files:
   ```bash
   python3 analyze_binaural.py [filename.flac]
   ```
   If no filename is provided, it will analyze all FLAC files in the current directory.

## For NixOS Users

This project includes a `flake.nix` that sets up a complete development environment with all required dependencies. To use it:

1. Enable flakes in your NixOS configuration:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

2. Enter the development environment:
   ```bash
   nix develop
   ```

3. All required tools will be automatically available in the shell.

## Output

Generated files will be organized in directories by wave type (delta, theta, alpha, beta, gamma) and named according to their frequency, e.g., `alpha/alpha_10hz.flac`.

## Technical Details

- Carrier frequency: 150 Hz
- Sample rate: 48000 Hz
- Duration: 900 seconds (15 minutes)
- Output format: FLAC (compression level 8)
- Stereo channels with precise frequency separation
- Metadata includes wave type, frequency, and optional cover art

## License

[Add your license information here]
