# DATATABLE TUTORIAL! #

# The data.table package was designed by Matt Dowle in 2008. 
#You can think of it as an "advanced" version of dataframe. 
#It is compatible with all base R packages!

# Why data.table?: To decrease programming time (simpler syntax) & computation time, 
# works well with large datasets, fast subsetting, grouping, merging, 
# & it uses a key to sort the data and increase search efficiency

# Similar to SQL: DT[i, j, by]
# i = where (row condition), j = select (column condition), by = group by (how you want to group your data)

###### SECTION 1. LOAD PACKAGES #####
#install.packages("data.table")
library(data.table)
#install.packages("tidyverse")
library(tidyverse)

#### SECTION 2. Subsetting by row (i). ####

# First, create a dataframe.
df <- data.frame(ID = 1:100, Value = rnorm(100), Province = c("Ontario", "BC", "Quebec", "Newfoundland", "Manitoba"))
# Now, convert it to datatable.
dt <- as.data.table(df)

# What's the difference?
head(df)
head(dt)  ## Datatable prints the row numbers with a colon.

# Datatables are accepted by all base R packages.
class(df)
class(dt)

# Remember dt[i, j, by]!
# Selecting rows by number in i.
dt[15:25, ]
dt[15:25]  ## You don't need the comma.

df[15:25, ]
df[15:25]  ## What happens?

# Let's try subsetting rows (i) according to a certain condition. 
# For example, subset only those rows with IDs greater than (>) 50. Notice that you don't have to specify dt$ID. The column names are taken as variables when using the datatable syntax (similar to tidyverse).
dt[ID > 50]
# A datatable is returned.
dt50 <- dt[ID > 50]
head(dt50)
# You can set more than 1 condition.
dt[Province == "Ontario" & ID > 50]  ## Notice that you don't need a comma!
# Another way to subset:
head(dt[Province %in% c("Ontario", "BC")])

# What if we wanted to sort the datatable?
dtOrder <- dt[order(Province, -Value)]  ## Sorted by Province first, and then by descending Value.
View(dtOrder)

rm(dt50, dtOrder)

#### SECTION 3. Subsetting by column (j). ####

# Let's do something by column (j). You can return a column as a vector:
values <- dt[, Value] 
class(values)
head(values)

# What if you want it returned as a datatable?
dtValue <- dt[, list(Value)]  ## Wrap the columns with list().
class(dtValue)
head(dtValue)
# OR!
dtValue2 <- dt[, .(Value)]  ## Use the alias "." in place of "list". 
head(dtValue2)
# Select two columns.
dtValue3 <- dt[, .(ID, Value)]
head(dtValue3)
# Rename the columns as you are selecting them.
dtValue4 <- dt[, .(Col1 = ID, Col2 = Value)]
head(dtValue4)

# Let's call a function using j.
# Remember that placing the comma first indicates that you want the mean Value of ALL of the rows (i.e. you didn't specify a particular subset of rows).
dt[, mean(Value)]
# Call a function on more than one column.
dt[, .(Average = mean(Value), Length = length(ID))]
# What if you only want the mean of certain rows (e.g. rows with IDs greater than 50)?
dt[ID > 50, mean(Value)]  ## Subset in i, and do in j.
dt[ID < 50, mean(Value)]
# This doesn't work when only using a dataframe!:
df[, mean(Value)]

# There are a few "special symbols" in the datatable package. For example: ".N". ".N is a special built-in variable that holds the number of observations in the current group."
# Simply:
dt[, .N]  ## Number of rows in dt
# If we wanted to count the number of Ontario observations:
dt[Province == "Ontario", .N]

rm(df, dtValue, dtValue2, dtValue3, dtValue4, values)

#### SECTION 4. Using by for grouping. ####

# Now, let's do some grouping (by). What is the mean of Value, grouped by province?
dt[, mean(Value), by = Province]  ## Woah!

# What is the mean of Value, grouped by province, for those rows with IDs greater than 50? (Using all three)!
dt[ID > 50, mean(Value), by = Province]


# How many observations for each province?
dt[, .N, by = Province]

