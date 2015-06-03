testObject <- function(object)
{
   exists(as.character(substitute(object)))
}

extractFRSRecords <- function(row) {
	id <- row[1]
	score <- row[2:6]
	duration <- row[7:11]
	selector <- !is.na(score) & !is.na(duration)
	sout <- score[selector]
	dout <- duration[selector]
	ids <- rep(id, times=1, length.out=length(sout))
	mapply(function(s,d){list(id, s, d)},sout,dout)
}

