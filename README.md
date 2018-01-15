![Logo](figs/logo.png)

# cdf2MID
Version: 1.0

## Short description
R-program to read CDF files containing time course of mass spectra of 13C-labeled metabolites, and write the extracted spectra in a format appropriate for further analysis.

## Description
cdf2MID is a computer program designed to read the machine-generated files saved in netCDF format containing registered time course of m/z chromatograms. It evaluates the mass isotopomer distribution (MID) at the moment when peaks are reached, and saves the obtained information in a table, making it ready for further correction for natural isotope occurrence.
cdf2MID is written in “R”, uses library “ncdf4” (it should be installed before the first use of cdf2MID)  and contains several functions, located in the files “cdf2mid.R” and "libcdf.R", designed to read cdf-files, and analyze and visualize the spectra that they contain. The functionality of cdf2MID is similar to that of RaMID, with the difference that it does not need the previously prepared table with a list of CDF files and additional information, but uses onl short description of conditions provided by the experimentalist.

## Key features
- primary processing of 13C mass isotopomer data obtained with GCMS

## Functionality
- Preprocessing of raw data
- initiation of workflows of the data analysis

## Approaches
- Isotopic Labeling Analysis / 13C
    
## Instrument Data Types
- MS

## Data Analysis
cdf2MID reads the CDF files presented in the working directory, and then
- separates the time courses for selected m/z peaks corresponding to specific mass isotopomers;
- corrects baseline for each selected mz;
- choses the time points where the distribution of peaks is less contaminated by other compounds and thus is the most representative of the real analyzed distribution of mass isotopomers;
- evaluates this distribution, and saves it in files readable by MIDcor, a program, which performs the next step of analysis, i.e. correction of the RaMID spectra for natural isotope occurrence, which is necessary to perform a fluxomic analysis.

## Screenshots
- screenshot of input data (format Metabolights), output is the same format with one more column added: corrected mass spectrum

![screenshot]()

## Tool Authors
- Vitaly Selivanov (Universitat de Barcelona)

## Container Contributors
- [Pablo Moreno](EBI)

## Website
- N/A

## Git Repository
- https://github.com/seliv55/wf/tree/master/RaMID/cdf2tab

## Installation

- As independent program, cdf2mid itself does not require installation.  There are two ways of using it: either creating a library "cdf2mid", or reading source files containing the implemented functions. Standing in the cdf2mid directory:

- 1) Create a library of functions:
   
```
 sudo R

 library(devtools)
 
 build() 
 
 install() 
 
 library(cdf2mid) 
 
 library(ncdf4)
```

- 2) read directly the necessary functions:
  
```
 R 
 
 source("R/cdf2mid.R") 
 
 source("R/libcdf.R") 
 
 library(ncdf4)
```

- a zip file should contain the .cdf files that are to be analyzed.

## Usage Instructions

- The analysis performed when executing the  command:

```
 source("metdata")
 
 metan(outfile, pat)
```
 
- here the parameters are the names of an output file with the result (extracted relative intensities for all m/z constituting the peak), and a pattern that  archive containing .CDF files with registration of the injections into the mass spectrometer performed in the course of the given analyzed experiment.


## An example provided

- The file "R/metdata.R" contains the additional information provided by the experimentalist that is necessary to fill the table keeping the format accepted as exchangeable with the Metabolights database. Currently it content is:
    
    metabs=list(
cit=list(mz0=459,rt=37.5,Cder="C20H39O6Si3",Cfrg="C1-C6", metname="Citrate",  chebi="CHEBI:35804"),
asp=list(mz0=418,rt=28.5,Cder="C18H40O4N1Si3",Cfrg="C1-C4", metname="Aspartate", chebi="CHEBI:29991"),
mal=list(mz0=419,rt=27.2,Cder="C18H39O5Si3",Cfrg="C1-C4", metname="Malate", chebi="CHEBI:"),
glc=list(mz0=328,rt=3.74,Cder="C14H18O8N1",Cfrg="C1-C6",  metname="Glucose", chebi="CHEBI:"),
glu24=list(mz0=152,rt=3.79,Cder="C5H5O1N1F3",Cfrg="C2-C4", metname="Glutamate2-4", chebi="CHEBI:"),
glu25=list(mz0=198,rt=3.79,Cder="C6H7O3N1F3",Cfrg="C2-C5", metname="Glutamate2-5", chebi="CHEBI:"),
lac=list(mz0=328,rt=5.33,Cder="C10H13O3N1F7",Cfrg="C1-C3", metname="Lactate", chebi="CHEBI:"),
rib=list(mz0=256,rt=5.28,Cder="C11H14O6N1",Cfrg="C1-C5", metname="Ribose", chebi="CHEBI:")
)
tracer=list(
list(nik="Gluc",name="D-[1,2-C13]-Glucose",pos="1,1,0,0,0,0",abund=50),
list(nik="Glutam",name="[3-C13]-Glutamine",pos="0,0,1,0,0",abund=100)
)
inctime=c(0,24)
cells=c("A549","NCI","BEAS2B")

First part describes metabolites of interest, which spectra were registered and presented in the given set of CDF files. Metabolite info includes m/z value for unlabeled isotopomers (M0), retention time, the formula of molecules derivated for gas chromatography, the location of the analyzed fragment in the parent molecule, name, chebi identification.
Then follows the list tracers used, with positions of labels in the carbon skeleton, and its abundance.
Then a list of time moments where the measurements were performed; then the list of extracellular metabolites (substrates); types of cells analyzed; concentrations corresponding to the moments of measurements.

Based on this information and that extracted from the CDF files presented in the working directory cdf2mid creates tables of data accepted as exchangeable with Metabolights database.


- Run this example using the command:

```
  source("metdata")
 
  metan(outfile="cdf2midout.csv", cdfdir="wd")
```

The file containing the results provided by cdf2mid (here "cdf2midout.csv") can be used by RaMID, or directly proceed for further correction by MIDcor.

