#!/usr/bin/env bash

# Function to generate binaural beats using SoX
generate_binaural_sox() {
    local wave_type="$1"
    local carrier_freq=150
    local duration=900
    local freq="$2"
    # Use printf for better floating point precision
    local left_freq=$(printf "%.3f" $(echo "$carrier_freq - ($freq/2)" | bc -l))
    local right_freq=$(printf "%.3f" $(echo "$carrier_freq + ($freq/2)" | bc -l))
    
    # Generate both channels in parallel using WAV for intermediate files
    parallel --will-cite --link sox -n -r 48000 -c 1 {1} synth "$duration" sine {2} gain -6 ::: \
        "${wave_type}/left_${freq}.wav" "${wave_type}/right_${freq}.wav" ::: \
        "$left_freq" "$right_freq"
    
    # Combine channels and convert to FLAC with metadata
    sox -M "${wave_type}/left_${freq}.wav" "${wave_type}/right_${freq}.wav" -C 8 "${wave_type}/${wave_type}_${freq}hz.flac"
    
    # Add metadata and cover art using metaflac
    metaflac --set-tag="TITLE=Binaural ${wave_type} ${freq}Hz" \
             --set-tag="ARTIST=Binaural Beat Generator" \
             --set-tag="ALBUM=${wave_type} Waves" \
             --set-tag="GENRE=Binaural Beats" \
             --import-picture-from="image.jpg" \
             "${wave_type}/${wave_type}_${freq}hz.flac"
    
    # Cleanup temporary WAV files
    rm "${wave_type}/left_${freq}.wav" "${wave_type}/right_${freq}.wav"
}

# Export the function so parallel can use it
export -f generate_binaural_sox

# Display menu
echo "Select the type of brainwave to generate:"
echo "1. Delta (0.5-4 Hz) - Deep sleep, healing, unconscious mind"
echo "2. Theta (4-8 Hz) - Meditation, creativity, deep relaxation"
echo "3. Alpha (8-13 Hz) - Relaxed focus, stress reduction, learning"
echo "4. Beta (13-30 Hz) - Active thinking, concentration, alertness"
echo "5. Gamma (30-50 Hz) - Peak awareness, cognitive enhancement"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)  wave_type="delta"
        start=0.5; end=4; step=0.5
        ;;
    2)  wave_type="theta"
        start=4; end=8; step=0.5
        ;;
    3)  wave_type="alpha"
        start=8; end=13; step=1
        ;;
    4)  wave_type="beta"
        start=13; end=30; step=2
        ;;
    5)  wave_type="gamma"
        start=30; end=50; step=2
        ;;
    *)  echo "Invalid choice"
        exit 1
        ;;
esac

# Create directory for the selected wave type
mkdir -p "$wave_type"

# Generate the selected wave sequence in parallel
echo "Generating ${wave_type} waves from ${start}Hz to ${end}Hz"
seq $start $step $end | parallel --will-cite --jobs $(nproc) generate_binaural_sox "$wave_type" {}
