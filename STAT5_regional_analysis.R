# Library
library(ggplot2)
library(hrbrthemes)
library('plotrix')

#Read in bigger control group this group 
controls <- read.csv(file ="PSWE_allEvents_controls_behavioural_homeint_noSingleChan_headposRemoved2_data.csv")
all_camcan <- read.csv(file = "PSWE_allCamCAN_behavioural_homeint_noSingleChan_headposRemoved_data.csv")

#Pull out regional values from control data 
LO_controls <- controls$Num.Left.Occipital
RO_controls <- controls$Num.Right.Occipital
LT_controls <- controls$Num.Left.Temporal
RT_controls <- controls$Num.Right.Temporal
LP_controls <- controls$Num.Left.Parietal
RP_controls <- controls$Num.Right.Parietal
LF_controls <- controls$Num.Left.Frontal
RF_controls <- controls$Num.Right.Frontal
total_controls <- controls$Number.of.Channels

#Plot control data only 
means = c(mean(LO_controls),  mean(RO_controls), 
          mean(LT_controls), mean(RT_controls), 
          mean(LP_controls), mean(RP_controls), 
          mean(LF_controls),  mean(RF_controls))
stdev = c(std.error(LO_controls), std.error(RO_controls), 
          std.error(LT_controls), std.error(RT_controls), 
          std.error(LP_controls), std.error(RP_controls), 
          std.error(LF_controls), std.error(RF_controls))
table = as.table(means)
rownames(table) = c("LO", "RO", "LT",  "RT", "LP",  "RP", "LF",  "RF")
barplot(table, ylim=c(0,3.5), ylab = 'Number of Channels', xlab='Region')
arrows(x0=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1), y0=means-stdev, 
       x1=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1), y1=means+stdev, code=3,angle=90,length=0.1)

low_evs = subset(controls, controls$Region.Count<5)
high_evs = subset(controls, controls$Region.Count>=5)

#T-tests between groups
t.test(low_evs$Num.Left.Occipital, high_evs$Num.Left.Occipital) #p<2.2e-16

t.test(low_evs$Num.Right.Occipital, high_evs$Num.Right.Occipital) #p<2.2e-16

t.test(low_evs$Num.Left.Temporal, high_evs$Num.Left.Temporal) #p<2.2e-16

t.test(low_evs$Num.Right.Temporal, high_evs$Num.Right.Temporal) #p<2.2e-16

t.test(low_evs$Num.Left.Parietal, high_evs$Num.Left.Parietal) #p=8.738e-8

t.test(low_evs$Num.Right.Parietal, high_evs$Num.Right.Parietal) #p=1.309e-6

t.test(low_evs$Num.Left.Frontal, high_evs$Num.Left.Frontal) #p<2.2e-16

t.test(low_evs$Num.Right.Frontal, high_evs$Num.Right.Frontal) #p<2.2e-16

#Re-format data to conduct anova
#Focal events analysis
group <- c(rep("LO",length(low_evs$Num.Left.Occipital)), rep("RO", length(low_evs$Num.Right.Occipital)),
          rep("LT",length(low_evs$Num.Left.Temporal)), rep("RT", length(low_evs$Num.Right.Temporal)),
          rep("LP",length(low_evs$Num.Left.Parietal)), rep("RP", length(low_evs$Num.Right.Parietal)),
          rep("LF",length(low_evs$Num.Left.Frontal)), rep("RF", length(low_evs$Num.Right.Frontal)))
chan_vals <- c(low_evs$Num.Left.Occipital, low_evs$Num.Right.Occipital, low_evs$Num.Left.Temporal, low_evs$Num.Right.Temporal, 
               low_evs$Num.Left.Parietal, low_evs$Num.Left.Parietal, low_evs$Num.Left.Frontal, low_evs$Num.Right.Frontal)
new_dat <- data.frame(group,chan_vals)
anova <- aov(chan_vals~group, data=new_dat)
summary(anova)
#Df Sum Sq Mean Sq F value Pr(>F)    
#group          7   2029  289.86   124.7 <2e-16 ***
#Residuals   5840  13571    2.32                    
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#There are significant differences between groups so compute multiple pairwise comparisons to determine which groups are different
TukeyHSD(anova)
#No significant differences between same regions in left and right hemispheres
#Temporal significantly higher than all other regions
#Parietal significantly lower than all other regions 
#No significant difference between occipital and frontal 

#Diffuse events analysis 
group <- c(rep("LO",length(high_evs$Num.Left.Occipital)), rep("RO", length(high_evs$Num.Right.Occipital)),
           rep("LT",length(high_evs$Num.Left.Temporal)), rep("RT", length(high_evs$Num.Right.Temporal)),
           rep("LP",length(high_evs$Num.Left.Parietal)), rep("RP", length(high_evs$Num.Right.Parietal)),
           rep("LF",length(high_evs$Num.Left.Frontal)), rep("RF", length(high_evs$Num.Right.Frontal)))
