# set up an empty matrix to collect (id, FRS-score, duration-day) values
outputMatrix <- matrix(,nrow=0,ncol=3)

# a 'helper' function that will be used to add (id, FRS-score, duration-day) values to the output matrix
addRow <- function(id, s, d){
	newrow <- c(id, s, d)
	outputMatrix <<- rbind(outputMatrix, newrow)
	newrow
}

sizeOfTrace = 1

# a 'helper' function (that uses addRow, above); used to traverse the multiple visits from input
extractFRSRecords <- function(row) {
	# this is BAD!!! - fixed values for indexes!
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
		mapply(function(s,d){addRow(id, as.numeric(s), as.numeric(d))},sout,dout,SIMPLIFY=FALSE)
	}
}

convertForPlotting <- function(input, minTraceLength=1) {

	sizeOfTrace <<- minTraceLength
	outputMatrix <<- matrix(,nrow=0,ncol=3)
	
	apply(input,1,extractFRSRecords)

	# adjust column and row names
	colnames(outputMatrix) <- c('id','frs_total','disease_days')
	rownames(outputMatrix) <- paste0('row-',c(1:length(outputMatrix[,1])))

	# set the data frame needed for plotting
	data.frame(outputMatrix)
}

makeSpaghettiPlot <- function(dataTable, xMin=-100, xMax=7000, 
			plot.subtitle=NULL,plot.title='ALSFRS-R by time') {
	# requires ggplot2
	plot <- ggplot(dataTable, aes(x=as.numeric(disease_days), y=as.numeric(frs_total), color=factor(id)))
	plot <- plot + geom_line(aes(group = factor(id))) + geom_point()
	plot <- plot + theme(legend.position="none")
	plot <- plot + coord_cartesian(xlim = c(-20, xMax))
	plot <- plot + geom_smooth(aes(group = 1), size = 2, method='loess')	
	plot <- plot + xlab("Disease Duration (days)") + ylab("ALSFRS-R")
	if (is.null(plot.subtitle)) {
		plot <- plot + ggtitle(plot.title)		
	}
	else {
		plot <- plot + ggtitle(bquote(atop(.(plot.title), atop(italic(.(plot.subtitle))))))
	}
	plot
}

checkDirection <- function(dataTable) {
	oldId <<- -1;
	oldV <<- -1;
	apply(dataTable,1,checkDirectionOfRow)
}

checkDirectionOfRow <- function(row) {
	id = row[1]
	value = row[2]
	data = row[3]
	
	if (id != oldId) {
		oldV <<- -1
		oldId <<- id
	} else {
    	if (oldV > value) {
	    	return (id)
	    }
		oldV <<- value
	}
	return (NULL)
}

findStudy <- function(indexForStudy) {
	studies <- studies <- getStudies()
	#verify
	print(studies$ontologyTerm.fullName)
	study <- studies$id[indexForStudy]
	print(study)
	return(study)
}

loadPlotData <- function(study, matchPatternForFrs, matchPatternForDuration) {
	print("Getting concepts for Study")
	concepts <- getConcepts(study)
	print("Summary of data about all concepts:")
	print(summary(concepts))
	# the FRS Scores - indexes
	index1 <- grep(matchPatternForFrs,concepts$fullName)
	# the duration - days since onset - indexes
	index2 <- grep(matchPatternForDuration,concepts$fullName)
	# both 
	index3 <- c(index1, index2)
	print("Showing concepts selected: ")
	concept3 <- concepts$fullName[index3]
	print(concept3)
	print("Getting observation data for selected concepts . . .")
	observations <- getObservations(study, concept.links = concepts$api.link.self.href[index3])
	print("Summary of observation data returned: ")
	print(summary(observations$observations))
	return (observations)
}

plotIt <- function(observations, traceLength=2, xLimit=200) {
	patients <- convertForPlotting(observations$observations,minTraceLength=traceLength)
	makeSpaghettiPlot(patients, xMax=xLimit)
}
