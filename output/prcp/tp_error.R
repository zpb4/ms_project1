#Calculate arrays of precip error

ef<-c('cf','mean')
fhrs<-15

for(k in 1:length(ef)){
ob<-readRDS('data/prcp/gpcc_tp_wc_1984_2019_ondjfma.rds')
rf<-readRDS(paste('data/prcp/ncep_rf2_tp_',ef[k],'_6_ondjfma.rds',sep=""))
tp_error<-array(NA,c(dim(rf)[1],dim(rf)[2],fhrs,dim(rf)[4]))
tp_error_unbias<-array(NA,c(dim(rf)[1],dim(rf)[2],fhrs,dim(rf)[4]))

  for (i in 1:fhrs){
    tp_error[,,i,(i+1):length(ob[1,1,])]<-rf[,,(i+1),1:(length(ob[1,1,])-i)] - ob[,,(i+1):length(ob[1,1,])]
    u<-apply(tp_error[,,i,],c(1,2),function(x){mean(x,na.rm=T)})
    for(j in 1:length(ob[1,1,])){
      tp_error_unbias[,,i,j]<-tp_error[,,i,j]-u
    }
  }
saveRDS(tp_error,paste('output/prcp/tp_error_',ef[k],'_ondjfma.rds',sep=""))
saveRDS(tp_error_unbias,paste('output/prcp/tp_error_unbias_',ef[k],'_ondjfma.rds',sep=""))
}