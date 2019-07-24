##Data Processing Script for Precipitation data

setwd("h:/project1")
library(stringr)
library(ncdf4)

#----------------------------------------------------------------------------------------------------------------------------
#1) Download GPCC data

#a. Full Daily data 1982 to 2016
yr<-(1982:2016) 

#use paste function and 'write.table' to create a text file of desired URLs.
filelist<-paste("https://opendata.dwd.de/climate_environment/GPCC/full_data_daily_V2018/full_data_daily_v2018_",yr,".nc.gz", sep="")
write.table(filelist, file = "data/prcp/filelist.txt", row.names=F, col.names=F, quote=F) #row name, col names and quotations not desired

##cygwin wget download
cd h:/project1/data/prcp  #set working directory in cygwin
wget -i filelist.txt  #pulls listed data from text file and downloads
gunzip f*.gz #unzips all files starting with 'f' and ending in '.gz'

#for reference
taskkill /IM wget.exe #will kill wget or any command ongoing in 'tasklist' if unable to stop

#b. First guess data 2009 to 2016 for comparison to 'Full Daily'
yr<-rep(2009:2016,each = 12) 
mo<-rep(1:12, length(2009:2016)) #repeats 1 to 12 by the number of years
mo<-str_pad(mo, 2, "left", pad="0")

filelist<-paste("https://opendata.dwd.de/climate_environment/GPCC/first_guess_daily/",yr,"/first_guess_daily_",yr,mo,".nc.gz", sep="")
write.table(filelist, file = "data/prcp/filelist.txt", row.names=F, col.names=F, quote=F) #row name, col names and quotations not desired

#####################################UNIX##########################################################
cd h:/project1/data/prcp  #set working directory in cygwin
wget -i filelist.txt  #pulls listed data from text file and downloads
gunzip f*.gz #unzips all files starting with 'f' and ending in '.gz'
#####################################UNIX##########################################################

#c. First guess data 2016 to 2019 for dataset extension
yr<-c(rep(2017:2018,each = 12),rep(2019,3)) 
mo<-c(rep(1:12, length(2017:2018)),(1:3)) #repeats 1 to 12 by the number of years
#package to do below
mo<-str_pad(mo, 2, "left", pad="0")
mo[8:11]<-paste(mo[8:11],"_update",sep="")

#use paste function and 'write.table' to create a text file of desired URLs.
filelist<-paste("https://opendata.dwd.de/climate_environment/GPCC/first_guess_daily/",yr,"/first_guess_daily_",yr,mo,".nc.gz", sep="")
write.table(filelist, file = "data/prcp/filelist.txt", row.names=F, col.names=F, quote=F) #row name, col names and quotations not desired

#####################################UNIX##########################################################
cd h:/project1/data/prcp  #set working directory in cygwin
wget -i filelist.txt  #pulls listed data from text file and downloads
gunzip f*.gz #unzips all files starting with 'f' and ending in '.gz'
mv f*.nc ./raw #moves all files to 'raw' directory
#####################################UNIX##########################################################


#-----------------------------------------------------------------------------------------------------------------------------

#2) Regrid downloaded NCEP reforecast data to match GPCC data (see ')

#####################################UNIX##########################################################
cat > mygrid << EOF
gridtype = lonlat
xsize    = 25
ysize    = 30
xfirst   = -139.5
xinc     = 1.0
yfirst   = 30.5
yinc     = 1.0
EOF

cdo remapbil,mygrid tp_ncep_cf_19841201_20190331_hres.nc tp_ncep_cf_19841201_20190331_hres_rg.nc #high res data
cdo remapbil,mygrid tp_ncep_cf_19841201_20190331_lres.nc tp_ncep_cf_19841201_20190331_lres_rg.nc #low res data
#####################################UNIX##########################################################dvvzdsf

#2)Configure data to georeferenced arrays for processing

##GPCC Compile and orient
library(pracma) #has matrix rotation

yr<-(1982:2016)

for (i in 1:length(yr)){
  loc<-paste("data/prcp/raw/full_data_daily_v2018_",yr[i],".nc",sep="")
  nc<-nc_open(loc)
  tp<-ncvar_get(nc,varid="p")
  nc_close(nc)
  rm(nc)
  if (i==1) gpcc_tp_array<-tp else
    gpcc_tp_array<-abind(gpcc_tp_array,tp,along=3)
  rm(tp)
}

gpcc_tp_array<-gpcc_tp_array[,,-c(ly)]

save(gpcc_tp_array,file="data/r_data/obs/tp_sum/gpcc_tp_array.RData")

gpcc_tp_array_flip<-array(NA,c(20,17,4380))

for(i in 1:length(gpcc_tp_array_flip[1,1,])){
  gpcc_tp_array_flip[,,i]<-rot90(as.matrix(gpcc_tp_array[,,i]),k=1) #pracma 'rot90' function
}

save(gpcc_tp_array_flip,file="data/r_data/obs/tp_sum/gpcc_tp_array_flip.RData")
############################################################END###############################################################