

##Script to calculate miss distances between forecast and observed IVT maxima along grid cells indentified
#in the SIO-R1 database

library(geosphere)

lfall<-cbind(c(20:60),c(255,255,255,254,253,252,251,250,249,247,245,244,243,242,241,240,239,
                          238,237,236,236,236,236,236,236,236,236,236,236,236,235,234,232,231,
                          230,229,228,227,225,223,221))
lon_idx<-c(200:260)
lfall_idx<-lfall
lfall_idx[,1]<-41:1
for(i in 1:length(lfall[,2])){
  lfall_idx[i,2]<-which(lfall[i,2]==lon_idx)
}

mask<-array(1,c(41,61))
for(j in 1:length(lfall[,2])){
  mask[lfall_idx[j,1],lfall_idx[j,2]]<-0
}

mat<-matrix(mask,ncol=61)
dat_ras<-raster(mat,xmn=-160,xmx=-100,ymn=20,ymx=60)

plot(dat_ras, legend=T,axes=F,main='Landfall Grids (1 DEG)') 
map('world', add=T) 
map('state',region=c('washington','oregon','california','nevada','idaho','montana','arizona'),
    add=T) #xlim = c(-161.25,-118.75),
axis(1,at=c(seq(-160,-100,10)),labels=c("W160","W150","W140","W130","W120","W110","W100"),cex.axis=.75)
axis(2,at=c(seq(20,60,10)),labels=c("N20","N30","N40","N50","N60"),las=2,cex.axis=.75)

#---------------------------------------------------------------------------------------------------------------

rf_type<-'mean' #'cf' or 'mean'
rf_model<-'ncep_rf2'
r_model<-'ncep2'
obs<-'gpcc'
ztime<-6
fday<-15
kmns<-4

cluster_index<-readRDS(paste('output/cluster/',rf_model,'_',obs,'_cluster_idx_',rf_type,'_man.rds',sep=""))
obs_ivt<-readRDS(paste('data/ivt/',r_model,'_ivt_tot_',ztime,'.rds',sep=""))
rf_ivt<-readRDS(paste('data/ivt/',rf_model,'_',rf_type,'_ivt_tot.rds',sep=""))
ivt_err<-array(NA,c(dim(obs_ivt)[1],dim(obs_ivt)[2],fday,dim(obs_ivt)[3]))
ev_index<-readRDS('output/index/gpcc_ev_index_1_full.rds')
ev_index<-ev_index[-c(263,292,295)]##ev index 292 (cf),263(mean) are all NAs, 295 is aberrant
fday<-15
kmns<-4
days<-rep(c(1,3,5,10,15),each=4)
kvec<-rep(1:kmns,5)
clus<-rep(c(1,2,3,4),5)

dist<-vector("list",length(days))
names(dist)<-c(paste(days,"-",clus))
lat_err<-vector("list",length(days))
names(lat_err)<-c(paste(days,"-",clus))

lfall_lat<-lfall_idx[,1]
lfall_lon<-lfall_idx[,2]


for(i in 1:(length(days))){
  ds<-c()
  le<-c()
  idx<-ev_index[which(cluster_index[,days[i]]==kvec[i])] 
  #lab<-paste(days[i],"-",clus[i])
  
  for(k in 1:length(idx)){
    ivt_f_vec<-c()
    ivt_o_vec<-c()
    
    for(j in 1:length(lfall_idx[,1])){
      ivt_f<-rf_ivt[lfall_lat[j],lfall_lon[j],days[i]+1,(idx[k]-i+1)]
      ivt_f_vec<-c(ivt_f_vec,ivt_f)
      ivt_o<-obs_ivt[lfall_lat[j],lfall_lon[j],(idx[k]+1)]
      ivt_o_vec<-c(ivt_o_vec,ivt_o)
    }
    
    max_f<-which(ivt_f_vec==max(ivt_f_vec))
    max_o<-which(ivt_o_vec==max(ivt_o_vec))
    d<-distm(c(lfall[max_f,2]-360,lfall[max_f,1]),c(lfall[max_o,2]-360,lfall[max_o,1]),fun = distHaversine)
    l<-lfall[max_f,1]-lfall[max_o,1]
    if (max_f<max_o) d<-(-d)
    ds[k]<- d / 1000
    le[k]<- l
  }
  dist[[i]]<-ds
  lat_err[[i]]<-le
}

b<-c(seq(-37.575,37.575,5.01))
id<-paste(days,"-",clus)

#pdf("Data/pdf/miss_hist.pdf")

par(mfrow=c(1,2))
for(i in 1:length(dist)){
  #p<-plot_ly(y = dist[[2]], type = "histogram",xanchor = "right")
  #layout(p,title = "Miss Distance Histogram",xlab = "counts")
  #p
  #hist(dist[[i]],main="IVT Miss Distance",xlab="Distance (km)",breaks=c(seq(-5000,5000,500)),ylab="Counts",ylim=c(0,10))
  len<-paste(length(lat_err[[i]]),"/94")
  hist(lat_err[[i]],main=c("IVT Miss Distance",len),breaks=b,xlab="Distance (Deg Lat)",ylab="Counts",
       ylim=c(0,14),axes=F,sub=id[i])
  axis(1,at=c(seq(-35,35,10)),labels=c(seq(-35,35,10)),cex.axis=1)
  axis(2,at=c(seq(0,14,2)),labels=c(seq(0,14,2)),cex.axis=1)
  abline(v=0,col="red",lty=2,lwd=3)
  text(15,14,"North Error")
  segments(9,0,9,10,lty=2)
  text(20,10,"1000 km")
  arrows(15,13,25,13,length=.1)
  text(-15,14,"South Error")
  arrows(-15,13,-25,13,length=.1)
  segments(-9,0,-9,10,lty=2)
  text(-20,10,"1000 km")
  #yhist<-hist(lat_err[[i]],main="IVT Miss Distance Latitude",xlab="Distance (Deg Lat)",ylab="Counts",
              #ylim=c(0,10),axes=F,plot=F) #,breaks=c(seq(-35,35,5))
  #plot(NULL, type = "n", xlim = c(0, 10), ylim = c(-35,35))
  #rect(yhist$counts, yhist$breaks[1:(length(yhist$breaks) - 1)], 0, yhist$breaks[2:length(yhist$breaks)])
  
  #mp<-barplot(yhist,axes=F,plot=F)
  #barplot(mp,horiz=T)
  #barplot(yhist$counts,horiz=T,xlab="Freq",ylab="Miss Dist (km)",axes=F,xlim=c(0,10))#names.arg=T,axisnames = T)
  #axis(2,at=c(seq(-35,35,10)),labels=c(seq(-35,35,10)),cex.axis=1)
  #axis(1,at=c(seq(0,10,2)),labels=c(seq(0,10,2)),cex.axis=1)
  #axis(2,at=yhist$breaks)
}

#dev.off()

  
