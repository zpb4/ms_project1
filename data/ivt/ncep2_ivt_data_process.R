#2) Create NCEP Reanalysis II IVT Arrays
source('output/index/array_rotate.r')
ztime<-6
var<-c('air','uwnd','vwnd','rhum')
full<-as.POSIXlt(seq(as.Date('1984-01-01'),as.Date('2019-06-30'),by='days'))
sub<-which(full >= '1984-11-30' & full <= '2019-03-31') #cuts off input date with <= for some reason
rm(full)

for(i in 1:length(var)){
  nc<-nc_open(paste('data/ivt/raw/',var[i],'.wc.rg.19842019.nc',sep=""))
  dat<-ncvar_get(nc,var[i],count=c(-1,-1,8,-1)); nc_close(nc); rm(nc)
  idx<-seq(which(c(0,6,12,18)==ztime),length(dat[1,1,1,]),4)
  dat<-dat[,,,idx]
  dat<-dat[,,,sub]
  saveRDS(dat,paste('data/ivt/raw/ncep2_',var[i],'_',ztime,'.rds',sep="")); rm(dat);gc()
}

rm(list=ls())

#b. Convert RH to SH (q) and calculate IVT arrays
ztime=6
source("data/ivt/rh_to_sh.r") #function to change rh to sh
air<-readRDS(paste('data/ivt/raw/ncep2_air_',ztime,'.rds',sep=""))
rhum<-readRDS(paste('data/ivt/raw/ncep2_rhum_',ztime,'.rds',sep=""))

q<-array(NA,c(dim(air)))
pl<-c(1000,925,850,700,600,500,400,300)

for(i in 1:length(pl)){
  q[,,i,]<-rh_to_sh_K(air[,,i,],pl[i],rhum[,,i,])
}

saveRDS(q,paste('data/ivt/raw/ncep2_q_',ztime,'.rds',sep=""))

rm(list=ls())

#b.iii. IVT arrays
source('output/index/array_rotate.r')
ztime<-6
uwnd<-readRDS('data/ivt/raw/ncep2_uwnd_6.rds')
z_fac<-array(NA,dim(uwnd))
z<-z<-c(3750,7500,11250,12500,10000,10000,10000,5000) #scaling factors for NCEP GEFSv2 output 1000 925 850 700 500 300, ref 'Brands et al 2018' and 'IVT PL by model ppt'
for(i in 1:length(z)){
  z_fac[,,i,]<-z[i]
}

vwnd<-readRDS(paste('data/ivt/raw/ncep2_vwnd_',ztime,'.rds',sep=""))
spfh<-readRDS(paste('data/ivt/raw/ncep2_q_',ztime,'.rds',sep=""))
    
ivt_u<-uwnd*spfh*z_fac #multiply wind component by q and 
ivt_v<-vwnd*spfh*z_fac
rm(uwnd,vwnd,spfh,z_fac,z);gc()
    
ivt_u<-apply(ivt_u,c(1,2,4),sum) / 9.81
ivt_v<-apply(ivt_v,c(1,2,4),sum) / 9.81

ivt_tot<-sqrt(ivt_u^2 + ivt_v^2)
ivt_d<-atan2(ivt_u/ivt_tot,ivt_v/ivt_tot)*(180/pi)+180

ivt_u<-array_rotate(ivt_u,2,1)
ivt_v<-array_rotate(ivt_v,2,1)
ivt_tot<-array_rotate(ivt_tot,2,1)
ivt_d<-array_rotate(ivt_d,2,1)
    
saveRDS(ivt_u,paste('data/ivt/ncep2_ivt_u_',ztime,'.rds',sep=""))
saveRDS(ivt_v,paste('data/ivt/ncep2_ivt_v_',ztime,'.rds',sep=""))
saveRDS(ivt_tot,paste('data/ivt/ncep2_ivt_tot_',ztime,'.rds',sep=""))
saveRDS(ivt_d,paste('data/ivt/ncep2_ivt_d_',ztime,'.rds',sep=""))

ondjfma<-readRDS('output/index/tp_idx19842019_ondjfma.rds')

ivt_u<-ivt_u[,,ondjfma]
ivt_v<-ivt_v[,,ondjfma]
ivt_tot<-ivt_tot[,,ondjfma]
ivt_d<-ivt_d[,,ondjfma]

saveRDS(ivt_u,paste('data/ivt/ncep2_ivt_u_',ztime,'_ondjfma.rds',sep=""))
saveRDS(ivt_v,paste('data/ivt/ncep2_ivt_v_',ztime,'_ondjfma.rds',sep=""))
saveRDS(ivt_tot,paste('data/ivt/ncep2_ivt_tot_',ztime,'_ondjfma.rds',sep=""))
saveRDS(ivt_d,paste('data/ivt/ncep2ivt_d_',ztime,'_ondjfma.rds',sep=""))

rm(list=ls())

#################################################END##################################################
