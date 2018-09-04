#  setwd(oldi)
# oldi<-getwd()
#  source(infile)
# print(infile)

metan<-function(infile="sw620",cdfdir="exam3/",outfile="cdf2midout.csv"){ # infile="simetdat", cdfdir="wd/", outfile="cdf2midout.csv"
#  and metabolite specified by m/z M-1 referred as ms
# call: metan()
# temp <- tempdir()#paste(,"/",sep="")  #"data/ttt/"  #
# lcdf<-unzip(cdfzip,exdir=temp)
#   setwd(cdfdir)
  start.time <- Sys.time()
   pat=".CDF"
lcdf<-dir(path = cdfdir,pattern=pat)
for(i in 1:length(lcdf)) lcdf[i]=paste(cdfdir,lcdf[i], sep="")
   intab<-read.table(infile,header=T,sep=" ")
     
title<-data.frame("Raw Data File", "cells", "tracer molecule","labelled positions","abundance","Parameter Value[injection]","Parameter Value[Replicate]","Factor Value[Incubation time]","Metabolite name","CHEBI identifier","atomic positions to the parent molecule/metabolite name","Empirical formula derivatized molecule/fragment", "retention(min)", "m/z monitored","signal intensity","isotopologue","isotologue abundance relative concentration")
tracer<-list(
list(nik="Gluc",name="D-[1,2-C13]-Glucose",pos="1,1,0,0,0,0",abund=50),
list(nik="12Glc",name="D-[1,2-C13]-Glucose",pos="1,1,0,0,0,0",abund=50),
list(nik="Glutam",name="[3-C13]-Glutamine",pos="0,0,1,0,0",abund=100),
list(nik="UGln",name="[U-C13]-Glutamine",pos="1,1,1,1,1",abund=100),
list(nik="cold",name="Glucose",pos="0,0,0,0,0,0",abund=100)
)

inctime<-c('_0',' 0',6,24,40)

cells<-c("A549","NCI","BEAS2B","SW620","HUVEC")

     ldf<-list(); # data frame to write Ramid output in PhenoMeNal format
     ifi<-0;
     finames=character()
     df0<-data.frame(); # data frame to write data in PhenoMeNal format

       for(fi in lcdf){itrac<-0 #labname<-" "; labpos<-" "; abund<-" "; ti<-0 #CDF files one by one
         for(trac in tracer) {  #check what label was used for the given file
         if(grepl(trac$nik,fi)) {
             itrac<-itrac+1; labname<-trac$name; labpos<-trac$pos; abund<-trac$abund; break }
         if(itrac==0) { labname<-" "; labpos<-" "; abund<-0 }}
         
           for(tinc in inctime)  #check the file for incubation time
           if(grepl(paste(tinc,'H',sep=""),fi)|grepl(paste(tinc,'h',sep=""),fi)) break;
           if(grepl('Cold',fi)) tinc<-'0'
           
           for(cel in cells) if(grepl(cel,fi)) break
           
           l<-regexpr("R[0-9]_", fi)+1
           if(l==0) l<-regexpr(" [0-9]_", fi)+1
           if(l==0) l<-regexpr("C[0-9][ _][0-9]", fi)+3
           inj<-substr(fi,nchar(fi)-4,nchar(fi)-4)
           rep<-substr(fi,l,l)
           print(fi)
        fispl<-tail(strsplit(fi,"/")[[1]],1)
  dfrow<-data.frame(fispl,cel,labname,labpos,abund,inj,rep,tinc)
     dfrow <-findpats(fi,intab,dfrow)
     irow<-nrow(dfrow)
      if(irow>1)  {  df0<-rbind(df0,dfrow) # filling df with dfrow
     }     }
#      for(i in 1:length(finames))  write.table(ldf[i], file=finames[i], row.names = F, col.names = F, sep=",") #simple output format
#    fi1=paste("../ramidin.csv"); #Ramid output
     write.table(title, file=outfile, row.names = F, col.names = F, sep=",") # Metabolights format, titles
       write.table(df0, file=outfile, row.names = F, col.names = F, append=T, sep=",") # Midcor input in PhenoMeNal format
#    setwd("../files")
# select<-run_midcor(infile=outfile);
# df0<-rbind(df0,select)
##    setwd(oldi)
#  
#       write.table(title, file=fi0, row.names = F, col.names = F, sep=",")
#       write.table(df0, file=fi0, row.names = F, col.names = F, append=T, sep=",")
  Sys.time() - start.time
#    unlink(temp, recursive = T, force = T)
  }
       
