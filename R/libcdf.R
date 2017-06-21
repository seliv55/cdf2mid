gnmass<-function(mzrang){# mzrang is a set of mz values for a given pattern of intensities
#gnmass finds the length of the first fragment assuming that a gap in mz values separates franments
  len=length(mzrang); lenpat<-numeric(); j<-1
 for(i in 2:len) if((mzrang[i]-mzrang[i-1])>1){lenpat[j]<-(i-1); j<-j+1}
  lenpat[j]<-len
     return(lenpat); }
     
filmat<-function(mat,val,mzpt,ofset=0){#np is a number of mz points in the spectrum
#numis is a number of mz points in the fragment
 nmi <-ncol(mat); ntp<-nrow(mat);
  for(i in 1:ntp){ ip=(i-1)*mzpt;
    for(j in 1:nmi)  mat[i,j]=val[ip+j+ofset];
               }
     return(mat);}

baseln<-function(matis,mi,ma){ #finds baseline
  niso<-ncol(matis)
  vlim=matis[mi,2]*1.7; bas=numeric(niso); k=0;
     for(i in 1:ma){
  if(matis[i,2]<vlim){ k=k+1;
    for(j in 1:niso) {bas[j]=bas[j]+matis[i,j];}}
  }
  for(j in 1:niso) bas[j]=bas[j]/k;
     return(bas);
}

subas<-function(matis,bas){ # subtract baseline
  niso<-ncol(matis)
  for(j in 1:niso)
    for(i in 1:nrow(matis)){ matis[i,j]=matis[i,j]-bas[j]; 
     if(matis[i,j]<0) matis[i,j]=0;
     }
       return(matis) }

eimpact<-function(matis){
  niso<-ncol(matis)
  rsum=numeric(2);
 for(i in 1:nrow(matis)){
  if(max(matis[i,])>1000){rsum[1]=rsum[1]+matis[i,1]; rsum[2]=rsum[2]+matis[i,2];} }
   ef=rsum[1]/rsum[2]; # factor proton impact
    for(i in 1:nrow(matis)){
  if(max(matis[i,])>1000){
    for(j in 1:(niso-1)) { prim=matis[i,j+1]*ef;
    matis[i,j]=matis[i,j]-prim; if(matis[i,j]<0) matis[i,j]=0;
       matis[i,j+1]=matis[i,j+1]+prim;}}}
         return(matis)}
         
rowfr<-function(matis){# normalization in each row
  niso<-ncol(matis)
  mm0=matis;
       mm0[,]=0;
    for(i in 1:nrow(mm0)){
  if(max(matis[i,])>1000){ sum0=sum(matis[i,2:(niso)])
    for(j in 2:(niso))  mm0[i,j-1]=matis[i,j]/sum0; }
     mm0[i,niso]=sum(mm0[i,1:(niso-1)]) }
        return(mm0)}

alclust<-function(mz,npoint){
    numps<-npoint[1]; ipos<-numeric(); j<-1
   for(i in 1:length(npoint)) { if(numps[j]==npoint[i]) next
    numps<-c(numps,npoint[i]); ipos[j]<-i; j<-j+1;
   }
    ipos[j]<-length(npoint); 
      mznach<-list(); ll<-numps[1]*(ipos[1]-1); mznach[[1]]<-mz[1:numps[1]]
      mzkon<-list();  mzkon[[1]]<-mz[(ll-numps[1]+1):ll]
    for(i in 2:length(numps)) {   mznach[[i]]<-mz[(ll+1):(ll+numps[i])]
       ll<-ll+numps[i]*(ipos[i]-ipos[i-1]); mzkon[[i]]<-mz[(ll-numps[i]+1):ll]
    }
      return(list(numps,ipos,mzkon,mznach))}
 
readcdf<-function(fi) {
 nc <- nc_open(fi, readunlim=FALSE)  #open cdf file
   rett<-ncvar_get( nc, "scan_acquisition_time" )
   tiv<-ncvar_get( nc, "total_intensity" )
   npoint<-ncvar_get( nc, "point_count" )
     mz<-ncvar_get( nc, "mass_values" )
     iv<-ncvar_get( nc, "intensity_values" )
   nc_close( nc )
        return(list(mz,iv,npoint,rett,tiv))    }
        
  getfrg<-function(mrang){# finds length of fragments 
      lfr=1; npnt=length(mrang)
      tmp=gnmass(mrang);
         if(tmp<npnt) { return(c(tmp,npnt-tmp)) }
    return(npnt) }
    
  savplt<-function(mm,mm0,nma,plname){
  png(paste("../graf/",plname,"png",sep=""))
  par(mfrow=c(2,1))
   plot(mm[,2],xlim=c(nma-50,nma+50))
   plot(mm0[,1],xlim=c(nma-50,nma+50))
   dev.off()
  }
    
  distr<-function(mm,plname){
 nma=which.max(mm[,2]); nmi=which.min(mm[1:nma,2]); # max, min
# baseline:
 bas=baseln(mm,nmi,nma)
  ilim=50; mm=mm[(nma-ilim):(nma+ilim),]; nma=ilim+1
  mm=subas(mm,bas)    # subtract baseline
  mm1=eimpact(mm)      # correct electron impact
  mm0=rowfr(mm)        # normalization
    savplt(mm1,mm0,nma,i,plname)
   pint=7;  nma1= which.max(mm0[(nma):(nma+pint),1])
 prep= nma1+nma-1
      return(list(mm0[prep,],mm1[prep,],mm[prep,])) }