chan_vals <- c(high_evs$Num.Left.Occipital, high_evs$Num.Right.Occipital, high_evs$Num.Left.Temporal, high_evs$Num.Right.Temporal, 
               high_evs$Num.Left.Parietal, high_evs$Num.Left.Parietal, high_evs$Num.Left.Frontal, high_evs$Num.Right.Frontal)
new_dat <- data.frame(group,chan_vals)
anova <- aov(chan_vals~group, data=new_dat) 
summary(anova)
#Df Sum Sq Mean Sq F value Pr(>F)    
#group          7   7456  1065.2   34.16 <2e-16 ***
#Residuals   1968  61361    31.2                 
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#There are significant differences between groups so compute multiple pairwise comparisons to determine which groups are different
TukeyHSD(anova)
#No significant differences between same regions in left and right hemispheres
#Temporal significantly higher than most other regions
#Parietal significantly lower than most other regions 
#Less significant differences between regions than reported with focal 
#Not significant: LP-LO, RP-LO, RF-LT (these were significant in focal analysis)
#No significant difference between occipital and frontal

#Plot means for each group
num_means = c(mean(na.omit(low_evs$Num.Left.Occipital)), mean(na.omit(high_evs$Num.Left.Occipital)), mean(na.omit(low_evs$Num.Right.Occipital)), mean(na.omit(high_evs$Num.Right.Occipital)), 
              mean(na.omit(low_evs$Num.Left.Temporal)), mean(na.omit(high_evs$Num.Left.Temporal)), mean(na.omit(low_evs$Num.Right.Temporal)), mean(na.omit(high_evs$Num.Right.Temporal)), 
              mean(na.omit(low_evs$Num.Left.Parietal)), mean(na.omit(high_evs$Num.Left.Parietal)), mean(na.omit(low_evs$Num.Right.Parietal)), mean(na.omit(high_evs$Num.Right.Parietal)),
              mean(na.omit(low_evs$Num.Left.Frontal)), mean(na.omit(high_evs$Num.Left.Frontal)), mean(na.omit(low_evs$Num.Right.Frontal)), mean(na.omit(high_evs$Num.Right.Frontal)))

num_stdev = c(std.error(na.omit(low_evs$Num.Left.Occipital)), std.error(na.omit(high_evs$Num.Left.Occipital)), std.error(na.omit(low_evs$Num.Right.Occipital)), std.error(na.omit(high_evs$Num.Right.Occipital)), 
               std.error(na.omit(low_evs$Num.Left.Temporal)), std.error(na.omit(high_evs$Num.Left.Temporal)), std.error(na.omit(low_evs$Num.Right.Temporal)), std.error(na.omit(high_evs$Num.Right.Temporal)), 
               std.error(na.omit(low_evs$Num.Left.Parietal)), std.error(na.omit(high_evs$Num.Left.Parietal)), std.error(na.omit(low_evs$Num.Right.Parietal)), std.error(na.omit(high_evs$Num.Right.Parietal)), 
               std.error(na.omit(low_evs$Num.Left.Frontal)), std.error(na.omit(high_evs$Num.Left.Frontal)), std.error(na.omit(low_evs$Num.Right.Frontal)), std.error(na.omit(high_evs$Num.Right.Frontal)))
table = as.table(num_means)
#rownames(table) = c("Focal PSWEs", "Diffuse PSWEs", "all PSWEs")
barplot(table, ylim = c(0,10),col=c("gray86","gray27",  "gray86","gray27", "gray86","gray27", "gray86","gray27",  "gray86","gray27",
                                    "gray86","gray27","gray86","gray27", "gray86","gray27"), ylab = 'Number of Channels', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y0=num_means-num_stdev, 
       x1=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

low_means = c(mean(na.omit(low_evs$Num.Left.Occipital)), mean(na.omit(low_evs$Num.Right.Occipital)), 
              mean(na.omit(low_evs$Num.Left.Temporal)), mean(na.omit(low_evs$Num.Right.Temporal)), 
              mean(na.omit(low_evs$Num.Left.Parietal)), mean(na.omit(low_evs$Num.Right.Parietal)), 
              mean(na.omit(low_evs$Num.Left.Frontal)), mean(na.omit(low_evs$Num.Right.Frontal)))

high_means = c(mean(na.omit(high_evs$Num.Left.Occipital)), mean(na.omit(high_evs$Num.Right.Occipital)), 
              mean(na.omit(high_evs$Num.Left.Temporal)), mean(na.omit(high_evs$Num.Right.Temporal)), 
              mean(na.omit(high_evs$Num.Left.Parietal)), mean(na.omit(high_evs$Num.Right.Parietal)),
              mean(na.omit(high_evs$Num.Left.Frontal)), mean(na.omit(high_evs$Num.Right.Frontal)))

low_sum = sum(low_means)
high_sum = sum(high_means)
low_dat = low_means/low_sum
high_dat = high_means/high_sum