info<-function(mz,iv,npoint){
#  mz,iv,npoint: mz, intensities and number mz points in every scan
      j<-1
  mzpt<-numeric() # number of m/z points in each pattern
  tpos<-numeric() # initial time position for each m/z pattern 
   mzi<-numeric() # initial value for each m/z pattern presented in the CDF file
    mzind<-numeric() # index in mz array corresponding to mzi
     mzrang<-list() # list of mz patterns presented in the .CDF
  mzpt[j]<-npoint[1]; tpos[j]<-1; mzi[j]<-mz[1]; imz<-1; mzind[j]<-imz
  mzrang[[1]]<-mz[1:mzpt[1]];
    for(i in 2:length(npoint)) { imz<-imz+npoint[i-1];
     if(mzi[j]!=mz[imz]){  j<-j+1; tpos[j]<-i;  mzpt[j]<-npoint[i]; mzi[j]<-mz[imz];
      mzind[j]<-imz; mzrang[[j]]<-mz[(mzind[j]):(mzind[j]-1+mzpt[j])] }
    }
  tpos[length(tpos)+1]<- length(npoint) # add the last timepoint
  return(list(mzpt,tpos,mzind,mzrang))
  }
  
findmax<-function(totiv,tin,tfi){
  totiv1<-totiv[tin:(tfi-1)]
  nma<-which.max(totiv1);
  return(nma)}
  
setmat<-function(mz00,mzrang,mzind,iv,mzpt,tini,tfin){
     ofs<-0
   lenpat<-gnmass(mzrang)
    for(k in 1:length(lenpat)){
     if(mz00 %in% (mzrang[(ofs+1):lenpat[k]]) ) {
      mzr<-mzrang[(ofs+1):lenpat[k]]
    mativ<-matrix(ncol=(lenpat[k]-ofs),nrow=(tfin-tini))
  mativ<-filmat(mativ,iv,mzpt,mzind-1+ofs)
}
  ofs<-lenpat[k]  }
  return(list(mativ,mzr))}
  
  
  
