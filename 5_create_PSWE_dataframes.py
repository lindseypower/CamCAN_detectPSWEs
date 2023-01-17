#################################################################################################
#Take information from PSWE dataframes and create 2 summary dataframes (one with a row for 
#each PSWE and one with a row per participant)

#Author: Lindsey Power (May 2020)
#################################################################################################

# Import libraries
import os
import numpy as np #v1.21.6
import pandas as pd #v1.3.5

camcanCSV = '/media/NAS/lpower/camcan/oneCSVToRuleThemAll.csv'
subjectData = pd.read_csv(camcanCSV)
subjects = subjectData['SubjectID'].tolist()
ages = subjectData['Age_x'].tolist()

# Paths and variables
homeDir = '/media/NAS/lpower'
dataDir = homeDir + '/PSWE/camcan_controls/'
avgEvsCSV = dataDir + 'PSWE_averageEvents.csv'
allEvsCSV = dataDir + 'PSWE_allEvents.csv'
unique_listOfDicts = []
listOfEvents = []
i = 0

for subID in subjects:
    uniqueEvsCSV = dataDir + subID + '/' + subID + '_regional_unique_events.csv'
    
    if os.path.exists(uniqueEvsCSV):
        
        # read in first subject's data and record average event characteristics
        subjectData = pd.read_csv(uniqueEvsCSV)

        #concatenate dataframes for individual events to create masterlist of events
        interval_list = []
        onsets = subjectData['Event Onset'].tolist()
        for j in range (0, len(onsets)-1):
            onset_interval = onsets[j+1]-onsets[j]
            interval_list.append(onset_interval)
        interval_list.append(0)
        subjectData['Inter-onset Interval'] = interval_list
        subjectData['Age'] = [ages[i]]*len(onsets)
        print(ages[i])
        print(i)
        listOfEvents.append(subjectData)
       
        numEvents = len(subjectData)
        burstRate = numEvents/14 #bursts/minute
        avgFreq = np.mean(np.asarray(subjectData['Mean Frequency'].tolist()))
        avgDur = np.mean(np.asarray(subjectData['Event Duration'].tolist()))
        avgChans = np.mean(np.asarray(subjectData['Number of Channels'].tolist()))
        avgInterval = np.mean(np.asarray(subjectData['Inter-onset Interval'].tolist()))
        
        thisDict ={"Subject": subID,"Age": ages[i], "Average Duration": avgDur, "Average Number of Channels": avgChans, 
                "Average Event Frequency": avgFreq, "Number of Events": numEvents, "Burst Rate": burstRate, "Average Onset Interval": avgInterval} 
        unique_listOfDicts.append(thisDict)
            
    elif os.path.exists(dataDir + subID): 
       
       thisDict ={"Subject": subID,"Age": ages[i], "Average Duration": 0, "Average Number of Channels": 0, 
               "Average Event Frequency": 0, "Number of Events": 0, "Burst Rate": 0, "Average Onset Interval": 0} 
       unique_listOfDicts.append(thisDict)
    
    i=i+1

#Create output CSVs 
Events_df = pd.concat(listOfEvents)
Events_df.to_csv(allEvsCSV)

Averages_df = pd.DataFrame(unique_listOfDicts)
Averages_df.to_csv(avgEvsCSV)
