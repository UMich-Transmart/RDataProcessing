# ---------------------
#  Control Parameters
# ---------------------

myWorkingDirectory <- "/Users/weymouth/Dropbox/testathon/ALS/github/RDataProcessing/RcodeForTransmartTests"

UrLOfServer <- "http://localhost:8080/transmart"

matchPatternForFrs <- "FRS Score\\\\[[:digit:]]"
matchPatternForDuration <- "Days Since Onset\\\\[[:digit:]]"

plotOutputDirectoryAndFile <- "~/Desktop/plot.pdf"

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
connectToTransmart(UrLOfServer,use.authentication=TRUE)

# get all studies on the server
studies <- getStudies()

#verify
print(studies$ontologyTerm.fullName)

# expected:
# [1] "\\Private Studies\\ALS_Goutman_1\\"         "\\Private Studies\\ALS_Goutman_10_Day\\"   
# [3] "\\Private Studies\\ALS_Goutman_Basic\\"     "\\Private Studies\\ALS_Goutman_Flow_Test\\"
# [5] "\\Private Studies\\ALS_Goutman_V2\\"       

# get study of interest - just to save myself from typing errors
study <- studies$ontologyTerm.fullName[3]

# verify
print(study)

# Expected
# [1] "\\Private Studies\\ALS_Goutman_Basic\\"

#get all concepts for study
concepts <- getConcepts(study)

# the FRS Scores - indexes
index1 <- grep(matchPatternForFrs,concepts$fullName)

# the duration - days since onset - indexes
index2 <- grep(matchPatternForDuration,concepts$fullName)

# both 
index3 <- c(index1, index2)

#verify concepts
concept3 <- concepts$fullName[index3]
print(concept3)

# get observations
observations <- getObservations(study, concept.links = concepts$api.link.self.href[index3])

# verify observations
summary(observations$observations)

# convert the input to the values for plotting - see helper functions
patients <- convertForPlotting(observations$observations,minTraceLength=1)

# verify
summary(patients)

write.csv(patients,"frsdata.csv")
data <- read.csv("frsdata.csv")

### Plot - this following code is the code I was send for plotting the Spaghetti Plot.
# with slight modifications: out destination, and the grouping for geom_line()

xMin <-20
xMax <- 7000

pdf(plotOutputDirectoryAndFile,xMin,xMax)
makeSpaghettiPlot(data)
dev.off ();
