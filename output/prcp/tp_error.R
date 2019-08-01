#Calculate arrays of precip error
ondjfma<-readRDS('output/index/tp_idx19842019_ondjfma.rds')
ef<-c('cf','mean')
model<-'ncep_rf2'
obs<-'gpcc'
fhrs<-15

ob<-readRDS(paste('data/prcp/',obs,'_tp_wc_1984_2019.rds',sep=""))
ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')

for(k in 1:length(ef)){
rf<-readRDS(paste('data/prcp/ncep_rf2_tp_',ef[k],'_6_mask.rds',sep=""))
tp_error<-array(NA,c(dim(rf)[1],dim(rf)[2],fhrs,dim(rf)[4]))
tp_error_unbias<-array(NA,c(dim(rf)[1],dim(rf)[2],fhrs,dim(rf)[4]))

  for (i in 1:fhrs){
    tp_error[,,i,i:length(ob[1,1,])]<-rf[,,(i+1),1:(length(ob[1,1,])-i+1)] - ob[,,i:length(ob[1,1,])]
    u<-apply(tp_error[,,i,ev_index],c(1,2),function(x){mean(x,na.rm=T)})
    for(j in 1:length(ob[1,1,])){
      tp_error_unbias[,,i,j]<-tp_error[,,i,j]-u
    }
  }
saveRDS(tp_error,paste('output/prcp/',model,'_',obs,'_tp_error_',ef[k],'.rds',sep=""))
saveRDS(tp_error_unbias,paste('output/prcp/',model,'_',obs,'_tp_error_unbias_',ef[k],'.rds',sep=""))
}

rm(list=ls())

##############################################END##############################################