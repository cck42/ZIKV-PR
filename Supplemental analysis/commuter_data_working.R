library(readr)
library(dplyr)
library(tidyverse)
library(stplanr)
library(readxl)

#commuter_data has columns:
#O = origin regioni
#D = destination region
#Carpool, drove, others, public = breakdown of the flow between that O-D pair by mode of transportation
#Total = total directional flow in that O-D pair
commuter_data <- read_excel("~/fakepath/OD_flow_intros.xlsx")
na.omit(commuter_data)
one_way<-od_oneway(commuter_data)
incidence_region_mo <- read.csv("~/fakepath/incidence_by_region_month.csv")

zikv_flow <- commuter_data %>%
  left_join(incidence_region_mo,by=c("O"="region")) %>%
  mutate(case_spread_total=Total*incidence/1000) %>%
  select(c("O","D","Total","month","Year","total_pop","incidence","realmonth","case_spread_total"))

write.csv(zikv_flow,"~/fakepath/zikv_flow.csv")

flow_with_intros <- read.csv("~/fakepath/zikv_flow_intros.csv")

t.test(case_spread_total~intro,data=flow_with_intros,alternative="greater")

summary(lm(intro~case_spread_total + Total+incidence,data=flow_with_intros))
summary(lm(intro~Total+incidence,data=flow_with_intros))
summary(lm(intro~incidence,data=flow_with_intros))


