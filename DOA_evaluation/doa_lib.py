import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.signal import fftconvolve
import IPython
import pyroomacoustics as pra
import soundfile

import librosa
import librosa.display
import samplerate

from scipy import signal

import pyroomacoustics as pra
from pyroomacoustics.doa import circ_dist

import pandas as pd
import os


scale_fact = 10000


def read_sound(file_name, time=[231, 245], channel = 0):
    data, fs = soundfile.read(file_name, stop=10)
    data, fs = soundfile.read(file_name, start=time[0]*fs, stop=time[1]*fs)
    
    data = data[:,0]
    
    return data, fs


def spect(data, fs, fmin=100, fmax = 1000, nfft_ratio=11, overlap_ratio=16, Gain = 35, figsize=(15, 10)):

       
    # Simple API
    nfft=int(1024*nfft_ratio)

    X = librosa.stft(data, n_fft=nfft, hop_length=int(nfft/(overlap_ratio*1.)))

    Xdb = librosa.amplitude_to_db(abs(X))
    
    Y = np.copy(Xdb)
    Y[:int(X.shape[0]*2*fmin/(fs)),:] = 0
    Y = Y[:int(X.shape[0]*(fmax*2./(fs))), :]
    vmin = Y.min()
    vmax = Y.max()
#     print(vmin, vmax)
    
    plt.figure(figsize=figsize)
    librosa.display.specshow(Xdb, sr=fs, x_axis='time', y_axis='hz', cmap='inferno')
    plt.ylim([fmin, fmax])
    plt.clim(vmin=-30, vmax=10)
    
    
def sim_room(signal, fs, room_dim = [10000, 10000, 10000], r_source=[5005, 7.5, 5000],
             r_rec=np.c_[
    [5000, 5, 5000],  # mic 1
    [5000, 10, 5000],  # mic 2
    ], **kwargs):
    
    if 'max_order' in kwargs.keys():
        max_order = kwargs['max_order']
    else:
        max_order = 5
    
    if 'absorption' in kwargs.keys():
        absorption = kwargs['absorption']
    else:
        absorption = 0.5
        
    room_dim = np.array(room_dim)/scale_fact
    r_source = np.array(r_source)/scale_fact
    r_rec = np.array(r_rec)/scale_fact
    
    aroom = pra.ShoeBox(room_dim, fs=fs, max_order=max_order, absorption=absorption)
    aroom.add_source(r_source, signal=signal)
    mic_array = pra.MicrophoneArray(r_rec, aroom.fs)
    aroom.add_microphone_array(mic_array)

#     aroom.plot()
    
    aroom.compute_rir()
    aroom.simulate()
    
    out_signal = aroom.mic_array.signals
    
    # normalize to originl sound levels
    org_ENR = np.sum(signal**2)
    new_ENR = np.sum(out_signal**2, axis=1).max()
    
    return np.sqrt(org_ENR/new_ENR)*out_signal


def add_noise(signal_dual, SNR=0, noise_location_doc='silence_180910_142834.txt', noise_id=(0,1)):
    """ add noise to dual channal signal at two recievers
    :param SNR: SNR relative to signal[0]
    :param noise_location_doc: the txt file containing the noise locations in the file
    :param noise_id: rows to use in file to extract noise
    """
    
    file_name = os.path.join('../recordings', '_'.join('silence_180910_142834.txt'.split('_')[1:3])[:-3] + 'wav')
    
    sea_noise_times = pd.read_csv(noise_location_doc, sep=' ', header=None).values
    noise_data_1, _ = read_sound(file_name, sea_noise_times[0, :])
    noise_data_2, _ = read_sound(file_name, sea_noise_times[1, :])
    noise_data = np.concatenate((noise_data_1.reshape(1,-1), noise_data_2.reshape(1,-1)), axis=0)
    
    # cut signal and noise to the length of the shortest of them
    final_signal_length = min(signal_dual.shape[1], noise_data.shape[1])
    
    noise_data = noise_data[:, :final_signal_length]
    signal_dual = signal_dual[:, :final_signal_length]
    
    ENR_sig = np.sum(signal_dual**2, axis=1, keepdims=True)
    ENR_noise = np.sum(noise_data**2, axis=1, keepdims=True)
    
    total_sig_noise = np.sqrt(10**(SNR/10))*(signal_dual / np.sqrt(ENR_sig.max())) + (noise_data / np.sqrt(ENR_noise))
    
    noised_signal = total_sig_noise / np.sqrt(np.sum(total_sig_noise**2, axis=1, keepdims=True)).max()
    
    return noised_signal


def produce_spect_for_music(signal, nfft=1024, overlap_ratio=1, fft_type='rfft'):
    if fft_type == 'rfft':
        X = pra.stft(signal, nfft, hop=int(nfft/(overlap_ratio*1.)), transform=np.fft.rfft).T 
    elif fft_type == 'stft':
        X = librosa.stft(signal, n_fft=nfft, hop_length=int(nfft/(overlap_ratio*1.)))
    else:
        raise(Exception('fft_type not legal'))
    return X


def locate_source(X, r_rec, fs, nfft, algo_name, freq_range = [200., 1000.]):
    r_rec_doa = r_rec/scale_fact
    doa = pra.doa.algorithms[algo_name](r_rec_doa, fs, nfft=nfft, c=1500/scale_fact, mode='near')
    doa.locate_sources(X, freq_range=freq_range)
    return doa


def plot_doa(doa, azimuth, algo_name):
    spatial_resp = dict()
    spatial_resp[algo_name] = doa.grid.values

    # normalize   
    min_val = spatial_resp[algo_name].min()
    max_val = spatial_resp[algo_name].max()
    spatial_resp[algo_name] = (spatial_resp[algo_name] - min_val) / (max_val - min_val)

    # plotting param
    base = 1.
    height = 10.
    true_col = [0, 0, 0]

    # loop through algos
    phi_plt = doa.grid.azimuth

    # plot
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='polar')
    c_phi_plt = np.r_[phi_plt, phi_plt[0]]
    c_dirty_img = np.r_[spatial_resp[algo_name], spatial_resp[algo_name][0]]
    ax.plot(c_phi_plt, base + height * c_dirty_img, linewidth=3,
            alpha=0.55, linestyle='-',
            label="spatial spectrum")
    plt.title(algo_name)

    # plot true loc
    for angle in azimuth:
        ax.plot([angle, angle], [base, base + height], linewidth=3, linestyle='--',
            color=true_col, alpha=0.6)
    K = len(azimuth)
    ax.scatter(azimuth, base + height*np.ones(K), c=np.tile(true_col,
               (K, 1)), s=500, alpha=0.75, marker='*',
               linewidths=0,
               label='true locations')

    plt.legend()
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles, labels, framealpha=0.5,
              scatterpoints=1, loc='upper left', fontsize=16,
              ncol=1, bbox_to_anchor=(1.6, 0.5),
              handletextpad=.2, columnspacing=1.7, labelspacing=0.1)

    ax.set_xticks(np.linspace(0, 2 * np.pi, num=12, endpoint=False))
    ax.xaxis.set_label_coords(0.5, -0.11)
    ax.set_yticks(np.linspace(0, 1, 2))
    ax.xaxis.grid(b=True, color=[0.3, 0.3, 0.3], linestyle=':')
    ax.yaxis.grid(b=True, color=[0.3, 0.3, 0.3], linestyle='--')
    ax.set_ylim([0, 1.05 * (base + height)]);

    plt.show()
