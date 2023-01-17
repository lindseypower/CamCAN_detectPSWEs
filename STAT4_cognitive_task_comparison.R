library(ggplot2)
library(hrbrthemes)
library('plotrix')
library(fBasics)
library('multimode')

#Read in bigger control group this group 
controls <- read.csv(file ="PSWE_averageEvents.csv ")
all_camcan <- read.csv(file = "PSWE_allCamCAN_behavioural_homeint_noSingleChan_data.csv")

##### TIME IN EVENTS ####
#evs = subset(all_camcan, all_camcan$Time.in.Events >0)
low_evs = subset(all_camcan, all_camcan$Time.in.Events<83) #Combine low and no evs because they weren't different in statistical score
high_evs = subset(all_camcan, all_camcan$Time.in.Events>=83)
#no_evs <- subset(all_camcan, all_camcan$Number.of.Events == 0)

#T-tests between groups
t.test(na.omit(low_evs$TOT.Z), na.omit(high_evs$TOT.Z)) #p=0.9359

t.test(low_evs$PicNaming.Z, high_evs$PicNaming.Z) #p=0.04992

t.test(low_evs$VSTM.Z, high_evs$VSTM.Z) #p=0.2946

t.test(low_evs$Famous.Face.Z, high_evs$Famous.Face.Z) #p=0.04909

t.test(low_evs$Unfamiliar.Face.Z, high_evs$Unfamiliar.Face.Z) #p=0.0003109*

t.test(low_evs$Fluid.Intelligence.Z, high_evs$Fluid.Intelligence.Z) #p=0.005656

t.test(low_evs$Hotel.Z, high_evs$Hotel.Z) #p=0.009064

t.test(low_evs$Emotional.Expression.Z, high_evs$Emotional.Expression.Z) #p=0.2714

#Plot means for each group
num_means = c(mean(na.omit(low_evs$TOT.Z)), mean(na.omit(high_evs$TOT.Z)),mean(na.omit(low_evs$PicNaming.Z)), mean(na.omit(high_evs$PicNaming.Z)),
              mean(na.omit(low_evs$VSTM.Z)), mean(na.omit(high_evs$VSTM.Z)),mean(na.omit(low_evs$Famous.Face.Z)), mean(na.omit(high_evs$Famous.Face.Z)), 
              mean(na.omit(low_evs$Unfamiliar.Face.Z)), mean(na.omit(high_evs$Unfamiliar.Face.Z)), mean(na.omit(low_evs$Fluid.Intelligence.Z)), mean(na.omit(high_evs$Fluid.Intelligence.Z)), 
              mean(na.omit(low_evs$Hotel.Z)), mean(na.omit(high_evs$Hotel.Z)), mean(na.omit(low_evs$Emotional.Expression.Z)), mean(na.omit(high_evs$Emotional.Expression.Z)))

num_stdev = c(std.error(na.omit(low_evs$TOT.Z)), std.error(na.omit(high_evs$TOT.Z)), std.error(na.omit(low_evs$PicNaming.Z)), std.error(na.omit(high_evs$PicNaming.Z)), 
              std.error(na.omit(low_evs$VSTM.Z)), std.error(na.omit(high_evs$VSTM.Z)), std.error(na.omit(low_evs$Famous.Face.Z)), std.error(na.omit(high_evs$Famous.Face.Z)), 
              std.error(na.omit(low_evs$Unfamiliar.Face.Z)), std.error(na.omit(high_evs$Unfamiliar.Face.Z)), std.error(na.omit(low_evs$Fluid.Intelligence.Z)), std.error(na.omit(high_evs$Fluid.Intelligence.Z)), 
              std.error(na.omit(low_evs$Hotel.Z)), std.error(na.omit(high_evs$Hotel.Z)), std.error(na.omit(low_evs$Emotional.Expression.Z)), std.error(na.omit(high_evs$Emotional.Expression.Z)))
