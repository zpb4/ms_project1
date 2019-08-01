#2) Process .nc files into RDS
#NOTE: Downloaded files from 1 Dec 84 to 31 Mar 19, 12539 days

ht<-500
ef<-'mean'#c('cf','mean')
  
for(k in 1:length(ef)){
  nc1<-nc_open(paste("data/geoht/raw/hgt",ht,"_ncep_",ef[k],"_19841201_20190331_hres.nc",sep=""))
  nc2<-nc_open(paste("data/geoht/raw/hgt",ht,"_ncep_",ef[k],"_19841201_20190331_lres.nc",sep=""))
  fhr1<-ncvar_get(nc1,varid="fhour")
  fhr2<-ncvar_get(nc2,varid="fhour")
  if(ef[k]=='mean') idx1<-c(2,6,10,seq(14,length(fhr1),4)) else
  idx1<-c(2,6,11,seq(15,length(fhr1),4))
  idx2<-seq(3,length(fhr2),4)
  for(i in 1:length(idx1)){
    dat1<-ncvar_get(nc1,nc1$var[[3]],start=c(1,1,1,idx1[i],1),count = c(-1,-1,1,1,-1))
    dat2<-ncvar_get(nc2,nc2$var[[3]],start=c(1,1,1,idx2[i],1),count = c(-1,-1,1,1,-1))
    lab1<-paste(ht,ef[k],fhr1[idx1[i]],sep="_")
    lab2<-paste(ht,ef[k],fhr2[idx2[i]],sep="_")
    saveRDS(dat1,paste('data/geoht/raw/ncep_rf2_',lab1,'.rds',sep=""))
    saveRDS(dat2,paste('data/geoht/raw/ncep_rf2_',lab2,'.rds',sep=""))
    rm(dat1,dat2)
  }
  nc_close(nc1);nc_close(nc2)
  rm(nc1,nc2)
}

#b. Create combined arrays
source('output/index/array_rotate.r')
n<-16
fhr<-seq(6,(n*24),24)
ht<-500
ef<-c('cf','mean') 
d<-readRDS('data/geoht/raw/500_cf_6.rds')
dims<-c(dim(d)[1],dim(d)[2],n,dim(d)[3])
rm(d)

for(k in 1:length(ef)){
  hgt_array<-array(NA,dims)
  for (j in 1:length(fhr)){
    hgt<-readRDS(paste('data/geoht/raw/',ht,'_',ef[k],'_',fhr[j],'.rds',sep=""))
    hgt_array[,,j,]<-hgt
    rm(hgt)
  }
  hgt_array<-array_rotate(hgt_array,1,2) #rot type 1, 90 left for correct georef
  saveRDS(hgt_array,paste('data/geoht/ncep_rf2_',ef[k],'_geoht_',ht,'.rds',sep=""))
}


rm(list=ls())