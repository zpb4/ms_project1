#Project 1 - Sacramento River Watershed - Folsom Reservoir
#Watershed Area N38.25-N42.75, W123.75 - 119.25 (-123.75 - -119.25 or 236.25 - 240.75 Deg E)

#WORKING DRIVE:
setwd("H:/Projects/Project1_Sac_Folsom/Data")

#PACKAGES:
#library(maps) etc

#----------------------------------------------------------------------------------------------------------------------
#                                         MAIN PLOTTING ScRIPT
#----------------------------------------------------------------------------------------------------------------------

#1) Plot IVT Precip Anomaly

source("H:/Projects/Project1_Sac_Folsom/Scripts/R/plot_ar_tp_anomaly.R")

#2) Cluster Error Plots

load("Data/R_Data/err/cluster/sf_tp_clusters_ndjfm_6_na")

man_idx<-rbind(c(4,2,3,1),c(4,3,2,1),c(1,2,4,3),c(2,4,1,3)) #3 is (4,2,3,1), #1 (3,2,4,1) -- for whole w coast

days<-c(3,5,10,14)

mycol<-brewer.pal(11,"RdYlGn")
mycol[6]<-"white"

par(mfrow=c(1,4))
for(i in 1:4){
  for(k in 1:4) {
    
    f_vec<-rep(NA,266)
    f_vec[which(is.na(cluster_array_ndjfm_6_wc[1,,1])==F)]<-sf_tp_clusters_ndjfm_6_wc[((days[i]-1)*4+man_idx[i,k]),]
    my_matrix<-matrix(f_vec,ncol = 14,byrow = F)
    
    lab<-paste(days[i]," day forecast",sep="")
    lab2<-paste("Cluster ",k,sep ="")
    
    clus_cnt<-length(which(cluster_index_array_ndjfm_6_wc[,days[i]]==man_idx[i,k]))
    cnt<-paste(clus_cnt,"/ 94 events")
    
    dat_ras<-raster(my_matrix,xmn=-135.75,xmx=-114.75,ymn=30.75,ymx=59.25)
    plot(dat_ras,legend = F,breaks=c(-50,-40,-30,-20,-10,-3,3,10,20,30,40,50), 
         col=mycol, xlab="Longitude (Deg E)",ylab="Latitude (Deg N)",
         main=c("Average Error (mm)",lab2, cnt),sub=lab, font.sub = 2)
    
    plot(dat_ras, legend.only = T, breaks=c(-50,-40,-30,-20,-10,-3,3,10,20,30,40,50), 
         col=mycol, legend.shrink=1.01, axis.args=list(cex.axis=0.75)) 
    #legend.args = list(text = 'Avg Error (mm)', side = 4, font = 2)) add legend text if desired
    
    map('world',xlim = c(-135.75,-114.75),ylim=c(30.75,59.25), add=T)
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        xlim = c(-135.75,-114.75),add=T)
    polygon(c(-123.75,-123.75,-119.25,-119.25,-123.75),y = c(38.25,42.75,42.75,38.25,38.25),lwd=3)
  }
}

load("data/r_data/err/cluster/sf_tp_clusters_ndjfm_6.rdata")
load("data/r_data/err/cluster/cluster_array_ndjfm_6.rdata")

man_idx<-rbind(c(1,3,2,4),c(4,1,3,2),c(4,1,3,2),c(2,4,3,1)) #3 is (1,3,2,4) -- for just US w coast

days<-c(3,5,10,14)

mycol<-brewer.pal(11,"RdYlGn")
mycol[6]<-"white"

