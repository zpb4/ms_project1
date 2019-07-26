#Create mask profile including ocean and interior 

library(pracma) 
library(ncdf4)
library(maps)

setwd("h:/GPCC_1982_2019")
nc<-nc_open("full.data_daily_v2018_1982.nc")
lon<-ncvar_get(nc,varid = "lon")
lat<-ncvar_get(nc,varid = "lat")
prcp<-ncvar_get(nc,varid = "precip")
nc_close(nc); rm(nc)

llon<-which(lon<=-115.5 & lon>=-139.5)
llat<-which(lat>=30.5 & lat<=59.5)

prcp<-prcp[llon,llat,1]

mask<-rot90(as.matrix(prcp,k=1))

View(mask)

mask[1,12:25]<-NA
mask[2,13:25]<-NA
mask[3,15:25]<-NA
mask[4,16:25]<-NA
mask[5,18:25]<-NA
mask[6,19:25]<-NA
mask[7,20:25]<-NA
mask[8,22:25]<-NA
mask[9,24:25]<-NA
mask[10,25]<-NA

gpcc_mask<-which(is.na(mask)==T)

saveRDS(gpcc_mask,'h:/ms_project1/output/index/gpcc_mask.rds')

mask[gpcc_mask]<-NA
mask[which(is.na(mask)==F)]<-1

par(mar=c(3,4,3,0))

dat_ras<-raster(mask,xmn=-140,xmx=-115,ymn=30,ymx=60)
plot(dat_ras, main="GPCC Cluster Area",legend=F)
map('world',add=T)#,xlim = c(-130,-115),ylim=c(30,60), add=T)
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona','utah','colorado','new mexico'),add=T)#,
    #xlim = c(-130,-115),add=T)
polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)

gpcc_sub_ondjfma<-readRDS('data/prcp/gpcc_tp_wc_1984_2019_ondjfma')
gpcc1<-gpcc_sub_ondjfma[,,1]
gpcc2<-gpcc_sub_ondjfma[,,2]
gpcc1[which(is.na(gpcc1)==F)]<-1
gpcc2[which(is.na(gpcc2)==F)]<-1
gpcc2[19:22,18:20,1]<-NA

par(mfrow=c(1,2))

dat_ras<-raster(gpcc1,xmn=-140,xmx=-115,ymn=30,ymx=60)
plot(dat_ras, main="GPCC Cluster Area",legend=F)
map('world',add=T)#,xlim = c(-130,-115),ylim=c(30,60), add=T)
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona','utah','colorado','new mexico'),add=T)#,
#xlim = c(-130,-115),add=T)
polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)

dat_ras<-raster(gpcc2,xmn=-140,xmx=-115,ymn=30,ymx=60)
plot(dat_ras, main="GPCC Cluster Area",legend=F)
map('world',add=T)#,xlim = c(-130,-115),ylim=c(30,60), add=T)
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona','utah','colorado','new mexico'),add=T)#,
#xlim = c(-130,-115),add=T)
polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)

rm(list=ls())

#################################################END#################################################