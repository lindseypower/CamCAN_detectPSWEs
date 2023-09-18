# Paroxysmal Slow-Wave Events (PSWEs) in the CamCAN dataset: relationship to age and cognitive performance

Project Background:

Paroxysmal patterns of slow cortical activity have been detected in M/EEG recordings from individuals with epilepsy and Alzheimer’s disease and have been shown to be correlated with cognitive dysfunction and blood-brain barrier disruption in these conditions. While it is known that these pathological events are less prevalent in healthy populations, the variability and age-related changes in healthy participants have not been studied. In this work we aimed to investigate the prevalence and characteristics of these events in non-pathological ageing and assess their relationship to normal cognitive variability. To address this objective, paroxysmal slow wave events were detected in MEG recordings from 623 healthy participants between the ages of 18-88 collected by the Cambridge Centre for Ageing and Neuroscience. Features of the events including their prevalence and regional distribution were then assessed for relationships to participant age and cognitive performance on 8 cognitive tasks. Slow wave events were detected in approximately 20% of healthy participants in the dataset, with linearly increasing prevalence with age. Lower cognitive ability was associated with both increased prevalence and wider spatial spread of slow wave events, with language and memory tasks showing the strongest relationships to slow wave prevalence and spread. These findings provided evidence, for the first time, that paroxysmal slow wave activity, which was previously thought to be pathological in nature, is detectable in a subset of healthy participants and is associated with ageing and cognition in this population. This evidence suggests the presence of an electrophysiological abnormality in as many as 1 in 5 purportedly healthy older adults. Going forward, these events may have utility as a biomarker for the detection of abnormal brain activity and reduced cognitive abilities in older adults.

This repository contains all of the code used to achieve this project. 

Required Files: 

All data was taken from the CamCAN open-access dataset available at http://www.mrc-cbu.cam.ac.uk/datasets/camcan

Raw resting state data (e.g., ‘<subID>_transdef_mf2pt2_rest_raw.fif’)
ICA fif file (e.g., <subID>_transdef_mf2pt2_rest_raw-ica.fif’)* 
Head position files (e.g., <subID>_mf2pt2_rest_raw_headposition.pos)
Raw scores from cognitive testing: 
-	TOT_summary.csv
-	PictureNaming_summary.csv
-	VSTMcolour.csv
-	FamousFaces_summary.csv
-	BentonFaces_summary.csv
-	FluidIntelligence_summary.csv
-	Hotel_summary.csv
-	EmotionalExpression_summary.csv

*ICA was calculated for this raw data in previous analysis, so it was not repeated here. 

Software Requirements: 

Note for all listed packages, the indicated version is the most recent version that has been tested for compatibility.

Python: 
Initial analysis was conducted in Python 2.7.13 but all scripts also run successfully in Python 3.9.7. The following packages were imported:

- mne == 1.0.3
- numpy == 1.21.6
- more_itertools == 9.0.0
- scipy == 1.7.3
- matplotlib == 3.5.2
- pandas == 1.3.5

R:
All statistical analysis was completed in R version 4.2.0. The following packages were imported: 

- ggplot2
- hrbrthemes
- plotrix
- fBasics
- multimode

Scripts for PSWE detection:

0_PSWE_functions.py
Script containing functions used to detect PSWEs in resting state MEG or EEG data

PSD_calc : Function to calculate PSD 
Arguments: 
-	data: MEG or EEG time series data (array of shape [times x channels])
-	fs: sampling frequency (int)
Outputs:
-	target_psds: PSDs of interest (ndarray)
-	target_freqs: frequencies associated with PSD (ndarray)

BW_calc: Function to calculate PSDs for specific bandwidths (frequency ranges)
Arguments: 
-	psds: PSDs calculated in PSD_calc function (ndarray)
-	freqs: freqs calculates in PSD_calc function (ndarray)
Outputs:
-	PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

MPF: Function to compute the median power frequency (MPF) used to identify PSWEs
Arguments: 
-	data: MEG or EEG time series data (array of shape [times x channels])
-	fs: sampling frequency (int)
-	PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)
Outputs:
-	medFreq: vector of MPF values for each second of time data (ndarray)
-	PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)