par(mfrow=c(1,4))
for(i in 1:4){
  for(k in 1:4) {
    
    f_vec<-rep(NA,88)
    f_vec[which(is.na(cluster_array_ndjfm_6[1,,1])==F)]<-sf_tp_clusters_ndjfm_6[((days[i]-1)*4+man_idx[i,k]),]
    my_matrix<-matrix(f_vec,ncol = 8,byrow = F)
    
    lab<-paste(days[i]," day forecast",sep="")
    lab2<-paste("Cluster ",k,sep ="")
    
    clus_cnt<-length(which(cluster_index_array_ndjfm_6[,days[i]]==man_idx[i,k]))
    cnt<-paste(clus_cnt,"/ 94 events")
    
    dat_ras<-raster(my_matrix,xmn=-125.25,xmx=-113.25,ymn=32.25,ymx=48.75)
    plot(dat_ras,legend = F,breaks=c(-50,-40,-30,-20,-10,-3,3,10,20,30,40,50), 
         col=mycol, xlab="Longitude (Deg E)",ylab="Latitude (Deg N)",
         main=c("Average Error (mm)",lab2, cnt),sub=lab, font.sub = 2)
    
    plot(dat_ras, legend.only = T, breaks=c(-50,-40,-30,-20,-10,-3,3,10,20,30,40,50), 
         col=mycol, legend.shrink=1.01, axis.args=list(cex.axis=0.75)) 
    #legend.args = list(text = 'Avg Error (mm)', side = 4, font = 2)) add legend text if desired
    
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        xlim = c(-125.25,-113.25),add=T)
    polygon(c(-123.75,-123.75,-119.25,-119.25,-123.75),y = c(38.25,42.75,42.75,38.25,38.25),lwd=3)
    
    err<-format(box_error_array[man_idx[i,k],days[i]],digits = 3)
    err<-paste(err,"% Error")
    legend("topright",err, cex = .8, xjust = 1,text.font = 2)
    
  }
}


#2) Plot IVT Error for each cluster

cluster_index<-readRDS('output/cluster/ncep_rf2_gpcc_cluster_idx_mean_man.rds')
ivt_comp<-readRDS('output/ivt/ncep_rf2_mean_ivt_comp.rds')
days<-c(1,3,5,10,14)

par(mfrow=c(1,4))

for(i in 1:5){
  d<-paste(days[i]," day forecast",sep="")
  
  for(k in 1:4){
    #par(mar=c(4,1.5,4,1.5))
    if(k==1)par(mar=c(3,3,1,0))
    if(k==2)par(mar=c(3,3,1,2.5))
    if(k==3)par(mar=c(3,2,1,3.5))
    if(k==4)par(mar=c(3,0.5,1,5))
    
    cl<-paste("Cluster ",k,sep="")
    clus_cnt<-length(which(cluster_index[,days[i]]==k))
    cnt<-paste(clus_cnt,"/ 292 events")
    
    mybreaks<-c(seq(-460,-10,by=10),seq(10,460,by=10))
    
    mat<-matrix(ivt_comp[,1:46,k,days[i]],ncol=46)
    dat_ras<-raster(mat,xmn=-160,xmx=-115,ymn=20,ymx=60)
    
    mycat<-cut(dat_ras,breaks=mybreaks)
    mycolpal<-colorRampPalette(c("red","white","green"))
    mycol<-mycolpal(length(mybreaks)-1)#[mycat]
    
    plot(dat_ras, col=mycol,breaks=mybreaks, #main="IVT Error",asp=1, 
         legend = F,axes =F)
    map('world', add=T) #,xlim = c(-160,-100),ylim=c(20,60)
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        add=T) #xlim = c(-161.25,-111.25),
    axis(1,at=c(seq(-160,-100,10)),labels=c("W160","W150","W140","W130","W120","W110","W100"),cex.axis=.75)
    if(k==1) axis(2,at=c(seq(20,60,10)),labels=c("N20","N30","N40","N50","N60"),las=2,cex.axis=.75)
    if(k==4) plot(dat_ras,legend.only=T,breaks=mybreaks,col=mycol,legend.shrink=1.00,
                  axis.args=list(at=seq(-450,450,50),labels=seq(-450,450,50),cex.axis=.8),
                  legend.args=list(text='IVT (kg m s-1)',side=2,line=.3,cex=.8))
    }
}


