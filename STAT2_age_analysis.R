library(ggplot2)
library(hrbrthemes)
library('plotrix')
library(fBasics)
library('multimode')
library('metafor')
library('mixdist')

#Read in bigger control group this group 
controls <- read.csv(file ="PSWE_averageEvents.csv ")
all_camcan <- read.csv(file = "PSWE_allCamCAN_behavioural_homeint_noSingleChan_data.csv")

##### TIME IN EVENTS ####
#Look at distribution of number of events 
evs = subset(all_camcan, all_camcan$Time.in.Events>0)
hist(evs$Time.in.Events)
modetest(evs$Time.in.Events)
locmodes(evs$Time.in.Events, mod0=1, display=TRUE) #17.79
#This distribution is not bimodal, but does have heavy tail
#Split at the point where an even distribution (centered at 17.79) would end 
#Begins at -50 so this theoretical value is 17.79+(17.79--50)=85.58 (86)

low_evs = subset(evs, evs$Time.in.Events<86)
high_evs = subset(evs, evs$Time.in.Events>=86)
no_evs <- subset(all_camcan, all_camcan$Time.in.Events == 0)

#T-tests between groups
t.test(low_evs$Age, no_evs$Age) #0.005534
t.test(low_evs$Age, high_evs$Age) #p=0.0008813
t.test(high_evs$Age, no_evs$Age) #p=1.465e-7

#Plot means for each group
num_means = c(mean(no_evs$Age), mean(low_evs$Age), mean(high_evs$Age))
num_stdev = c(std.error(no_evs$Age), std.error(low_evs$Age), std.error(high_evs$Age))
table = as.table(num_means)
rownames(table) = c("No PSWEs", "Less PSWEs", "More PSWEs")
barplot(table, ylim = c(0,75),col=c("white","gray86", "gray27"), ylab = 'Age', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9,3.1), y0=num_means-num_stdev, x1=c(0.7,1.9,3.1), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

group1 = subset(subset(all_camcan, all_camcan$Age < 25), subset(all_camcan, all_camcan$Age < 25)$Age >= 18)
group2 = subset(subset(all_camcan, all_camcan$Age < 32), subset(all_camcan, all_camcan$Age < 32)$Age >= 25)
group3 = subset(subset(all_camcan, all_camcan$Age < 39), subset(all_camcan, all_camcan$Age < 39)$Age >= 32)
group4 = subset(subset(all_camcan, all_camcan$Age < 46), subset(all_camcan, all_camcan$Age < 46)$Age >= 39)
group5 = subset(subset(all_camcan, all_camcan$Age < 53), subset(all_camcan, all_camcan$Age < 53)$Age >= 46)
group6 = subset(subset(all_camcan, all_camcan$Age < 60), subset(all_camcan, all_camcan$Age < 60)$Age >= 53)
group7 = subset(subset(all_camcan, all_camcan$Age < 67), subset(all_camcan, all_camcan$Age < 67)$Age >= 60)
group8 = subset(subset(all_camcan, all_camcan$Age < 74), subset(all_camcan, all_camcan$Age < 74)$Age >= 67)
group9 = subset(subset(all_camcan, all_camcan$Age < 81), subset(all_camcan, all_camcan$Age < 81)$Age >= 74)
group10 = subset(subset(all_camcan, all_camcan$Age <= 88), subset(all_camcan, all_camcan$Age < 88)$Age >= 81)

#Time in events regression
control_evs <- subset(all_camcan, all_camcan$Time.in.Events>0)

num_evs = c(length(group1$Time.in.Events),length(group2$Time.in.Events),length(group3$Time.in.Events),
            length(group4$Time.in.Events),length(group5$Time.in.Events),length(group6$Time.in.Events),
            length(group7$Time.in.Events),length(group8$Time.in.Events),length(group9$Time.in.Events),
            length(group10$Time.in.Events))
control_longTime = subset(control_evs, control_evs$Time.in.Events >= 86)
#Split long events at antimode instead of 3rd quartile