PSWE: Main PSWE detection function (per channel)
Arguments: 
-	data: MEG or EEG time series data (array of shape [times x channels])
-	fs: sampling frequency (int)
-	freqThresh: maximum frequency of PSWEs (int)
-	lenThresh: minimum duration of PSWEs (int)
-	PSD values for delta, theta, alpha, beta, gamma and PSWE ranges (ndarrays)
Outputs:
-	num_of_events: number of PSWEs detected at each channel (array [1 x channels])
-	time_in_events: percent of recording spent in PSWE (array [1 x channels]) 
-	meanFreq: average PSWE frequency at each channel (array [1 x channels])
-	meanDur: average PSWE duration at each channel (array [1 x channels])
-	df: dataframe containing information about each event (onset, offset, duration, mean frequency, channel, subject)
-	medFreq: vector of MPF values for each second of time data (ndarray)

1_PSWE_run.py
Main code used to detect PSWEs in resting state MEG or EEG data
For each participant:
-	Reads in raw resting state data 
-	Applies highpass and lowpass filters
-	Creates a single 9-minute epoch 
-	Applies ICA (previously calculated) 
-	Uses PSWE_functions to detect PSWEs in cleaned epoch data
-	Creates some summary topography plots 
-	Outputs a dataframe containing a list of PSWEs and their characteristics
-	Saves dataframe as <subID>_events.csv

2_PSWEs_by_region.py
Defines 8 spatial regions (frontal, temporal, parietal, occipital (left and right)) and determines the region associated with each PSWE
For each participant:
-	Reads in dataframe of PSWEs (<subID>_events.csv)
-	Matches channel in each row to associated spatial region 
-	Adds “Region” column to participants’ dataframe
-	Saves new dataframe as <subID>_regional_events.csv

3_find_unique_PSWEs.py
Combines overlapping single-channel PSWEs to create multi-channel PSWEs
For each participant:
-	Reads in dataframe of PSWEs (<subID>_regional_events.csv)
-	Sorts PSWEs by their onset time
-	If the offset of one event is later than the onset of an event at a different channel, the events are combined 
-	Creates a new dataframe of multi-channel PSWEs
-	Saves datatframe as <subID>_regional_unique_events.csv
Creates a master dataframe with all multi-channel events from all participants and saves it as all_regional_unique_events.csv

4_analyse_headmovement_PSWEs.py
Finds PSWEs that occurs during significant head movements 
For each participant: 
-	Reads in resting state head position file 
-	Reads in dataframe of multi-channel PSWEs (<subID>_regional_unique_events.csv)
-	Calculates the mean head position velocity during the scan
-	Uses a t-test to compare mean velocity to velocity during each PSWE 
-	Find PSWEs for which the velocity during the event is significantly higher than the mean velocity of the scan 
Save a dataframe of p-values associated with each PSWE as headpositions_p_vals.csv

5_create_PSWE_dataframes.py
Takes information from PSWE dataframes and create 2 summary dataframes 
For each participant: 
-	Reads in <subID>_regional_unique_events.csv
-	Calculates summary statistics for the participant (e.g., average frequency, average duration, average number of channels, burst rate)
Saves a summary dataframe with one row per participant as PSWE_averageEvents.csv 
Saves a summary dataframe with one row per event as PSWE_allEvents.csv

6_make_PSWE_behavioural_data.py
Adds behavioural (i.e., cognitive) data to the dataframe of PSWEs
Reads in master dataframe of PSWEs (PSWEs_allEvents.csv)
For each of 8 cognitive tasks: 
-	Reads in dataframe containing scores of cognitive test
-	Calls get_scores function to pull out the score of interest from the dataframe 
-	Calls calculate_z function to calculate z scores for each participant relative to other participants 
-	Flips sign of z scores if necessary 
-	Adds raw scores and z scores for each participant to master dataframe 
Saves new master dataframe as PSWE_allEvents_controls_behaviouralData.csv

7_restructure_data.py
Removes PSWEs associated with head movements from the dataframe
-	Reads in PSWE_allEvents_controls_behaviouralData.csv and headpositions_p_vals.csv and merges them on based on subject and event times
-	Removes any events for which the p-value is less than 0.05 (corrected for number of tests)
-	Saves final dataframe  as PSWE_allEvents_controls_behavioural_headposRemoved_data.csv

Scripts for statistics and figure generation:

FIG_create_average_sensor_maps.py
Creates topographies representing the number of PSWEs detected at each channel
-	Reads in PSWE dataframe (1 row per event)
-	Splits participants into low and widespread events 
-	Uses info from a sample raw file to create topographies
-	Replaces the topography data with counts of the number of PSWEs detected at each sensor
-	Plots topographies (magnetometers and gradiometers separately)