findpats<-function(fi,intab,dfrow,tlim=100){
# fi: file name
    a<-readcdf(fi);
#    mz, intensities, number of mz-point at each rett, sum of iv at each rett
     mz<-a[[1]]; iv<-a[[2]]; npoint<-a[[3]]; rett<-a[[4]]; totiv<-a[[5]];
#    summary: 
 a<-info(mz,iv,npoint); mzpt<-a[[1]]; tpos<-a[[2]]; mzind<-a[[3]]; mzrang<-a[[4]]; 
     icyc<-0; imet<--1; ranum<- 0; dfrow1=data.frame()
     rts<-intab$RT*60.; mz0<-round(intab$mz0,1); mzcon<-round(intab$control,1)
#  search for specified metabolites
 for(i in 1:nrow(intab)) {nm<-as.character(intab$Name[i]);
        ltp<- (rts[i]<rett[tpos])       # time interval that includes rts
        ranum<-(c(1:length(tpos))[ltp])[1]-1;
        ranum[is.na(ranum)]<-0; if(ranum<1) next
        mzrang[[ranum]]<-round(mzrang[[ranum]],1)
   if((mz0[i] %in% mzrang[[ranum]])&(mzcon[i] %in% mzrang[[ranum]])) {
#   check whether mid for a given metabolite is presented in the found time interval
        tpclose<-which.min(abs(rett-rts[i]))
#        tlim<-min(tlim,tpclose-tpos[ranum],tpos[ranum+1]-tpclose)
        tplow<-max(tpclose-tlim,tpos[ranum]); tpup<-min(tpclose+tlim,tpos[ranum+1])     # boundaries that include desired peak
   mzi<-mzind[ranum]+mzpt[ranum]*(tplow-tpos[ranum])#index of initial mz point
   mzfi<-mzi+mzpt[ranum]*(tpup-tplow)   	#index of final mz point
   rtpeak<-rett[tplow:tpup] # retention times within the boundaries
        tpclose<-which.min(abs(rtpeak-rts[i]))
# additional peak
      nmass<-3; rtdev<-20;
    misoc<-c(intab$control[i],intab$control[i]+1,intab$control[i]+2)#desired mz values
    lmisoc<-mzrang[[ranum]] %in% misoc
    intens<-matrix(ncol=nmass,nrow=(tpup-tplow),0)
    intens<-sweep(intens,2,iv[mzi:mzfi][lmisoc],'+')
    pospiks<-apply(intens,2,which.max)
    pikintc<-apply(intens,2,max)
   if(max(abs(diff(pospiks)))>9) goodiso<-which.min(abs(pospiks-tpclose))  else goodiso<-which.max(pikintc)
        pikposc<-pospiks[goodiso]
        
  if((pikposc>2)&(pikposc<(nrow(intens)-2))) {
        maxpikc<-pikintc[goodiso]
    for(k in 1:nmass) pikintc[k]<-sum(intens[(pikposc-2):(pikposc+2),k])
      basc<-round(apply(intens,2,basln,pos=pikposc,ofs=5))
                deltac<-round(pikintc-basc)
                ratc<-deltac/basc
# main peak
  if(ratc[goodiso]>3){ frag<-as.character(intab$Fragment[i])
     print(i)
     frpos<-gregexpr("C[0-9]",frag)[[1]]+1
      c1=as.numeric(substr(frag,frpos[1],frpos[1]));  c2=as.numeric(substr(frag,frpos[2],nchar(frag)))
    nCfrg<-c2-c1+1
        nmass<-nCfrg+5 # number of isotopomers to present calculated from formula
    misofin<-array((mz0[i]-1):(mz0[i]+nmass-2)) # isotopores to present in the spectrum
    lmisofin<-mzrang[[ranum]] %in% misofin # do they are present in the given mzrang?
    pikmz<-mzrang[[ranum]][lmisofin] # extrat those that are present
    nmass<-length(pikmz)
    intens<-matrix(ncol=nmass,nrow=(tpup-tplow),0)
    intens<-sweep(intens,2,iv[mzi:mzfi][lmisofin],'+') # create matrix iv(col=mz,row=rt) that includes the peak
     piklim<-min(rtdev,pikposc-1,nrow(intens)-pikposc-1)
    intens<-intens[(pikposc-piklim):(pikposc+piklim),]

    pikint<-apply(intens,2,max)
    isomax<-which.max(pikint)
    pikpos<-which.max(intens[,isomax])
    maxpik<-intens[pikpos,isomax]; smaxpik<-"max_peak:";
     if(maxpik>8300000) {smaxpik<-"**** !?MAX_PEAK:"; print(paste("** max=",maxpik,"   ",nm,"   **")); next;}
    bas<-apply(intens,2,basln,pos=pikpos,ofs=15)
  if((pikpos>2)&(pikpos<(nrow(intens)-2))){
     for(k in 1:nmass) pikint[k]<-sum(intens[(pikpos-2):(pikpos+2),k])
   }
    delta<-round(pikint-bas); s5tp<-"5_timepoints:"
    if((misofin[1]==pikmz[1])&(delta[1]/delta[2] > 0.075)) { s5tp<-"*!?* 5_timepoints:";
      print(paste("+++ m-1=",delta[1],"  m0= ",delta[2],"   +++ ",nm)); next }
          
                rat<-delta/bas
                rel<-round(delta/max(delta),4)      # normalization
	dat=intab[i,]
    miso=paste("13C",pikmz-dat$mz0,sep="") #isotopomer names
  dfrow0<-cbind(dfrow,as.character(dat$Name),"Chebi",as.character(dat$Fragment),as.character(dat$Formula),dat$RT, miso, delta, miso," ")
   dfrow1=rbind(dfrow1,dfrow0)
      } }
   } }
 return(dfrow1)}
 
  peakdist<-function(fi,intens,rett1,tlim=50,peakf=5,ipmi=5,stabin=2){
# fi: file name
# met: parameters of metabolite (mz for m0, retention time)
# ilim: number of points limiting half peak
# peakf: factor to define lower limit of peak interval used for fitting
# ipmi: minimal number of points for half peak taken for fitting
# stabin: numer of points after peak to defing mi ratio
   inmax<-which.max(intens[tlim,]); porog<-intens[tlim,inmax]/peakf
   ip<-1; while(intens[tlim-ip,inmax]>porog & intens[tlim+ip,inmax]>porog) ip<-ip+1
   if(ip<ipmi) ip<-ipmi
  mm1=eimpact(intens)      # correct electron impact
  mm0=rowfr(mm1)        # normalization
   a<-fitdist(rett1,mm1,tlim,pint=ip)
   reti<-a[[1]]; ye<-a[[2]]; yf<-a[[3]]; area<-a[[4]]
    relar<-area/sum(area)
#    savplt(intens,mm0,nma,fi)
#    plal(fi,reti,ye,yf)
 return(list(mm0[tlim,],relar))#MID calculated as ratio either of intensities or areas of fitted peaks
  }

