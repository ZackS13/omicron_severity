#Data Analysis for Omicron Severity
#Authors: Zachary Strasser and Hossein Estiri
#Data: 4/28/22

#Data should be pulled, clear, and organized into the following columns: with unique categorical variables
#female: 1, 0 (1 representative of female)
#age: integer
#race: "BLACK OR AFRICAN AMERICAN", "WHITE", "OTHER/UNKNOWN", "ASIAN"
#hispanic: 1, 0 (1 representative of hispanic)
#vaccine_status: "N", "First Dose Only", "Fully Vaccinated", "Fully Vaccinated with Booster"
#mortality: Y, N
#hospitalization: Y, N
#Onset_ym: "Wave 2" (Winter 20' - 21'), "Spring 2021", "Delta", "0000" (Omicron)
#Onset: date
#charlson_score: integer  (calculated using comorbidity package on extracted ICD codes)

#Store this table in a dataframe called glm.dat
library(survey)
library(weightit)
library(data.frame)
library(dplyr)
library(lubridate)
library(tidyr)

###################First Perform Fischer Exact Test on the various periods#######################

#filter omicron period and delta period
test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Delta',]
#calculate fisher's exact test for mortality
fisher.test(table(test$Onset_ym, test$mortality))

test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Spring 2021',]  #filter omicron period and spring period
fisher.test(table(test$Onset_ym, test$mortality)) #calculate fisher's exact test for mortality

test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Wave 2',] #filter omicron and wave 2 
fisher.test(table(test$Onset_ym, test$mortality)) #calculate fisher's exact test for mortality

test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Delta',] #filter omicron and delta period
fisher.test(table(test$Onset_ym, test$hospitalization)) #calculate fisher's exact test for hospitalization

test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Spring 2021',] #filter omicron and spring 2021
fisher.test(table(test$Onset_ym, test$hospitalization))#calculate fisher's exact test for hospitalization

test = glm.dat[glm.dat$Onset_ym== '0000' | glm.dat$Onset_ym== 'Wave 2',] #filter omicron and wave 2
fisher.test(table(test$Onset_ym, test$hospitalization)) #calculate fisher's exact test for hospitalization


########################################Now perform IPTW############################################

#function for IPTW weights
outglm <- function(outcome,#outcome of interest
                   dat.aoi,#data for modeling
                     group
                     
){

dat.aoi$label <- as.factor(dat.aoi[,which(colnames(dat.aoi)==outcome)])
dat.aoi <- dat.aoi[,c(1:5,10,12:13)]
dat.aoi$label <- ifelse(dat.aoi$label == "N",0,1)#as.numeric(dat.aoi$label)
W.out <- weightit(Onset_ym ~ vaccine_status+hispanic+race+age+female+charlson_score,
                    data = dat.aoi, estimand = "ATT",focal ="0000" , method = "ebal")

# Now that we have our weights stored in W.out, let's extract them and estimate our treatment effect.
dat.aoi.w <- svydesign(~1, weights = W.out$weights, data = dat.aoi)

logitMod <- svyglm(label ~ Onset_ym+vaccine_status+hispanic+race+age+female+charlson_score, 
              design = dat.aoi.w)
summary <- summary(logitMod)
lreg.or <-exp(cbind(OR = coef(logitMod), confint(logitMod))) ##CIs using profiled log-likelihood
output <- data.frame(round(lreg.or, digits=4))
output$features <- rownames(output)
rownames(output) <- NULL
ps <- data.frame(
  round(
    coef(summary(logitMod))[,4],4))#P(Wald's test)
ps$features <- rownames(ps)
rownames(ps) <- NULL
output <- merge(output,ps,by="features")
output$features <- sub('`', '', output$features, fixed = TRUE)
output$features <- sub('`', '', output$features, fixed = TRUE)
colnames(output) <- c("features","OR","2.5","97.5","P (Wald's test)")
output$outcome <- outcome
output$group <- group


###proportions
pat.agg <- dat.aoi %>% 
  dplyr::group_by(Onset_ym,vaccine_status,label) %>%
  dplyr::summarise(patients=n())
pat.agg$outcome <- outcome
pat.agg$group <- group

rm(logitMod,outcome,group)


return(
  list(ORs= output,
       summary=summary,
       counts = pat.agg)
)

}

#store hosp. OR and CI in hospitalization variable
all.hospitalization <- outglm(outcome = "hospitalization",dat.aoi=glm.dat,group="all")

#store mortality OR and CI in mortality variable
all.mortality <- outglm(outcome = "mortality",dat.aoi=glm.dat,group="all")

