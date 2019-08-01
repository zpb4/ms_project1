#Script to cluster precip data
err_type<-'unbias'
rf_type<-'mean' #'cf' or 'mean'
rf_model<-'ncep_rf2'
obs<-'gpcc'
plotk<-'T'
save<-'T'

if(err_type=='unbias'){error<-readRDS(paste('output/prcp/',rf_model,'_',obs,'_tp_error_unbias',rf_type,'.rds',sep=""))} else
error<-readRDS(paste('output/prcp/',rf_model,'_',obs,'_tp_error_',rf_type,'.rds',sep=""))

ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')
ev_index<-ev_index[-c(263,292,295)]##ev index 292 (cf),263(mean) are all NAs, 295 is aberrant

clus_array<-array(NA,c(length(ev_index),750,15))
clus_array_nona<-array(NA,c(length(ev_index),290,15)) #array with na's removed for k-means


#n. Populate arrays
for (i in 1:length(ev_index)){
  
  for (j in 1:15){
    v<-as.vector(error[,,j,ev_index[i]]) #remove row/column w/all NAs
    clus_array[i,,j]<-v
    clus_array_nona[i,,j]<-v[-c(which(is.na(v)==T))]
  }
}

if(save=='T'){
  saveRDS(clus_array,'output/cluster/clus_array.rds')
  saveRDS(clus_array_nona,'output/cluster/clus_array_nona.rds')
}

#k-means clustering

kmns<-4
k_vector<-rep(kmns,15)

# Plot average error values for each grid cell and cluster for each forecast day
clusters<-array(NA,c(sum(k_vector),length(clus_array_nona[1,,1]))) #array to store all clusters
cluster_index<-array(NA,c(length(ev_index),15)) #array to store the cluster index for each forc day

library(RColorBrewer)
mycol<-brewer.pal(11,"RdYlGn")
mycol[6]<-"white"

#pdf("pdf/cluster_plots_4.pdf")
par(mfrow=c(1,kmns),mar=c(4,3,3,3.5))

for (i in 1:15) {
  km<-kmeans(clus_array_nona[,,i],k_vector[i],nstart = 100)
  clus_ind<-as.numeric(km$cluster)
  cluster_index[,i]<-clus_ind
  
  for (k in 1:k_vector[i]){
    clus_val<-clus_array_nona[which(clus_ind==k),,i]
    clus_avg<-apply(clus_val,2,FUN = mean)
    clus_cnt<-length(which(clus_ind==k))
    cnt<-paste(clus_cnt," / ",length(ev_index), sep="")
    
    f_vec<-rep(NA,750)
    f_vec[which(is.na(clus_array[1,,1])==F)]<-clus_avg
    my_matrix<-matrix(f_vec,ncol = 25,byrow = F)
    
    lab<-paste(i," day forecast",sep="")
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
    map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),add=T)
    polygon(c(-123,-123,-120,-120,-123),y = c(38,42,42,38,38),lwd=3)
    
    clusters[(((i-1)*kmns) + k),]<-clus_avg
  }
}

if(save=='T'){
  saveRDS(cluster_index,paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'.rds',sep=""))
  saveRDS(clusters,paste('output/cluster/',rf_model,'_',obs,'_clusters_',rf_type,'.rds',sep=""))
}

#k determination as needed
if(plotk=='T'){
  pdf(paste('output/cluster/',rf_model,rf_type,obs,"pdf",sep="."))
  par(mfrow=c(3,2))
  
  for (i in 1:15){
    kvec<-c()
    for (k in 1:10){
      km<-kmeans(clus_array_nona[,,i],k,nstart = 100)
      kv<-km$betweenss / km$totss
      kvec<-c(kvec,kv)
    }
  lab<-paste(i," day forecast",sep="")
  lab2<-paste(rf_model,rf_type,obs)
  plot(1:10,kvec,type='b',xlab=lab,main=lab2)
  }
  dev.off()
}

rm(list=ls())
###################################################END############################################