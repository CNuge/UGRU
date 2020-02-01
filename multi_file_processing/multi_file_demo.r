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
	#^ these will come up later, we will walked through iterative file merger/munging

	#i prefer tsvs to csvs because they're easier to examine visually in my text editor
	write_tsv(iris, fname) 
	write_tsv(iris, right_fname) 
}


#side note - you'll notice I'm not in rstudio, one of the reasons I don't use it is what
#we are discussing today, lot easier to process files when I have the folder open and 
#i can keep track of things. find moving/keeping track of files in rstudio really frustrating
#^this is opinion


#now we have 5 pairs of files with different names, that have same data strucutre
#this could come up if your working with standard data formats, i.e. in genetics
#maybe fasta files, in ecology maybe datasheets from different oservation years,
#or different raster files. If you need to run the same cleaning steps (i.e. remove
#NAs, scale values etc.) but don't want to merge (or cant merge) into a single file
#here is a simple solution.

########
# iteratively working on and writing outputs for multiple files.
########

# Below is the code for working on our series of files, without having to hard code in
# a bunch of read_tsv and write_tsv statements. we also don't have to copy and paste
# the code block for each file, or come up with unique variable names for each one.
# 

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
#quotes, brackets and parentheses

#note2 - skip typing with list.files() exists, but here be dragons if you have other things in the wd.
#^ if you want to do this, you need to be organized


#next we iterate over the FILENAMES and do our workflow for each file

#cam tip - I coment the following line out above my file loops to facilitate testing on
#only a single example, just run this line to simulate the first loop and check it works

print("processing data files")

#f = file_vec[[1]]
for(f in file_vec){

	#prints aren't needed, I do it to generate a log file (record of where things break)
	print(paste0("on file: ", f)) 
	dat = read_tsv(f)

	print("conducting analysis")
	#your manipulation code would go here. turning column to uppercase as a standin for real analysis 
	dat$Species = toupper(dat$Species)

	#build the output filename from the input, adding the necessary prefix
	#note this is because you generally never ever want to overwrite the input file, could make unfixable error!
	outname = paste0("output_", f) 
	print(paste0("writing to file: ", outname))

	write_tsv(dat, outname)

}


#########
# organized version of above
#########
#instead of just reading and writing to the current directory, you can make a subfolder
#called data, and save the data to there.
#ill usually have an something like a 'raw' folder that the original tsvs are read from as well.

dir.create('data/') #equivalent to mkdir from the cmd line

#same loop as above, but the output file prefix now includes the foler in the name
for(f in file_vec){

	dat = read_tsv(f)

	dat$Species = toupper(dat$Species) #usual r code goes here

	outname = paste0("data/output_", f) 

	write_tsv(dat, outname)

}



#########
# multiple file loop processing
#########

# remember we made that second set of files at the start
# here is the trick to extending this tchnique to processing two streams of 
# files instead of iterating over file names, we label two vectors and iterate
# over the names in order to read them both in, without needing to hardcode the names


#here we merge out demo inputs with our other info, and make a series of output files
#could do any necessary cross file comparison, or data manipulation in the middle
file_vec = c(
'f1' = 'demo_input_file_1.tsv',
'f2' = 'demo_input_file_2.tsv',
'f3' = 'demo_input_file_3.tsv',
'f4' = 'demo_input_file_4.tsv',
'f5' = 'demo_input_file_5.tsv'
)


other_file_vec = c(
'f1' = 'other_info_file_1.tsv',
'f2' = 'other_info_file_2.tsv',
'f3' = 'other_info_file_3.tsv',
'f4' = 'other_info_file_4.tsv',
'f5' = 'other_info_file_5.tsv'
)

#instead of pasting a prefix like above, we can use the same trick to access 
#bespoke output filenames with ease
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
# - don't have to make new variable names to make the different read/write unique
# - to scale up, we just add files to the initial list
# - organized, all the files in question are listed in a single place



#closing related thoughts:
# - never put spaces in filenames, can lead to some nuanced errors. extremly bad practice
# - keeping your data in subfolders such as  data/ help keep things organized, paste0 
#   lets you add the folder name prefix to the filename string with ease
# - reading in a bunch of dataframes and rbinding them can overcomplicate things at times, but
#   there are also times where that approach is the more logical choice.
# - this approach lets you write 'set and forget' scripts. run front to back without having to 
#   touch the code. Mark of a good R script is one that can execute using the Rscript command 
#   from the command line.
#   Rscript multi_file_demo.r 
# - the print statements and Rscript allow for tidy tracking of execution progress, can identify
#   corrupted inputs, or bugs in our code more easily
#   Rscript multi_file_demo.r > cam_example.log

# ^change an input filename and rerun this line, we can catch the error easily b/c/ of the prints


############################################
# NOTE - DANGER ZONE!!!!!!
# dont run this if you are not following along in a dedicated working directory
# nor if you don't understand it.
# YOU WILL DELETE ALL THE .TSVs IN THE FOLDER

#this is wrapped in a function only so that you can't execute it by accident
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