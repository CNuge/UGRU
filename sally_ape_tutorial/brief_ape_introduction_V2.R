#### 1. INTRO----

#Purpose: This tutorial provides a BRIEF introduction (Karl said 20 minutes!) 
#to the package ape, which is one of the commonly-used R packages in ecology 
#(see Lai et al 2019. Ecosphere. 10(1): e02567). 
#ape is considered a foundational package for phylogenetics in R and 
#is useful for reading, writing, and manipulating phylogenetic trees as 
#well as various evolutionary analysis. There are many other packages 
#that use the same structure for phylogenies (phylo object). 
#By completing this brief tutorial, I hope that you will become convinced 
#that ape is a useful package, and we will aim to understand the phylo object. 
#At the bottom, there are links for further resources.

#Description by Emmanuel Paradis of ape package:
#https://www.rdocumentation.org/packages/ape/versions/5.2

#TIP on wrapping comments: To read the comments, be sure to wrap the 
#text using the following setting in RStudio:
#Tools -> Global Options -> Code -> click on "Soft-wrap R source files"

#TIP - Remember from last time that we can use four or more hyphens at 
#the end of a comment to treat it as a title. We can then fold that block.

#Background: Phylogenies are a representation of evolutionary relatedness. 
#Because species share their evolutionary history to varying extents, 
#treating species as completely independent can violate assumptions of 
#statistical tests when making cross-species comparisons 
#(e.g. see Felsenstein J. 1985. Phylogenies and the comparative method. 
#The American Naturalist. 125(1): 1-15). 
#As well, phylogenies are increasingly being incorporated into research 
#in community ecology, macroecology, and biogeography. 
#As an example, check out this interesting papers (editor's pick) 
#on community patterns of ants along an altitudinal gradient by Alex Smith 
#and colleagues: Smith et al 2014. Diversity and phylogenetic community 
#structure of ants along a Costa Rican elevational gradient. Ecography.37: 720-731.

#Manual: Note that the manual for the ape package is 286 pages long. 
#This is a brief introduction here! You can explore many other functions 
#and can access the full manual here: 
#https://cran.r-project.org/web/packages/ape/ape.pdf

#### 2. INSTALLING AND LOADING PACKAGES----

#If you don't already have ape, uncomment (i.e. delete the #) and run this 
#line to install the package; then, load the package using the library function.
#install.packages("ape")
library(ape)

#install.packages("tidyverse")
library(tidyverse)

#install.packages("phytools")
library(phytools)

#TIP when you are having trouble installing a package. 
#This morning when I tried to install phytools, I had trouble. 
#So, I changed CRAN mirror using the following function, and then all was fine.
#chooseCRANmirror()

#TIP: Remember you can use Ctrl-Enter to run lines of code in RStudio, 
#rather than hitting Run using the mouse.

#### 3. A PHYLOGENY OBJECT----

#Credit: Some of the below lines of codes are from the following vignette. 
#Also, I found that tutorial by Liam Revell helpful for understanding the 
#structure of the phylo object and for some tips on manipulating phylo objects.
#See: http://www.phytools.org/eqg/Exercise_3.2/

#We can use ape to generate a random phylogeny with 20 tips using the function rtree.
tree = rtree(n = 20)

#We can see the function's default arguments and options through the help:
?rtree()

#Plotting a visualization of the tree
plot(tree, edge.width = 2)

#Options for this function. R will use the plot.phylo() function 
# when we pass a phylo object to plot().
?plot.phylo()

#Example:
plot.phylo(tree, edge.width = 4)

#see some properties about our tree
tree

#See the structure of the phylo object
str(tree)
names(tree)

#We can look at elements of the phylo object, such as the edges (etc.), in the following way because ape has created a list of class phylo.
tree[[1]]
tree[[2]]
tree[[3]]

#Or:
tree$edge
tree$tip.label

