#An introduction to social network analysis

#Different types of network data####

#Croft et al 2008 "Exploring Animal Social Networks" is a good basic introductory book

#install.packages('sna')

library(sna)


#Edge list

#Each line is the IDs of two individuals that interacted
el = cbind(c(1,1,2),c(2,3,3))

el.net=network(el,matrix.type="edgelist",directed=FALSE)

gplot(el.net, vertex.col="firebrick4")

#Group by indivdual matrix

#Each line is a group sighting, awith a 1 if that individual was seen in that group, or a 0 if not
gbi=matrix(c(1,1,0,1,0,1,0,1,1),3,3)

gbi.net=gbi%*%t(gbi) 
diag(gbi.net)=0

gplot(gbi.net, vertex.col="darkgoldenrod1")


#Association matrix

#n by n matrix of interactions/associations
am = matrix(c(0,1,0,0,0,1,1,0,0),3,3)
  
am.net=network(am,matrix.type="adjacency",directed=FALSE)

gplot(am.net, vertex.col="cornflowerblue")


#Based on "Comparing pre- and post-copulatory mate competition using social network analysis in wild crickets"
# -David N. Fisher, Rolando Rodríguez-Muñoz and Tom Tregenza, Behav. Ecol. 2016 doi: 10.1093/beheco/arv236

load("cricket_network_data.RData")

#Male fighting network 2006 - symmetrical
mfnetwork06 = network(mfnet06sym, directed=F, ignore.eval=FALSE, names.eval="weight")

#Male mating (sperm competition) network 2006 - symmetrical
mmnetwork06 = network(mmnet06sym, directed=F, ignore.eval=FALSE, names.eval="weight")


#Plotting networks####

gplot(mfnetwork06, gmode="graph")
gplot(mfnetwork06, gmode="graph", mode="circle")

#Want to incorporate traits of our individuals
summary(traits06)

#Add these as properties of the nodes (a.k.a vertices, hence the v)
mfnetwork06 %v% "aggression" <- traits06$aggression
mfnetwork06 %v% "mass" <- traits06$mass

mmnetwork06 %v% "aggression" <- traits06$aggression
mmnetwork06 %v% "mass" <- traits06$mass

#Plot fighting network with range of reds for aggression
palette(colorRampPalette(c("coral", "darkred"))(10))
#Node size is based on mass
#Edge thickness represents number of interactions
gplot(mfnetwork06, gmode="graph", vertex.cex= (mfnetwork06 %v% "mass")^2, vertex.col=mfnetwork06 %v% "aggression", vertex.border = "black",
                                    edge.col="darkgrey", edge.lwd=mfnetwork06 %e% "weight")

#Plot sperm competition with range of blues, still for aggression
palette(colorRampPalette(c("aliceblue", "darkblue"))(10))

gplot(mmnetwork06, gmode="graph", vertex.cex= (mfnetwork06 %v% "mass")^2, vertex.col=mfnetwork06 %v% "aggression",
                                    edge.col="darkgrey", edge.lwd=mfnetwork06 %e% "weight", vertex.border = "black")

#But its hard to compare these visually, as node locations change from plot to plot

#So manually set node coordinates. USe sum of two networks to give overall centrality, then use that to plot

#Create summmed network
allnetwork06<-network(mmnet06sym+mfnet06sym, directed =F, ignore.eval=F, names.eval="weight")
#Extract node coordinates from ut
pos.all<-network.layout.fruchtermanreingold(allnetwork06, layout.par=NULL )

#Plot with them using "coord="
palette(colorRampPalette(c("coral", "darkred"))(10))
gplot(mfnetwork06, gmode="graph", vertex.cex= (mfnetwork06 %v% "mass")^2, vertex.col=mfnetwork06 %v% "aggression",
      edge.col="darkgrey", edge.lwd=mfnetwork06 %e% "weight", vertex.border = "black", coord=pos.all)

palette(colorRampPalette(c("aliceblue", "darkblue"))(10))
gplot(mmnetwork06, gmode="graph", vertex.cex= (mfnetwork06 %v% "mass")^2, vertex.col=mfnetwork06 %v% "aggression",
      edge.col="darkgrey", edge.lwd=mfnetwork06 %e% "weight", vertex.border = "black", coord=pos.all)

#Correlating networks####
#for question 1: relationships between the intensity of pre- and post-copulatory competition within pairs of competing males

#Requires networks to be same size and in same order, already sorted this out

#Comapring networks of different sizes notoriously tricky, not defined how best to do it

library(vegan)
mantel(mfnet06sym, mmnet06sym)

sperm.pred06<- list(mmnet06sym, mtime06, mspace06)

sperm.model06<-netlm(mfnet06sym, sperm.pred06, intercept=T, mode="graph", nullhyp="qapspp")
summary(sperm.model06)

#Re-scale
s.mmnet06sym<- (mmnet06sym-mean(mmnet06sym))/sd(mmnet06sym)
s.mtime06 <- (mtime06 -mean(mtime06))/sd(mtime06)
s.mspace06 <- (mspace06 -mean(mspace06))/sd(mspace06)
s.sperm.pred06<- list(s.mmnet06sym,s.mtime06,s.mspace06)
 
