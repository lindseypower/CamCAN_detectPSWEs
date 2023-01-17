#################################################################################################
#Find PSWEs that occur during significant head movements 

#Author: Lindsey Power (November 2022)
#################################################################################################

#imports
import mne #v1.0.3
import numpy as np #v1.21.6
import pandas as pd #v1.3.5
import os 
import matplotlib.pyplot as plt #v3.5.2
import scipy.stats as stats #v1.7.3

#Define list of subjects to loop through
subDir = '/media/NAS/lpower/PSWE/camcan_controls/'
subjects = next(os.walk(subDir))[1]

#Create dataframes to store variance and correlation values 
var_df = pd.DataFrame(columns=['Subject ID', 'q1var', 'q2var', 'q3var','q4var','q5var','q6var', 
                            'pswe_corr','pswe_corr_p','percent_overlap', 'percent_chance', 'percent_diff'])
headpos_p_df = pd.DataFrame(columns=['Subject','headpos_p_val', 'Event.Onset', 'Event.Offset'])

#Read head position and pswe files for each subject to check if there is a correlation between timestamps 
headpos_p_list = []
for subID in subjects: 
    print(subID)
    headpos_file = '/home/timb/camcan/megData_moveComp/' + subID + '/rest/mf2pt2_rest_raw_headposition.pos'
    pswe_file = '/media/NAS/lpower/PSWE/camcan_controls/' + subID + '/' + subID + '_regional_unique_events.csv'
    if os.path.exists(headpos_file):
        headpos_df = pd.read_table(headpos_file, sep='\s+')
        mean_velocity = np.mean(headpos_df['velocity'].tolist())

        #If this participant had pswes, compare to the headpos timestamps of interest 
        if os.path.exists(pswe_file):
            pswe_df = pd.read_csv(pswe_file)
            #for each event check the headposition velocity between the onset and offset of pswe
            for i in range(len(pswe_df)):
                row = pswe_df.iloc[[i]]
                onset = int(row['Event Onset'].tolist()[0])
                offset = int(row['Event Offset'].tolist()[0])
                vels = [] 
                for t in range(onset,offset):
                    if onset > np.min(headpos_df['Time'].tolist()):
                        pos_row = headpos_df[headpos_df['Time']==t]
                        velocity = pos_row['velocity'].tolist()[0]
                        vels.append(velocity)
                #Compare velocity values during pswe to the overall average velocity for the scan 
                if len(vels)>0:
                    t_statistic, headpos_p_value = stats.ttest_1samp(a=vels, popmean=mean_velocity)
                else:
                    headpos_p_value = 1
                p_val_dict = {'Subject': subID, 'headpos_p_val':headpos_p_value, 
                            'Event.Onset': onset, 'Event.Offset': offset}
                headpos_p_df = headpos_p_df.append(p_val_dict, ignore_index=True)     

#Save csv 
output_file = '/media/NAS/lpower/PSWE/camcan_controls/headposition_p_vals.csv'
headpos_p_df.to_csv(output_file)