#3) Plot Geopotential Height Anomaly Contour (obs - NCEPII) 
cluster_index<-readRDS('output/cluster/ncep_rf2_gpcc_cluster_idx_cf_man.rds')
err_comp<-readRDS('output/geoht/ncep_rf2_cf_geoht_err_comp_500.rds')
obs_comp<-readRDS('output/geoht/ncep2_cf_geoht_obs_comp_500_6.rds')
days<-c(1,3,5,10,14)


par(mfrow=c(1,4))
#par(mar=c(4,5,4,1))
#par(mar=c(2,0,2,0))
for(i in 1:5){
  d<-paste(days[i]," day forecast",sep="")
  
  for(k in 1:4){
    #par(mar=c(3,2,1,2))
    if(k==1)par(mar=c(3,3,1,0))
    if(k==2)par(mar=c(3,3,1,2.5))
    if(k==3)par(mar=c(3,2,1,3.5))
    if(k==4)par(mar=c(3,0.5,1,5))
    
    cl<-paste("Cluster ",k,sep="")
    clus_cnt<-length(which(cluster_index[,days[i]]==k))
    cnt<-paste(clus_cnt,"/ 94 events")
    
    mybreaks<-c(seq(-2,-.05,by=.05),seq(.05,2,by=.05))
    
    mat<-matrix(obs_comp[,1:46,k,i],ncol=46)
    dat_ras<-raster(mat,xmn=-160,xmx=-115,ymn=20,ymx=60)
    
    mat1<-matrix(err_comp[,1:46,k,i],ncol=46)
    dat_ras1<-raster(mat1,xmn=-160,xmx=-115,ymn=20,ymx=60)
    
    mycat<-cut(dat_ras1,breaks=mybreaks)
    mycolpal<-colorRampPalette(c("red","white","green"))
    mycol<-mycolpal(length(mybreaks)-1)#[mycat]
    
    plot(dat_ras1, col=mycol,breaks=mybreaks, 
         legend = F,axes =F, interpolate=T) #, xlab = d, main=c("Geoht Anomaly",cl, cnt)
    contour(dat_ras, axes=F, legend=F, add=T)
    map('world', add=T) #xlim = c(-161.25,-118.75),ylim=c(18.75,61.25),
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        add=T) #xlim = c(-161.25,-118.75),
    axis(1,at=c(seq(-160,-120,10)),labels=c("W160","W150","W140","W130","W120"),cex.axis=.75)
    if(k==1) axis(2,at=c(seq(20,60,10)),labels=c("N20","N30","N40","N50","N60"),las=2,cex.axis=.75)
    if(k==4) plot(dat_ras,col=mycol,breaks=mybreaks,legend.only=T,legend.shrink=1.00,
                  axis.args=list(at=seq(-2,2,.5),labels=seq(-2,2,.5),cex.axis=.75),
                  legend.args=list(text='NCEP Reforecast Error',side=2,line=.3, cex=.75))
    #points(-140,45,pch=19)
    #arrows(-130,45,-132,47,length=0.1)
    #arrows(-130,40,-129,41,length=0.1,lwd=2)
  }
}



#5) Histogram of AR miss distances (Lat difference btwn forecast and actual max IVT landfall)

b<-c(seq(-40.5,40.5,3))

