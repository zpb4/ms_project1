#Manually synch and plot clusters

err_type<-'unbias'
rf_type<-'cf' #'cf' or 'mean'
rf_model<-'ncep_rf2'
obs<-'gpcc'
kmns<-4
show_fday<-'T'

box_error<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_box_error_',rf_type,'.rds',sep=""))
clusters<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_clusters_',rf_type,'_man.rds',sep=""))
cluster_index<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
clus_array<-readRDS('output/cluster/clus_array.rds')

days<-c(1,3,5,10,15)

library(RColorBrewer)
mycol<-brewer.pal(11,"RdYlGn")
mycol[6]<-"white"

#pdf("pdf/cluster_plots_4.pdf")
if(show_fday=='T') par(mfrow=c(1,kmns),mar=c(4,3,3,3.5)) else
par(mfrow=c(1,kmns),mar=c(3,3,4,3.5))

for (i in 1:5){
  for (k in 1:kmns){
    clus_cnt<-length(which(cluster_index[,days[i]]==k))
    cnt<-paste(clus_cnt,"/ 292 events")

    f_vec<-rep(NA,750)
    f_vec[which(is.na(clus_array[1,,1])==F)]<-clusters[((days[i]-1)*kmns+k),]
    my_matrix<-matrix(f_vec,ncol = 25,byrow = F)

    lab<-paste(days[i]," day forecast",sep="")
    lab2<-paste("Cluster ",k,sep ="")

    dat_ras<-raster(my_matrix,xmn=-140,xmx=-115,ymn=30,ymx=60)
    plot(dat_ras,legend = F,axes=F,breaks=c(-65,-40,-30,-20,-10,-3,3,10,20,30,40,65), 
     col=mycol, xlab=lab,main=c(lab2, cnt))

    axis(1,at=c(seq(-140,-115,5)),labels=c("W140","W135","W130","W125","W120","W115"),cex.axis=.75)
    if(k==1) axis(2,at=c(seq(30,60,5)),labels=c("N30","N35","N40","N45","N50","N55","N60"),las=2,cex.axis=.75)
    if(k==kmns){plot(dat_ras, legend.only = T, breaks=c(-65,-40,-30,-20,-10,-3,3,10,20,30,40,65), 
                 col=mycol, legend.shrink=1.01, axis.args=list(cex.axis=0.75),
                 legend.args = list(text = 'Avg Error (mm)', side = 2, line=0.1,cex=0.6))} #add legend text if desired

    map('world',xlim = c(-140,-115),ylim=c(30,60), add=T)
    map('state',region=c('washington','oregon','california','nevada','idaho','montana',
                         'arizona','utah','wyoming','colorado','new mexico'),add=T)
    polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)
    
    err<-format(box_error[k,days[i]],digits = 3)
    err<-paste(err,"% Error")
    legend("topright",err, cex = .8, xjust = 1,text.font = 2)
  }
}


rm(list=ls())



############################################END#################################################