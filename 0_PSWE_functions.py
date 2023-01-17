#################################################################################################
#Script containing functions used to detect PSWEs in resting state MEG or EEG data

#Adapted from methods by Milikovsky et al., 2019 originally written in MATLAB
#Code translated to python by Lindsey Power: March 2020
#################################################################################################

#imports
import mne #v1.0.3
import numpy as np #v1.21.6
import more_itertools as mit #v9.0.0
import scipy.signal as ss #v1.7.3
import matplotlib.pyplot as plt #v3.5.2
import math
import pandas as pd #v1.3.5

#################################################################################################
#Function to calculate PSD 

#Arguments: 
#data: MEG or EEG time series data (array of shape [times x channels])
#fs: sampling frequency (int)

#Outputs:
#target_psds: PSDs of interest (ndarray)
#target_freqs: frequencies associated with PSD (ndarray)


def PSD_calc(data, fs):
    #Specify FFT parameters
    def nextpow2(i):
        n = 1
        while n < i: n *= 2
        return n
    
    n_fft = nextpow2(len(data))  #best to have an exact power of 2 for fft so specify the next smallest power of 2 greater than the data length
    
    #run the psd welch method which retuns psds and frequency values 
    freqs, psds = ss.welch(data.T, fs=fs, nfft=8192) #too much data to use above method - this gives about 0.2Hz resolution (as of now, use 2048 for lupus and 8192 for camcan)
    
    #limit PSD values to frequencies between 1 and 50Hz
    i_min = 0
    i_max = 0
    for x in freqs:
        if x < 1:
            i_min+=1
        if x < 50:
            i_max+=1 
    target_freqs = freqs[i_min:i_max]
    target_psds = psds[:,i_min:i_max]
    
    #function outputs
    return target_freqs, target_psds
######################################################################################################
    
######################################################################################################
#Function to calculate PSDs for specific bandwidths (frequency ranges)

#Arguments: 
#psds: PSDs calculated in PSD_calc function (ndarray)
#freqs: freqs calculates in PSD_calc function (ndarray)

#Outputs:
#PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

def BW_calc(psds, freqs): 
    #Set upper and lower limits for each frequency range
    delta = [1,3]
    theta = [3,8]
    alpha = [8,12]
    beta = [12,20]
    gamma = [20,50]
    pswe = [1,6]
    
    #function to find psds in the frequency range of interest
    def find_target_psds(range):
        i_min = 0
        i_max = 0
        for x in freqs:
            if x < range[0]:
                i_min+=1
            if x < range[1]:
                i_max+=1 
        target_psds = psds[:,i_min:i_max]
        
        return target_psds
        
    #Find the target psds for all frequency ranges of interest
    deltaPSD = find_target_psds(delta)
    thetaPSD = find_target_psds(theta)
    alphaPSD = find_target_psds(alpha)
    betaPSD = find_target_psds(beta)
    gammaPSD = find_target_psds(gamma)
    pswePSD = find_target_psds(pswe)
    
    #function outputs
    return deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD
########################################################################################################

########################################################################################################
#Function to compute the median power frequency (MPF) used to identify PSWEs 

#Arguments: 
#data: MEG or EEG time series data (array of shape [times x channels])
#fs: sampling frequency (int)
#PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

#Outputs:
#medFreq: vector of MPF values for each second of time data (ndarray)
#PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

def MPF(data, fs, deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD):
    #create 2s windows with 1s overlap 
    windows = np.asarray(list(mit.windowed(data, n=int(fs*2), step=int(fs))))#Try 1 s windows with 0.5 s overlap
    #delcare arrays to hold a median frequency and powers for each window
    medFreq = np.zeros(windows.shape[0])
    deltaPSD = np.zeros([windows.shape[0],deltaPSD.shape[1]])
    thetaPSD = np.zeros([windows.shape[0],thetaPSD.shape[1]])
    alphaPSD = np.zeros([windows.shape[0],alphaPSD.shape[1]])
    betaPSD = np.zeros([windows.shape[0],betaPSD.shape[1]])
    gammaPSD = np.zeros([windows.shape[0],gammaPSD.shape[1]])
    pswePSD = np.zeros([windows.shape[0],pswePSD.shape[1]])
    
    #Find PSD for each window
    for i in range(1,windows.shape[0]-1):
        y = np.asarray(list(windows[i,:]))
        y = y.reshape([windows.shape[1],1])
        freqs, psds = PSD_calc(y,fs)
        s_PSD = np.sum(psds) #sum across all psds in this window
        
        #Find the median frequency for each window (defined as the point where the cumulative sum is greater than 1/2 total sum)
        cum_sum = np.cumsum(psds) 
        if len((np.where(cum_sum>s_PSD/2)[0]))>0:
            medFreq[i] = freqs[np.where(cum_sum>s_PSD/2)[0][0]]
        else:
            medFreq[i] = 0
        
        #Calculate the power spectrum for each bandwidth of interest
        deltaPSD[i],thetaPSD[i],alphaPSD[i],betaPSD[i],gammaPSD[i],pswePSD[i] = BW_calc(psds,freqs)
    
    #plot the median power frequency      
    #plt.figure()
    #times = np.arange(0,medFreq.shape[0])
    #plt.plot(times, medFreq)
    #plt.show()
    #Returns median power frequency and 6 power values(for each bandwidth)
    return medFreq, deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD
