require("transmartRClient")
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

# set up an empty matrix to collect (id, FRS-score, duration-day) values
outputMatrix <- matrix(,nrow=0,ncol=3)

# a 'helper' function that will be used to add 
addRow <- function(id, s, d){
	newrow <- c(id, s, d)
	outputMatrix <<- rbind(outputMatrix, newrow)
	newrow
}

sizeOfTrace = 4

# a 'helper' function (that uses addRow, above); used to traverse the multiple visits from input
extractFRSRecords <- function(row) {
	id <- row[1]
	score <- row[2:6]
	duration <- row[7:11]
	selector <- !is.na(score) & !is.na(duration)
	sout <- score[selector]
	dout <- duration[selector]
	ids <- rep(id, times=1, length.out=length(sout))
	## limit output to only those patients with more the one record; 
	## for all records, change sizeOfTrace, above, to 1
	if (length(sout) >= sizeOfTrace) {
		mapply(function(s,d){addRow(id,s,d)},sout,dout,SIMPLIFY=FALSE)
	}
}

# convert the input to the values for plotting
apply(observations$observations,1,extractFRSRecords)

# adjust column and row names
colnames(outputMatrix) <- c('id','frs_total','disease_days')
rownames(outputMatrix) <- paste0('row-',c(1:length(outputMatrix[,1])))

# set the data frame needed for plotting
patients <- data.frame(outputMatrix)

### Plot - this following code is the code I was send for plotting the Spaghetti Plot.
# with slight modifications: out destination, and the grouping for geom_line()

#Open ggplot2 Library#
library(ggplot2)

#Save the plot as a PDF file and assign the location for the plot#
pdf('~/Desktop/plot.pdf')

#Make the plot#
ggplot(patients, aes(x=disease_days, y=frs_total, color=factor(id))) +
geom_line(aes(group = factor(id))) + geom_point() +
theme_bw() +
geom_smooth(aes(group = 1), size = 2) +
xlab("Disease Duration (days)") + ylab("ALSFRS-R") +
ggtitle("ALSFRS-R by time")
dev.off ();


