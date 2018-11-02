setwd('~/Code/UGRU/non_rectangles/')

# this is a file with the text from a short story by Isaac Asimov:
# 'The last question'
multivac = 'asimov_the_last_question.txt'


#it gets confused because we told it to read a csv, but there are just random
#commas interspersed throughout the lines...
csv_try = read.csv(multivac)

#this works, it just reads the data in line by line 
# and stores the contents as a list of strings
lines = readLines(multivac)

summary(lines)
is.vector(lines)

#first two members of vector
lines[1:2]
#last member of vector
lines[length(lines)] 

#####################
#Questions to answer:
#####################

#####################
# 1. how many lines of dialogue are there?:
# hint: look at lines 27, 29, 36, 90
# efficiency hint: can you write a generic function to answer this and question 2?
i= 27
lines[i]
grepl("\"" , lines)


dialouge = 0
for(i in 1:length(lines)){
  if(grepl("\"" , lines[i])){
    dialouge = dialouge + 1	
  }
}

dialouge

dialouge_list = grepl("\\?", lines)
dialouge_list

#####################
# 2. a. what is the first question in the text? 
q_list = grepl("\\?", lines)
q_list


is_question =  lines[q_list == TRUE]
is_question[1]
lines[29]
# b. what is the last question?
is_question[length(is_question)]

rev(is_question)[1]

#####################

WordCount = function(str){
  words = strsplit(str, "\\s+")[[1]]
  return(length(words))#int
}


wc = lapply(lines, function(x){WordCount(x)})
unlist(wc)



# 3. build a dataframe with the following columns (and data types)
#Line	is_dialogue	is_question	word_count	text
#int	Bool		    Bool		    int			    string

data.frame(is_dialogue = )

seq_along(lines)
seq(1,length(lines))
seq(1,10,2)

question_df = data.frame(line= 1:length(lines),
                         is_dialouge = unlist(dialouge_list),
                         is_question = unlist(question_bool),
                         word_count = unlist(wc),
                         text = lines)

head(question_df)
question_df$is_dialouge
#####################
# 4. finally answer the following:
# The Hemingway-Kafka index is a measure of how long an author's sentences are. 
# It is a simply the average number of words in a sentence from a given text.
	# For the purpose of today's exercise, lines of dialogue are counted as a single sentence.

# a. What is the HK-index for 'The Last Question'?


# 24 years after writing 'The Last Question', our boy Isaac wrote another short story
# titled 'The Last Answer' which is found in the following text file:

last_answer = readLines('asimov_the_last_answer.txt')

# b. Given the HK-index of the two texts, is there statistical evidence of Isaac Asimov 
# getting more long winded with age?




