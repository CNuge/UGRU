###########
# file loops
# a ugru tutorial by cam
###########


#I find read_csv to be superior in pretty nuch every way
#ergo we will use it

#install.packages('tidyverse')
library(tidyverse)


# To start we are going to make some demo files to process, 
# make sure you know your working dir for this
getwd() #files will appear where this is set to.
#warning: we gonna make this folder a mess on purpose.


#this puts fake ids on the iris dataset, we will use these for merging dataframes
iris$id_index = unlist(lapply(1:nrow(iris), function(i){
	paste0("ID_", i)
	}))

#setup - make some data files
#the contents of the files aren't all that important, so we will just
#rep the iris datset using the following

#note below the use of paste0 to make a string, this is a good motif for auto generating
#filenames on the fly (i.e. if the filenames are structured)
print("building demo files")
for(i in 1:5){
	fname = paste0("demo_input_file_", i, '.tsv') #this makes a string from all the components

	right_fname = paste0("other_info_file_", i, '.tsv') 
	#^ these will come up later, we will walk through iterative file merger/dataframe joining

	#i prefer tsvs to csvs because they're easier to examine visually in my text editor
	write_tsv(iris, fname) 
	write_tsv(iris, right_fname) 
}


#side note - you'll notice I'm not in rstudio, one of the reasons I don't use it is what
#we are discussing today, I find it a lot easier to process files when I have the folder open and 
#i can keep track of things. Plus I like having a terminal readily available
# I find moving/making/keeping track of files in rstudio really frustrating
#^this is opinion


#now we have 5 pairs of files with different names, that have same data strucutre
#this could come up if your working with standard data formats, i.e. in genetics
#maybe fasta files or sequencing runs, in ecology maybe datasheets for different years of observations,
#or different raster files. If you need to run the same cleaning steps (i.e. remove
#NAs, scale values etc.) but don't want to merge (or cant merge) data into a single file
#here is a simple solution.

########
# iteratively working on and writing outputs for multiple files.
########

# Below is the code for working on our series of files without having to hard code in
# a bunch of read_tsv and write_tsv statements. we also don't have to copy and paste
# the code block for each file, or come up with unique variable names for each one.
# All we do it write out all the processing steps once, and iterate over the
# vector of filenames to apply to processing to all files sequentially.

#the demo files we generated above, names hardcoded
file_vec = c(
	'demo_input_file_1.tsv',
	'demo_input_file_2.tsv',
	'demo_input_file_3.tsv',
	'demo_input_file_4.tsv',
	'demo_input_file_5.tsv'
	)
#note: you can call ls in the wd from your terminal to get these filenames quickly,
#without needing to type them out yourself. Then just paste and add the 
#quotes, brackets and parentheses. Or use list.files() in R.

#note2 - you can skip typing the list by using list.files() 
# but here be dragons if you have other things in the wd.
#^ if you want to do this, you need to be organized and have the data in a dedicated folder

#next we iterate over the FILENAMES and do our workflow for each file
print("processing data files") #this will come up at the end

#cam tip - I comment the following line out above my file loops to facilitate testing on
#only a single example, just run this line to simulate the first iteration and check it all works

#f = file_vec[[1]]
for(f in file_vec){

	#prints aren't needed, I do it to generate a log file (record of where things break)
	print(paste0("on file: ", f)) 
	dat = read_tsv(f)

	print("conducting analysis")
	#your manipulation code would go here. We're turning a column to uppercase as a standin for real analysis .
	dat$Species = toupper(dat$Species)

	#build the output filename from the input name. We are adding a prefix to denote it as the output
	#note - this is because you generally never ever want to overwrite the input file, could make unfixable error!
	outname = paste0("output_", f) 
	print(paste0("writing to file: ", outname))

	write_tsv(dat, outname)

}


#########
# organized version of above
#########
#instead of just reading and writing to the current directory, you can make a subfolder
#called data, and save the data to there.
#I'll usually have an something like a 'raw' folder that the original tsvs are read from as well.

dir.create('data/') #equivalent to mkdir from the cmd line

