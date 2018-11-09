

# for a recent tutorial at the university of guelph R users group, I was going through
# how to generate summary stats & tidy dataframes from messy data sources

# we were working with text data, and the exercise I designed called for us to process
# a series of sentences and answer 3 questions about each line:
# is the line dialouge (by presence of a quotation mark)
# is the line a question (by presence of a question mark) and 
# what is the word count of the line

# a common design pattern from other languages that I wanted to employ was to design 
# a function that would return the answers to all three of these questions at once
# in python this would look like so:

question, dialouge, word_count = line_stats(line)

# in this example the function 'line_stats' takes a single input ('line') and the 
# does the necessary work and returns 3 values. These three values are then assigned to
# the three variable names on the left side of the equals function.

# This is not a viable thing to do in R. As we can see below when I try to implement this
# design pattern, having multiple variable names on the left side of
# the statement is not permitted


ex1 = "The Voice said, \"This is no place as you understand place.\""

line_stats = function(line){
	# this doesn't work
	is_question = grepl("\\?", line)
	is_dialogue = grepl("\"" , line)
	word_count = length(strsplit(line, "\\s+")[[1]])

	return(is_question, is_dialogue, word_count)

}

question, dialogue, word_count = line_stats(ex1)


# with a slight modification to the return line from the 'line_stats' function we 
# designed above, we are however able to extract all three of the values computed by the function
# as a vector 

line_stats = function(line){
	# takes in a line and returns a vector with three fields
	is_question = grepl("\\?", line)
	is_dialogue = grepl("\"" , line)
	word_count = length(strsplit(line, "\\s+")[[1]])

	return(c(is_question, is_dialogue, word_count))

}

ex1_stats = line_stats(ex1)

ex1_stats

# this lets us have a function that computes several outputs in one go, but the result is 
# still not perfect. the output has the necessary data, but it is not well documented and
# it would not be very difficult to mix up which field in the output vector corresponds
# to which of the summary statistics we want. To make things even less obvious returning a vector
# leads to the boolean result being returned as 1 or 0 as opposed to TRUE and FALSE

# To improve the reuse, readability and saftey of the line_stats function, there is a pattern 
# we can employ to return three values, which each have a clear and unambigious name
# to do this we return a named list from the function


line_stats = function(line){
	# takes in a line and returns a labelled list with the following:
	# question T/F , dialogue T/F, wc int
	is_question = grepl("\\?", line)
	is_dialogue = grepl("\"" , line)
	word_count = length(strsplit(line, "\\s+")[[1]])

	return(list(question = is_question, dialogue = is_dialogue, wc = word_count))

}


ex1_stats = line_stats(ex1)

ex1_stats

ex1_stats$question
ex1_stats$dialogue
ex1_stats$wc

# with the named list being returned we get an output that is arguably more 
# organized than the original 3 variable return I had tried to implement.
# The function output is all assigned to a single variable, and then from this variable
# we can call the desired subcomponents using the familiar dollar sign syntax of R.
# This is concise, organized and lets use avoid having to separately implement a set of 2-3
# highly similar functions. Overall this is a design pattern that I will employ more often in future R code!
