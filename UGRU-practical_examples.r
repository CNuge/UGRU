
#example of 'one liners' where its safer to break the explicit syntax rules in the name of style
#turn a DNA sequence into a lower case vector
s2v = function(dna_string) tolower(strsplit(dna_string, "")[[1]]) 
#turn a vector of DNA sequence into a string
v2s = function(dna_vec) paste(dna_vec, collapse = "")

#get a random DNA nucleotide
#the argument with a default lets this be
#used in solving two problems!
random_bp = function(exclude_base = NULL){
  bps = c('a', 't', 'g', 'c')
  if(!is.null(exclude_base)){
    bps = bps[bps != exclude_base]
  }
  sample(bps, 1)
}


# a simplified version of a function to introduce errors into DNA sequences
#by using functions, I've been able to use the random_bp to accomplish to related
#but different tasks with minimal effort
error_introduce = function(dna_string, global_mutation_rate = 0.01, global_indel_rate = 0.01){

	org_vec = s2v(dna_string)
	new_seq = c() 

	for(i in 1:length(org_vec)){
		b = org_vec[[i]]
		prob = runif(1)
	    if(prob < global_mutation_rate){ 
    			#point mutation 
    			new_b = random_bp(exclude_base=b) 
    			new_seq = c(new_seq,new_b) 
	    } else if ((global_mutation_rate < prob) && (prob<(global_indel_rate+global_mutation_rate))){ 
          #indel 
          in_prob = runif(1) 
          if(in_prob<0.5){ 
            #insertion 
            #add the base 
            new_seq = c(new_seq, b) 
            #insert a base after 
            new_seq = c(new_seq, random_bp()) 
          }else{ 
            #deletion 
            #don't add anything so base is skipped
            #this 'else' statement could be omitted for brevity
          	next
          } 
	    }else{ 
    		  new_seq = c(new_seq, b) 
		} 
	}                    

	output = v2s(new_seq)
	return(output)
}



#reusing the 'building blocks' I've made to easily do something else
random_add = function(seq, side = 3 , max = 100){
  #side says where the addition is made
  #1 = front
  #2 = back
  #3 = both
  front_seq = c()
  back_seq = c()
  if(side == 1 || side == 3){
    for(i in 1:sample.int(max, 1)){
      front_seq = c(front_seq, random_bp())
    }
  }
  if(side == 2 || side == 3){
    for(i in 1:sample.int(max, 1)){
      back_seq = c(back_seq, random_bp())
    }
  }
  return(v2s(c(front_seq, seq, back_seq)))
}



dna_string = "ctctacttgatttttggtgcatgagcaggaatagttggaatagctttaagtttactaattcgcgctgaactaggtcaacccggatctcttttaggggatgatcagatttataatgtgatcgtaaccgcccatgcctttgtaataatcttttttatggttatacctgtaataattggtggctttggcaattgacttgttcctttaataattggtgcaccagatatagcattccctcgaataaataatataagtttctggcttcttcctccttcgttcttacttctcctggcctccgcaggagtagaagctggagcaggaaccggatgaactgtatatcctcctttagcaggtaatttagcacatgctggcccctctgttgatttagccatcttttcccttcatttggccggtatctcatcaattttagcctctattaattttattacaactattattaatataaaacccccaactatttctcaatatcaaacaccattatttgtttgatctattcttatcaccactgttcttctactccttgctctccctgttcttgcagccggaattacaatattattaacagaccgcaacctcaacactacattctttgaccccgcagggggaggggacccaattctctatcaacactta"
error_introduce(dna_string)

error_introduce("ctctacttgatttttggtgcatgagcaggaatagttggaatagctttaagt")






























#you can put those nice little pipes you make into a function to turn
#them into simple and reusable one liners!
library(tidyverse)
#this is matt's code from last week that uses mtcars to make a new col
mutate_df = function(df){
  df %>%
    mutate(NEW_COLUMN = mpg + cyl) %>%
    rename(new_column_new_you = NEW_COLUMN) %>%
    # rename can also be used to change the names of fixed positions
    arrange(hp) %>%
    dplyr::select(-new_column_new_you)
  
  return(df)
}

#all the detail is abstracted away to just this!
new_df = mutate_df(mtcars)