basln<-function(vec,pos=length(vec),ofs=0){# baseline
   basl<--1; basr<--1;bas<-0
  if(pos>ofs) basl<-mean(vec[1:(pos-ofs)])
  if(pos<(length(vec)-ofs)) basr<-mean(vec[(pos+ofs):length(vec)])
  if((basl>0)&(basr>0)) bas<-min(basl,basr)
  else if(basl<0) bas<-basr
  else if(basr<0) bas<-basl
 return(bas*5)}

#  
#     
# nma1= which.max(mm0[(nma):(nma+stabin),1])
# prep= nma1+nma-1; # print(prep)
# list(mm0[prep,],relar,mzr)
# }
#     
#   
#  return(list(mativ,rett1,totiv1,mzr))
## mativ: matrix of intensities corresponding to various mz in rows and to retention times in columns, corresponding to metp
## rett1: vector of retention times, corresponding to metp
## totiv1: sum of intensities in each row
#}

fitG <-function(x,y,mu,sig,scale){
# x,y: x and y values for fitting
# mu,sig,scale: initial values for patameters to fit  
  f = function(p){
    d = p[3]*dnorm(x,mean=p[1],sd=p[2])
    sum((d-y)^2)
  }
  optim(c(mu,sig,scale),f,method="CG")
 # nlm(f, c(mu,sig,scale))
# output: optimized parameters
   }
  
fitdist<-function(x,ymat,nma,pint=5,cini=2,fsig=1.5,fsc=2.){ # fits distributions
# x: vector of x-values
# ymat: matrix of experimental values where columns are time courses for sequential mz
# nma: point of maximal value
# pint: half interval taken for fitting
# cini: initial column number
  cfin<-ncol(ymat)#cini+nmi-1;
  nmi<-cfin-cini+1 #ncol(ymat)-1;
   fscale<-numeric()
   xe<-x[(nma-pint):(nma+pint)];    facin<-max(ymat[nma,]);
   yemat<-ymat[(nma-pint):(nma+pint),cini:cfin]/facin
      yfmat<-yemat
          mu<-xe[pint+1]
          sig<-(xe[2*pint]-xe[2])/fsig
   for(i in 1:nmi){
          scale<-yemat[pint,i]*sig/fsc
   fp<-fitG(xe,yemat[,i],mu,sig,scale)
    fscale[i]<-fp$par[3]*facin
    yfmat[,i]<-fp$par[3]*dnorm(xe,mean=fp$par[1],sd=fp$par[2])
#    fscale[i]<-fp$estimate[3]*facin
#    yfmat[,i]<-fp$estimate[3]*dnorm(xe,mean=fp$estimate[1],sd=fp$estimate[2])
#   mu<-fp$par[1];  sig<-fp$par[2];# scale<-fp$par[3]
   }
   list(xe,yemat,yfmat,fscale)
#   xe: x-values used for fit
#   yemat: matrix of experimental intensities
#   yfmat: matrix of fitted intensities
#   fscale: areas of peaks
}
     
plal<-function(fi,x,me,mf){# plots intensities from matrix mm; nma - position of peaks; abs - 0 or 1 depending on mm
# fi: file to plot in
# x: vector of x-values
# me: matrix of experimental values where columns are time courses for sequential mz
# mf: matrix of fittings corresponding to me
    fi<-strsplit(fi,"CDF")[[1]][1]
  png(paste("../graf/",fi,"png",sep=""))
  x_range<-range(x[1],x[length(x)])
  g_range <- range(0,1)
  nkriv<-ncol(me); sleg<-"m0"
  plot(x,me[,1], xlim=x_range, ylim=g_range,col=1)
  lines(x,mf[,1],col=1, lty=1)
   for(i in 2:nkriv){ sleg<-c(sleg,paste("m",i-1))
    points(x,me[,i],pch=i,col=i)
    lines(x,mf[,i],col=i, lty=i)
  }
  legend("topright",sleg,col = 1:length(sleg),lty=1:length(sleg))
   dev.off()
   }
     