par(mfrow=c(1,4),mar=c(5,3,2,1))
for(i in 1:length(dist)){
  hist(lat_err[[i]],main = "",breaks=b,xlab="Miss Distance (Degrees Latitude)",ylab="Counts",
       ylim=c(0,20),axes=F)
  axis(1,at=c(seq(-35,35,10)),labels=c(seq(-35,35,10)),cex.axis=1)
  axis(2,at=c(seq(0,20,5)),labels=c(seq(0,20,5)),cex.axis=1)
  segments(0,0,0,20,col="red",lty=2,lwd=3)
  text(15,20,"North Error")
  segments(12.5,0,12.5,12,lty=2,col="blue")
  text(19,15,"1500 km",col="blue")
  arrows(15,18,25,18,length=.1)
  text(-15,20,"South Error")
  arrows(-15,18,-25,18,length=.1)
  segments(-12.5,0,-12.5,12,lty=2, col="blue")
  text(-20,15,"1500 km",col="blue")
  #mtext("TEST",side=2,line=2)
  #if(i==1) mtext("IVT MISS DISTANCE HISTOGRAMS",side=2,line=4.5, font=2, cex=1.5)
  #if(i==5) mtext("IVT MISS DISTANCE HISTOGRAMS",side=2,line=4.5, font=2, cex=1.5)
  #if(i==9) mtext("IVT MISS DISTANCE HISTOGRAMS",side=2,line=4.5, font=2, cex=1.5)
  #if(i==13) mtext("IVT MISS DISTANCE HISTOGRAMS",side=2,line=4.5, font=2, cex=1.5)
  box(which="figure")
}

#dev.off()


#6) Plot Temperature cluster

load("data/R_Data/err/tmp/Tk_925mb_ncep2_error_comp_array.RData")

days<-c(1,5,10,14)
man_idx<-rbind(c(1,2,3,4),c(4,1,3,2),c(4,1,3,2),c(2,4,3,1))

par(mfrow=c(1,4))

for(i in 1:4){
  d<-paste(days[i]," day forecast",sep="")
  
  for(k in 1:4){
    par(mar=c(4,1.5,4,1.5))
    if(k==1)par(mar=c(4,2.5,4,0))
    if(k==4)par(mar=c(4,0,4,4.5))
    
    cl<-paste("Cluster ",k,sep="")
    clus_cnt<-length(which(cluster_index_array_ndjfm_6[,days[i]]==man_idx[i,k]))
    cnt<-paste(clus_cnt,"/ 94 events")
    
    mybreaks<-c(seq(-15,-.1,by=.1),seq(.1,15,by=.1))
    
    mat<-matrix(Tk_925mb_ncep2_error_comp_array[,,man_idx[i,k],days[i]],ncol=17)
    mat<-t(mat)
    dat_ras<-raster(mat[,1:20],xmn=-161.25,xmx=-111.25,ymn=18.75,ymx=61.25)
    
    mycat<-cut(dat_ras,breaks=mybreaks)
    mycolpal<-colorRampPalette(c("red","white","green"))
    mycol<-mycolpal(length(mybreaks)-1)#[mycat]
    
    plot(dat_ras, col=mycol,breaks=mybreaks, main="925mb Temp Error",asp=1, 
         legend = F,axes =F)
    map('world',xlim = c(-161.25,-111.25),ylim=c(18.75,61.25), add=T)
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        xlim = c(-161.25,-111.25),add=T)
    axis(1,at=c(seq(-160,-110,10)),labels=c("W160","W150","W140","W130","W120","W110"),cex.axis=.75)
    if(k==1) axis(2,at=c(seq(20,60,10)),labels=c("N20","N30","N40","N50","N60"),las=2,cex.axis=.75)
    if(k==4) plot(dat_ras,legend.only=T,breaks=mybreaks,col=mycol,legend.shrink=1.00,
                  axis.args=list(at=seq(-15,15,2.5),labels=seq(-15,15,2.5),cex.axis=.6),
                  legend.args=list(text='Temp Error (K)',side=2,line=.3,cex=.8))
  }
}

#7) Plot q cluster

load("data/R_Data/err/tmp/q_925mb_ncep2_error_comp_array.RData")
q1k_925mb_ncep2_error_comp_array<-q_925mb_ncep2_error_comp_array_unbias * 1000 #convert to g/kg

days<-c(1,5,10,14)
man_idx<-rbind(c(1,2,3,4),c(4,1,3,2),c(4,1,3,2),c(2,4,3,1))