#same loop as above, but the output file prefix now includes the folder in the name
for(f in file_vec){

	dat = read_tsv(f)

	dat$Species = toupper(dat$Species) #your r code goes here

	outname = paste0("data/output_", f) 

	write_tsv(dat, outname)

}



#########
# multiple file loop processing
#########

# remember we made that second set of files at the start?
# here is the trick to extending this technique to processing two streams of files. 
# Instead of iterating over file names, we label two vectors and iterate
# over the vector names. This lets us grab both filenames and read them in 
# without needing to hardcode any of the read or write statements.
# We also don't have to copy and paste the in between code all over the place.


#Here we merge out demo inputs with our other info, and make a series of output files.
#Could do any necessary cross file comparison, or data manipulation in the middle

#set of files 1
file_vec = c(
'f1' = 'demo_input_file_1.tsv',
'f2' = 'demo_input_file_2.tsv',
'f3' = 'demo_input_file_3.tsv',
'f4' = 'demo_input_file_4.tsv',
'f5' = 'demo_input_file_5.tsv'
)

#set of files 2
other_file_vec = c(
'f1' = 'other_info_file_1.tsv',
'f2' = 'other_info_file_2.tsv',
'f3' = 'other_info_file_3.tsv',
'f4' = 'other_info_file_4.tsv',
'f5' = 'other_info_file_5.tsv'
)

# bonus pattern
# instead of pasting a prefix using paste0 like we did above, 
# we can use the same trick to access bespoke output filenames with ease
custom_outname = c(
'f1' = 'joined_file_1.tsv',
'f2' = 'joined_file_2.tsv',
'f3' = 'joined_file_3.tsv',
'f4' = 'joined_file_4.tsv',
'f5' = 'joined_file_5.tsv'
)


#f = names(file_vec)[[1]]
for(f in names(file_vec)){

	dat = read_tsv(file_vec[[f]])

	other_dat = read_tsv(other_file_vec[[f]])

	#join the two inputs
	out_dat = left_join(dat, other_dat, by = 'id_index')

	#do other stuff here


	#write the merged and manipulated df to the output
	write_tsv(out_dat, custom_outname[[f]])

}

#benefits of this approach:
# - don't have to copy and paste code
# - don't have to make new variable names to make the different read/write instances unique
# - to scale up, we just add files to the initial vectors
# - organized, all the files in question are listed in a single place
# - never more than one file loaded into memory at a time, if you tried to do this by rbinding your
#   dataframes or by loading all in and manipulating them with lapply or equivalent
#   then all files have to be held in RAM at once. this can lead to a crash if you have big files 
#   (or if you have chrome and spotify and a bunch of other things open).


#closing related thoughts:
# - never ever put spaces in filenames (or folder names), can lead to some nuanced errors. 
#   ^ extremly bad practice
# - keeping your data in subfolders such as  data/ to help keep things organized, paste0 
#   lets you add the folder name prefix to the filename string with ease
# - reading in a bunch of dataframes and rbinding them can overcomplicate things at times, but
#   there are also times where that approach is the more logical choice.
# - this approach lets you write 'set and forget' scripts. run front to back without having to 
#   touch the code. I think the mark of a good R script is one that can execute using the Rscript command 
#   from the command line without error. Otherwise you're not organized and your code is too fragile.
#
#   Rscript multi_file_demo.r 
#
# - the print statements and use of Rscript allow for tidy tracking of execution progress, can identify
#   corrupted inputs, or bugs in our code more easily
#
#   Rscript multi_file_demo.r > cam_example.log
#
#   ^cam when doing demo remember to change an input filename or strucutre and rerun this line, 
#    we can catch the error easily b/c of the prints






############################################
# NOTE - DANGER ZONE!!!!!!
# dont run this if you are not following along in a dedicated working directory
# or if you don't understand it.
# YOU WILL DELETE ALL THE .TSVs IN THE FOLDER

#this is wrapped in a function only so that you can't execute it by accident if you're
#playing fast and loose with the running of code.
#run the function body only.
danger_x = function(){

	#delete all the tsvs we just made
	for(f in list.files()){
		if(substr(f, (nchar(f)-3), nchar(f)) == ".tsv"){
			file.remove(f)		
		}
	}

}

  
#############################################

# note - we are out of the danger zone, as you were
print('done!')
