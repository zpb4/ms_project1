#2) Create NCEP Reanalysis II Geopotential Height Arrays
source('output/index/array_rotate.r')
ztime<-6
hgt<-500
full<-as.POSIXlt(seq(as.Date('1984-01-01'),as.Date('2019-06-30'),by='days'))
sub<-which(full >= '1984-11-30' & full <= '2019-03-31') #cuts off input date with >= for some reason
rm(full)

nc<-nc_open(paste('data/geoht/raw/hgt.wc.rg.',hgt,'.19842019.nc',sep=""))
dat<-ncvar_get(nc,'hgt'); rm(nc)
idx<-seq(which(c(0,6,12,18)==ztime),length(dat[1,1,]),4)
dat<-dat[,,idx]
dat<-dat[,,sub]
dat<-array_rotate(dat,2,1)
saveRDS(dat,paste('data/geoht/ncep2_geoht_',hgt,'_',ztime,'.rds',sep=""))

rm(list=ls())