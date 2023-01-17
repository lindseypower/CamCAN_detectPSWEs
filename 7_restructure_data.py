#################################################################################################
#Removes PSWEs associated with head movements from the dataframe

#Author: Lindsey Power (May 2022)
#################################################################################################

import numpy as np #v1.21.6
import pandas as pd #v1.3.5

data_dir = '/Users/lindseypower/Dropbox/PhD/Research Question 2A - PSWE Detection/'

#Merging two dataframes based on their columns
file1 = dataDir + 'headposition_p_vals.csv'
file2 = dataDir + 'PSWE_allEvents_controls_behaviouralData.csv'
data1 = pd.read_csv(file1)
data2 = pd.read_csv(file2)
new_data = data2.merge(data1, on=['Subject', 'Event.Onset','Event.Offset'], how='outer')
out_file = dataDir +'PSWE_allEvents_controls_behavioural_homeint_noSingleChan_headpos_data.csv'
new_data.to_csv(out_file)

#Remove significant headpos rows
p_thresh = 0.05/len(new_data)
no_sig_data = new_data[new_data['headpos_p_val']>=p_thresh]
out_file = dataDir +'PSWE_allEvents_controls_behavioural_headposRemoved_data.csv'
no_sig_data.to_csv(out_file)

