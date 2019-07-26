library(stringr)
library(POT)

#1) Find 'heavy' to 'extreme' precipitation events non-duplicated at each grid cell and declustered
gpcc_sub_ondjfma<-readRDS('data/prcp/gpcc_tp_wc_1984_2019_ondjfma.rds')
sub_ondjfma<-readRDS('output/index/tp_idx19842019_ondjfma.rds')
sub_pos_ondjfma<-readRDS('output/index/tp_dates19842019_ondjfma.rds')

rw<-rep(19:22,each=3)
co<-rep(18:20,4)

#Simple percentile method
#p<-0.98 #percentile
#n<-round(p*(length(gpcc_sub_ondjfma[1,1,])))
#gpcc_ev<-c()
#for (i in 1:12) {
  #s_dat<-sort(gpcc_sub_ondjfma[rw[i],co[i],])
  #gpcc_ev<-c(gpcc_ev,which(gpcc_sub_ondjfma[rw[i],co[i],]>s_dat[n]))
  #gpcc_ev<-gpcc_ev[!duplicated(gpcc_ev)] #removes duplicate values
#}
#gpcc_ev<-sort(gpcc_ev)

#Top X% of all non-zero precip days not duplicated for each grid cell
#Heavy precip defined as top 1% of days with precip: https://www.globalchange.gov/browse/indicators/heavy-precipitation
gpcc_ev<-c()
p1<-0.95
min<-1.0

for (i in 1:12) {
  s_dat<-sort(gpcc_sub_ondjfma[rw[i],co[i],])
  s_dat<-s_dat[which(s_dat>min)] #reduces vector to only non-zero precip days
  n<-round(p1*(length(s_dat))) #identify top 1% of events in non-zero precip
  gpcc_ev<-c(gpcc_ev,which(gpcc_sub_ondjfma[rw[i],co[i],]>s_dat[n]))
  gpcc_ev<-gpcc_ev[!duplicated(gpcc_ev)] #removes duplicate values
}
gpcc_ev<-sort(gpcc_ev)

#a.ii. Declustering 

arr<-array(NA,c(length(gpcc_sub_ondjfma[1,1,]),2))
gpcc_mn<-apply(gpcc_sub_ondjfma[19:22,18:20,],3,mean) #mean precip over basin

m<-c(rep(0,length(gpcc_sub_ondjfma[1,1,])))
colnames(arr)<-c("obs","time")
m[gpcc_ev]<-gpcc_mn[gpcc_ev]
arr[,1]<-m
arr[,2]<-sub_ondjfma
m_clust<-clust(arr,0,0,clust.max = T)
m[gpcc_ev]<-1
arr[,1]<-m
m_clust1<-clust(arr,0,0,clust.max = F) #gives list of all clusters to pull first day of cluster for each

#create vector of 'DAY 1' of each cluster

d1_ev<-c()
for (i in 1:length(m_clust1)) {
  d1<-as.Date(m_clust1[[i]][1,1],origin = "1970-01-01")
  d1<-which(sub_ondjfma==d1)
  d1_ev<-c(d1_ev,d1)
}

#create vector of cluster sizes

cl_sz<-c()
for (i in 1:length(m_clust1)) {
  cs<-m_clust1[[i]][2,]
  cs<-which(cs>0)
  cs<-length(cs)
  cl_sz<-c(cl_sz,cs)
}
cl_sz<-as.numeric(cl_sz)

gpcc_ev_dates_1<-sub_pos_ondjfma[d1_ev]
gpcc_ev_index_1<-d1_ev
gpcc_ev_dates_max<-as.Date(as.numeric(m_clust[,1]), origin = '1970-01-01')
gpcc_ev_index_max<-as.numeric(m_clust[,3])

ar_tab<-read.table("output/index/ARcatalog_NCEP_NEW_1948-2019_COMPREHENSIVE_20FEB2019.txt", header = T)
ar_tab<-ar_tab[which(ar_tab$Year>=1984),]

mo<-str_pad(ar_tab$Month, 2, "left", pad="0")
dy<-str_pad(ar_tab$Day, 2, "left", pad="0")
ar_tab_dates<-paste(ar_tab$Year,mo,dy,sep = "-")

ar_tab<-cbind(ar_tab,ar_tab_dates) 
ar_match<-c()

for (i in 1:length(gpcc_ev_dates_1)) {
  if (any(ar_tab_dates==as.Date(gpcc_ev_dates_1[i]))==T) {ar_match[i]<-"AR Present"} 
  else if (any(ar_tab_dates==as.Date(gpcc_ev_dates_1[i])+1)==T) {ar_match[i]<-"AR +1 day"}
  else if (any(ar_tab_dates==as.Date(gpcc_ev_dates_1[i])-1)==T) {ar_match[i]<-"AR -1 day"}
  else {ar_match[i]<-"No AR"}
}

#create combined data frame and save .csv as above but with 'AR Matches' added
gpcc_ev_summary<-cbind(gpcc_ev_index_1,as.character(gpcc_ev_dates_1),cl_sz,ar_match)
colnames(gpcc_ev_summary)<-c("Index 1","Dates 1","Length","AR Match")
write.csv(gpcc_ev_summary, file = "output/index/gpcc_ev_summary.csv")

#save
saveRDS(gpcc_ev_dates_1, file = "output/index/gpcc_ev_dates_1.rds")
saveRDS(gpcc_ev_index_1, file = "output/index/gpcc_ev_index_1.rds")
saveRDS(gpcc_ev_dates_max, file = "output/index/gpcc_ev_dates_max.rds")
saveRDS(gpcc_ev_index_max, file = "output/index/gpcc_ev_index_max.rds")

#stat
no_ar<-length(which(ar_match=='No AR')) #ans: 7 / 24 for 95 pcntile
no_ar_pct<-length(which(ar_match=='No AR')) / length(ar_match) #ans: 4.7% / 8.1% for 95 pcntile

#stat2 - total ar precip 
tp_idx<-readRDS('output/index/tp_dates19842019.rds')
tp_data<-readRDS('data/prcp/gpcc_tp_wc_1984_2019.rds')
#define ARs btwn 35 and 42.5 per anomaly plots 
lb<-35.0
ub<-42.5
ar_tab1<-ar_tab[which(ar_tab$Lat>=lb & ar_tab$Lat<=ub),]
ar_idx<-which(tp_idx%in%ar_tab1$ar_tab_dates)
tp_tot<-sum(apply(tp_data[19:22,18:20,],c(1,2),sum))
ar_tot<-sum(apply(tp_data[19:22,18:20,ar_idx],c(1,2),sum))
pcnt<-ar_tot / tp_tot * 100 #55.4%

rm(list=ls())


#################################################END#################################################