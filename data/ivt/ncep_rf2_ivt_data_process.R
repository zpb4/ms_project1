##NCEP/DOE GEFS v2 REFORECAST DATA PROCESSING SCRIPT
#Purpose: Download and format IVT components into RData Arrays

setwd("h:/project1")
library(stringr)
library(ncdf4)
library(abind)

#-----------------------------------------------------------------------------------------------------
#1) Download data (as needed, graphical interface faster)

#a. Create txt file for 'wget' routine
type<-'c00' #'c00' for cf or 'mean' for ensemble mean
var<-'spfh' #'spfh' specific humidity; 'acpc' accum precip; 'ugrd' uwind; 'vgrd' vwind; 'tmp' temperature
lvl<-'pres' #'sfc' or 'pres'
b_date<-'1985-01-01'
e_date<-'1995-12-31'
mth<-as.POSIXlt(seq(as.Date(b_date), as.Date(e_date),by="days")) 
yr<-mth$year
yr[which(yr>99)]<-yr[which(yr>99)]-100
yr<-str_pad(yr, 2, "left", pad="0")
yr<-c(paste("19",yr[which(yr>19)],sep=""),paste("20",yr[which(yr<=19)],sep=""))
if (all(mth$year<100)==T) yr<-yr[1:length(yr)-1]
mo<-mth$mo+1
dy<-mth$mday

#package to do below
mo<-str_pad(mo, 2, "left", pad="0")
dy<-str_pad(dy, 2, "left", pad="0")

#txt file of URLs for wget
filelist<-paste("ftp://ftp.cdc.noaa.gov/Projects/Reforecast2/",yr,"/",yr,mo,"/",yr,mo,dy,"00/",type,"/latlon/",
                var,"_",lvl,"_",yr,mo,dy,"00_",type,".grib2", sep="")
write.table(filelist, file = "data/ivt/raw/filelist.txt", row.names=F, col.names=F, quote=F)

#same as above but for low res data
filelist_t190<-paste("ftP:/ftp.cdc.noaa.gov/Projects/Reforecast2/",yr,"/",yr,mo,"/",yr,mo,dy,"00/",type,"/latlon/",
                     var,"_",lvl,"_",yr,mo,dy,"00_",type,"_t190.grib2", sep="")
write.table(filelist_t190, file = "data/prcp/filelist_t190.txt", row.names=F, col.names=F, quote=F)

#b. UNIX input
#####################################UNIX##########################################################
wget -i filelist.txt
ncl_convert2nc *.grib2 #convert grib2 files to ncdf
#####################################UNIX##########################################################

#--------------------------------------------------------------------------------------------------
#2) Process .nc files into RDS
  #NOTE: Downloaded files from 1 Dec 84 to 31 Mar 19, 12539 days

var<-c('uwnd','vwnd','spfh','tmp')
ef<-c('cf','mean')

for(j in 1:length(var)){
  
  for(k in 1:length(ef)){
  nc1<-nc_open(paste("data/ivt/raw/",var[j],"_ncep_",ef[k],"_19841201_20190331_hres.nc",sep=""))
  nc2<-nc_open(paste("data/ivt/raw/",var[j],"_ncep_",ef[k],"_19841201_20190331_lres.nc",sep=""))
  fhr1<-ncvar_get(nc1,varid="fhour")
  fhr2<-ncvar_get(nc2,varid="fhour")
  idx<-seq(1,length(fhr1),2)
  if(var[j]=='tmp') idx<-seq(1:length(fhr1))

    for(i in 1:length(idx)){
    dat1<-ncvar_get(nc1,nc1$var[[3]],start=c(1,1,1,idx[i],1),count=c(-1,-1,-1,1,-1))
    dat2<-ncvar_get(nc2,nc2$var[[3]],start=c(1,1,1,idx[i],1),count=c(-1,-1,-1,1,-1))
    lab1<-paste(var[j],ef[k],fhr1[idx[i]],sep="_")
    lab2<-paste(var[j],ef[k],fhr2[idx[i]],sep="_")
    saveRDS(dat1,paste('data/ivt/raw/',lab1,'.rds',sep=""))
    saveRDS(dat2,paste('data/ivt/raw/',lab2,'.rds',sep=""))
    rm(dat1,dat2)
    }
  nc_close(nc1);nc_close(nc2)
  rm(nc1,nc2)
  }
}

#-------------------------------------------------------------------------------------------
#3) Calculate IVT

#a. Create arrays of IVT by forecast hour
n<-16
fhr<-seq(6,(n*24),24)
ef<-c('cf','mean')

#a.i. define multiplication factor array 'z_fac'
uwnd<-readRDS('data/ivt/raw/uwnd_cf_6.rds')
z_fac<-array(NA,c(dim(uwnd)[1],dim(uwnd)[2],dim(uwnd)[3],dim(uwnd)[4]))
z<-c(3750,7500,11250,17500,20000,10000) #scaling factors for NCEP GEFSv2 output 1000 925 850 700 500 300, ref 'Brands et al 2018' and 'IVT PL by model ppt'
#z<-c(3750,7500,11250,12500,10000,10000,10000,5000) #NCEP2 scaling factors 1000  925  850  700  600  500  400  300
for(i in 1:length(z)){
  z_fac[,,i,]<-z[i]
}
rm(uwnd,z)

