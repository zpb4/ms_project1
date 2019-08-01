##ERROR for Clusters

rf_model<-'ncep_rf2'
rf_type<-'mean' #'cf' or 'mean'
obs<-'gpcc'
kmns<-4
fdays<-15
lat<-19:22 #box is [19:22,18:20]
lon<-18:20

obs_tp<-readRDS(paste('data/prcp/',obs,'_tp_wc_1984_2019.rds',sep=""))
rf_tp<-readRDS(paste('data/prcp/',rf_model,'_tp_',rf_type,'_6_mask.rds',sep=""))
clus_idx<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
ev_index<-readRDS(paste('output/index/',obs,'_ev_index_1_full.rds',sep=""))

box_error<-array(NA, c(kmns,fdays))

for(i in 1:15){
  for(k in 1:4){
    forc<-rf_tp[lat,lon,i+1,(ev_index[which(clus_idx[,i]==k)]-i+1)]
    forc_mn<-apply(forc,3,function(x){mean(x,na.rm=T)})
    ob<-obs_tp[lat,lon,ev_index[which(clus_idx[,i]==k)]]
    obs_mn<-apply(ob,3,function(x){mean(x,na.rm=T)})
    err<-mean((forc_mn-obs_mn)/obs_mn) * 100
    box_error[k,i]<-err
  }
}

saveRDS(box_error,paste('output/cluster/',rf_model,'_',obs,'_box_error_',rf_type,'.rds',sep=""))

rm(list=ls())


######################################END#####################################
