#################################################################################################
#Reads in dataframes of detected PSWEs and combines overlapping single-channel PSWEs to create
#multi-channel PSWEs 

#Author: Lindsey Power (May 2020)
#################################################################################################

#imports
import pandas as pd #v1.3.5
import numpy as np #v1.21.6
import os

#Define participants of interest
camcanCSV = '/media/NAS/lpower/camcan/oneCSVToRuleThemAll.csv'
subjectData = pd.read_csv(camcanCSV)
subjects = np.unique(np.asarray(subjectData['SubjectID'].tolist()))

#Empty dataframe to hold multi-channel events 
allSubDf = pd.DataFrame(columns= ["Subject","Event Onset","Event Offset","Event Duration","Num Left Frontal","Num Right Frontal","Num Left Parietal","Num Right Parietal","Num Left Temporal","Num Right Temporal","Num Left Occipital","Num Right Occipital","Mean Frequency","Number of Channels","Chan List"])

#Loops through participants and combines overlapping single channel events to form multi-channel events 
count_subs =0
for subID in subjects:
    df_name = '/media/NAS/lpower/PSWE/camcan_controls/' + subID + '/' + subID + '_regional_events.csv'
    print(df_name) 

    if os.path.exists(df_name):
        print(subID)
        print(count_subs)
        count_subs =count_subs+1
        
        df = pd.read_csv(df_name)
        
        if df.empty == False:
            
            #Sort by event onset and pull out each column as a list
            df = df.sort_values(by=['Event Onset'])
            onsets = df['Event Onset'].tolist()
            offsets = df['Event Offset'].tolist()
            regions = df['Region'].tolist()
            frequencies = df['Mean Frequency'].tolist()
            durations = df['Event Duration'].tolist()
            channels = df['Channel'].tolist()
            
            #Loop to determine same events based on onset and offset times 
            count = 0
            ev_label = 0
            ev_list = []
     
            #if the offset of one event is later than the onset of tne next event, they are part of the same event and are labelled as such
            for offset in offsets[:-1]:
                if not (onsets[count + 1] < offset):
                    ev_list.append(ev_label)
                    ev_label = ev_label + 1
                else:
                    ev_list.append(ev_label)
                count = count+1
            ev_list.append(ev_label)
    
            #For each distinct labelled event - average across their event characteristics (onset, offset, frequency, duration) 
            #Also record number of channels involved in the event
            ev_list = np.asarray(ev_list)
            new_events = []
            i = 0
            while i <= max(ev_list):
                inds = np.where(ev_list==i)[0]
                onset = np.min(np.asarray(onsets[inds[0]:inds[-1]+1]))
                offset = np.max(np.asarray(offsets[inds[0]:inds[-1]+1]))
                
                ar, ind = np.unique(np.asarray(channels[inds[0]:inds[-1]+1]),return_index=True)
                regs = np.asarray(regions[inds[0]:inds[-1]+1])
                regs = [regs[i] for i in ind]
                regs = np.asarray(regs)
                
                numChans = len(regs)
                #Create an event only if the number of channels is greater than 1 (single-channel events are likely artefactual)
                if numChans > 1:
                    numL_frontal = len(np.where(regs=="Left Frontal")[0])
                    numR_frontal = len(np.where(regs=="Right Frontal")[0])
                    numL_parietal = len(np.where(regs=="Left Parietal")[0])
                    numR_parietal = len(np.where(regs=="Right Parietal")[0])
                    numL_temporal = len(np.where(regs=="Left Temporal")[0])
                    numR_temporal = len(np.where(regs=="Right Temporal")[0])
                    numL_occipital = len(np.where(regs=="Left Occipital")[0])
                    numR_occipital = len(np.where(regs=="Right Occipital")[0])
                    frequency = np.mean(np.asarray(frequencies[inds[0]:inds[-1]+1]))
                    duration = np.mean(np.asarray(durations[inds[0]:inds[-1]+1]))
                    thisDict ={"Subject": subID, "Event Onset": onset, "Event Offset": offset, "Event Duration": duration,
                        "Num Left Frontal": numL_frontal, "Num Right Frontal": numR_frontal, "Num Left Parietal": numL_parietal,
                        "Num Right Parietal": numR_parietal, "Num Left Temporal": numL_temporal, "Num Right Temporal": numR_temporal,
                        "Num Left Occipital": numL_occipital, "Num Right Occipital": numR_occipital,"Mean Frequency": frequency,
                        "Number of Channels": numChans, "Chan List": ar}
                        new_events.append(thisDict)
                        i = i + 1
            
            #Save dataframe for each participant with multi-channel events
            df = pd.DataFrame(new_events)
            csv_name = '/media/NAS/lpower/PSWE/camcan_controls/' + subID + '/' + subID + '_regional_unique_events.csv'
            df.to_csv(csv_name)

            allSubDf = allSubDf.append(df)

#Save overall dataframe that includes multi-channel events from all subjects
csv_name = '/media/NAS/lpower/PSWE/camcan_controls/all_regional_unique_events.csv'
allSubDf.to_csv(csv_name)
