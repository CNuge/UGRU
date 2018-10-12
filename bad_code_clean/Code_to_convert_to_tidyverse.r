load("subsampled.RM.out.RData")
head(subsampled.RM.out)

dat = subsampled.RM.out
rm(subsampled.RM.out)

head(dat)


#this was missing?
dat$Window_Size = dat$End - dat$Start
#but its not needed?

#no its a lil window thingy
Window.Size = 150000

comm_by_chromosome <- lapply(split(dat, dat$Chromosome), function(y) t(sapply(split(y, list(cut(y[,"End"], as.integer(max(y$End)/as.integer(Window.Size))))), function(x) table(x$Family))))

#########
#########
# other example count the number of TE from each family on each chromosome.
#########
#########

all_chr = unique(dat$Chromosome)
length(all_chr) #humans!

all_fams = factor(unique(dat$Family))

length(all_fams)
levels(all_fams)

comm_by_chromosome = data.frame(Family = all_fams)
comm_by_chromosome

for(chr in all_chr){
	comm_by_chromosome[,chr] = 0 

	subset = dat[dat$Chromosome == chr ,]

	for(trans in comm_by_chromosome$Family){
		count = length(subset$Family[subset$Family == trans])
		comm_by_chromosome[comm_by_chromosome$Family == trans, chr]	= count
	}

}

head(comm_by_chromosome) #dataframe with chr as columns and family counts in rows


#challenge - one line the above with a groupby