# Adding/updating columns by reference #
# Let's add another column called "Rank" to the datatable. You can use := to create or update columns.
# Note: you do not have to assign (<-) the result to dt when creating or updating columns using :=
dt[, Rank := sample(LETTERS[1:4], 100, rep = T)]
head(dt)
# You can also use := to UPDATE columns by reference.
dt[, Rank := sample(LETTERS[1:4], 100, rep = T)][] ## Adding [] prints result.

# Grouping by multiple columns!
dt[, .N, by = .(Province, Rank)]  ## Note that it retains the original order of the datatable.

# Using keyby.
# You can use "keyby" instead of "by" to sort by the variables that you group by (always in increasing order). For example:
dfKeyed <- dt[, .N, keyby = .(Province, Rank)]
head(dfKeyed) ## Number of observations by Rank within each Province (sorted!).

# You can set a key on multiple columns and duplicate key values are allowed. Keys can be thought of as "supercharged" rownames. They may be of the integer, factor, numeric, or character type. Using a key greatly increases search efficiency by using binary search algorithm! 
key(dfKeyed)
setkey(dfKeyed, Province) ## Change the key by using setkey.
key(dfKeyed)

# Now that Province is the key, instead of:
dfKeyed[Province == "Ontario"]
# You can simply run:
dfKeyed["Ontario"]  ## Simpler syntax. And when dealing with larger datasets, it's much faster...

# Vector scan:
N <- 2e7L
dt3 <- data.table(x = sample(letters, N, TRUE), y = sample(1000L, N, TRUE), val = runif(N))
system.time(dt3[x == "a"])
# The column 'x' is searched for the value 'a' row by row.

# Binary search approach:
setkey(dt3, x)
key(dt3)
system.time(dt3["a"])
# Since the data is sorted, do not have to search row by row...
# search is O(log(n)) as opposed to O(n)

# Yes...it's even faster than tidyverse!
system.time(dt3 %>% 
              group_by(x) %>% 
              filter(y > 500) %>% 
              summarise(sum(val), mean(y)))
              
system.time(dt3[y > 500, .(sum(val), mean(y)), by = x])

rm(dfKeyed, dt3, N)

#### SECTION 5. Chaining. ####

# Datatable's way of avoiding creation of intermediate variables (akin to piping in tidyverse).
dtChain <- dt[, .N, keyby = .(Province, Rank)]
head(dtChain, 10)

# What if we only wanted groups with more than 3 observations? We could create a new datatable, and subset using i.
dtChainSorted <- dtChain[N > 3]
head(dtChainSorted, 10)

# OR! We could do it all in one step by chaining commands together! dtChainSorted doesn't need to be created now.
dtChain <- dt[, .N, keyby = .(Province, Rank)][N > 3]
head(dtChain)
head(dtChainSorted) ## They are the same.

# Note: .SD is a special symbol in the datatable package. It means "subset of data". For example, what if you wanted the calculate the mean for MULTIPLE columns?
# Let's make a new datatable.
dt2 <- data.table(replicate(5, sample(1:5, 20, rep = T)))
head(dt2)
# Add a Rank column.
dt2[, Rank := sample(LETTERS[1:5], 20, rep = T)]
head(dt2)

# .SD contains all of the columns EXCEPT the variable you are grouping by. You can only specify .SD in j. For example:
dt2[, lapply(.SD, mean), by = Rank]  ## These columns contain the mean values, grouped by the 5 Ranks.

# Using .SDcols. What if you just want to calculate the mean on a few columns (not ALL of them)?
dt2[, lapply(.SD, mean), by = Rank, .SDcols = c("V2", "V4")]

rm(dt2, dtChain, dtChainSorted)

#### SECTION 6. Convenience functions. ####

# The datatable package also offers some convenience functions. For example...
?like
# like is a convenience function for calling regexpr.

# Let's try it out!
head(dt[Province %like% "ario"])
head(dt[Province %like% "[BQ]"])
head(dt[Province %like% "Ma"])

?between
# between is a convenience function for range subsets.
head(dt[Value %between% c(0, 1)])


# Also useful is the setnames funtion to rename columns by reference.
setnames(dt, "Value", "Karl")
head(dt)

