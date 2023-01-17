library(ggplot2)
library(hrbrthemes)
library('plotrix')
library(fBasics)
library('multimode')
library('metafor')

#Read in bigger control group this group 
controls <- read.csv(file ="PSWE_averageEvents.csv ")
all_camcan <- read.csv(file = "PSWE_allCamCAN_behavioural_homeint_noSingleChan_data.csv")
controls <- na.omit(controls)
all_camcan <- na.omit(all_camcan)

z_bins = c( -1.25, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75)
group1 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[1]))
group2 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[2]), subset(all_camcan, all_camcan$Mean.Z < z_bins[2])$Mean.Z >= z_bins[1])
group3 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[3]), subset(all_camcan, all_camcan$Mean.Z < z_bins[3])$Mean.Z >= z_bins[2])
group4 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[4]), subset(all_camcan, all_camcan$Mean.Z < z_bins[4])$Mean.Z >= z_bins[3])
group5 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[5]), subset(all_camcan, all_camcan$Mean.Z < z_bins[5])$Mean.Z >= z_bins[4])
group6 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[6]), subset(all_camcan, all_camcan$Mean.Z < z_bins[6])$Mean.Z >= z_bins[5])
group7 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[7]), subset(all_camcan, all_camcan$Mean.Z < z_bins[7])$Mean.Z >= z_bins[6])
group8 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[8]), subset(all_camcan, all_camcan$Mean.Z < z_bins[8])$Mean.Z >= z_bins[7])
group9 = subset(subset(all_camcan, all_camcan$Mean.Z < z_bins[9]), subset(all_camcan, all_camcan$Mean.Z < z_bins[9])$Mean.Z >= z_bins[8])
group10 = subset(subset(all_camcan, all_camcan$Mean.Z >= z_bins[9]))

##### TIME IN EVENTS ####
evs = subset(all_camcan, all_camcan$Time.in.Events >0)
low_evs = subset(evs, evs$Time.in.Events<86)
high_evs = subset(evs, evs$Time.in.Events>=86)
no_evs <- subset(all_camcan, all_camcan$Number.of.Events == 0)

#T-tests between groups
t.test(low_evs$Mean.Z, no_evs$Mean.Z) #p=0.1983
t.test(low_evs$Mean.Z, high_evs$Mean.Z) #p=0.0587
t.test(high_evs$Mean.Z, no_evs$Mean.Z) #p=0.004361

#Plot means for each group
num_means = c(mean(no_evs$Mean.Z), mean(low_evs$Mean.Z), mean(high_evs$Mean.Z))
num_stdev = c(std.error(no_evs$Mean.Z), std.error(low_evs$Mean.Z), std.error(high_evs$Mean.Z))
table = as.table(num_means)
rownames(table) = c("No PSWEs", "Less PSWEs", "More PSWEs")
barplot(table, ylim = c(-0.5, 0.5),col=c("white","gray86", "gray27"), ylab = 'Overall Cognitive Score', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9,3.1), y0=num_means-num_stdev, x1=c(0.7,1.9,3.1), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

#Time in events regression
control_evs <- subset(all_camcan, all_camcan$Time.in.Events>0)

num_evs = c(length(group1$Time.in.Events),length(group2$Time.in.Events),length(group3$Time.in.Events),
            length(group4$Time.in.Events),length(group5$Time.in.Events),length(group6$Time.in.Events),
            length(group7$Time.in.Events),length(group8$Time.in.Events),length(group9$Time.in.Events),
            length(group10$Time.in.Events))

control_longTime = subset(control_evs, control_evs$Time.in.Events >=83)
#Split long events at antimode instead of 3rd quartile

group1ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[1]))
group2ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[2]), subset(control_longTime, control_longTime$Mean.Z < z_bins[2])$Mean.Z >= z_bins[1])
group3ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[3]), subset(control_longTime, control_longTime$Mean.Z < z_bins[3])$Mean.Z >= z_bins[2])
group4ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[4]), subset(control_longTime, control_longTime$Mean.Z < z_bins[4])$Mean.Z >= z_bins[3])
group5ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[5]), subset(control_longTime, control_longTime$Mean.Z < z_bins[5])$Mean.Z >= z_bins[4])
group6ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[6]), subset(control_longTime, control_longTime$Mean.Z < z_bins[6])$Mean.Z >= z_bins[5])
group7ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[7]), subset(control_longTime, control_longTime$Mean.Z < z_bins[7])$Mean.Z >= z_bins[6])
group8ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[8]), subset(control_longTime, control_longTime$Mean.Z < z_bins[8])$Mean.Z >= z_bins[7])
group9ed = subset(subset(control_longTime, control_longTime$Mean.Z < z_bins[9]), subset(control_longTime, control_longTime$Mean.Z < z_bins[9])$Mean.Z >= z_bins[8])
group10ed = subset(subset(control_longTime, control_longTime$Mean.Z >= z_bins[9]))

