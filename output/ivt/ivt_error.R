#IVT error script
rf_type<-'mean' #'cf' or 'mean'
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

for(i in 1:fday){
  ivt_err[,,i,(i+1):length(obs_ivt[1,1,])]<-rf_ivt[,,(i+1),1:(length(obs_ivt[1,1,])-i)]-obs_ivt[,,(i+1):(length(obs_ivt[1,1,]))]
}

saveRDS(ivt_err,paste('output/ivt/',rf_model,'_',rf_type,'_ivt_error.rds',sep=""))


#create cluster composites
ivt_comp<-array(NA,c(dim(ivt_err)[1],dim(ivt_err)[2],kmns,fday))

for (i in 1:fday) {
  for (k in 1:kmns){
    ivt_idx<-ev_index[which(cluster_index[,i]==k)]
    ivt_sub<-ivt_err[,,i,ivt_idx]
    ivt_avg<-apply(ivt_sub,c(1,2),function(x){mean(x,na.rm=T)}) #takes mean of 3rd dimension of each array
    
    ivt_comp[,,k,i]<-ivt_avg
  }
}

saveRDS(ivt_comp,paste('output/ivt/',rf_model,'_',rf_type,'_ivt_comp.rds',sep=""))

rm(list=ls())

############################################END###########################################