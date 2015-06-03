#Load csv with headers#
patients <- read.csv(file="~/Dropbox/testathon/ALS/PracticeFlow.csv",head=TRUE,sep=",")
#Open ggplot2 Library#
library(ggplot2)

#Save the plot as a PDF file and assign the location for the plot#
pdf('~/Desktop/plot.pdf')

#Make the plot#
ggplot(patients, aes(x=disease_days, y=frs_total, color=factor(PT_ID))) +
geom_line() + geom_point() +
theme_bw() +
geom_smooth(aes(group = 1), size = 2) +
xlab("Disease Duration (days)") + ylab("ALSFRS-R") +
ggtitle("ALSFRS-R by time")
dev.off ();

