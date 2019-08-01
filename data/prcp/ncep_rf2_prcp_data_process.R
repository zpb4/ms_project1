##Data Processing Script for NCEP GEFSv2 Precipitation data

setwd("h:/ms_project1")
library(abind)
library(ncdf4)

#----------------------------------------------------------------------------------------------------------------------------
#1) Configure NCEP GEFv2 Reforecast data
source('output/index/array_rotate.r')
source('data/prcp/gpcc_mask.R')
ondjfma<-readRDS('output/index/tp_idx19842019_ondjfma.rds')
ld<-16 #forecast lead days desired
ztime<-6 #Z time of 
var<-'tp'
ef<-c('cf','mean')
h_idx<-seq(ztime,(24*(ld-1)+ztime),24)
ls<-vector("list",17); ls[[1]]<-c(1,3); ls[[2]]<-c(5,7,9,11);ls[[3]]<-c(13,15,17,19); ls[[4]]<-c(21,23,25,26); ls[[5]]<-27:30
ls[[6]]<-31:34; ls[[7]]<-35:38; ls[[8]]<-39:42; ls[[9]]<-43:45; ls[[10]]<-3; ls[[11]]<-4:7
ls[[12]]<-8:11; ls[[13]]<-12:15; ls[[14]]<-16:19; ls[[15]]<-20:23; ls[[16]]<-24:27; ls[[17]]<-28:31

for(j in 1:length(var)){
  for(k in 1:length(ef)){
    nc1<-nc_open(paste("data/prcp/raw/",var[j],"_ncep_",ef[k],"_19841201_20190331_hres_rg.nc",sep=""))
    nc2<-nc_open(paste("data/prcp/raw/",var[j],"_ncep_",ef[k],"_19841201_20190331_lres_rg.nc",sep=""))
    dat1<-ncvar_get(nc1,nc1$var[[3]]); nc_close(nc1); rm(nc1)
    dat2<-ncvar_get(nc2,nc2$var[[3]]); nc_close(nc2); rm(nc2)
    dat<-array(NA,c(dim(dat1)[1],dim(dat1)[2],16,dim(dat1)[4]))
    for(i in 1:length(ls)){
      if(i<=8){dat[,,i,]<-apply(dat1[,,ls[[i]],],c(1,2,4),sum)}
      else if(i==9){dat[,,i,]<-apply(dat1[,,ls[[i]],],c(1,2,4),sum)}
      else if(i==10){dat[,,i-1,]<-dat1[,,i-1,]+dat2[,,ls[[i]],]}
      else {dat[,,i-1,]<-apply(dat2[,,ls[[i]],],c(1,2,4),sum)}
    }
    rm(dat1,dat2)
    dat<-array_rotate(dat,1,2)
    lab<-paste(var[j],ef[k],ztime,sep="_")
    saveRDS(dat,paste('data/prcp/ncep_rf2_',lab,'.rds',sep=""))
    dat<-gpcc_mask(dat,2)
    saveRDS(dat,paste('data/prcp/ncep_rf2_',lab,'_mask.rds',sep=""))
  }
}

rm(list=ls())

#fhr1<-ncvar_get(nc1,'fhour')
#fhr2<-ncvar_get(nc2,'fhour')
#for(i in 1:length(ls)){
#if(i<10) out<-fhr1[ls[[i]]]
#else out<-fhr2[ls[[i]]]
#print(out)
#}


############################################################END###############################################################