table = as.table(num_means)
#rownames(table) = c("Low PSWEs", "High PSWEs", "no PSWEs")
barplot(table, ylim = c(-1,0.5),col=c("gray86","gray27", "gray86","gray27","gray86","gray27", "gray86","gray27", "gray86","gray27", 
                                      "gray86","gray27",  "gray86","gray27", "gray86","gray27"), ylab = 'Z Score', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y0=num_means-num_stdev, 
       x1=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

#### NUMBER OF REGIONS ####
low_evs = subset(controls, controls$Region.Count<5)
high_evs = subset(controls, controls$Region.Count>=5)

#T-tests between groups
t.test(na.omit(low_evs$TOT.Z), na.omit(high_evs$TOT.Z)) #p=0.00316

t.test(low_evs$PicNaming.Z, high_evs$PicNaming.Z) #p=0.0001023*

t.test(low_evs$VSTM.Z, high_evs$VSTM.Z) #p=0.007393

t.test(low_evs$Famous.Face.Z, high_evs$Famous.Face.Z) #p=0.5201

t.test(low_evs$Unfamiliar.Face.Z, high_evs$Unfamiliar.Face.Z) #p=0.001394*

t.test(low_evs$Fluid.Intelligence.Z, high_evs$Fluid.Intelligence.Z) #p=0.32

t.test(low_evs$Hotel.Z, high_evs$Hotel.Z) #p=0.03887

t.test(low_evs$Emotional.Expression.Z, high_evs$Emotional.Expression.Z) #p=0.03699

#Plot means for each group
num_means = c(mean(na.omit(low_evs$TOT.Z)), mean(na.omit(high_evs$TOT.Z)), mean(na.omit(low_evs$PicNaming.Z)), mean(na.omit(high_evs$PicNaming.Z)), 
              mean(na.omit(low_evs$VSTM.Z)), mean(na.omit(high_evs$VSTM.Z)), mean(na.omit(low_evs$Famous.Face.Z)), mean(na.omit(high_evs$Famous.Face.Z)), 
              mean(na.omit(low_evs$Unfamiliar.Face.Z)), mean(na.omit(high_evs$Unfamiliar.Face.Z)), mean(na.omit(low_evs$Fluid.Intelligence.Z)), mean(na.omit(high_evs$Fluid.Intelligence.Z)), 
              mean(na.omit(low_evs$Hotel.Z)), mean(na.omit(high_evs$Hotel.Z)), mean(na.omit(low_evs$Emotional.Expression.Z)), mean(na.omit(high_evs$Emotional.Expression.Z)))

num_stdev = c(std.error(na.omit(low_evs$TOT.Z)), std.error(na.omit(high_evs$TOT.Z)), std.error(na.omit(low_evs$PicNaming.Z)), std.error(na.omit(high_evs$PicNaming.Z)), 
              std.error(na.omit(low_evs$VSTM.Z)), std.error(na.omit(high_evs$VSTM.Z)), std.error(na.omit(low_evs$Famous.Face.Z)), std.error(na.omit(high_evs$Famous.Face.Z)), 
              std.error(na.omit(low_evs$Unfamiliar.Face.Z)), std.error(na.omit(high_evs$Unfamiliar.Face.Z)), std.error(na.omit(low_evs$Fluid.Intelligence.Z)), std.error(na.omit(high_evs$Fluid.Intelligence.Z)), 
              std.error(na.omit(low_evs$Hotel.Z)), std.error(na.omit(high_evs$Hotel.Z)), std.error(na.omit(low_evs$Emotional.Expression.Z)), std.error(na.omit(high_evs$Emotional.Expression.Z)))
table = as.table(num_means)
#rownames(table) = c("Low PSWEs", "High PSWEs", "no PSWEs")
barplot(table, ylim = c(-1,0.5),col=c("gray86","gray27", "gray86","gray27","gray86","gray27", "gray86","gray27", "gray86","gray27", 
                                      "gray86","gray27",  "gray86","gray27", "gray86","gray27"), ylab = 'Z Score', cex.axis=1.2, cex.names=1.2)
arrows(x0=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y0=num_means-num_stdev, 
       x1=c(0.7,1.9,3.1,4.3,5.5,6.7,7.9,9.1,10.3,11.5,12.7,13.9,15.1,16.3,17.5,18.7), y1=num_means+num_stdev, code=3,angle=90,length=0.1)

TOT_mod <- lm(TOT.Z~Age, data=all_camcan)
summary(TOT_mod) #Slope = -0.01809, R2=0.104

PicNaming_mod <- lm(PicNaming.Z~Age, data=all_camcan)
summary(PicNaming_mod) #Slope = -0.03307, R2=0.362

VSTM_mod <- lm(VSTM.Z~Age, data=all_camcan)
summary(VSTM_mod) #Slope=-0.02493, R2=0.206

FamousFace_mod <- lm(Famous.Face.Z~Age, data=all_camcan)
summary(FamousFace_mod)#Slope=-0.02254, R2=0.171

UnfamiliarFace_mod <- lm(Unfamiliar.Face.Z~Age, data=all_camcan)
summary(UnfamiliarFace_mod)#Slope=-0.02514, R2-0.214

FI_mod <- lm(Fluid.Intelligence.Z~Age, data=all_camcan)
summary(FI_mod)#Slope=-0.03583, R2=0.437

Hotel_mod <- lm(Hotel.Z~Age, data=all_camcan)
summary(Hotel_mod)#Slope=-0.01329, R2=0.0583

EE_mod <- lm(Emotional.Expression.Z~Age, data=all_camcan)
summary(EE_mod)#Slope=-0.01857, R2=0.114

# linear trend + confidence interval (all data)
ggplot(all_camcan, aes(x=Age, y=TOT.Z)) +
  geom_point(color="black") +
  geom_smooth(method=lm , color="black", fill="skyblue", se=TRUE, fullrange=TRUE) +
  xlab('Age') +
  ylab('Z Score') +
  #ylim(5.2,5.8) + 
  theme_bw() +
  theme(text=element_text(size=24), 
        axis.text=element_text(size=20, color="black"),
        axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())

