from scipy.signal import lfilter, filtfilt, butter
import numpy as np


class SignalPreprocessor():
    def __init__(self, sample_rate=120):
        self.sample_rate = sample_rate

    def rolling_average(self, signal):
        """Computes the rolling average of the signal."""
        window_size_seconds = 0.5
        window_size = int(window_size_seconds * self.sample_rate)
        if window_size % 2 == 0:
            window_size += 1
        y = np.convolve(signal, np.ones(window_size), 'valid') / window_size
        y = np.pad(y, [((window_size - 1) // 2, (window_size - 1) // 2)], mode='edge')
        return y

    def butter_lowpass_filter(self, signal, low, filter_order):
        """Apply a lowpass butterworth filter to the signal."""
        nyq = 0.5 * self.sample_rate
        normal_cutoff = low / nyq
        b, a = butter(filter_order, normal_cutoff, btype='low', analog=False)
        y = lfilter(b, a, signal)
        return y

    def butter_highpass_filter(self, signal, cutoff, order):
        """Apply a highpass butterworth filter to the signal."""
        no_nan_signal = np.array(signal)
        n_nan = 0
        if np.any(np.isnan(signal)):
            n_nan = signal[np.isnan(signal)].shape[0]
            no_nan_signal = signal[~np.isnan(signal)]
        nyq = 0.5 * self.sample_rate
        normal_cutoff = cutoff / nyq
        b, a = butter(order, normal_cutoff, btype='high', analog=False)
        y = filtfilt(b, a, no_nan_signal)
        y = np.concatenate((np.full(n_nan, np.nan), y), axis=0)
        return y
