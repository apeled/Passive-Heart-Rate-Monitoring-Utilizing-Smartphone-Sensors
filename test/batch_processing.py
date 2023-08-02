"""
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.venv\scripts\activate
"""
import os
import time
import cv2
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import concurrent.futures
from signal_processing import SignalPreprocessor as sig

# Setting the matplotlib backend
plt.switch_backend('TkAgg')

# Constants
START_RECORDING_SECONDS = 3
STOP_RECORDING_SECONDS = 33
HIGHPASS_CUTOFF = 0.5
HIGHPASS_ORDER = 2

def luma_component_mean(frame, luma_signal):
    """
    Compute mean luma value for each frame.
    Args:
        frame: Frame to compute luma.
        luma_signal: List to append luma values to.
    Returns:
        luma_signal with appended mean luma value.
    """
    img_ycrcb = cv2.cvtColor(frame, cv2.COLOR_BGR2YCrCb)
    mean_of_luma = img_ycrcb[..., 0].mean() * -1
    luma_signal.append(mean_of_luma)
    return luma_signal

def process_video_file(video_file_path):
    """
    Processes a video file, calculates luma value for each frame.
    Args:
        video_file_path: Path of the video file to process.
    Returns:
        final_signal: A list of processed luma signals.
    """
    cap = cv2.VideoCapture(video_file_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    luma_signal = []

    with concurrent.futures.ThreadPoolExecutor() as executor:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            executor.submit(luma_component_mean, frame, luma_signal)

    cap.release()

    start_recording_values = fps * START_RECORDING_SECONDS
    stop_recording_values = fps * STOP_RECORDING_SECONDS
    final_signal = np.array(luma_signal)[int(start_recording_values):int(stop_recording_values)]
    final_signal = sig.butter_highpass_filter(signal=final_signal, cutoff=HIGHPASS_CUTOFF, order=HIGHPASS_ORDER)

    print(f"The FPS of this video was: {int(fps)}")
    print("Please adjust the file name and its corresponding column name in the csv, if needed.")
    return final_signal

def update_master_dataset(root_dir, csv_filename):
    """
    Update the master dataset with new data.
    Args:
        root_dir: Directory where the data is located.
        csv_filename: CSV file where the results will be saved.
    """
    results_df = pd.DataFrame()

    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".MOV") or file.endswith(".mp4"):
                file_path = os.path.join(root, file)
                print(f"Working on video {file}")
                start_time_for_video = time.time()
                luma_signal = process_video_file(file_path)

                folder_name = os.path.basename(root)
                col_name = folder_name + file
                results_df[col_name] = pd.Series(luma_signal)
                print(f"Finished with video: {file} --- {time.time() - start_time_for_video} seconds ---")

    results_df.to_csv(csv_filename, index_label="Frame")

def plot_from_dataset(csv_file_for_analysis):
    """Takes in the name of the csv file used for analysis and produces a line plot of the luma values for the specified columns"""

    # Read in the CSV file
    df = pd.read_csv(csv_file_for_analysis)
    results_df = pd.DataFrame(index=["PulseOx HR", "Calc HR", "Diff"])

    # For each column in the dataframe
    for i in range(1, df.shape[1]):
        fig, axs = plt.subplots(2)
        data = df.iloc[:, i] - np.mean(df.iloc[:, i])
        data_len = len(data)
        frequencies = np.fft.fft(data)
        frequencies = np.abs(frequencies)/data_len
        freq = np.fft.fftfreq((data_len), d=0.0083333) * 60
        calcHR = abs(freq[frequencies[0:200].argmax()])
        measuredHR = int(df.columns[i].split("_")[-1].split(".")[0].split("HR")[1])
        dif = measuredHR - calcHR
        results_df[df.columns[i]] = pd.Series([measuredHR, calcHR, dif], index=["PulseOx HR", "Calc HR", "Diff"])
        
        print(f"The HR measured with a Pulse OX was {measuredHR} while the HR calculated was {calcHR} with a difference of {dif}")
        
        axs[0].plot(df.iloc[:, 0] / 120, data)
        axs[1].plot(freq, frequencies)
        axs[0].set_xlabel('Time (s)')
        axs[0].set_ylabel("Luma value")
        axs[1].set_xlabel('Heart Rate (BPM)')
        axs[1].set_ylabel("Energy")
        plt.show()
        
    results_df.to_csv("Heart Rate Value.csv", index_label="Entry")

if __name__ == "__main__":
    start_time = time.time()

    # Define the root directory for searching
    root_dir = input("Please provide the root directory for searching: ")

    # Define the csv file to write the results to
    csv_filename = input("Please provide the CSV file to write the results to: ")

    update_master_dataset(root_dir, csv_filename)
    
    # plot_from_dataset(csv_filename)

    print(f"TOTAL RUNTIME --- {time.time() - start_time} seconds ---")


