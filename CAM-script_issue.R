library('tidyverse')

#this is unchanged
in_range = function(val, min, max){
  if((val >= min) & (val <= max)){
    return(TRUE)
  }
  return(FALSE)
}

#TY for making this part easy for me
df_outliers = read_tsv('GSBPI_outliers_range.txt')
df_nonout = read_tsv('GSBPI_neutral_SNPS.txt')

list_of_dfs = list()

#note the for loop I had range in my inital writing - that was a python brain issue, 
#this is now iterating over the numbers 1 -> length of the outlier dataframe (1 -> 163)
for(i in 1:nrow(df_outliers)){

	#moved the subsetting out of lapply and here so its easier to keep track of
	id = df_outliers[['SNP']][[i]]
	min = df_outliers[['low']][[i]]
	max = df_outliers[['high']][[i]]

	#we are working with multiple chromosomes so should subset on that first
	chr = df_outliers[['CHR']][[i]]
	#get all snps for the chr of the outlier snp
	chr_snps = df_nonout[df_nonout$CHR == chr,]

	#simplified. here we are iterating over the position column for the chr, not full df
	#looks a little cleaner than my initial description because we make the min and max
	#variables above, not in the lapply
	keep_vec = unlist(lapply(chr_snps[['POS']], function(x){
							in_range(x, min, max)
							}))

	#subset the chr non-outliers based off the boolean vector we just made
	new_df = chr_snps[keep_vec,]
  	#add a new member to the list, name for each list member is the outlier snp,
  	#value for each list member is the dataframe corresponding to the snps in the
  	#window
	list_of_dfs[[id]] = new_df
}

#double checks
length(list_of_dfs) == nrow(df_outliers)
names(list_of_dfs) == df_outliers[['SNP']]
#look at it to understand the structure
list_of_dfs
names(list_of_dfs) #outlier IDS
list_of_dfs[1]	#df with outlier label
list_of_dfs[[1]]#just the df

#neither of below tested:
#from here you could either add the label (name for each list member) to a column
#and then merger the list into a single df. 
#something like: 
#lapply(1:length(list_of_dfs), function(i){
#	list_of_dfs[[i]][['new_col']] = names(list_of_dfs[[i]]
#	})
#out = do.call(list_of_dfs, rbind)
#or you could write them all to a set of files and then use them one by one in the 
#next program. something like: 
#for(i in 1:length(list_of_dfs)){
#	write_tsv(list_of_dfs[[i]], 
#				paste0(names(list_of_dfs[[i]]), "_non-outliers.tsv"))
#	}