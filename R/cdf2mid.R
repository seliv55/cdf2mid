#  setwd(oldi)
# oldi<-getwd()
#  source(infile)
# print(infile)

metan<-function(outfile="cdf2midout.csv",cdfzip="roldan.zip"){ #infile="metdata",  main function; evaluates MID for a set of CDF files specified by pat
#  and metabolite specified by m/z M-1 referred as ms
# call: metan()
 temp <- tempdir()#paste(,"/",sep="")  #"data/ttt/"  #
 lcdf<-unzip(cdfzip,exdir=temp)
  start.time <- Sys.time()
#    fi0=paste("../",cel,lab, sep=""); # file to write Midcor output in PhenoMeNal format
     df0<-data.frame(); # data frame to write Midcor output in PhenoMeNal format
#title<-data.frame("MS Assay Name","cells","tracer molecule","labelled positions","abundance(%)","injection","Replicate","Factor Value[Incubation time](hours)", "Metabolite name", "CHEBI identifier","fragment positions in the parent molecule", "Empirical formula derivatized molecule/fragment", "retention(min)", "m/z monitored", "signal intensity", "Isotopologue", "isotologue abundance(%)")
     
title<-data.frame("Raw Data File", "cells", "tracer molecule","labelled positions","abundance","Parameter Value[injection]","Parameter Value[Replicate]","Factor Value[Incubation time]","Metabolite name","CHEBI identifier","atomic positions to the parent molecule/metabolite name","Empirical formula derivatized molecule/fragment", "retention(min)", "m/z monitored","signal intensity","isotopologue","isotologue abundance relative concentration")

     ldf<-list(); # data frame to write Ramid output in PhenoMeNal format
     ifi<-0;
     finames=character()
     df0<-data.frame(); # data frame to write Ramid output in PhenoMeNal format

       for(fi in lcdf){itrac<-0 #labname<-" "; labpos<-" "; abund<-" "; ti<-0 #CDF files one by one
         for(trac in tracer) {  #check what label was used for the given file
         if(grepl(trac$nik,fi)) {itrac<-itrac+1; labname<-trac$name; labpos<-trac$pos; abund<-trac$abund }
         if(itrac==0) { labname<-" "; labpos<-" "; abund<-0 }}
         
           for(tinc in inctime)  #check the file for incubation time
           if(grepl(paste(tinc,'H',sep=""),fi)|grepl(paste(tinc,'h',sep=""),fi)) break;
           
           for(cel in cells) if(grepl(cel,fi)) break
           
           inj=substr(fi,nchar(fi)-4,nchar(fi)-4)
           rep=substr(fi,nchar(fi)-7,nchar(fi)-7)
           
     a <-findpats(fi,finames,ldf);
     finames<-a[[1]]; ldf<-a[[2]]   # output 1: reltive intensities; 2: relative peak areas;
 if(length(a)>1)  { ifi<-ifi+1; mzr<-a[[3]]; imet<-a[[4]]; dist<-a[[5]];
        for(j in 1:length(imet)) {data=metabs[[imet[j]]]; miso=character(); miso=paste("13C",mzr[[j]]-data$mz0,sep="") #isotopomer names
        fispl<-tail(strsplit(fi,"/")[[1]],1)
  dfrow<-data.frame(fispl,cel,labname,labpos,abund,inj,rep,tinc,data$metname,data$chebi,data$Cfrg,data$Cder,data$rt, mzr[[j]], c(0,dist[[j]]), miso," ")
  df0<-rbind(df0,dfrow) # filling df with dfrow
     }
     }
       }
      for(i in 1:length(finames))  write.table(ldf[i], file=finames[i], row.names = F, col.names = F, sep=",") #simple output format
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
    unlink(temp, recursive = T, force = T)
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
  
  
  
findpats<-function(fi,finames,ldf,tlim=50){
# fi: file name
# metp: parameters of metabolite (mz for m0, retention time)
    a<-readcdf(fi);
#    mz, intensities, number of mz-point at each rett, sum of iv at each rett
     mz<-a[[1]]; iv<-a[[2]]; npoint<-a[[3]]; rett<-a[[4]]; totiv<-a[[5]];
#    summary: 
 a<-info(mz,iv,npoint); mzpt<-a[[1]]; tpos<-a[[2]]; mzind<-a[[3]]; mzrang<-a[[4]]; 
     
     icyc<-0; lmet<-numeric(); imet<--1; mzr<-list(); dispik<-list(); disar<-list()
     
         for(metp in metabs) { icyc=icyc+1;  rts<-as.numeric(metp$rt)*60.;
        for(i in 1:length(mzrang))
   if((metp$mz0 %in% mzrang[[i]]) & (rts > rett[tpos[i]]) & (rts < rett[tpos[i+1]-5])) {
#   find whether mid for a given metabolite is presented in the file fi 
                 ranum<-i
  nma<-findmax(totiv=totiv,tin=tpos[ranum],tfi=tpos[ranum+1]);
  
   if((rett[tpos[i]+nma]>(rts-15))&(rett[tpos[i]+nma]<(rts+15))){ imet<-icyc
            fil<-paste(metp$mz0,metp$metname,sep="")
         if(!(fil %in% finames)) { finames<-c(finames,fil); cat("\n",file=fil)
           ldf[[length(finames)]]<-data.frame();       }
               finum<-which(finames %in% fil)
 
  mzi<-mzind[ranum]+mzpt[ranum]*(nma-tlim)
   tl<-tpos[ranum]+nma-tlim;  tu<-tpos[ranum]+nma+tlim;
    tiv<-totiv[tl:tu]; rett1<-rett[tl:tu] #separate area peak ± tlim for total intensity and retention
    nmi<-which.min(tiv);
   
 a<-setmat(mz00=metp$mz0,mzrang=mzrang[[ranum]],mzind=mzi,iv=iv, mzpt=mzpt[ranum],tini=tl,tfin=tu);
 intens<-a[[1]];  mzr[[length(mzr)+1]]<-a[[2]];# separate area peak ± tlim for intensity matrix
   bas=baseln(intens,nmi,tlim)   # baseline:
  intens<-subas(intens,bas)    # subtract baseline
  
    a<- peakdist(fi,intens,rett1,tlim)
    dispik[[length(dispik)+1]]<-a[[1]]; disar[[length(disar)+1]]<-a[[2]]
    fi<-strsplit(fi,"CDF")[[1]][1]
    ldf[[finum]]<-rbind(ldf[[finum]],t(c(fi,disar[[length(disar)]])))
    lmet<-c(lmet,imet)
      } }
   }
 return(list(finames,ldf,mzr,lmet,disar))}
 
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
     