#Looking at a simpler example. Here, we are specifying the topology of a simple tree with 5 tips:
tree = read.tree(text = "(((A,B),(C,D)),E);")
#note the semi colon in the above is to tell it the topology is complete
tree

#Plotting the tree and showing the node labels and tip labels.
plot(tree, edge.width = 2, label.offset = 0.1, type = "cladogram")
nodelabels()
tiplabels()

#Now let's look at the structure

#The first element of our phylo object is a matrix that specifies the edges. Edges are between two nodes.
tree[[1]]

#The second element of our phylo object tells us the number of internal nodes. Remember back to Karl's tutorial regarding the difference between [] and [[]] when looking at list elements.
tree[2]
tree[[2]]

#Tip names
tree[[3]]

#The online tutorial (http://www.phytools.org/eqg/Exercise_3.2/) 
#also describes how to do manipulations such as:
#a) dropping tips
#b) checking whether a tree is bifurcating
#c) randomly resolving multifurcations
#d) rotating or re-rooting the tree
#e) working with sets of trees (e.g. a set generated through Bayesian analysis)
#These tools are very helpful for preparing a phylogeny for downstream analysis.

#For now, let's move on to look at some further types of phylogeny plots...

#### 4. PHYLOGENY VISUALIZATIONS----

#from a further online tutorial by Liam Revell
#http://www.phytools.org/Cordoba2017/ex/2/Intro-to-phylogenies.html

text.string = 
  "(((((((cow, pig),whale),(bat,(lemur,human))),(robin,iguana)),coelacanth),gold_fish),shark);"

vert.tree = read.tree(text = text.string)

plot(vert.tree,no.margin=TRUE,edge.width=2)

#This function is from phytools package to build a rounded tree.
roundPhylogram(vert.tree)

#Plotting an axial format tree
plot(unroot(vert.tree), type="unrooted", no.margin=TRUE, lab4ut="axial", edge.width=2)

#Plot a fan format tree.
plotTree(vert.tree, type="fan", fsize=0.7, lwd=1, ftype="i")

#Add arrows. Here, we will point an arrow to the aquatic taxa.
add.arrow(vert.tree, tip = c(3, 9, 10, 11), arrl = 0.5)

#### 5. CHALLENGE----

#Specify a phylogenetic tree that shows the relationship among: 
#, , , , ,  , , 







camlogeny = 
  "
  (((Fly, Daphnia)), (Horseshoe_crab, (((Salmon, Coelacanth),Shark) , (((Bird, Lizard), Crocodile ), (Cow,(Mouse,Bat) )))));
  "


cam_tree = read.tree(text = camlogeny)

plot(cam_tree,no.margin=TRUE,edge.width=2)

plotTree(cam_tree, type="fan", fsize=0.7, lwd=1, ftype="i")


#Visualize your tree.

#Check out this tutorial on ancestral state reconstruction:
#http://www.phytools.org/eqg2015/asr.html

#Specify which organisms have flight capability.

#Show the history of the evolution of flight mapped onto the tree.

#### 6. FURTHER RESOURCES FOR PHYLOGENETICS IN R----

#Overview of helpful packages through CRAN task view by Brian O'Meara:
#https://cran.r-project.org/web/views/Phylogenetics.html

#picante is a package particularly of relevance for community ecologists. 
#You can use that package to test whether a given community consists of species 
#that are more closely related or more distantly related than expected by chance.

#phytools has functionality for reconstructing ancestral character states
#http://www.phytools.org/eqg2015/asr.html

#ggtree is a particularly helpful package for visualization of phylogenies. 
#It builds upon the ggplot2 system. See the vignette and some 
#cool visualizations by Guangchuang Yu and Tommy Tsan-Yuk Lam:
#http://www.bioconductor.org/packages/3.1/bioc/vignettes/ggtree/inst/doc/ggtree.html

#Check out the Bioconductor repository for ~1500 packages related to bioinformatics

#Can we build phylogenies in R? Yes! If there is interest, I am happy to provide 
#a brief overview of DNA sequence handling and phylogeny building in R.

