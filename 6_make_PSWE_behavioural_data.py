#################################################################################################
#Add behavioural (i.e., cognitive) data to the dataframe of PSWEs 

#Author: Lindsey Power (May 2022)
#################################################################################################

import numpy as np #v1.21.6
import pandas as pd #v1.3.5

data_dir = '/Users/lindseypower/Dropbox/PhD/Research Question 2A - PSWE Detection/'

#Read in PSWE data from camcan subjects
PSWE_file =  data_dir + 'Data_May2022/PSWE_allEvents.csv'
PSWE_data = pd.read_csv(PSWE_file)
subjects = PSWE_data['Subject'].tolist()
print(PSWE_data)

#Loop through all the subjects in the PSWE data and find their corresponding scores in the behavioural task
#Create a dataframe conraining all the scores that matches the length and participant order of the PSWE data
def get_scores(data, ID, score):
    scores = pd.DataFrame(columns=[score])
    count = 1
    for sub in subjects: 
        line = data[data[ID]==sub]
        line = line[[score]]
        if line.empty:
            line = pd.DataFrame({'Score':[np.nan]},columns=['Score'])
        scores = scores.append(line)
        count = count + 1
    
    scores = scores[score].tolist()
    return scores
    
#Function to calculate the z score for each participant
def get_zscores(scores, mean, std):
    zscores = []
    for score in scores: 
        if np.isnan(score):
            z = np.nan
        else:
            z = (score - mean)/std
        zscores.append(z)
    return zscores

#Function to calculate the mean and standard deviation and call z_score function 
def calculate_z(PSWE_data, task_scores, task_z):    

    mean = np.nanmean(PSWE_data[task_scores])
    std = np.nanstd(PSWE_data[task_scores])
    zscores = get_zscores(PSWE_data[task_scores], mean, std)
    PSWE_data[task_z] = zscores
    
    return PSWE_data
    
### Tip of Tongue Task ###
TOT_file = data_dir + '/Behavioural_data/TOT_summary.csv'
TOT_data = pd.read_csv(TOT_file)

TOT_scores = get_scores(TOT_data, 'Subject', 'ToT_ratio')
PSWE_data['TOT Score'] = TOT_scores
PSWE_data = calculate_z(PSWE_data, 'TOT Score', 'TOT Z')
PSWE_data['TOT Z'] = -PSWE_data['TOT Z'] #Flip sign because lower score is better

### Picture Naming Task ###
picNaming_file = data_dir + '/Behavioural_data/PictureNaming_summary.csv'
picNaming_data = pd.read_csv(picNaming_file)

picNaming_scores = get_scores(picNaming_data, 'Subject', 'ncorrect')
PSWE_data['PicNaming Score'] = picNaming_scores
PSWE_data = calculate_z(PSWE_data, 'PicNaming Score', 'PicNaming Z')

### Visual Short Term Memory Task ###
VSTM_file = data_dir + '/Behavioural_data/VSTMcolour_summary.csv'
VSTM_data = pd.read_csv(VSTM_file)

VSTM_scores = get_scores(VSTM_data, 'CCID', 'K_ss4')
PSWE_data['VSTM Score'] = VSTM_scores
PSWE_data = calculate_z(PSWE_data, 'VSTM Score', 'VSTM Z')

### Familiar Face Recognition Task ###
FamousFaces_file = data_dir + '/Behavioural_data/FamousFaces_summary.csv'
FamousFaces_data = pd.read_csv(FamousFaces_file)

FamousFaces_scores = get_scores(FamousFaces_data, 'CCID', 'Accuracy')
FamousFaces_scores = [float(x) for x in FamousFaces_scores] 
PSWE_data['Famous Face Score'] = FamousFaces_scores
PSWE_data = calculate_z(PSWE_data, 'Famous Face Score', 'Famous Face Z')

### Unfamiliar Face Recognition Task ###
BentonFaces_file = data_dir + '/Behavioural_data/BentonFaces_summary.csv'
BentonFaces_data = pd.read_csv(BentonFaces_file)

BentonFaces_scores = get_scores(BentonFaces_data, 'CCID', 'TotalScore')
PSWE_data['Unfamiliar Face Score'] = BentonFaces_scores
PSWE_data = calculate_z(PSWE_data, 'Unfamiliar Face Score', 'Unfamiliar Face Z')

### Fluid Intelligence Task ###
FluidIntelligence_file = data_dir + '/Behavioural_data/FluidIntelligence_summary.csv'
FluidIntelligence_data = pd.read_csv(FluidIntelligence_file)

FluidIntelligence_scores = get_scores(FluidIntelligence_data, 'CCID', 'TotalScore')
PSWE_data['Fluid Intelligence Score'] = FluidIntelligence_scores
PSWE_data = calculate_z(PSWE_data, 'Fluid Intelligence Score', 'Fluid Intelligence Z')

### Hotel Task ###
Hotel_file = data_dir + '/Behavioural_data/Hotel_summary.csv'
Hotel_data = pd.read_csv(Hotel_file)

Hotel_scores = get_scores(Hotel_data, 'CCID', 'Time')
PSWE_data['Hotel Score'] = Hotel_scores
PSWE_data = calculate_z(PSWE_data, 'Hotel Score', 'Hotel Z')
PSWE_data['Hotel Z'] = -PSWE_data['Hotel Z'] #Flip sign because lower score is better

### Emotional Expression Recognition ###
EmotionalExpression_file = data_dir + '/Behavioural_data/EmotionalExpression_summary.csv'
EmotionalExpression_data = pd.read_csv(EmotionalExpression_file)

EmotionalExpression_scores = get_scores(EmotionalExpression_data, 'CCID', 'Total_Acc')
PSWE_data['Emotional Expression Score'] = EmotionalExpression_scores
PSWE_data = calculate_z(PSWE_data, 'Emotional Expression Score', 'Emotional Expression Z')

#Save final PSWE data to a new CSV file 
PSWE_out =  data_dir + 'Data_May2022/PSWE_allEvents_controls_behaviouralData.csv'
PSWE_data.to_csv(PSWE_out)