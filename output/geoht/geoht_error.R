#Geoht anomaly script
err_type<-'unbias'
rf_type<-'mean' #'cf' or 'mean'
rf_model<-'ncep_rf2'
r_model<-'ncep2'
obs<-'gpcc'
ht<-500
ztime<-6
fday<-15
kmns<-4

cluster_index<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')
ev_index<-ev_index[-c(263,292,295)]##ev index 292 (cf),263(mean) are all NAs, 295 is aberrant

#anomaly error
rf_anom<-readRDS(paste('output/geoht/',rf_model,'_',rf_type,'_geoht_anom_',ht,'.rds',sep=""))
obs_anom<-readRDS(paste('output/geoht/',r_model,'_geoht_anom_',ht,'_',ztime,'.rds',sep=""))

anom_err<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],fday,dim(obs_anom)[3]))

for(i in 1:fday){
  anom_err[,,i,(i+1):length(obs_anom[1,1,])]<-rf_anom[,,(i+1),1:(length(obs_anom[1,1,])-i)]-obs_anom[,,(i+1):(length(obs_anom[1,1,]))]
}

saveRDS(anom_err,paste('output/geoht/',rf_model,'_',rf_type,'_geoht_anom_err_',ht,'.rds',sep=""))

rm(rf_anom,obs_anom,anom_err)

#composite of observed and error
obs_anom<-readRDS(paste('output/geoht/',r_model,'_geoht_anom_',ht,'_',ztime,'.rds',sep=""))
anom_err<-readRDS(paste('output/geoht/',rf_model,'_',rf_type,'_geoht_anom_err_',ht,'.rds',sep=""))
obs_comp<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],kmns,fday))
err_comp<-array(NA,c(dim(obs_anom)[1],dim(obs_anom)[2],kmns,fday))

for (i in 1:fday) {
  for (k in 1:kmns){
    hgt_idx<-ev_index[which(cluster_index[,i]==k)]
    err_sub<-anom_err[,,i,hgt_idx]
    obs_sub<-obs_anom[,,hgt_idx]
    err_avg<-apply(err_sub,c(1,2),function(x){mean(x,na.rm=T)}) #takes mean of 3rd dimension of each array
    obs_avg<-apply(obs_sub,c(1,2),function(x){mean(x,na.rm=T)})
    
    err_comp[,,k,i]<-err_avg
    obs_comp[,,k,i]<-obs_avg
  }
}

saveRDS(obs_comp,paste('output/geoht/',r_model,'_',rf_type,'_geoht_obs_comp_',ht,'_',ztime,'.rds',sep=""))
saveRDS(err_comp,paste('output/geoht/',rf_model,'_',rf_type,'_geoht_err_comp_',ht,'.rds',sep=""))

rm(list=ls())

############################################END###########################################