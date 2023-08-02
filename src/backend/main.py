# Import necessary libraries
from google.cloud import storage
from google.cloud import firestore
from google.cloud import logging
import cv2
import numpy as np
import concurrent.futures
from scipy.signal import filtfilt, butter

def hello_gcs(event, context):
    """
    Google Cloud Function that is triggered by a change to a Cloud Storage bucket.
    This function processes a video file and extracts the heart rate from the video data.

    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """

    def compute_luma(frame, luma_signal):
        """
        Computes the mean luma value for each frame and returns the value.

        Args:
            frame: video frame
            luma_signal: list to store luma value

        Returns:
            luma_signal: updated list with new luma value
        """
        # Conversion of BGR to YCrCb
        img_ycrcb = cv2.cvtColor(frame, cv2.COLOR_BGR2YCrCb)

        # Computation of mean luma
        mean_of_luma = img_ycrcb[..., 0].mean() * -1
        luma_signal.append(mean_of_luma)

        return luma_signal

    def apply_highpass_filter(signal, cutoff, order):
        """
        Applies a high-pass filter to the signal.

        Args:
            signal: Input signal
            cutoff: Cutoff frequency for the filter
            order: Order of the filter

        Returns:
            y: Filtered signal
        """
        # Handle NaN values in the signal
        no_nan_signal = np.array(signal)
        n_nan = 0
        if np.any(np.isnan(signal)):
            n_nan = signal[np.isnan(signal)].shape[0]
            no_nan_signal = signal[~np.isnan(signal)]

        # Define the high-pass filter
        nyq = 0.5 * 120
        normal_cutoff = cutoff / nyq
        b, a = butter(order, normal_cutoff, btype='high', analog=False)
        y = filtfilt(b, a, no_nan_signal)

        # Add back the NaN values
        y = np.concatenate((np.full(n_nan, np.nan), y), axis=0)

        return y

    def process_video_data(video_data):
        """
        Processes video data frame-by-frame and calculates the heart rate.

        Args:
            video_data: The video data as a byte array.

        Returns:
            heart_rate: The calculated heart rate.
        """
        # Convert byte array to numpy array
        video_data = np.asarray(bytearray(video_data), dtype=np.uint8)
        cap = cv2.VideoCapture()
        cap.open(video_data)

        # Get FPS of video
        FPS = cap.get(cv2.CAP_PROP_FPS)

        # List to store luma values
        luma_signal = []

        # Process video frame by frame
        with concurrent.futures.ThreadPoolExecutor() as executor:
            while True:
                ret, frame = cap.read()
                if not ret:
                    break
                executor.submit(compute_luma, frame, luma_signal)

        # Release the video
        cap.release()

        # Select the portion of the signal for processing
        start_recording_values = int(FPS * 3)
        stop_recording_values = int(FPS * 33)
        final_signal = np.array(luma_signal)[start_recording_values:stop_recording_values]

        # Apply high-pass filter
        final_signal = apply_highpass_filter(signal=final_signal, cutoff=0.7, order=2)

        # Perform FFT
        FFT_result = np.fft.fft(final_signal)
        FFT_freq = np.fft.fftfreq(len(final_signal), d=1)

        # Find the index of the maximum amplitude in the positive frequency range
        positive_freq_range = np.where(FFT_freq > 0)
        max_amp_index = np.argmax(np.abs(FFT_result[positive_freq_range]))

        # Calculate heart rate from the frequency
        heart_rate = int(np.abs(FFT_freq[positive_freq_range][max_amp_index]) * 60)

        return heart_rate

    # Extract information from the event
    bucket_name = event['bucket']
    file_name = event['name']

    # Initialize the Cloud Storage client
    storage_client = storage.Client()

    # Get a reference to the video file
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(file_name)

    # Download the video file as a byte array
    video_data = blob.download_as_bytes()
    print(f"Processing file: {file_name}.")

    # Process video data and calculate heart rate
    heart_rate = process_video_data(video_data)

    return heart_rate
