#!/usr/bin/env python3

import sys
import glob
import os
import numpy as np
import soundfile as sf
from multiprocessing import Pool, cpu_count

def find_dominant_frequency(data, sample_rate):
    # Perform FFT
    fft_data = np.fft.fft(data)
    freqs = np.fft.fftfreq(len(data), 1/sample_rate)
    
    # Get positive frequencies only
    pos_mask = freqs > 0
    freqs = freqs[pos_mask]
    fft_data = np.abs(fft_data[pos_mask])
    
    # Find the frequency with maximum amplitude
    dominant_freq = freqs[np.argmax(fft_data)]
    return round(dominant_freq, 2)

def analyze_audio(filename):
    try:
        # Read the audio file using soundfile
        data, sample_rate = sf.read(filename)
        
        # Check if stereo
        if len(data.shape) != 2:
            return f"Error: {filename} must be stereo (2 channels)"
        
        # Separate channels
        left_channel = data[:, 0]
        right_channel = data[:, 1]
        
        # Find dominant frequencies
        left_freq = find_dominant_frequency(left_channel, sample_rate)
        right_freq = find_dominant_frequency(right_channel, sample_rate)
        
        return f"\nAnalysis of {filename}:\n" \
               f"Left channel frequency:  {left_freq} Hz\n" \
               f"Right channel frequency: {right_freq} Hz\n" \
               f"Binaural beat frequency: {abs(right_freq - left_freq)} Hz"
        
    except Exception as e:
        return f"Error analyzing {filename}: {str(e)}"

def get_safe_core_count():
    total_cores = cpu_count()
    # Use 60% of available cores, minimum of 1
    recommended_cores = max(1, int(total_cores * 0.60))
    return recommended_cores

if __name__ == "__main__":
    if len(sys.argv) == 1:
        flac_files = sorted(glob.glob("*.flac"))
        if not flac_files:
            print("No FLAC files found in current directory")
            sys.exit(1)
            
        total_cores = cpu_count()
        num_cores = get_safe_core_count()
            
        print(f"\nSystem Information:")
        print(f"Total CPU cores detected: {total_cores}")
        print(f"Cores to be used: {num_cores} ({num_cores/total_cores*100:.0f}% of CPU)")
        print(f"Files to process: {len(flac_files)}")
        
        # Ask for user confirmation
        response = input("\nProceed with processing? (y/N): ").lower()
        if response != 'y':
            print("Operation cancelled by user")
            sys.exit(0)
            
        print(f"\nProcessing {len(flac_files)} files...")
        
        # Process files in parallel with fixed pool size
        with Pool(processes=num_cores) as pool:
            # Explicitly set chunksize to ensure even distribution
            chunksize = max(1, len(flac_files) // num_cores)
            results = pool.map(analyze_audio, flac_files, chunksize=chunksize)
            for result in results:
                print(result)
    else:
        # Analyze specific file
        print(analyze_audio(sys.argv[1]))
