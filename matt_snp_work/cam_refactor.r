##############################
## Code review script - candidate genes
##
## original by Matt Brachmann (PhDMattyB)
## refactor by Cam
##
## 2020-01-10
##
##############################


#this package is used to load and manipulate the relevant dataframes
#install.packages(tidyverse)
library(tidyverse)
#its the only package from the original list we actually need >:(

#alter this line to the directory on your computer containing the files to be analyzed
setwd("~/bin/UGRU/matt_snp_work")


###########
# functions for file loading and manipulation
##########

# this function takes a .gff or .gff3 file and creates a tibble
# arguments:
# filename -  the name of the gff file
# lead_skip - this argument specifies the
# chromosome - the chromosome to subset from the full gff, default is 'all' and no subset is performed.
read_gff = function(filename, lead_skip = 9, chromosome = "all"){
  #CAM - personally I would pass a vector of names to the read_tsv as opposed to renaming in the pipe (this could be an argument too).
  colnames = c("chr", "source", "feature", "start", "end", "score", "strand", "frame", "attribute" )
  #read in the raw file with readr
  gff = read_tsv(filename, col_names = colnames, skip = lead_skip) %>%
          filter(feature == 'gene') %>% 
            arrange(start, end) %>% 
              mutate(mid = start + (end-start)/2) ## arrange each gene by its start and end points on each chromosome
  #subset if user changed the chromosome argument
  if(chromosome != "all"){
    sub_gff = gff %>% filter(chr == chromosome)
    return(sub_gff)
  }
  #if the default chr arg was not changed, return full gff
  return(gff)
}

# this function takes a tab delimited file of outlier loci and creates a tibble
# arguments:
# filename -  the name of the gff file
# chromosome - the chromosome to subset from the full gff, default is 'all' and no subset is performed.
read_outlier = function(filename, chromosome = "all"){
  #read in the dataframe
  out_dat = read_tsv(filename) %>% 
              arrange(CHROME3) %>% 
                filter(CHROME3 != 'Contigs')
  #subset if user changed the chromosome argument
  if(chromosome != "all"){
    sub_out = out_dat %>% 
                filter(CHROME3 == chromosome) 
    return(sub_out)
  }
  #if the default chr arg was not changed, return full gff
  return(out_dat)
}


###############
# main analysis begins here:
###############

#I set important filenames etc. to variables, so they can be easily found, changed, and reused.
gff_filename = "ref_ASM291031v2_top_level.gff3"
ncbi_code_AC08 = "NC_036848.1"
outlier_data = "PCAdapt_lake_outliers.txt"
outlier_code_AC08 = "AC08"

########
# read in the data
# all the detail above is abstracted away into these two lines
AC08 = read_gff(gff_filename, chromosome = ncbi_code_AC08)
AC08_out = read_outlier(outlier_data, chromosome = outlier_code_AC08)

# obtain outlier positions
pos = AC08_out$PDIST.x

#obtain genes in those positions
gene_regions = AC08 %>% 
                mutate(hit_dist = abs(mid - pos)) %>% 
                  arrange(hit_dist) %>% 
                    filter(hit_dist <5000) %>%
                      select(chr, start, end, attribute, hit_dist) %>% 
                        pull(attribute)
