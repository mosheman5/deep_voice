import sys
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from scipy.signal import fftconvolve
import IPython
import pyroomacoustics as pra
import soundfile
import sounddevice as sd

plt.rcParams['font.size'] = 20
plt.rcParams['xtick.labelsize'] = 15
plt.rcParams['ytick.labelsize'] = 15

import librosa
import librosa.display
import samplerate

from scipy import signal

import pyroomacoustics as pra
from pyroomacoustics.doa import circ_dist

import pandas as pd

import time

from doa_lib import *

import argparse

parser = argparse.ArgumentParser(description='Perform DOA on tagged signals')
parser.add_argument('tag_file', type=str,
                    help='tag file to use')
parser.add_argument('rec_path', type=str,
                help='folder of that days recordings')
parser.add_argument('-p' ,'--play', action='store_true',
                    help='play the sounds in the tagging file with bottom as right channel')

args = parser.parse_args()
tagging_file =  args.tag_file
rec_path = args.rec_path

if (tagging_file.find('ZOOM') is not -1):
    file_name = tagging_file[tagging_file.find('ZOOM'):].split('_')[0]
else:
    raise(Exception('tagging is not of Zoom file'))
        
upper_hydrophone_file = os.path.join(rec_path,file_name, file_name + '_Tr2.WAV')
lower_hydrophone_file = os.path.join(rec_path,file_name, file_name + '_Tr1.WAV')

if not (os.path.exists(upper_hydrophone_file) and os.path.exists(lower_hydrophone_file)):
    print(upper_hydrophone_file)
    print(lower_hydrophone_file)
    raise(Exception('Zoom file does not exist or Tr1 or Tr2 are missing'))

algo_name = 'MUSIC'
play_sig = args.play

# rec time and length
time_start_file = int(tagging_file.split('(')[1].split(',')[1])

with open(tagging_file, 'r') as f:
    line_list = f.readlines()
    
def norm(data):
    return data/np.sqrt(np.sum(data**2))

start_tag = True
tag_list = []
for line in line_list:
    if line.startswith('high'):
        break
    if start_tag:
        tag_dict = {'low':float(line.split(' ')[0]), 'high':float(line.split(' ')[1]), 'start':0, 'stop':0}
        start_tag = False
    else:
        tag_dict['start'] = time_start_file + float(line.split(' ')[0])
        tag_dict['stop'] = time_start_file + float(line.split(' ')[1])
        tag_list.append(tag_dict)
        start_tag = True
        
# array parameters
length = 0.41
depth = 5
r_rec = np.c_[
             [5000, depth+length/2., 5000],  # mic upper,
             [5000, depth-length/2., 5000]  # mic lower,
              ]

# source angle
azimuth = [-0.982793723247329]

# fft params
nfft = 1024*4
overlap_ratio = 4

# from here: code!
for tag_dict in tag_list:

    time_vec = [tag_dict['start'], tag_dict['stop']]

    data_upper, fs = read_sound(upper_hydrophone_file, time=time_vec)

    data_lower, fs = read_sound(lower_hydrophone_file, time=time_vec)

    # normalize powers
    rec_signal_noised = [norm(data) for data in [data_upper, data_lower]]
#     rec_signal_noised = [data_upper, data_lower] # unnormalzied

    X = np.array([produce_spect_for_music(channel_sig, nfft=nfft, overlap_ratio=overlap_ratio, fft_type='stft')
                  for channel_sig in rec_signal_noised])

    doa = locate_source(X, r_rec, fs, nfft, algo_name, freq_range = [tag_dict['low'], tag_dict['high']])
    DOA_angle = calc_doa(doa, algo_name)
    DOA_angle = DOA_angle*180/np.pi
    if DOA_angle > 180:
        DOA_angle = DOA_angle - 360
    print(DOA_angle)

    if play_sig:
        sd.play(np.concatenate(
                tuple((norm(data).reshape(1,-1) for data in [data_lower, data_upper])),
                axis=0).T, samplerate=fs)
        status = sd.wait()
        if status:
            parser.exit('Error during playback: ' + str(status))
        time.sleep(1)
    #     plt.clim(clim)