group1ed = subset(subset(control_longTime, control_longTime$Age < 25), subset(control_longTime, control_longTime$Age < 25)$Age >= 18)
group2ed = subset(subset(control_longTime, control_longTime$Age < 32), subset(control_longTime, control_longTime$Age < 32)$Age >= 25)
group3ed = subset(subset(control_longTime, control_longTime$Age < 39), subset(control_longTime, control_longTime$Age < 39)$Age >= 32)
group4ed = subset(subset(control_longTime, control_longTime$Age < 46), subset(control_longTime, control_longTime$Age < 46)$Age >= 39)
group5ed = subset(subset(control_longTime, control_longTime$Age < 53), subset(control_longTime, control_longTime$Age < 53)$Age >= 46)
group6ed = subset(subset(control_longTime, control_longTime$Age < 60), subset(control_longTime, control_longTime$Age < 60)$Age >= 53)
group7ed = subset(subset(control_longTime, control_longTime$Age < 67), subset(control_longTime, control_longTime$Age < 67)$Age >= 60)
group8ed = subset(subset(control_longTime, control_longTime$Age < 74), subset(control_longTime, control_longTime$Age < 74)$Age >= 67)
group9ed = subset(subset(control_longTime, control_longTime$Age < 81), subset(control_longTime, control_longTime$Age < 81)$Age >= 74)
group10ed = subset(subset(control_longTime, control_longTime$Age <= 88), subset(control_longTime, control_longTime$Age < 88)$Age >= 81)

Num_longTime = c(length(group1ed$Time.in.Events),length(group2ed$Time.in.Events),length(group3ed$Time.in.Events),length(group4ed$Time.in.Events),
                 length(group5ed$Time.in.Events),length(group6ed$Time.in.Events),length(group7ed$Time.in.Events),length(group8ed$Time.in.Events),
                 length(group9ed$Time.in.Events),length(group10ed$Time.in.Events))
percent_long = (Num_longTime/num_evs)*100
age <- c(21.5, 28.5, 35.5, 42.5, 49.5, 56.5, 63.5, 70.5, 77.5, 84.5)
percent_vars <- (1/num_evs)*100
num_data<- data.frame(percent_long, age)

num_age <- lm(percent_long ~ as.numeric(age), data=num_data)
num_age <- rma(percent_long ~ as.numeric(age), percent_vars, method="FE")
summary(num_age)

#Model Results:
  
#  estimate      se     zval    pval    ci.lb    ci.ub     ​ 
#intrcpt           -6.6833  1.2672  -5.2741  <.0001  -9.1670  -4.1997  *** 
#as.numeric(age)    0.2228  0.0220  10.1070  <.0001   0.1796   0.2660  ***
  
#  ---
#  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
lin_vals <- c(0,10,20,30,40,50,60,70,80,90)
lin_dat <- 0.2228*lin_vals -6.6833

