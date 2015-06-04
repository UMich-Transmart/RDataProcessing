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

makeSpaghettiPlot <- function(patients) {
	# requires ggplot2
	#Save the plot as a PDF file and assign the location for the plot#

	#Make the plot#
	ggplot(patients, aes(x=disease_days, y=frs_total, color=factor(id))) +
	geom_line(aes(group = factor(id))) + geom_point() +	
	theme_bw() +
	geom_smooth(aes(group = 1), size = 2) +	
	xlab("Disease Duration (days)") + ylab("ALSFRS-R") +
	ggtitle("ALSFRS-R by time")
}

