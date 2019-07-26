
gpcc_mask<-function(array,tdims){
  #array = input array
  #tdims = # of time dimensions up to 2, eg. days and hours
  library(pracma)
  gpcc_mask<-readRDS('h:/ms_project1/output/index/gpcc_mask.rds')
  
    if(tdims==1){
      for(i in 1:length(array[1,1,])){
        mask_array<-array[,,i]
        mask_array[gpcc_mask]<-NA
        array[,,i]<-mask_array
      }
    }
    else if(tdims==2){
      for(i in 1:length(array[1,1,1,])){
        for(j in 1:length(array[1,1,,1])){
          mask_array<-array[,,j,i]
          mask_array[gpcc_mask]<-NA
          array[,,j,i]<-mask_array
        }
      }
    }
  return(array)
}