s.sperm.model06<-netlm(mfnet06sym, s.sperm.pred06, intercept=T, mode="graph", nullhyp="qapspp")
summary(s.sperm.model06)

#In an Exponential Random Graph Model, accounting for bodymass and aggression
#Intro to ERGMs for animal behaviour research: www.sciencedirect.com/science/article/pii/S0003347217302543


require(ergm)
require(ergm.count)

ergm_fit_06<- ergm(mfnetwork06 ~   CMP + nonzero +
                     nodecov("mass")+ nodecov("aggression") + 
                     edgecov(s.mtime06) + edgecov(s.mspace06) + edgecov(s.mmnet06sym),
                   reference=~Poisson,response="weight")

summary(ergm_fit_06)

mcmc.diagnostics(ergm_fit_06)


#Calculating individual network metrics####
#For question 2: the correlation within-individuals in engagement in pre- and post-copulatory competition

#unweighted degree - WAT IS THIS?
#Huge diversity in network metrics
#Both at the level of the individual e.g. degree, betweenness
#And at the level of the network e.g. degree correlation, clustering coefficient

mmnet06.deg<-degree(mmnet06sym,  cmode="outdegree", ignore.eval=T) 
mfnet06.deg<-degree(mfnet06sym,  cmode="outdegree", ignore.eval=T)

plot(jitter(mmnet06.deg),jitter(mfnet06.deg), pch=16)

cor.test(mmnet06.deg,mfnet06.deg,method="spearman")

#weighted degree - WAT IS THIS?

mmnet06.wdeg<-degree(mmnet06sym,  cmode="outdegree",ignore.eval=F)
mfnet06.wdeg<-degree(mfnet06sym,  cmode="outdegree",ignore.eval=F)

plot(jitter(mmnet06.wdeg),jitter(mfnet06.wdeg), pch=16)

cor.test(mmnet06.wdeg, mfnet06.wdeg,method="spearman") 



#Network-level metrics & randomisations####
#For question 3: if promiscuous males mate with promiscuous females

gplot(mfmnet06, vertex.col = "black", edge.col = "black", arrowhead.cex = 0)

require(tnet)

mf06id.tm<-as.tnet(mfmnet06)
mf06id.f.tm<-as.tnet(cbind(mf06id.tm[,2],mf06id.tm[,1],mf06id.tm[,3]),type="weighted two-mode tnet") 
#create a two-mode network of mating, but with females as the focus this time

#create vector of the male side of each edge, with the degree of the male replacing his ID. Using female focused edgelist hence males are column 2 and the j nodes
mf06id.f.dj<-degree_tm(mf06id.tm,measure="degree")[,2][match(mf06id.f.tm[,2],degree_tm(mf06id.tm,measure="degree")[,1])]

#create vector of the female side of each edge, with the degree of the female replacing her ID. Using female focused edgelist hence females are column 1 and the i nodes
mf06id.f.di<-degree_tm(mf06id.f.tm,measure="degree")[,2][match(mf06id.f.tm[,1],degree_tm(mf06id.f.tm,measure="degree")[,1])]

(real.cor.mf06<-cor(mf06id.f.di,mf06id.f.dj,method="spearman"))


#Randomisations - rationale and process
#See: https://www.sciencedirect.com/science/article/pii/S0169534711001455 & https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/2041-210X.12121

#This takes a while to run, so run lines 188-224 NOW then we will chat

#Create "potentially interacted" network
matlso06<-matlo06 * matso06

gplot(matlso06, vertex.col = "black", edge.col = "black", arrowhead.cex = 0)
#Potential network is denser, so when we re-sample it, need to remove some edges
#This is key as many network statistics are influenced by network density

n.zeroes=length(matlso06[matlso06!=0]) - length(mfmnet06[mfmnet06!=0]) #this tells us how many zeroes
n.ones=length(mfmnet06[mfmnet06!=0]) #this tells us how many ones

n.mats06<-array(0,c(nrow(mfmnet06),ncol(mfmnet06),1000))

for (k in 1:1000) {
  
  for (i in 1:ncol(n.mats06)) {
    for (j in 1:nrow(n.mats06)) {
      if (matlso06[j,i]>0) { n.mats06[j,i,k]<-sample(c(rep(0,n.zeroes),rep(1,n.ones)),1)
      }
    }
  }
  
}


cors.mf06<-vector(mode="numeric",1000)
for (i in 1:1000){
  m06id.tm<-as.tnet(n.mats06[,,i])
  m06id.f.tm<-as.tnet(cbind(m06id.tm[,2],m06id.tm[,1])) 
  m06id.f.dj<-degree_tm(m06id.tm,measure="degree")[,2][match(m06id.f.tm[,2],degree_tm(m06id.tm,measure="degree")[,1])]
  m06id.f.di<-degree_tm(m06id.f.tm,measure="degree")[,2][match(m06id.f.tm[,1],degree_tm(m06id.f.tm,measure="degree")[,1])]
  cors.mf06[i]<-cor(m06id.f.di,m06id.f.dj,method="spearman")
}
cors.mf06



Dbig06 <- sum(cors.mf06 >= real.cor.mf06)
Dbig06 / length(cors.mf06) #permutation p value
#note this may not be exactly the same as quoted in the paper or each time the analysis is run
#This is because the random permutations will produce a slightly different result each time
#the overall conclusions should not be altered.