#### SECTION 7. Sequence quality control using data.table. ####

# Reading and writing using data.table's fwrite and fread functions. These are VERY fast!
?fwrite

dtSalmon <- fread("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Salmonidae&geo=Canada&format=tsv")[, c("recordID", "bin_uri", "species_name", "markercode", "lat", "nucleotides")]
dtSalmon

class(dtSalmon)

# Let's try using datatable syntax on sequence data.

### FILTER 1 ###
# Filters are used for quality control purposes.
dtSalmon[dtSalmon == ""] <- NA  ## Replace all blanks with NA
# Filtering for presence of a BIN URI, a form of BIN identification.
sum(is.na(dtSalmon$bin_uri))
# Using the %like% convenience function.
dtSalmon <- dtSalmon[bin_uri %like% "[:]"]
sum(is.na(dtSalmon$bin_uri))  ## No more NAs!
# Remove "BOLD:" from the BIN URIs. We are updating the bin_uri column using :=
head(dtSalmon$bin_uri)
dtSalmon[, bin_uri := substr(bin_uri, 6, 13)]
head(dtSalmon$bin_uri)

### FILTER 2 ###
# Filtering for presence of a sequence.
dtSalmon <- dtSalmon[nucleotides %like% "[ACTG]"]

### INITIAL BIN SIZE ###
# Determine how many sequences are in a BIN in total prior to any sequence filtering (i.e. # of original raw sequences). Here, we are creating a new column called "initial_bin_size", and counting the number of recordIDs, grouping by BIN.
dtSalmon[, initial_bin_size := length(recordID), keyby = bin_uri]  ### Notice the values are recycled.
View(dtSalmon)

### FILTER 3 ###
# Set the key.
setkey(dtSalmon, markercode)
# Filtering for COI-5P as these are the only markers we are looking at.
unique(dtSalmon$markercode)
dtSalmon <- dtSalmon["COI-5P"]
unique(dtSalmon$markercode)

### FILTER 4 ###
# Remove sequences with N/gap content above a certain threshold (1%).
# Determine the number of positions where an N or gap is found for each sequence.
dtSalmon[, gapN := str_count(nucleotides, c("[N-]"))]
View(dtSalmon)
# Remove sequence if the number of Ns or gaps is greater than 1% (0.01) of the total length of the sequence.
dtSalmon <- dtSalmon[, percentage_gapN := gapN/nchar(nucleotides)][!percentage_gapN > 0.01]  ## Example of chaining!
View(dtSalmon)  ## Sort by percentage_gapN
# Remove these columns as they are no longer needed.
dtSalmon[, c("gapN", "percentage_gapN") := NULL]
# Alternatively:
#removeThese <- c("gapN", "percentage_gapN")
#dtSalmon[, (removeThese) := NULL]

### FILTER 5 ###
# Filter out sequences (when gaps are not included) that are less than 640 bp and greater than 1000 bp. 
dtSalmon <- dtSalmon[nchar(gsub("-", "", nucleotides)) %between% c(640, 1000)]

### FILTER 6 ###
# Remove rows with no species information. This will remove BINs without any species information.
dtSalmon <- dtSalmon[species_name %like% "[A-Z]"]

### FILTER 7 ###
# Suppose we only want Salmon species that reside north of the equator.
dtSalmonNorth <- dtSalmon[lat > 0]
# What's the median latitude for each BIN?
head(dtSalmonNorth[, .(lat = median(lat)), by = bin_uri])
                                     
             
multiply_these =  function(x, y){
	x*y
}                        

#merging
#Merge Two Data.Tables
#Fast merge of two data.tables. The data.table method behaves very similarly to that of data.frames except that, by default, it attempts to merge

prov_type


dt[,'Province']
dt[6]

x = dt[, unique(Province)]
where = data.table(Province = x)
where = data.table(unique(dt[,'Province']))

where[,'Region'] = list("mid", "west", "east", "east", "mid")
where[,'Region' := list("mid", "west", "east", "east", "mid")]


df['Province']
df[6,]


dt2 = merge(dt, where, by="Province")
dt2








