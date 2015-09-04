# ---------------------
# Install support code (should only be needed at start and for update)
# ---------------------
# Originally copied from Rinterface/bin/installCommands.R

# ---------------------
#  Control Parameters
# ---------------------

# for local server
# UrLOfServer <- "http://localhost:8080/transmart"

# for umich
UrlOfServer <- "http://als-transmart.med.umich.edu:8080/transmart"

myWorkingDirectory <- "/Users/weymouth/Dropbox/ALS/github/RDataProcessing/RcodeForTransmartTests"

matchPatternForFrs <- "FRS Score\\\\Visit [[:digit:]]"
matchPatternForDuration <- "Days Since Onset\\\\Visit [[:digit:]]"

saveLoadFile <- "~/Desktop/observations.save"
saveFinalDataFile <- "~/Desktop/frsScore.csv"
plotOutputDirectoryAndFile <- "~/Desktop/plot.pdf"

# --- Simplified Script Steps (in place of the steps below)
require("transmartRClient")
require("ggplot2")
setwd(myWorkingDirectory)
source("./helpers.R")
connectToTransmart(UrlOfServer)
# (interaction required just above this line)
study <- findStudy(1)
observations <- loadPlotData(study, matchPatternForFrs, matchPatternForDuration)
plotIt(observations, 2, 200)
save(observations,file=saveLoadFile)

# --- save and load data
# save(observations,file=saveLoadFile)
load(saveLoadFile)
require("ggplot2")
setwd(myWorkingDirectory)
source("./helpers.R")
plotIt(observations, 2, 200)

# --- Script Steps 

# get required libraries - NOTE: this assuems that you have installed the pagkages for transmartRClient
# see bin/InstallCommands.R in https://github.com/thehyve/RInterface
require("transmartRClient")
require("ggplot2")

# set working directory
setwd(myWorkingDirectory)

# get helper functions (note relitive path from myWorkingDirectory) 
source("./helpers.R")

# Connect to the tranSMART Database server
# Note: this will print a URL for you to past in the browse and will ask you 
# to copy the verifier token that is returned in the browser and past it in R
connectToTransmart(UrlOfServer)

# get all studies on the server
studies <- getStudies()

#verify
print(studies$ontologyTerm.fullName)

# expected:
# [1] "\\Private Studies\\ALS_Goutman_1\\"         "\\Private Studies\\ALS_Goutman_10_Day\\"   
# [3] "\\Private Studies\\ALS_Goutman_Basic\\"     "\\Private Studies\\ALS_Goutman_Flow_Test\\"
# [5] "\\Private Studies\\ALS_Goutman_V2\\"        "\\Private Studies\\ALS_Goutman_V2_1\\"     
# [7] "\\Private Studies\\ALS_Goutman_V2_NS\\"    

# get study of interest - just to save myself from typing errors
study <- studies$id[1]

#get all concepts for study
concepts <- getConcepts(study)

#verify
summary(concepts)

#expected
#     name             fullName         api.link.self.href api.link.observations.href
# Length:23480       Length:23480       Length:23480       Length:23480              
# Class :character   Class :character   Class :character   Class :character          
# Mode  :character   Mode  :character   Mode  :character   Mode  :character 

# the FRS Scores - indexes
index1 <- grep(matchPatternForFrs,concepts$fullName)

# the duration - days since onset - indexes
index2 <- grep(matchPatternForDuration,concepts$fullName)

# both 
index3 <- c(index1, index2)

#verify concepts
concept3 <- concepts$fullName[index3]
print(concept3)

# Expect
# [1] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS FRS\\FRS Score\\Visit 1\\"             
# [2] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS FRS\\FRS Score\\Visit 2\\"             
# [3] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS FRS\\FRS Score\\Visit 3\\"             
# [4] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS FRS\\FRS Score\\Visit 4\\"             
# [5] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS FRS\\FRS Score\\Visit 5\\"             
# [6] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS Diagnosis\\Days Since Onset\\Visit 1\\"
# [7] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS Diagnosis\\Days Since Onset\\Visit 2\\"
# [8] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS Diagnosis\\Days Since Onset\\Visit 3\\"
# [9] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS Diagnosis\\Days Since Onset\\Visit 4\\"
#[10] "\\Private Studies\\ALS_Goutman_V2\\Flow\\ALS Diagnosis\\Days Since Onset\\Visit 5\\"

# get observations
observations <- getObservations(study, concept.links = concepts$api.link.self.href[index3])

# verify observations
summary(observations$observations)

# Expect
#  subject.id        ALS FRS_FRS Score_Visit 1 ALS FRS_FRS Score_Visit 2 ALS FRS_FRS Score_Visit 3
# Length:610         Length:610                Length:610                Length:610               
# Class :character   Class :character          Class :character          Class :character         
# Mode  :character   Mode  :character          Mode  :character          Mode  :character         
# ALS FRS_FRS Score_Visit 4 ALS FRS_FRS Score_Visit 5 ALS Diagnosis_Days Since Onset_Visit 1
# Length:610                Length:610                Length:610                            
# Class :character          Class :character          Class :character                      
# Mode  :character          Mode  :character          Mode  :character                      
# ALS Diagnosis_Days Since Onset_Visit 2 ALS Diagnosis_Days Since Onset_Visit 3
# Length:610                             Length:610                            
# Class :character                       Class :character                      
# Mode  :character                       Mode  :character                      
# ALS Diagnosis_Days Since Onset_Visit 4 ALS Diagnosis_Days Since Onset_Visit 5
# Length:610                             Length:610                            
# Class :character                       Class :character                      
# Mode  :character                       Mode  :character              

# convert the input to the values for plotting - see helper functions
# note: minTraceLength=2 implies that all patients with only one data point are dropped
patients <- convertForPlotting(observations$observations,minTraceLength=2)

# verify
summary(patients)

# Expect
#           id        frs_total    disease_days
#  1000386432:  4   31     : 12   1036   :  2  
#  1000386477:  4   35     : 11   234    :  2  
#  1000386694:  4   28     : 10   380    :  2  
#  1000386735:  4   29     : 10   578    :  2  
#  1000386233:  3   27     :  9   1027   :  1  
#  1000386273:  3   34     :  9   1035   :  1  
#  (Other)   :148   (Other):109   (Other):160  

# To save/reload these results - eq for adjusting plotting parameters
# write.csv(patients,saveFinalDataFile)
# plotdata <- read.csv(saveFinalDataFile)
# otherwise 
plotdata <- patients

### Plot - this following code is the code I was sent for plotting the Spaghetti Plot.
# with slight modifications: out destination, and the grouping for geom_line()

## use this statement to make PDF copy - bracketed with the dev.off() below
# pdf(plotOutputDirectoryAndFile)

makeSpaghettiPlot(plotdata, xMax=200)

# dev.off()