#a.ii. calculate ivt and save
for (k in 1:length(ef)){
  for (j in 1:length(fhr)) {
  uwnd<-readRDS(paste('data/ivt/raw/uwnd_',ef[k],'_',fhr[j],'.rds',sep=""))
  vwnd<-readRDS(paste('data/ivt/raw/vwnd_',ef[k],'_',fhr[j],'.rds',sep=""))
  spfh<-readRDS(paste('data/ivt/raw/spfh_',ef[k],'_',fhr[j],'.rds',sep=""))
  
  ivt_u<-uwnd*spfh*z_fac #multiply wind component by q and 
  ivt_v<-vwnd*spfh*z_fac
  
  ivt_u<-apply(ivt_u,c(1,2,4),sum) / 9.81
  ivt_v<-apply(ivt_v,c(1,2,4),sum) / 9.81
  
  ivt_tot<-sqrt(ivt_u^2 + ivt_v^2)
  ivt_d<-atan2(ivt_u/ivt_tot,ivt_v/ivt_tot)*(180/pi)+180
  
  saveRDS(ivt_u,paste('data/ivt/raw/ivt_u_',ef[k],'_',fhr[j],'.rds',sep=""))
  saveRDS(ivt_v,paste('data/ivt/raw/ivt_v_',ef[k],'_',fhr[j],'.rds',sep=""))
  saveRDS(ivt_tot,paste('data/ivt/raw/ivt_tot_',ef[k],'_',fhr[j],'.rds',sep=""))
  saveRDS(ivt_d,paste('data/ivt/raw/ivt_d_',ef[k],'_',fhr[j],'.rds',sep=""))
  rm(uwnd,vwnd,spfh,ivtu,ivtv,ivt_tot,ivt_d)
  }
}

rm(list=ls())

#b. Create combined arrays of IVT u,v,tot,d
source('output/index/array_rotate.r')
n<-16
fhr<-seq(6,(n*24),24)
co<-c('u','v','tot','d') 
ef<-c('cf','mean') 
d<-readRDS('data/ivt/raw/ivt_tot_cf_6.rds')
dims<-c(dim(d)[1],dim(d)[2],n,dim(d)[3])
rm(d)

for(i in 1:length(co)){
  for(k in 1:length(ef)){
    ivt_array<-array(NA,dims)
    for (j in 1:length(fhr)){
      ivt<-readRDS(paste('data/ivt/raw/ivt_',co[i],'_',ef[k],'_',fhr[j],'.rds',sep=""))
      ivt_array[,,j,]<-ivt
      rm(ivt)
    }
    ivt_array<-array_rotate(ivt_array,1,2) #rot type 1, 90 left for correct georef
    saveRDS(ivt_array,paste('output/ivt/ncep_rf2_',ef[k],'_ivt_',co[i],'.rds',sep=""))
  }
}

rm(list=ls())

#c. Create array of temp, wind, spfh at given pl
source('output/index/array_rotate.r')
n<-16
fhr<-seq(6,(n*24),24)
co<-c('tmp','uwnd','vwnd','spfh') #might need '_tot' or '_d' 
ef<-c('cf','mean') 
lvl<-925 ; z<-c(1000,925,850,700,500,300)
pl<-which(z==lvl)
d<-readRDS('data/ivt/raw/ivt_tot_cf_6.rds')
dims<-c(dim(d)[1],dim(d)[2],n,dim(d)[3])
rm(d)

for(i in 1:length(co)){
  for(k in 1:length(ef)){
    var_array<-array(NA,dims)
    for (j in 1:length(fhr)){
      var<-readRDS(paste('data/ivt/raw/',co[i],'_',ef[k],'_',fhr[j],'.rds',sep=""))
      var_array[,,j,]<-var[,,pl,]
      rm(var)
    }
    var_array<-array_rotate(var_array,1,2)
    saveRDS(var_array,paste('output/ivt/ncep_rf2_',ef[k],'_',co[i],'_',lvl,'.rds',sep=""))
  }
}

rm(list=ls())


test<-readRDS('data/ivt/ncep_rf2_cf_ivt_u.rds')
length(which(is.na(uwnd)==T))

test<-readRDS('data/geoht/ncep_rf2_cf_geoht_500.rds')
length(which(is.na(test)==T))

test<-readRDS('data/ivt/ncep2_ivt_tot_6.rds')
length(which(is.na(test)==T))

k<-1
na<-c()
for (j in 1:length(fhr)) {
  uwnd<-readRDS(paste('data/ivt/raw/uwnd_',ef[k],'_',fhr[j],'.rds',sep=""))
  n<-length(which(is.na(uwnd)==T))
  na[j]<-c(na,n)
}

s<-sum(na)
##############################################################END########################################################