library('tidyverse')

multivac = 'asimov_the_last_question.txt'
# this is a file with the text from a short story by Isaac Asimov:
# 'The last question'


csv_try = read_csv(multivac)
#it gets confused because we told it to read a csv, but there are just random
#commas interspersed throughout the lines...


lines = read_lines(multivac)

summary(lines)

lines[1:2]

lines[length(lines)-2] #last line a bit of a spoiler so lets check the penultimate


#Questions to answer:

# 1. how many lines of dialogue are there?:
# hint: look at lines 27, 29, 36, 90
# efficiency hint: can you write a generic function to answer this and question 2?

# 2. a. what is the first question in the text? 

# b. what is the last question?


# 3. build a dataframe with the following columns (and data types)

#Line	is_dialogue	is_question	word_count	text
#int	Bool		Bool		int			string



# 4. finally answer the following:
# The Hemingway-Kafka index is a measure of how long an author's sentences are. 
# It is a simply the average number of words in a sentence from a given text.
	# For the purpose of today's exercise, lines of dialogue are counted as a single sentence.

# a. What is the HK-index for 'The Last Question'?


# 24 years after writing 'The Last Question', our boy Isaac wrote another short story
# titled 'The Last Answer' which is found in the following text file:

last_answer = read_lines('asimov_the_last_answer.txt')

# b. Given the HK-index of the two texts, is there statistical evidence of Isaac Asimov getting more long winded with age?