Num_longTime = c(length(group1ed$Time.in.Events),length(group2ed$Time.in.Events),length(group3ed$Time.in.Events),length(group4ed$Time.in.Events),
                 length(group5ed$Time.in.Events),length(group6ed$Time.in.Events),length(group7ed$Time.in.Events),length(group8ed$Time.in.Events),
                 length(group9ed$Time.in.Events),length(group10ed$Time.in.Events))
percent_long = (Num_longTime/num_evs)*100
cognitive <- c(-1.375,-1.125,-0.875, -0.675, -0.425, -0.175, 0.075, 0.325, 0.575, 0.825)
num_data<- data.frame(percent_long, cognitive)
percent_vars <- (1/num_evs)*100

num_cog <- lm(percent_long ~ as.numeric(cognitive), data=num_data)
num_cog <- rma(percent_long ~ as.numeric(cognitive), percent_vars, method="FE")
summary(num_cog)
#Model Results:
#estimate      se     zval    pval    ci.lb    ci.ub     ​ 
#intrcpt                  5.3955  0.4472  12.0647  <.0001   4.5190   6.2720  *** 
#as.numeric(cognitive)   -4.4914  0.7517  -5.9747  <.0001  -5.9647  -3.0180 

# linear trend + confidence interval (all data)
ggplot(num_data, aes(x=cognitive, y=percent_long)) +
  geom_abline(intercept=5.3955, slope=-4.4914, color='black',lwd=1.5) +
  geom_point(color="black") +
  geom_errorbar(aes(ymin=(percent_long)-(percent_vars), ymax=(percent_long)+(percent_vars)), width=0, position=position_dodge(0.9)) +
  geom_errorbar(aes(xmin=cognitive-0.125, xmax=cognitive+0.125), width=0.2, position=position_dodge(0.9)) +
  xlab('Cognitive Score') +
  ylab('% of Participants') +
  xlim(-1.5,1.2) +
  theme_bw() +
  theme(text=element_text(size=24), 
        axis.text=element_text(size=20, color="black"),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

### NUMBER OF REGIONS ##
low_evs = subset(controls, controls$Region.Count<5)
high_evs = subset(controls, controls$Region.Count>=5)

#T-tests between groups
t.test(low_evs$Mean.Z, high_evs$Mean.Z) #p=7.882e-5

#Plot means for each group
num_means = c(mean(low_evs$Mean.Z), mean(high_evs$Mean.Z))
num_stdev = c(std.error(low_evs$Mean.Z), std.error(high_evs$Mean.Z))
table = as.table(num_means)
rownames(table) = c("Low spread PSWEs", "Widespread PSWEs")
barplot(table, ylim = c(-0.8,0),col=c("gray86","gray27"), ylab = 'Overall Cognitive Score', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9), y0=num_means-num_stdev, x1=c(0.7,1.9), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

group1 = subset(subset(controls, controls$Mean.Z < z_bins[1]))
group2 = subset(subset(controls, controls$Mean.Z < z_bins[2]), subset(controls, controls$Mean.Z < z_bins[2])$Mean.Z >= z_bins[1])
group3 = subset(subset(controls, controls$Mean.Z < z_bins[3]), subset(controls, controls$Mean.Z < z_bins[3])$Mean.Z >= z_bins[2])
group4 = subset(subset(controls, controls$Mean.Z < z_bins[4]), subset(controls, controls$Mean.Z < z_bins[4])$Mean.Z >= z_bins[3])
group5 = subset(subset(controls, controls$Mean.Z < z_bins[5]), subset(controls, controls$Mean.Z < z_bins[5])$Mean.Z >= z_bins[4])
group6 = subset(subset(controls, controls$Mean.Z < z_bins[6]), subset(controls, controls$Mean.Z < z_bins[6])$Mean.Z >= z_bins[5])
group7 = subset(subset(controls, controls$Mean.Z < z_bins[7]), subset(controls, controls$Mean.Z < z_bins[7])$Mean.Z >= z_bins[6])
group8 = subset(subset(controls, controls$Mean.Z < z_bins[8]), subset(controls, controls$Mean.Z < z_bins[8])$Mean.Z >= z_bins[7])
group9 = subset(subset(controls, controls$Mean.Z < z_bins[9]), subset(controls, controls$Mean.Z < z_bins[9])$Mean.Z >= z_bins[8])
group10 = subset(subset(controls, controls$Mean.Z >= z_bins[9]))

num_evs = c(length(group1$Event.Duration),length(group2$Event.Duration),length(group3$Event.Duration),
            length(group4$Event.Duration),length(group5$Event.Duration),length(group6$Event.Duration),
            length(group7$Event.Duration),length(group8$Event.Duration),length(group9$Event.Duration),
            length(group10$Event.Duration))

control_widespread <- subset(controls, controls$Region.Count >= 5)

group1nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[1]))
group2nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[2]), subset(control_widespread, control_widespread$Mean.Z < z_bins[2])$Mean.Z >= z_bins[1])
group3nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[3]), subset(control_widespread, control_widespread$Mean.Z < z_bins[3])$Mean.Z >= z_bins[2])
group4nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[4]), subset(control_widespread, control_widespread$Mean.Z < z_bins[4])$Mean.Z >= z_bins[3])
group5nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[5]), subset(control_widespread, control_widespread$Mean.Z < z_bins[5])$Mean.Z >= z_bins[4])
group6nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[6]), subset(control_widespread, control_widespread$Mean.Z < z_bins[6])$Mean.Z >= z_bins[5])
group7nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[7]), subset(control_widespread, control_widespread$Mean.Z < z_bins[7])$Mean.Z >= z_bins[6])
group8nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[8]), subset(control_widespread, control_widespread$Mean.Z < z_bins[8])$Mean.Z >= z_bins[7])
group9nc = subset(subset(control_widespread, control_widespread$Mean.Z < z_bins[9]), subset(control_widespread, control_widespread$Mean.Z < z_bins[9])$Mean.Z >= z_bins[8])
group10nc = subset(subset(control_widespread, control_widespread$Mean.Z >= z_bins[9]))

