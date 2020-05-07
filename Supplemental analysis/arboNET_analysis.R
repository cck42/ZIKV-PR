library(readr)
library(dplyr)
library(plyr)
library(tidyverse)
library(stplanr)
library(readxl)
library(lubridate)

epiData <- read_excel("~/fakepath/arboNET_epi_data.xlsx")
fips <- read_excel("~/fakepath/fips_tidy.xlsx")
census_data <- read.csv("~/fakepath/census_pop_estimates.csv")

epiYM <- epiData %>%
  full_join(fips, by=c("fipscode"="fips_long"))

grouped_cases<-ddply(epiYM,c("region","month","Year"),summarise,total_cases=sum(COUNT))
grouped_pop <- ddply(census_data,"region",summarise,total_pop=sum(as.numeric(est_2016)),.inform="TRUE")

incidence_table <- grouped_cases %>%
  full_join(grouped_pop, by=c("region"="region")) %>%
  mutate(incidence=(total_cases*100000/total_pop)) %>%
  mutate(realmonth=(as.numeric(Year)*12+month))

write.csv(incidence_table,"~/fakepath/incidence_by_region_month.csv")

cases_by_month_region <- incidence_table %>% 
  ggplot(aes(x=realmonth, y=incidence, group=as.factor(region), color=as.factor(region))) +
  geom_line() +
  ggtitle("Zika virus incidence by region, 2016") +
  ylab("Monthly incidence per 100000") +
  xlab("Month") +
  xlim(24180,24216)#+

cases_by_month_region + scale_colour_manual(name="Region\ in\ Puerto\ Rico",values=c("#C12352","#CE0808", "#B43A83", "#A74D9E","#7A698D","#826393","#8D5D9A","#BA2F6D"),
                       breaks=c("region_1", "region_2", "region_3","region_4","region_5","region_6","region_7","region_8"),
                       labels=c("Region 1","Region 2","Region 3","Region 4","Region 5","Region 6","Region 7","Region 8")) 

cases_by_month_region + scale_colour_manual(name="Region\ in\ Puerto\ Rico",values=c("gray","red", "yellow", "orange","green","pink","blue","cyan"),
                                            breaks=c("region_1", "region_2", "region_3","region_4","region_5","region_6","region_7","region_8"),
                                            labels=c("Region 1","Region 2","Region 3","Region 4","Region 5","Region 6","Region 7","Region 8")) 



cases_by_region<-ddply(epiYM,"region",summarise,total_cases=sum(COUNT))
grouped_pop <- ddply(census_data,"region",summarise,total_pop=sum(as.numeric(est_2016)),.inform="TRUE")
incidence_by_region <- cases_by_region %>%
  full_join(grouped_pop, by=c("region"="region")) %>%
  mutate(incidence=(total_cases*100000/total_pop))

write.csv(incidence_by_region,"~/fakepath/incidence_by_region_total.csv")
