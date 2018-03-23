##########
#PCA
##########
library('vegan')
library('tidyverse')

islands = read.csv('island_metrics.csv', header=T)
row.names(islands) = islands$ISLAND

#Recall, we have 4 environmental variables (each with mean, max, min)
names(islands)
head(islands)

#And since we have means, mins, and maxs, let's separate these out
mean.isl = islands %>% select(Mean.Wave, Mean.SST,Mean.Chl,Mean.PAR)
max.isl = islands %>% select(Max.Wave,Max.SST,Max.Chl,Max.PAR)
min.isl = islands %>% select(Min.Wave,Min.SST,Min.Chl,Min.PAR)

#for practical purposes, let's just look at the means. 


#Let's (kind of!) roll!
pca.1=prcomp(mean.isl)
pca.1
summary(pca.1)

#rotation = eigenvectors; relationship of each variable to the PC, ie the 'weight' of how much the factor contributes to the PC. Notice that Wave's weight coefficient  is HUUUGELY larger than the other factors!
#Visualize it!
par(mfrow=c(1,1))
biplot(pca.1)
#as expected, Mean.Wave is stronger than other variables in grouping islands, given the strong negative eigenvector
#prop of variance explained by each PC. PC1=most of it. Confirmed with Screeplot. 
screeplot(pca.1)

#But hold up! We have forgotten to standardize our data! Recall that all of our variables have very different units! Let's normalize them. If we don't do this = meaningless!
#Also, recall the results with non-standardized data with Wave being (basically) the only thing that mattered. Why?
(max(Mean.Wave)-min(Mean.Wave));(max(Mean.SST)-min(Mean.SST));(max(Mean.Chl)-min(Mean.Chl));(max(Mean.PAR)-min(Mean.PAR))
#Becuase wave has a disproportionally large range compared to other factors! Then PAR, then SST, and Chl barely varies. This is mirrors the size of the eigenvectors!

#Now, let's do this the right way!
pca.2=prcomp(mean.isl,scale=TRUE,center=TRUE);pca.2;summary(pca.2) 
#what is the biplot likely to look like?
biplot(pca.2)
#Exactly what we'd expect! PC1 has Wave, SST having large weights, approx. equal and opposite (and since neither is important in PC2, we expect them to fall roughly around y=0). Then on PC2, PAR and Chl are most impt., both are negative, and affected a little bit by PC1 (in opposite ways.).
#And even though biplot only lets us plot 2 PCs, how many are important?
screeplot(pca.2)

#Also, is what we've been doing even valid? How is the (transformed) data distributed?
library(car)
norm.data.islands = apply(mean.isl,2,function(x) (x-mean(x))/sd(x))
scatterplotMatrix(norm.data.islands)
#What does a log transform do? (And we need to go back to original data, not standardized data.)
log.mean.isl=cbind.data.frame(log(Mean.Wave),log(Mean.SST),log(Mean.Chl),log(Mean.PAR))
log.norm.data.islands = apply(log.mean.isl,2,function(x) (x-mean(x))/sd(x))
scatterplotMatrix(log.norm.data.islands)
#So log transform doesn't really do anything. So let's just keep rolling with our untransformed data for simplicity's sake. 

#Let's play with vegan! We can (kind of) do these same tests.
#install.packages('vegan')
library(vegan)

pca.5=rda(mean.isl,scale=T,center=T,scaling=1);pca.5#;summary(pca.5)
#But...the eigenvalues are different than what they were for the prcomp function! Has to do with scaling. Go here: http://cran.r-project.org/web/packages/vegan/vignettes/decision-vegan.pdf
#Still, it's just scaling - same result. Proportions of variation, proportional loadings=same. 
biplot(pca.5)

#So, knowing that the scalings are different, what does this visually mean?
par(mfrow=c(1,2))
biplot(pca.2)
biplot(pca.5)
#yes, x&y axis have different scales, but same relationships etc.

#Fancy plot it!
par(mfrow=c(1,1))
name.isl=islands[,c(1,2)]
with(name.isl,levels(REGION))
scl=3
colvec=c(2,3,5,6,7)
plot(pca.5,type='n',scaling=scl,ylim=c(-2,.5),xlim=c(-2,2))
with(name.isl,points(pca.5,display='sites',type='p',col=colvec[REGION],scaling=scl,pch=21,bg=colvec[REGION]),ylim=c(-2,.5),xlim=c(-2,2))
par(new=T);biplot(pca.5,display='species',type='t',ylim=c(-2,.5),xlim=c(-2,2),scaling=scl,col='1',cex=.8)
with(pca.5,legend('bottomleft',legend=levels(REGION),bty='n',col=colvec,pch=21,pt.bg=colvec))
#ordihull(pca.6,REGION,col='blue',ylim=c(-2,.5),xlim=c(-2,2),scaling=scl)
with(name.isl,ordiellipse(pca.5,REGION,kind='se',conf=0.95,label=F,scaling=scl,ylim=c(-2,.5),xlim=c(-2,2),col='blue'))#ordiellipse =dispersion ellipse using sdevs
#with(name.isl,ordispider(pca.6,REGION,label=F,scaling=scl,ylim=c(-2,.5),xlim=c(-2,2),col='blue'))#links points to a ceteroid

########http://cc.oulu.fi/~jarioksa/opetus/metodi/vegantutor.pdf; http://cran.r-project.org/web/packages/\

######## try it with the mins/maxes



