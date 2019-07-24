type<-'c00' #'c00' for cf or 'mean' for ensemble mean
var<-'spfh' #'spfh' specific humidity; 'acpc' accum precip; 'ugrd' uwind; 'vgrd' vwind; 'tmp' temperature
lvl<-'pres' #'sfc' or 'pres'
b_date<-'1985-01-01'
e_date<-'1985-01-31'
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

#use paste function and 'write.table' to create a text file of desired URLs.
filelist<-paste("ftp://ftp.cdc.noaa.gov/Projects/Reforecast2/",yr,"/",yr,mo,"/",yr,mo,dy,"00/",type,"/latlon/",
                var,"_",lvl,"_",yr,mo,dy,"00_",type,".grib2", sep="")
write.table(filelist, file = "data/ivt/raw/filelist.txt", row.names=F, col.names=F, quote=F)

wget -i filelist.txt -r

filelist_t190<-paste("ftP:/ftp.cdc.noaa.gov/Projects/Reforecast2/",yr,"/",yr,mo,"/",yr,mo,dy,"00/",type,"/latlon/",
                     var,"_",lvl,"_",yr,mo,dy,"00_",type,"_t190.grib2", sep="")
write.table(filelist_t190, file = "data/prcp/filelist.txt", row.names=F, col.names=F, quote=F)

##############################################################END########################################################