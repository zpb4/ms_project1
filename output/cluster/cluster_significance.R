#significance testing
library(MASS)

err_type<-'bias'
rf_type<-'cf' #'cf' or 'mean'
rf_model<-'ncep_rf2'
obs<-'gpcc'
kmns<-4
repl<-T
days<-c(1,3,5,10,15)
nfe<-10
sig<-0.05

if(err_type=='unbias'){error<-readRDS(paste('output/prcp/',rf_model,'_',obs,'_tp_error_unbias_',rf_type,'.rds',sep=""))} else
  error<-readRDS(paste('output/prcp/',rf_model,'_',obs,'_tp_error_',rf_type,'.rds',sep=""))

clus_idx<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')
ev_index<-ev_index[-c(263,292,295)]##ev index 292 (cf),263(mean) are all NAs, 295 is aberrant

sig_array<-array(NA,c(nfe,290)) ##fix 290
sigv<-c(sig/2,1-(sig/2))

for(j in 1:length(days)){
  for(k in 1:length(kmns)){
    for(i in 1:nfe){
      idx<-sample(ev_index,length(which(clus_idx[,days[j]]==k)),replace = repl)
      err<-apply(error[,,days[j],idx],c(1,2),mean)
      v<-as.vector(err) #remove row/column w/all NAs
      na_idx<-which(is.na(v)==T)
      v<-v[-c(na_idx)]
      sig_array[i,]<-v
      fit<-fitdistr(sig_array[,1],'normal')
      qnorm(sigv,fit$estimate[1],fit$estimate[2])
    }
  }
}
