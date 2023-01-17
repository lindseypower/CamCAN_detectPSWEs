library(ggplot2)
library(hrbrthemes)
library('plotrix')
library(fBasics)
library('multimode')

#Read in bigger control group this group 
controls <- read.csv(file ="PSWE_averageEvents.csv ")
all_camcan <- read.csv(file = "PSWE_allCamCAN_behavioural_homeint_noSingleChan_data.csv")

#Restructure all_camcan data
subs <- unique(controls$Subject)
no_evs <- subset(all_camcan, !(all_camcan$Subject %in% subs))
evs <- subset(all_camcan, all_camcan$Subject %in% subs)
evs <- evs[order(evs$Subject),]
all_camcan <- rbind(no_evs,evs)

#Find how many regions are active for each event
region_count_list <- c()
left_bool_list <- c()
right_bool_list <- c()
bilateral_bool_list <- c()

for (row in controls$X){
  curr = subset(controls, controls$X == row)
  region_count = 0
  left_bool = 0
  right_bool = 0
  bilateral_bool = 0
  left_regions = c('Num.Left.Frontal','Num.Left.Occipital', 'Num.Left.Temporal','Num.Left.Parietal')
  right_regions = c('Num.Right.Frontal','Num.Right.Occipital', 'Num.Right.Temporal','Num.Right.Parietal')
  for (region in right_regions){
    if (curr[[region]]>0){
      right_bool=1
      region_count = region_count+1
    }
  }
  for (region in left_regions){
    if (curr[[region]]>0){
      left_bool=1
      region_count=region_count+1
    }
  }
  if (left_bool==1 && right_bool==1){
    bilateral_bool = 1
    left_bool = 0
    right_bool = 0
  }
  region_count_list <- c(region_count_list, region_count)
  left_bool_list <- c(left_bool_list, left_bool)
  right_bool_list <- c(right_bool_list, right_bool)
  bilateral_bool_list <- c(bilateral_bool_list, bilateral_bool)
}

#Add column to dataframe
controls$Region.Count <- region_count_list

#Calculate the time in events for each participant
subs <- controls$Subject
time_list <- c()
num_evs <- c()
diffuse_list <- c()
for (sub in subs)
{
  durs <- subset(controls, controls$Subject == sub)$Event.Duration
  time_in_evs = sum(durs)
  len = length(durs)
  time_list <- c(time_list, time_in_evs)
  num_evs <- c(num_evs, len)
  subDat <- subset(controls, controls$Subject == sub)
  totalReg <- subDat$Region.Count
  diffuse <- subset(subDat, subDat$Region.Count<5)$Region
  percent_diffuse <- length(diffuse)/length(totalReg)
  diffuse_list <- c(diffuse_list, percent_diffuse)
}

#Add column to dataframe
controls$Time.in.Events <- time_list
controls$Number.of.Events <- num_evs
controls$Percent.Diffuse <- diffuse_list

### Now deal with all_camcan df
#Calculate the time in events for each participant
subs <- evs$Subject
time_list <- c()
num_evs <- c()
diffuse_list <- c()
for (sub in subs)
{
  durs <- subset(controls, controls$Subject == sub)$Event.Duration
  time_in_evs = sum(durs)
  len = length(durs)
  time_list <- c(time_list, time_in_evs)
  num_evs <- c(num_evs, len)
  subDat <- subset(controls, controls$Subject == sub)
  totalReg <- subDat$Region.Count
  diffuse <- subset(subDat, subDat$Region.Count<5)$Region
  percent_diffuse <- length(diffuse)/length(totalReg)
  diffuse_list <- c(diffuse_list, percent_diffuse)
}

#Add zeros for the participants with no events
len_zeros = length(all_camcan$Subject)-length(num_evs)
zeros = rep(0,len_zeros)

#Add time in events to dataframe
all_times <- c(zeros,time_list)
all_nums <- c(zeros,num_evs)
all_camcan$Time.in.Events <- all_times
all_camcan$Number.of.Events <- all_nums 

#Write new files 
write.csv(controls, file ="PSWE_averageEvents.csv")
write.csv(all_camcan, file ="PSWE_allCamCAN_behavioural_homeint_noSingleChan_data.csv")