# The `\test` Directory

This subdirectory contains scripts that process and analyze signals from a variety of data sources. Below you will find descriptions of the two main Python scripts found in this directory.

## Files

1. **signal_processing.py**: This file contains the `SignalPreprocessor` class, which is used to preprocess signal data. This class includes methods for applying rolling averages and Butterworth lowpass/highpass filters to the signals.

2. **batch_processing.py**: This script is used to loop through all the files in a specified directory and perform some operation on each file. In this case, it applies various signal processing operations to each file.

## Usage

To use these scripts, first ensure that your Python environment has the necessary packages installed.

```sh
pip install numpy scipy
