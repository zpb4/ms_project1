#IVT anomaly script
rf_type<-'cf' #'cf' or 'mean'
rf_model<-'ncep_rf2'
r_model<-'ncep2'
obs<-'gpcc'
ztime<-6
fday<-15
kmns<-4

cluster_index<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
obs_ivt<-readRDS(paste('data/ivt/',r_model,'_ivt_tot_',ztime,'.rds',sep=""))
rf_ivt<-readRDS(paste('data/ivt/',rf_model,'_',rf_type,'_ivt_tot.rds',sep=""))
ivt_err<-array(NA,c(dim(obs_ivt)[1],dim(obs_ivt)[2],fday,dim(obs_ivt)[3]))
ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')
ev_index<-ev_index[-c(263,292,295)]##ev index 292 (cf),263(mean) are all NAs, 295 is aberrant

#IVT anomaly

mo<-readRDS('output/index/tp_dates19842019.rds')
rf_ivt<-readRDS(paste('data/ivt/',rf_model,'_',rf_type,'_ivt_tot.rds',sep=""))
ivt_anom<-array(NA,c(dim(rf_ivt)[1],dim(rf_ivt)[2],(fday+1),dim(rf_ivt)[4]))

#rf anomaly
for(k in 1:(fday+1)){
  for(i in 1:12){
    anom<-rf_ivt[,,k,which(mo$mon==(i-1))]
    m<-apply(anom,c(1,2),mean)
    s<-apply(anom,c(1,2),sd)
    m1<-array(NA,c(dim(rf_ivt)[1],dim(rf_ivt)[2],length(anom[1,1,])))
    s1<-array(NA,c(dim(rf_ivt)[1],dim(rf_ivt)[2],length(anom[1,1,])))
    for(j in 1:length(anom[1,1,])){
      s1[,,j]<-s
      m1[,,j]<-m
    }
    
    ivt_anom[,,k,which(mo$mon==(i-1))]<-(anom-m1)/s1
    rm(m,s,m1,s1,anom);gc()
  }
}

saveRDS(ivt_anom,paste('output/ivt/',rf_model,'_',rf_type,'_ivt_anom.rds',sep=""))
rm(rf_ivt)

#reanalysis anomaly
obs_ivt<-readRDS(paste('data/ivt/',r_model,'_ivt_tot_',ztime,'.rds',sep=""))
ivt_anom<-array(NA,c(dim(obs_ivt)[1],dim(obs_ivt)[2],dim(obs_ivt)[3]))

for(i in 1:12){
  anom<-obs_ivt[,,which(mo$mon==(i-1))]
  m<-apply(anom,c(1,2),mean)
  s<-apply(anom,c(1,2),sd)
  m1<-array(NA,c(dim(obs_ivt)[1],dim(obs_ivt)[2],length(anom[1,1,])))
  s1<-array(NA,c(dim(obs_ivt)[1],dim(obs_ivt)[2],length(anom[1,1,])))
  
  for(j in 1:length(anom[1,1,])){
    s1[,,j]<-s
    m1[,,j]<-m
  }
  
  ivt_anom[,,which(mo$mon==(i-1))]<-(anom-m1)/s1
  rm(m,s,m1,s1,anom);gc()
}

saveRDS(ivt_anom,paste('output/ivt/',r_model,'_ivt_anom_',ztime,'.rds',sep=""))
rm(obs_ivt)

#anomaly error
rf_anom<-readRDS(paste('output/ivt/',rf_model,'_',rf_type,'_ivt_anom.rds',sep=""))
obs_anom<-readRDS(paste('output/ivt/',r_model,'_ivt_anom_',ztime,'.rds',sep=""))

anom_err<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],fday,dim(obs_anom)[3]))

for(i in 1:fday){
  anom_err[,,i,(i+1):length(obs_anom[1,1,])]<-rf_anom[,,(i+1),1:(length(obs_anom[1,1,])-i)]-obs_anom[,,(i+1):(length(obs_anom[1,1,]))]
}

saveRDS(anom_err,paste('output/ivt/',rf_model,'_',rf_type,'_ivt_anom_err.rds',sep=""))

rm(rf_anom,obs_anom,anom_err)

#composite of observed and error
obs_anom<-readRDS(paste('output/ivt/',r_model,'_ivt_anom_',ztime,'.rds',sep=""))
anom_err<-readRDS(paste('output/ivt/',rf_model,'_',rf_type,'_ivt_anom_err.rds',sep=""))
obs_comp<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],kmns,fday))
err_comp<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],kmns,fday))

for (i in 1:fday) {
  for (k in 1:kmns){
    ivt_idx<-ev_index[which(cluster_index[,i]==k)]
    err_sub<-anom_err[,,i,ivt_idx]
    obs_sub<-obs_anom[,,ivt_idx]
    err_avg<-apply(err_sub,c(1,2),function(x){mean(x,na.rm=T)}) #takes mean of 3rd dimension of each array
    obs_avg<-apply(obs_sub,c(1,2),function(x){mean(x,na.rm=T)})
    
    err_comp[,,k,i]<-err_avg
    obs_comp[,,k,i]<-obs_avg
  }
}

saveRDS(err_comp,paste('output/ivt/',r_model,'_',rf_type,'_ivt_obs_comp_',ztime,'.rds',sep=""))
saveRDS(obs_comp,paste('output/ivt/',rf_model,'_',rf_type,'_ivt_err_comp.rds',sep=""))

rm(list=ls())

############################################END###########################################