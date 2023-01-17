#################################################################################################
#Reads in dataframes of detected PSWEs and creates topographies representing channels involved
#in PSWEs

#Author: Lindsey Power (May 2022)
#################################################################################################

#imports
import mne
import os
import numpy as np
import pandas as pd

#Reads in dataframes and splits participants into low and widespread groups
dataDir = '/media/NAS/lpower/PSWE/camcan_controls/'
camcanCSV = dataDir + 'PSWE_allEvents_controls_behavioural_homeint_noSingleChan_headposRemoved2_data.csv'

camcanData = pd.read_csv(camcanCSV)
subjects = np.unique(camcanData['Subject'].tolist())
low_evs = camcanData[camcanData['Region.Count']<5]
high_evs = camcanData[camcanData['Region.Count']>=5]

rawFile =  '/home/timb/camcan/megData_moveComp/CC110037/rest/transdef_mf2pt2_rest_raw.fif'
raw = mne.io.Raw(rawFile, preload=True)
raw.pick_types(meg=True)
channels = np.asarray(raw.info['ch_names'])

#Function to convert string data in dataframe to an array
def toArray(string):
    lst = string.split()
    if lst[0] == "[":
        lst = lst[1:]
    if lst[-1] == "]":
        lst = lst[:-1]
    str_list = []
    for x in lst:
        x = x.replace("[","")
        x = x.replace("]","")
        x = x.replace("\'","")

        str_list.append(x)

    array = np.asarray(str_list)
    
    return array


### OVERALL EVS ###
chan_counts = np.zeros(len(channels))

#Find how many active channels for all events 
for chans in camcanData['Chan.List']:
    chan_array = toArray(chans)
    for chan in chan_array:
        ind = np.where(channels == chan)[0][0]
        chan_counts[ind] = chan_counts[ind]+1

chan_counts = chan_counts.reshape(306,1)

#Create a plot from the channel count data 
NumEventsEvoked= mne.EvokedArray(chan_counts*1e-15, raw.info)
numFig = NumEventsEvoked.plot_topomap(times=[0.0], vmin=np.min(chan_counts), vmax=np.max(chan_counts),cmap='jet', outlines='head', contours=0, res=200, size=5)

#save figure 
figPath = '/media/NAS/lpower/PSWE/camcan_controls/'
numFig.savefig(figPath + 'numEventsTopo_overall')

### LOW EVS MAP ### 
chan_counts = np.zeros(len(channels))

#Find how many active channels for lowspread events only 
for chans in low_evs['Chan.List']:
    chan_array = toArray(chans)
    for chan in chan_array:
        ind = np.where(channels == chan)[0][0]
        chan_counts[ind] = chan_counts[ind]+1

chan_counts = chan_counts.reshape(306,1)

#Create a plot from the channel count data 
NumEventsEvoked= mne.EvokedArray(chan_counts*1e-15, raw.info)
magFig = NumEventsEvoked.plot_topomap(times=[0.0],cmap='jet', vmin=0, vmax=10, outlines='head', contours=0, res=200, size=5, ch_type='mag')

NumEventsEvoked= mne.EvokedArray(chan_counts*1e-15, raw.info)
grad1Fig = NumEventsEvoked.plot_topomap(times=[0.0], cmap='jet', vmin=0, vmax=0.1, outlines='head', contours=0, res=200, size=5, ch_type='grad')

#save figure 
figPath = '/media/NAS/lpower/PSWE/camcan_controls/'
magFig.savefig(figPath + 'numEventsTopo_focal_mag')
grad1Fig.savefig(figPath + 'numEventsTopo_focal_grad1')

### HIGH EVS MAP ### 
chan_counts = np.zeros(len(channels))

#Find how many active channels for lowspread events only 
for chans in high_evs['Chan.List']:
    chan_array = toArray(chans)
    for chan in chan_array:
        ind = np.where(channels == chan)[0][0]
        chan_counts[ind] = chan_counts[ind]+1

chan_counts = chan_counts.reshape(306,1)

#Create a plot from the channel count data 
NumEventsEvoked= mne.EvokedArray(chan_counts*1e-15, raw.info)
magFig = NumEventsEvoked.plot_topomap(times=[0.0], cmap='jet', vmin=0, vmax=25, outlines='head', contours=0, res=200, size=5, ch_type='mag')

NumEventsEvoked= mne.EvokedArray(chan_counts*1e-15, raw.info)
grad1Fig = NumEventsEvoked.plot_topomap(times=[0.0],cmap='jet', vmin=0, vmax=0.25, outlines='head', contours=0, res=200, size=5, ch_type='grad')

#save figure 
figPath = '/media/NAS/lpower/PSWE/camcan_controls/'
magFig.savefig(figPath + 'numEventsTopo_diffuse_mag')
grad1Fig.savefig(figPath + 'numEventsTopo_diffuse_grad1')


        
