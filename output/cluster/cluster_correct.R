#manually correct clusters

rf_type<-'cf' #'cf' or 'mean'
rf_model<-'ncep_rf2'
obs<-'gpcc'
kmns<-4

clusters<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_clusters_',rf_type,'.rds',sep=""))
cluster_index<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'.rds',sep=""))

if(rf_type=='cf') idx<-rbind(c(1,2,3,4),c(1,3,2,4),c(3,2,1,4),c(1,2,4,3),c(2,1,4,3)) else #cf
  idx<-rbind(c(3,2,1,4),c(3,4,1,2),c(3,2,1,4),c(1,2,4,3),c(4,3,2,1)) #mean
days<-c(1,3,5,10,15)

for(i in 1:5){
  i1<-which(cluster_index[,days[i]]==idx[i,1])
  i2<-which(cluster_index[,days[i]]==idx[i,2])
  i3<-which(cluster_index[,days[i]]==idx[i,3])
  i4<-which(cluster_index[,days[i]]==idx[i,4])
  c1<-clusters[((days[i]-1)*kmns+idx[i,1]),]
  c2<-clusters[((days[i]-1)*kmns+idx[i,2]),]
  c3<-clusters[((days[i]-1)*kmns+idx[i,3]),]
  c4<-clusters[((days[i]-1)*kmns+idx[i,4]),]
  cluster_index[i1,days[i]]<-1
  cluster_index[i2,days[i]]<-2
  cluster_index[i3,days[i]]<-3
  cluster_index[i4,days[i]]<-4
  clusters[((days[i]-1)*kmns+1),]<-c1
  clusters[((days[i]-1)*kmns+2),]<-c2
  clusters[((days[i]-1)*kmns+3),]<-c3
  clusters[((days[i]-1)*kmns+4),]<-c4
}

saveRDS(clusters,paste('output/cluster/',rf_model,'_',obs,'_clusters_',rf_type,'_man.rds',sep=""))
saveRDS(cluster_index,paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))


rm(list=ls())


############################################END##########################################