Num_widespread = c(length(group1nc$Region.Count),length(group2nc$Region.Count),length(group3nc$Region.Count),length(group4nc$Region.Count),
                   length(group5nc$Region.Count),length(group6nc$Region.Count),length(group7nc$Region.Count),length(group8nc$Region.Count),
                   length(group9nc$Region.Count),length(group10nc$Region.Count))
cognitive <- c(-1.375,-1.125,-0.875, -0.675, -0.425, -0.175, 0.075, 0.325, 0.575, 0.825)
percent_widespread = (Num_widespread/num_evs)*100
num_data<- data.frame(percent_widespread, cognitive)
percent_vars <- 1/num_evs*100

num_cog <- lm(percent_widespread ~ as.numeric(cognitive), data=num_data)
num_cog <- rma(percent_widespread ~ as.numeric(cognitive), percent_vars, method="FE")
summary(num_cog)
#Model Results:
#                       estimate      se      zval    pval     ci.lb     ci.ub     ​ 
#intrcpt                 15.1896  0.4166   36.4569  <.0001   14.3730   16.0062  *** 
#as.numeric(cognitive)  -12.4601  0.7224  -17.2493  <.0001  -13.8759  -11.0443  *** 

# linear trend + confidence interval (all data)
ggplot(num_data, aes(x=cognitive, y=percent_widespread)) +
  geom_abline(intercept=15.1896, slope=-12.4601, color='black',lwd=1.5) +
  geom_point(color="black") +
  geom_errorbar(aes(ymin=(percent_widespread)-(percent_vars), ymax=(percent_widespread)+(percent_vars)), width=0, position=position_dodge(0.9)) +
  geom_errorbar(aes(xmin=cognitive-0.125, xmax=cognitive+0.125), width=0.2, position=position_dodge(0.9)) +
  xlab('Cognitive Score') +
  ylab('% of Participants') +
  xlim(-1.5,1.2) +
  theme_bw() +
  theme(text=element_text(size=24), 
        axis.text=element_text(size=20, color="black"),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

