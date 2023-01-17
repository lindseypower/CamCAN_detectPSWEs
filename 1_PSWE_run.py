#################################################################################################
#Main code used to detect PSWEs in resting state MEG or EEG data
#Outputs a dataframe for each participant containing a list of detected PSWEs

#Adapted from methods by Milikovsky et al., 2019 originally written in MATLAB
#Code translated to python by Lindsey Power: March 2020
#################################################################################################

#imports
import mne #v1.0.3
import numpy as np #v1.21.6
import pandas as pd #v1.3.5
import os
from PSWE_functions import *

#Uses camcanCSV to define participant sample to use
camcanCSV = '/media/NAS/lpower/camcan/oneCSVToRuleThemAll.csv'
subjectData = pd.read_csv(camcanCSV)
subjects = subjectData['SubjectID'].tolist()
age = subjectData['Age_x'].tolist()
hand = subjectData['Hand_x'].tolist()
count = 0 

#Loops through each subject in the sample and detects PSWEs in their MEG data
for subID in subjects:
    #Save dataframe 
    print(count)
    count = count + 1
    csvFname = '/media/NAS/lpower/PSWE/camcan_controls/'+ subID + '/' + subID + '_events.csv'
    
    if not os.path.exists(csvFname):
        print(subID)
        
        #Read in raw resting state data and filter 
        dataDir = '/home/timb/camcan/megData_moveComp/'
        rawFile = dataDir + subID + '/rest/transdef_mf2pt2_rest_raw.fif'
        if os.path.exists(rawFile):
            raw = mne.io.Raw(rawFile, preload=True)
            raw.filter(l_freq=1, h_freq=50)
            #raw.notch_filter([50, 100])    
     
            #Create a single epoch out of this data (there are no events, so make some)
            #One 9 minute long epoch starting 30 seconds after start of recording
            evs = mne.make_fixed_length_events(raw, start=15.0, duration=540.0)
            evs = evs[0,:]
            evs = evs.reshape([1,3])
            epochs = mne.Epochs(raw, evs, None, tmin=0, tmax=540.0, verbose=False, preload=True, baseline=(0,0))
         
            #ICA hasn't been performed on this data so do that here 
            icaFif = '/media/NAS/lpower/camcan/spectralEvents/rest/proc_data/' + subID +'/transdef_mf2pt2_rest_raw-ica.fif'
            if os.path.exists(icaFif):
                ica = mne.preprocessing.read_ica(icaFif)
                ica.apply(epochs, exclude=ica.exclude)
         
                epochs.pick_types(meg=True) 
                fs = epochs.info['sfreq']
     
                #epochdata is an array in the form [times x channels]
                epochData = np.squeeze(epochs.get_data()).T
                freqThresh = 6
                lenThresh = 5
                chansN = 2
    
                #calculate PSDs and filter them into bandwidths of interest
                freqs, psds = PSD_calc(epochData, fs)
                deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD = BW_calc(psds, freqs)
     
                #Find PSWEs 
                NperChan,time_in_events_byChan, meanMPF, meanDur_byChan, df, medFreq = PSWE(epochData, fs, freqThresh, lenThresh,deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD, subID, epochs)
    
                #if any(NperChan[0]):
                # Get the info for this reduced dataset
                raw.pick_types(meg=True)
                info = raw.info
     
                # Put your PSWE values into MNE’s “evoked” format
                NumEventsEvoked= mne.EvokedArray(NperChan.T*1e-15, info)
                TimeInEventsEvoked = mne.EvokedArray(time_in_events_byChan.T*1e-15, info)
                MeanFreqEvoked = mne.EvokedArray(meanMPF.T*1e-15, info)
                MeanDurEvoked = mne.EvokedArray(meanDur_byChan.T*1e-15, info)
    
                # In this new variable, “time” is actually the meaningless, but I think it starts at t=0.0
                # Now plot your data as a topography
                numFig = NumEventsEvoked.plot_topomap(times=[0.0], vmin=np.min(NperChan), vmax=np.max(NperChan)/2, cmap='jet', cbar_fmt='%3.3f')
                timeFig = TimeInEventsEvoked.plot_topomap(times=[0.0], vmin=np.min(time_in_events_byChan), vmax=np.max(time_in_events_byChan)/2, cmap='jet', cbar_fmt='%3.3f')
                freqFig = MeanFreqEvoked.plot_topomap(times=[0.0], vmin=np.min(meanMPF), vmax=np.max(meanMPF), cmap='jet', cbar_fmt='%3.3f')
                durFig = MeanDurEvoked.plot_topomap(times=[0.0], vmin=np.min(meanDur_byChan), vmax=np.max(meanDur_byChan), cmap='jet', cbar_fmt='%3.3f')
     
                figPath = '/media/NAS/lpower/PSWE/camcan_controls/'+ subID
                if not os.path.exists(figPath):
                    os.mkdir(figPath)
                numFig.savefig(figPath + '/' + subID + 'numEventsTopo')
                timeFig.savefig(figPath+ '/' + subID + 'timeEventsTopo')
                freqFig.savefig(figPath+ '/' + subID + 'freqEventsTopo')
                durFig.savefig(figPath+ '/' + subID + 'durEventsTopo')
     
                #Save dataframe 
                csvPath = '/media/NAS/lpower/PSWE/camcan_controls/'+ subID
                if not os.path.exists(csvPath):
                    os.mkdir(csvPath)
                csvFname = csvPath + '/' + subID + '_events.csv'
                df.to_csv(csvFname)

