

array_rotate<-function(array,type,tdims){
#array = input array
#type = type of rotation, 1: 90 left{gpcc,nceprf2}, 2: 90 left + rev col {ncep2}, 3: 90 left + rev col w 3rd non-time dim {ncep2}
#tdims = # of time dimensions up to 2, eg. days and hours
library(pracma)

if(type==1){
  if(tdims==1){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3]))
    for(i in 1:length(array[1,1,])){
    rot_array[,,i]<-rot90(as.matrix(array[,,i]),k=1) #pracma 'rot90' function
    }
  }
  else if(tdims==2){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3],dim(array)[4]))
    for(i in 1:length(array[1,1,1,])){
      for(j in 1:length(array[1,1,,1])){
        rot_array[,,j,i]<-rot90(as.matrix(array[,,j,i]),k=1)
      }
    }
  }
}
if(type==2){
  if(tdims==1){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3]))
    for(i in 1:length(array[1,1,])){
      rot90<-rot90(as.matrix(array[,,i]),k=1) #pracma 'rot90' function
      rot_array[,,i]<-apply(rot90,2,rev)
    }
  }
  else if(tdims==2){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3],dim(array)[4]))
    for(i in 1:length(array[1,1,1,])){
      for(j in 1:length(array[1,1,,1])){
      rot90<-rot90(as.matrix(array[,,j,i]),k=1)
      rot_array[,,j,i]<-apply(rot90,2,rev)
      }
    }
  }
}
if(type==3){
  if(tdims==1){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3],dim(array)[4]))
    for(k in 1:length(array[1,1,,1])){
      for(i in 1:length(array[1,1,1,])){
        rot90<-rot90(as.matrix(array[,,k,i]),k=1) #pracma 'rot90' function
        rot_array[,,k,i]<-apply(rot90,2,rev)
      }
    }
  }
  else if(tdims==2){
    rot_array<-array(NA,c(dim(array)[2],dim(array)[1],dim(array)[3],dim(array)[4],dim(array)[5]))
    for(k in 1:length(array[1,1,,1,1])){
      for(i in 1:length(array[1,1,1,1,])){
        for(j in 1:length(array[1,1,1,,1])){
          rot90<-rot90(as.matrix(array[,k,j,i]),k=1)
          rot_array[,,k,j,i]<-apply(rot90,2,rev)
        }
      }
    }
  }
}
return(rot_array)
}