# linear trend + confidence interval (all data)
ggplot(num_data, aes(x=age, y=percent_long)) +
  geom_abline(intercept=-6.6833, slope=0.2228, color='black',lwd=1.5) +
  geom_point(color="black") +
  geom_errorbar(aes(ymin=(percent_long)-(percent_vars), ymax=(percent_long)+(percent_vars)), width=0.2, position=position_dodge(0.9)) +
  geom_errorbar(aes(xmin=age-3.5, xmax=age+3.5), width=0.2, position=position_dodge(0.9)) +
  xlab('Age') +
  ylab('% of Participants') +
  xlim(15,90) +
  theme_bw() +
  theme(text=element_text(size=24), 
        axis.text=element_text(size=20, color="black"),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

### NUMBER OF REGIONS ##

#Look at distribution of number of events 
hist(controls$Region.Count)
modetest(controls$Region.Count)
locmodes(controls$Region.Count, mod0=2, display=TRUE)
#Antimode at  regions: split the data into high and low PSWE groups based on this 

low_evs = subset(controls, controls$Region.Count<5)
length(unique(low_evs$Subject))
length(unique(high_evs$Subject))
high_evs = subset(controls, controls$Region.Count>=5)

#T-tests between groups
t.test(low_evs$Age, high_evs$Age) #p=0.9547

#Plot means for each group
num_means = c(mean(low_evs$Age), mean(high_evs$Age))
num_stdev = c(std.error(low_evs$Age), std.error(high_evs$Age))
table = as.table(num_means)
rownames(table) = c("Low spread PSWEs", "Widespread PSWEs")
barplot(table, ylim = c(0,70),col=c("gray86","gray27"), ylab = 'Age', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9), y0=num_means-num_stdev, x1=c(0.7,1.9), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

group1 = subset(subset(controls, controls$Age < 25), subset(controls, controls$Age < 25)$Age >= 18)
group2 = subset(subset(controls, controls$Age < 32), subset(controls, controls$Age < 32)$Age >= 25)
group3 = subset(subset(controls, controls$Age < 39), subset(controls, controls$Age < 39)$Age >= 32)
group4 = subset(subset(controls, controls$Age < 46), subset(controls, controls$Age < 46)$Age >= 39)
group5 = subset(subset(controls, controls$Age < 53), subset(controls, controls$Age < 53)$Age >= 46)
group6 = subset(subset(controls, controls$Age < 60), subset(controls, controls$Age < 60)$Age >= 53)
group7 = subset(subset(controls, controls$Age < 67), subset(controls, controls$Age < 67)$Age >= 60)
group8 = subset(subset(controls, controls$Age < 74), subset(controls, controls$Age < 74)$Age >= 67)
group9 = subset(subset(controls, controls$Age < 81), subset(controls, controls$Age < 81)$Age >= 74)
group10 = subset(subset(controls, controls$Age <= 88), subset(controls, controls$Age < 88)$Age >= 81)

num_evs = c(length(group1$Event.Duration),length(group2$Event.Duration),length(group3$Event.Duration),
            length(group4$Event.Duration),length(group5$Event.Duration),length(group6$Event.Duration),
            length(group7$Event.Duration),length(group8$Event.Duration),length(group9$Event.Duration),
            length(group10$Event.Duration))

control_widespread <- subset(controls, controls$Region.Count >= 5)

group1nc = subset(subset(control_widespread, control_widespread$Age < 25), subset(control_widespread, control_widespread$Age < 25)$Age >= 18)
group2nc = subset(subset(control_widespread, control_widespread$Age < 32), subset(control_widespread, control_widespread$Age < 32)$Age >= 25)
group3nc = subset(subset(control_widespread, control_widespread$Age < 39), subset(control_widespread, control_widespread$Age < 39)$Age >= 32)
group4nc = subset(subset(control_widespread, control_widespread$Age < 46), subset(control_widespread, control_widespread$Age < 46)$Age >= 39)
group5nc = subset(subset(control_widespread, control_widespread$Age < 53), subset(control_widespread, control_widespread$Age < 53)$Age >= 46)
group6nc = subset(subset(control_widespread, control_widespread$Age < 60), subset(control_widespread, control_widespread$Age < 60)$Age >= 53)
group7nc = subset(subset(control_widespread, control_widespread$Age < 67), subset(control_widespread, control_widespread$Age < 67)$Age >= 60)
group8nc = subset(subset(control_widespread, control_widespread$Age < 74), subset(control_widespread, control_widespread$Age < 74)$Age >= 67)
group9nc = subset(subset(control_widespread, control_widespread$Age < 81), subset(control_widespread, control_widespread$Age < 81)$Age >= 74)
group10nc = subset(subset(control_widespread, control_widespread$Age <= 88), subset(control_widespread, control_widespread$Age < 88)$Age >= 81)

Num_widespread = c(length(group1nc$Region.Count),length(group2nc$Region.Count),length(group3nc$Region.Count),length(group4nc$Region.Count),
                   length(group5nc$Region.Count),length(group6nc$Region.Count),length(group7nc$Region.Count),length(group8nc$Region.Count),
                   length(group9nc$Region.Count),length(group10nc$Region.Count))
age <- c(21.5, 28.5, 35.5, 42.5, 49.5, 56.5, 63.5, 70.5, 77.5, 84.5)
percent_widespread = (Num_widespread/num_evs)*100
num_data<- data.frame(percent_widespread, age)
percent_vars <- (1/num_evs)*100

num_age <- lm(percent_widespread ~ as.numeric(age), data=num_data)
num_age <- rma(percent_widespread ~ as.numeric(age), percent_vars, method="FE")
summary(num_age)
#Model Results:
#estimate      se     zval    pval    ci.lb    ci.ub     ​ 
#intrcpt           20.0352  1.3845  14.4711  <.0001  17.3217  22.7488  *** 
#as.numeric(age)    0.0107  0.0210   0.5061  0.6128  -0.0306   0.0519   

# linear trend + confidence interval (all data)
ggplot(num_data, aes(x=age, y=percent_widespread)) +
  geom_abline(intercept=20.0352, slope=0.0107, color='black',lwd=1.5) +
  geom_point(color="black") +
  geom_errorbar(aes(ymin=(percent_widespread)-(percent_vars), ymax=(percent_widespread)+(percent_vars)), width=0.2, position=position_dodge(0.9)) +
  geom_errorbar(aes(xmin=age-3.5, xmax=age+3.5), width=0.2, position=position_dodge(0.9)) +
  xlab('Age') +
  ylab('% of Participants') +
  xlim(15,90) +
  theme_bw() +
  theme(text=element_text(size=24), 
        axis.text=element_text(size=20, color="black"),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

