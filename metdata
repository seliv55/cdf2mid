metabs<-list(
cit=list(mz0=459,rt=37.5,Cder="C20H39O6Si3",Cfrg="C1-C6",  conc=1, metname="Citrate",  chebi="CHEBI:35804"),
asp=list(mz0=418,rt=28.5,Cder="C18H40O4N1Si3",Cfrg="C1-C4", conc=1, metname="Aspartate", chebi="CHEBI:29991"),
mal=list(mz0=419,rt=27.2,Cder="C18H39O5Si3",Cfrg="C1-C4", conc=1, metname="Malate", chebi="CHEBI:"),
glc=list(mz0=328,rt=3.74,Cder="C14H18O8N1",Cfrg="C1-C6", conc=1, metname="Glucose", chebi="CHEBI:"),
glu24=list(mz0=152,rt=3.79,Cder="C5H5O1N1F3",Cfrg="C2-C4", conc=1, metname="Glutamate2-4", chebi="CHEBI:"),
glu25=list(mz0=198,rt=3.79,Cder="C6H7O3N1F3",Cfrg="C2-C5", conc=1, metname="Glutamate2-5", chebi="CHEBI:"),
lac=list(mz0=328,rt=5.33,Cder="C10H13O3N1F7",Cfrg="C1-C3", conc=1, metname="Lactate", chebi="CHEBI:"),
rib=list(mz0=256,rt=5.28,Cder="C11H14O6N1",Cfrg="C1-C5", conc=1, metname="Ribose", chebi="CHEBI:")
)

tracer<-list(
list(nik="Gluc",name="D-[1,2-C13]-Glucose",pos="1,1,0,0,0,0",abund=50),
list(nik="Glutam",name="[3-C13]-Glutamine",pos="0,0,1,0,0",abund=100)
)

inctime<-c(0,24)

# extracellular concentrations at "inctime":
substrates<-c("Glucose","Glutamine","Lactate","Glutamate")

cells<-c("A549","NCI","BEAS2B")

concentrations<-list(
A549=list(cl="A549",Glucose=c(8.636, 5.282),Glutamine=c(2.915, 2.167), Lactate=c(0.907, 7.850),Glutamate=c(0.101, 0.542)),
NCIH460=list(cl="NCIH460",Glucose=c(9.003, 3.063),Glutamine=c(2.955, 1.903),Lactate=c(0.920, 12.517),Glutamate=c(0.105, 0.419)),
BEAS2B=list(cl="BEAS2B",Glucose=c(10.107, 7.489),Glutamine=c(3.809, 3.666),Lactate=c(0.000, 5.950),Glutamate=c(0.000, 0.230))
)

keys<-list(t=inctime[2],cel=cells[1],trac=tracer[[1]]$name)

