#Geoht anomaly script
err_type<-'unbias'
rf_type<-'cf' #'cf' or 'mean'
rf_model<-'ncep_rf2'
r_model<-'ncep2'
obs<-'gpcc'
ht<-500
ztime<-6
fday<-15
kmns<-4

mo<-readRDS('output/index/tp_dates19842019.rds')
rf_hgt<-readRDS(paste('data/geoht/',rf_model,'_',rf_type,'_geoht_',ht,'.rds',sep=""))
hgt_anom<-array(NA,c(dim(rf_hgt)[1],dim(rf_hgt)[2],(fday+1),dim(rf_hgt)[4]))

#rf anomaly
for(k in 1:(fday+1)){
  for(i in 1:12){
    anom<-rf_hgt[,,k,which(mo$mon==(i-1))]
    m<-apply(anom,c(1,2),function(x){mean(x,na.rm=T)})
    s<-apply(anom,c(1,2),function(x){sd(x,na.rm=T)})
    m1<-array(NA,c(dim(rf_hgt)[1],dim(rf_hgt)[2],length(anom[1,1,])))
    s1<-array(NA,c(dim(rf_hgt)[1],dim(rf_hgt)[2],length(anom[1,1,])))
    for(j in 1:length(anom[1,1,])){
      s1[,,j]<-s
      m1[,,j]<-m
    }
    
    hgt_anom[,,k,which(mo$mon==(i-1))]<-(anom-m1)/s1
    rm(m,s,m1,s1,anom);gc()
  }
}

saveRDS(hgt_anom,paste('output/geoht/',rf_model,'_',rf_type,'_geoht_anom_',ht,'.rds',sep=""))

rm(rf_hgt)

#reanalysis anomaly
obs_hgt<-readRDS(paste('data/geoht/',r_model,'_geoht_',ht,'_',ztime,'.rds',sep=""))
hgt_anom<-array(NA,c(dim(obs_hgt)[1],dim(obs_hgt)[2],dim(obs_hgt)[3]))

for(i in 1:12){
  anom<-obs_hgt[,,which(mo$mon==(i-1))]
  m<-apply(anom,c(1,2),mean)
  s<-apply(anom,c(1,2),sd)
  m1<-array(NA,c(dim(obs_hgt)[1],dim(obs_hgt)[2],length(anom[1,1,])))
  s1<-array(NA,c(dim(obs_hgt)[1],dim(obs_hgt)[2],length(anom[1,1,])))
  
  for(j in 1:length(anom[1,1,])){
    s1[,,j]<-s
    m1[,,j]<-m
  }
  
  hgt_anom[,,which(mo$mon==(i-1))]<-(anom-m1)/s1
  rm(m,s,m1,s1,anom);gc()
}

saveRDS(hgt_anom,paste('output/geoht/',r_model,'_geoht_anom_',ht,'_',ztime,'.rds',sep=""))

rm(list=ls())

############################################END###########################################