par(mfrow=c(1,4))

for(i in 1:4){
  d<-paste(days[i]," day forecast",sep="")
  
  for(k in 1:4){
    par(mar=c(4,1.5,4,1.5))
    if(k==1)par(mar=c(4,2.5,4,0))
    if(k==4)par(mar=c(4,0,4,4.5))
    
    cl<-paste("Cluster ",k,sep="")
    clus_cnt<-length(which(cluster_index_array_ndjfm_6[,days[i]]==man_idx[i,k]))
    cnt<-paste(clus_cnt,"/ 94 events")
    
    mybreaks<-c(seq(-6,-.1,by=.1),seq(.1,6,by=.1))
    
    mat<-matrix(q1k_925mb_ncep2_error_comp_array[,,man_idx[i,k],days[i]],ncol=17)
    mat<-t(mat)
    dat_ras<-raster(mat[,1:20],xmn=-161.25,xmx=-111.25,ymn=18.75,ymx=61.25)
    
    mycat<-cut(dat_ras,breaks=mybreaks)
    mycolpal<-colorRampPalette(c("red","white","green"))
    mycol<-mycolpal(length(mybreaks)-1)#[mycat]
    
    plot(dat_ras, col=mycol,breaks=mybreaks, main="925mb q Error (unbiased)",asp=1, 
         legend = F,axes =F)
    map('world',xlim = c(-161.25,-111.25),ylim=c(18.75,61.25), add=T)
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
        xlim = c(-161.25,-111.25),add=T)
    axis(1,at=c(seq(-160,-110,10)),labels=c("W160","W150","W140","W130","W120","W110"),cex.axis=.75)
    if(k==1) axis(2,at=c(seq(20,60,10)),labels=c("N20","N30","N40","N50","N60"),las=2,cex.axis=.75)
    if(k==4) plot(dat_ras,legend.only=T,breaks=mybreaks,col=mycol,legend.shrink=1.00,
                  axis.args=list(at=seq(-15,15,2.5),labels=seq(-15,15,2.5),cex.axis=.6),
                  legend.args=list(text='q error (g/kg)',side=2,line=.3,cex=.8))
  }
}


#########################################MISCELLANEOUS PLOTS#########################################
ondjfma<-readRDS('output/index/tp_idx19842019_ondjfma.rds')
idx_1<-readRDS('output/index/gpcc_ev_index_1.rds')
idx_max<-readRDS('output/index/gpcc_ev_index_max.rds')
gpcc<-readRDS('data/prcp/gpcc_tp_wc_1984_2019_ondjfma.rds')
rf2<-readRDS('data/prcp/ncep_rf2_tp_cf_6.rds')

dat1<-dat[,,,ondjfma]
dat2<-dat1[,,16,idx_1-14]
dat3<-dat1[,,16,idx_max-14]
dat2<-apply(dat2,c(1,2),mean)
dat3<-apply(dat3,c(1,2),mean)

par(mfrow=c(1,2))

dat_ras<-raster(dat2,xmn=-140,xmx=-115,ymn=30,ymx=60)
plot(dat_ras, main="NCEP Day 1 Precip Composite",legend=T, sub="15 day lead")
map('world',add=T)#,xlim = c(-130,-115),ylim=c(30,60), add=T)
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona','utah','colorado','new mexico'),add=T)#,
#xlim = c(-130,-115),add=T)
polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)


dat_ras<-raster(ivt_tot[,,70],xmn=-160,xmx=-100,ymn=20,ymx=60)
plot(dat_ras, main="NCEP Max Precip Composite",legend=T,sub="15 day lead")
map('world',add=T)#,xlim = c(-130,-115),ylim=c(30,60), add=T)
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona','utah','colorado','new mexico'),add=T)#,
#xlim = c(-130,-115),add=T)
polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)

rm(list=ls())















######################################################END#############################################