##Data Processing Script for GPCC Precipitation data

setwd("h:/ms_project1")
library(abind)
library(ncdf4)

#----------------------------------------------------------------------------------------------------------------------------
#1) Configure NCEP GEFv2 Reforecast data
source('output/index/array_rotate.r')
source('data/prcp/gpcc_mask.r')


nc<-nc_open('data/prcp/raw/gpcc_wc_prcp.1982_2019.nc')
gpcc_full<-ncvar_get(nc,varid='precip'); nc_close(nc); rm(nc)
gpcc_full<-array_rotate(gpcc_full,1,1)
gpcc_full<-gpcc_mask(gpcc_full,1)
saveRDS(gpcc_full,'data/prcp/gpcc_tp_wc_1982_2019.rds')

full<-as.POSIXlt(seq(as.Date('1982-01-01'),as.Date('2019-03-31'),by='days'))
sub<-which(full >= '1984-11-30') #cuts off input date with <= for some reason
gpcc_sub<-gpcc_full[,,sub]; rm(gpcc_full)
saveRDS(gpcc_sub,'data/prcp/gpcc_tp_wc_1984_2019.rds')

sub_pos<-full[sub]
sub_ondjfma<-sort(c(which(sub_pos$mo>=9), which(sub_pos$mo<=3)))
sub_pos_ondjfma<-sub_pos[sub_ondjfma]
gpcc_sub_ondjfma<-gpcc_sub[,,sub_ondjfma]
saveRDS(gpcc_sub_ondjfma,'data/prcp/gpcc_tp_wc_1984_2019_ondjfma.rds')
saveRDS(sub_pos_ondjfma,'output/index/tp_dates19842019_ondjfma.rds')
saveRDS(sub_ondjfma,'output/index/tp_idx19842019_ondjfma.rds')
saveRDS(sub_pos,'output/index/tp_dates19842019.rds')


rm(list=ls())


############################################################END###############################################################