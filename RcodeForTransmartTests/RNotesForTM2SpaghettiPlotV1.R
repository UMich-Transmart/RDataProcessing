require("transmartRClient")
require("ggplot2")

source("./helpers.R")

connectToTransmart("http://localhost:8080/transmart")

# get all studies
studies <- getStudies()

#verify
print(studies)

# expected
#> print(studies)
#                                         id             api.link.self.href
#ALS_GOUTMAN_1                 ALS_GOUTMAN_1         /studies/als_goutman_1
#ALS_GOUTMAN_10_DAY       ALS_GOUTMAN_10_DAY    /studies/als_goutman_10_day
#ALS_GOUTMAN_BASIC         ALS_GOUTMAN_BASIC     /studies/als_goutman_basic
#ALS_GOUTMAN_FLOW_TEST ALS_GOUTMAN_FLOW_TEST /studies/als_goutman_flow_test
#ALS_GOUTMAN_V2               ALS_GOUTMAN_V2        /studies/als_goutman_v2
#                                           ontologyTerm.fullName
#ALS_GOUTMAN_1                 \\Private Studies\\ALS_Goutman_1\\
#ALS_GOUTMAN_10_DAY       \\Private Studies\\ALS_Goutman_10_Day\\
#ALS_GOUTMAN_BASIC         \\Private Studies\\ALS_Goutman_Basic\\
#ALS_GOUTMAN_FLOW_TEST \\Private Studies\\ALS_Goutman_Flow_Test\\
#ALS_GOUTMAN_V2               \\Private Studies\\ALS_Goutman_V2\\

# get study of interest
study <- studies[[1]][3]

# verify
print(study)

# Expected
# [1] "ALS_GOUTMAN_BASIC"

#get all concepts for study
concepts <- getConcepts(study)

# the AFS Scores - indexes
index1 <- grep("FRS Score\\\\[[:digit:]]",concepts$fullName)

# the days since onset - indexes
index2 <- grep("Days Since Onset\\\\[[:digit:]]",concepts$fullName)

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

### Plot - this following code is the code I was send for plotting the Spaghetti Plot.
# with slight modifications: out destination, and the grouping for geom_line()

filepath <- "~/Desktop/plot.pdf"
pdf(filepath)
makeSpaghettiPlot(patients)
dev.off ();