################################################################################################################

################################################################################################################
#Main PSWE detection function (per channel) 

#Arguments: 
#data: MEG or EEG time series data (array of shape [times x channels])
#fs: sampling frequency (int)
#freqThresh: maximum frequency of PSWEs (int)
#lenThresh: minimum duration of PSWEs (int)
#PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

#Outputs:
#num_of_events: number of PSWEs detected at each channel (array [1 x channels])
#time_in_events: percent of recording spent in PSWE (array [1 x channels]) 
#meanFreq: average PSWE frequency at each channel (array [1 x channels])
#meanDur: average PSWE duration at each channel (array [1 x channels])
#df: dataframe containing information about each event (onset, offset, duration, mean frequency, channel, subject)
#medFreq: vector of MPF values for each second of time data (ndarray)

def PSWE(data, fs, freqThresh, lenThresh, deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD, subID, labels):
    
    #If the data is a row vector, transpose to a column vector
    if (np.shape(data)[0]<=np.shape(data)[1]):
        data = np.transpose(data)
        
    #Pre-allocate outputs of the function 
    num_of_events = np.zeros([1,np.shape(data)[1]])
    time_in_events = np.zeros([1,np.shape(data)[1]])
    meanFreq = np.zeros([1,np.shape(data)[1]])
    meanDur = np.zeros([1,np.shape(data)[1]])
    listofDicts = [] #To create pandas dataframe of events
    
    #For all channels 
    for j in range(0,np.shape(data)[1]):
        print(j)
        print(data[:,j].shape)
        print(data[:,j])
        
        #Find the median power frequency for each of N windows (by calling MPF function)
        #Each windowed segment is then run through the PSD_calc and BW_calc function and the MPF and powers are returned for each segment
        medFreq, deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD = MPF(data[:,j],fs, deltaPSD, thetaPSD, alphaPSD, betaPSD, gammaPSD, pswePSD)
        print ('MEdFreq:')
        print(medFreq.shape)
        print(np.partition(medFreq, 3)[3])
        print(np.mean(medFreq))
        print(np.where((medFreq<6) & (medFreq>1)))
        #Tim's code
        PSWEfreqs = []
        PSWEoffsetIndex = []
        PSWEDurationSamples = []
        a = medFreq < freqThresh
        b = medFreq >= 1
        targetBand = a*b

        targetBand_diff = np.diff(1*targetBand)
        eventStartInd = np.where(targetBand_diff==1)[0]
        eventEndInd = np.where(targetBand_diff==-1)[0]
        
        if len(eventStartInd) > 0 and len(eventEndInd) > 0:
            firstStart = eventStartInd[0]
            firstEnd = eventEndInd[0]

            if firstStart>firstEnd:
                eventEndInd = eventEndInd[1::]

            starts = len(eventStartInd)
            ends = len(eventEndInd)
            minLength = np.min([starts, ends])

            if not (starts==ends):
                eventStartInd = eventStartInd[0:minLength]
                eventEndInd = eventEndInd[0:minLength]

            eventDur = eventEndInd-eventStartInd
            longEventIndex = np.where(eventDur>=(lenThresh))[0]#I had multiplied by 2 here 
            PSWEonsetIndex = eventStartInd[longEventIndex] + 1  # I think we need to add 1 to correct for translation due to np.diff
            PSWEDurationSamples = eventDur[longEventIndex]
            
            #plt.plot(medFreq)
            #plt.plot(targetBand)

            for (thisOnset, thisDuration) in zip(PSWEonsetIndex, PSWEDurationSamples):
            
                thisStart = thisOnset
                thisEnd = thisOnset + thisDuration - 1
                #plt.axvline(x=thisStart)
                #plt.axvline(x=thisEnd)
                thisMedFreq = medFreq[thisStart:thisEnd]
                PSWEfreqs.append(np.mean(thisMedFreq))
                PSWEoffsetIndex.append(thisEnd)
                thisDict = {"Subject": subID, "Channel": labels.ch_names[j], "Event Onset": thisStart, 
                "Event Offset": thisEnd, "Event Duration": thisDuration, "Mean Frequency": np.mean(thisMedFreq)}
                listofDicts.append(thisDict)
                print(thisDict)
                
            
        #After all segments are analysed - update output vectors with results 
        num_of_events[0,j] = len(PSWEfreqs)
        time_in_events[0,j] = np.sum(PSWEDurationSamples)/len(medFreq) #Percent of total data length
        meanFreq_curr = np.mean(PSWEfreqs)
        if math.isnan(meanFreq_curr):
            meanFreq_curr = 0 
        meanFreq[0,j] = meanFreq_curr
        meanDur_curr = np.mean(PSWEDurationSamples)
        if math.isnan(meanDur_curr):
            meanDur_curr = 0 
        meanDur[0,j] = meanDur_curr
    
    #make dataframe for every event
    df = pd.DataFrame(listofDicts)
    
    #Returns for the PSWE function
    return num_of_events,time_in_events, meanFreq, meanDur, df, medFreq
##############################################################################################################
