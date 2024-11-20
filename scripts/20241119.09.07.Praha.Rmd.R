############ commands to be used in R on your computer
##! be careful to adapt the commands with your paths !

## version 2024 11 10 at 20.00
## lucie.bittner@gmail.com

# commands used with R version 4.1.1 (2021-08-10) -- "Kick Things"



# download the libraries
library("vegan")
library("readxl")
library("dplyr")
library("FactoMineR")
library("factoextra")
library("ggplot2")
library("tidyverse")
library("bestNormalize")
library("psych")
library("rstatix")
library("corrplot")
library("readr")
library("devtools")
# install_github("kassambara/factoextra")

# if warning message > library not installed
## install.packages("vegan")
## library("vegan")

# General seting
options(stringsAsFactors = F)
set.seed(0)

# Cleaning
rm(list=ls())
graphics.off()



# 1 # load the metadata (data associated to the samples)
env <- read_excel("./Documents/enseignements/Alliance4EU_Protists/Praha/R_analyses/MetaData Samples MICROEUK.xlsx")
dim(env)
head(env)
names(env)
str(env)

# PCA on environmental data
# the goal is to explore the data and find environmental gradients
env1 <- unique(subset(env, select=c("St Number", "Exact Depth sampled (m)", "T090C", "Sal00", "O2 (µmol/kg)", "Fluo")))
# remove lines with NA
env2 <- na.omit(env1)
summary(env2)

var.names.env2 <- paste("st", env2$`St Number`, "_D", env2$`Exact Depth sampled (m)`, sep="")
env3 <- as.data.frame(env2)
# class(env3)
rownames(env3) <- var.names.env2
colnames(env3) <- c("St Number", "Depth", "Temperature", "Salinity", "Oxygen", "Fluo")
env3  

## explore variables
plot(env3$Depth, env3$Temperature, xlab="depth", ylab="temperature")
# distinguish st4 and st15
env3.st4 <- env3[env3$`St Number`=="4",]
env3.st15 <- env3[env3$`St Number`=="15",]
summary(env3.st4[,2:6])
summary(env3.st15[,2:6])

# plot st15
plot(env3.st15$Depth, env3.st15$Temperature, xlab="depth", ylab="temperature", col = "blue", pch=19, lwd=1, )
#overlay st4
points(env3.st4$Depth, env3.st4$Temperature, col="green", lty = 1, pch=19, lwd=1)

# same with lines plot st15
plot(env3.st15$Depth, env3.st15$Temperature, xlab="depth", ylab="temperature", type= "l", col = "green", pch=19, lwd=1)
#overlay st4
lines(env3.st4$Depth, env3.st4$Temperature, col="blue", lty = 1, pch=19, lwd=1)
legend("topright", legend = c("st4","st15") , col = c('blue', 'green') , bty = "n", pch=20 , pt.cex = 1, cex = 1, horiz = FALSE, inset=c(0.03,0.03))
points(env3.st15$Depth, env3.st15$Temperature, col="green", lty = 1, pch=1, lwd=1)
points(env3.st4$Depth, env3.st4$Temperature, col="blue", lty = 1, pch=4, lwd=1)



# calculate correlations between env variables (method = "pearson" (default), "kendall", or "spearman": can be abbreviated.)
mcor <- cor(env3[,2:6])
symnum(mcor)
# coefficients between 0 and 0.3 correspond to a space " "
# coeff between 0.3 and 0.6 correspond to a "." 
# coeff between 0.6 and 0.8 correspond to a "," 
# coeff between 0.8 and 0.9 correspond to a "+" 
# coeff between 0.9 and 0.95 correspond to a "*" 

cor.env <- corr.test(env3[,2:6])


cor.mat <- env3[,2:6] %>% cor_mat()
cor.mat
# Significance levels
cor.mat %>% cor_get_pval()
cor.mat %>% cor_gather()
cor.mat %>% cor_gather() %>% print(n=25)

# Visualize # Insignificant correlations are marked by crosses
cor.mat %>%
  cor_reorder() %>%
  pull_upper_triangle() %>%
  cor_plot(label = TRUE)


# pairs.panels(env3[,2:6])
# corrplot(mcor, type="upper", order="hclust", tl.col="black", tl.srt=45)

#calculate principal components
res.pca = PCA(env3[,2:6], scale.unit=TRUE, ncp=5, graph=T)
#env3[,2:6]: the data set used
#scale.unit: to choose whether to scale the data or not
#ncp: number of dimensions kept in the result
#graph: to choose whether to plot the graphs or not 

plot.PCA(res.pca, axes=c(1, 2), choix="ind", habillage=2)
#res.pca: the result of a PCA
#axes: the axes to plot
#choix: the graph to plot ("ind" for the individuals, "var" for the variables)
#habillage: to choose the colours of the individuals: no colour ("none"), a colour for each individual ("ind") or to colour the individuals according to a categorical variable (give the number of the qualitative variable)
plot.PCA(res.pca, axes=c(1, 2), choix="ind", habillage=1)
plot.PCA(res.pca, axes=c(1, 2), choix="ind", habillage=3)
plot.PCA(res.pca, axes=c(1, 2), choix="ind", habillage=4)
plot.PCA(res.pca, axes=c(1, 2), choix="ind", habillage=5)

plot.PCA(res.pca, axes=c(1, 2), choix="var")
dimdesc(res.pca, axes=c(1,2))

eigenvalues <- res.pca$eig
head(eigenvalues)
barplot(eigenvalues[, 2], names.arg=1:nrow(eigenvalues), 
        main = "Variances",
        xlab = "Principal Components",
        ylab = "Percentage of variances",
        col ="steelblue")
# Add connected line segments to the plot
lines(x = 1:nrow(eigenvalues), eigenvalues[, 2], 
      type="b", pch=19, col = "red")


hc <- hclust(dist(res.pca$ind$coord[,1:2], diag = T), method = "ward.D2")


inertie <- sort(hc$height, decreasing = TRUE)
plot(inertie[1:20], type = "s", xlab = "Nombre de classes", ylab = "Inertie")
points(c(2, 3, 4, 5, 6), inertie[c(2, 3, 4, 5, 6)], 
       col = c("green3", "red3", "yellow", "blue3", "orange"), cex = 2, lwd = 3)
bind_rows(cutree(hc, 2),
          cutree(hc, 3),
          cutree(hc, 4),
          cutree(hc, 5), 
          cutree(hc, 6)) %>% 
  t() %>% 
  as.data.frame() %>% 
  `names<-`(c("clus2", "clus3", "clus4", "clus5", "clus6")) %>% 
  mutate(station = row.names(.)) -> env_cluster
env_cluster


res1.pca <- prcomp(env3[,2:6], scale = TRUE)
#display principal components
res1.pca$rotation
biplot(res1.pca, scale = 0)
biplot(res1.pca, scale = 1)



#### 
# 2 cluster env = 
# clus 1 = st4_D52, st4_D5, st15_D65, st15_D5
# clus 2 = the others ... 




########### Biological data ##############@@#

old.par <- par(mar = c(0, 0, 0, 0))
par(old.par)

# load your metabarcoding data for illumina
#OTU.tab <- read_excel("./Downloads/v4_otu_table.xlsx")
#OTU.tax <- read_excel("./Downloads/v4_taxonomy_table.xlsx")
OTU.tab.ill <- read_tsv("./Downloads/feature-table.tsv")
OTU.tax.ill <- read_tsv("./Downloads/taxonomy_table.tsv")


# check the dimension of your tables, and explore them
dim(OTU.tab.ill)
dim(OTU.tax.ill)

head(OTU.tab.ill)
OTU.tab.ill[1:4,1:6]
names(OTU.tab.ill)


# statistics on the ASV
summary(apply(OTU.tab.ill[,2:25], 1, sum))
hist(apply(OTU.tab.ill[,2:13], 1, sum), 100)

# statistics on the samples
summary(apply(OTU.tab.ill[,2:25], 2, sum))
apply(OTU.tab.ill[,2:25], 2, sum)
barplot(sort(apply(OTU.tab.ill[,2:25], 2, sum)), horiz=TRUE, las=1)


head(OTU.tax.ill)
# A tibble, or tbl_df, is a modern reimagining of the data.frame
OTU.tax.ill[1:4,1:6]
summary(as.numeric(OTU.tax.ill$Pident))
table(OTU.tax.ill$Supergroup)
table(OTU.tax.ill$Subdivision)
# number of species
length(unique(OTU.tax.ill$Species))
head(table(OTU.tax.ill$Species))

summary(OTU.tax.ill$Length)
# to extract lines with a NA
OTU.tax.ill[is.na(OTU.tax.ill$Length), ] 


####### merge OTU tab and tax
OTU.tab.tax.ill <- merge(OTU.tab.ill, OTU.tax.ill, by="ASV", all=TRUE)   # by means by rownames
dim(OTU.tab.tax.ill)
OTU.tab.tax.ill[1:4,1:4]
str(OTU.tab.tax.ill)

## check how many ASVs correspond to taxonomical unknowns
OTU.tab.tax.ill[is.na(OTU.tab.tax.ill$Pident), c(1, 25:39) ]
nrow(OTU.tab.tax.ill[is.na(OTU.tab.tax.ill$Pident), c(1, 25:39) ])
# [1] 106
dim(OTU.tab.ill)
dim(OTU.tax.ill)
# nrow(OTU.tax.ill) + 106
# 5827
# ok, = nrow(OTU.tab.ill)

# which proportion of sequences do the unknownws correspond to in the samples?
OTU.tab.tax.ill.unknowns <- OTU.tab.tax.ill[is.na(OTU.tab.tax.ill$Pident), c(2:25) ]
as.matrix(sort(apply(OTU.tab.tax.ill.unknowns, 2, sum) / apply(OTU.tab.tax.ill[, c(2:25)], 2, sum) * 100))


## Diversity counts
# they can be done at different taxonomical ranks
# ASV level # col 1
# Division level  # OTU.tab.tax$Division
# species level OTU.tab.tax# $Species


# create abundance table for ASV
Atab.ASV.ill <- OTU.tab.tax.ill[,c(1,grep("_D*", names(OTU.tab.tax.ill)))]
dim(Atab.ASV.ill)
# create abundance table for Division
Atab.Division.ill <- aggregate(OTU.tab.tax.ill[,c(2:25)], by=list(Division=OTU.tab.tax.ill$Division), FUN=sum)
dim(Atab.Division.ill)
# 28 25

## barplot (cumulative abundance) for Division
par(cex.axis=0.5)
par(mar=c(7,4,4,7))
barplot(as.matrix(Atab.Division.ill[,c(2:25)]),
        las=2, 
        col=rainbow(nrow(Atab.Division.ill)),
        main = "Abundance at the Division level - Illumina",
        legend.text = Atab.Division.ill$Division,
        args.legend = list(x = "topright", inset = c(- 0.3, 0), cex=0.5))
grid()

# normalize abundance table for Division
Atab.Division.ill.n <- prop.table(as.matrix(Atab.Division.ill[,c(2:25)]),2)
rownames(Atab.Division.ill.n) <- Atab.Division.ill$Division
# barplot again
barplot(Atab.Division.ill.n,
        las=2, 
        col=rainbow(nrow(Atab.Division.ill.n)),
        main = "Proportional abundance at the Division level - Illumina",
        legend.text = rownames(Atab.Division.ill.n),
        args.legend = list(x = "topright", inset = c(- 0.3, 0), cex=0.5))
grid()



### zoom on a specific group > Rhizaria Division
OTU.tab.tax.ill.Rhizaria <- OTU.tab.tax.ill[ OTU.tab.tax.ill$Division == "Rhizaria" , ]
# remove lines with NA
OTU.tab.tax.ill.Rhizaria <- OTU.tab.tax.ill.Rhizaria[complete.cases(OTU.tab.tax.ill.Rhizaria), ]
dim(OTU.tab.tax.ill.Rhizaria)
# select the Classes
Atab.Class.Rhizaria.ill <- aggregate(OTU.tab.tax.ill.Rhizaria[,c(2:25)], by=list(Class=OTU.tab.tax.ill.Rhizaria$Class), FUN=sum)
dim(Atab.Class.Rhizaria.ill)
# normalize by total number of sequences in each sample
Atab.Class.Rhizaria.ill.n <- sweep(Atab.Class.Rhizaria.ill[,c(2:25)], 2, colSums(Atab.Division.ill[,c(2:25)]), FUN = '/')
Atab.Class.Rhizaria.ill.n <- prop.table(as.matrix(Atab.Class.Rhizaria.ill.n), 2)
rownames(Atab.Class.Rhizaria.ill.n) <- Atab.Class.Rhizaria.ill$Class
# barplot again
barplot(as.matrix(Atab.Class.Rhizaria.ill.n),
        las=2, 
        col=rainbow(nrow(Atab.Class.Rhizaria.ill.n)),
        main = "Proportional abundance at the Class level for Rhizaria - Illumina",
        legend.text = rownames(Atab.Class.Rhizaria.ill.n),
        args.legend = list(x = "topright", inset = c(- 0.3, 0), cex=0.5))
grid()







## calculate abundance of sequences and richness of ASV for each sample
barplot(colSums(OTU.tab.tax.ill[,c(2:25)]), las=2, main = "Number of Sequences - Illumina")
barplot(colSums(OTU.tab.tax.ill[,c(2:25)] != 0), las=2, main = "Number of ASVs - Illumina")
barplot(diversity(t(OTU.tab.tax.ill[,c(2:25)])), las = 2, main = "Shannon on ASVs - Illumina")
barplot(diversity(t(OTU.tab.tax.ill[,c(2:25)]), "simpson"), las = 2, main = "Simpson on ASVs - Illumina")


## correlation between ASV and sequences abundance, Plotting a 95% confidence interval for a lm object
plot(colSums(OTU.tab.tax.ill[,c(2:25)]), colSums(OTU.tab.tax.ill[,c(2:25)] != 0), pch = 16, xlab = "Nb sequences", ylab= "Nb ASVs")
x <- colSums(OTU.tab.tax.ill[,c(2:25)])
y <- colSums(OTU.tab.tax.ill[,c(2:25)] != 0)
lm.out <- lm(y ~ x)
newx = seq(min(x),max(x),by = 0.05)
conf_interval <- predict(lm.out, newdata=data.frame(x=newx), interval="confidence", level = 0.95)
plot(x, y, xlab="Nb sequences", ylab="Nb ASVs", main="Regression", las = 1)
abline(lm.out, col="lightblue")
matlines(newx, conf_interval[,2:3], col = "blue", lty=2)
summary(lm.out)
# Call:
#   lm(formula = y ~ x)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max
# -335.01 -127.63  -21.19  140.22  256.29
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)
# (Intercept) 2.104e+02  1.638e+02   1.284    0.212
# x           7.111e-03  3.044e-03   2.336    0.029 *
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 179 on 22 degrees of freedom
# Multiple R-squared:  0.1987,	Adjusted R-squared:  0.1623
# F-statistic: 5.457 on 1 and 22 DF,  p-value: 0.02901

# Since this p-value is less than .05, the model as a whole is statistically significant.
# Multiple R-squared = .1987. This tells us that 19.87% of the variation in the response variable, y, can be explained by the predictor variable, x.
# Coefficient estimate of x: 7.111e-03. This tells us that each additional one unit increase in x is associated with an average increase of 7.111e-03 in y.
# y = 2.104e+02 + 7.111e-03*(x)





## compare diversity by group
## Station
## Depth
## Size fraction

## compare diversity by group : nb of sequences
nb.seq.ill=colSums(OTU.tab.tax.ill[,c(2:25)])
par(mfrow = c(1, 3))
boxplot(
  nb.seq.ill[grep("_08", names(nb.seq.ill))],
  nb.seq.ill[grep("_3", names(nb.seq.ill))], 
  names = c("08-3um", ">3um"), 
  main = "Nb of sequences - \n Illumina", las =1, cex.main=0.7
  )
boxplot(
  nb.seq.ill[grep("04_", names(nb.seq.ill))],
  nb.seq.ill[grep("15_", names(nb.seq.ill))], 
  names = c("st4", "st15"), 
  main = "Nb of sequences - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  nb.seq.ill[grep("D6", names(nb.seq.ill))],
  nb.seq.ill[grep("D5", names(nb.seq.ill))], 
  nb.seq.ill[grep("D1|D2|D3|D4", names(nb.seq.ill))], 
  names = c("SRF", "DCM", "DEEP"), 
  main = "Nb of sequences - \n Illumina", las =1, cex.main=0.7
)
par(mfrow = c(1, 1))

## compare diversity by group : nb of ASVs
nb.ASV.ill=colSums(OTU.tab.tax.ill[,c(2:25)] != 0)
par(mfrow = c(1, 3))
boxplot(
  nb.ASV.ill[grep("_08", names(nb.ASV.ill))],
  nb.ASV.ill[grep("_3", names(nb.ASV.ill))], 
  names = c("08-3um", ">3um"), 
  main = "Nb of ASVs - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  nb.ASV.ill[grep("04_", names(nb.ASV.ill))],
  nb.ASV.ill[grep("15_", names(nb.ASV.ill))], 
  names = c("st4", "st15"), 
  main = "Nb of ASVs - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  nb.ASV.ill[grep("D6", names(nb.ASV.ill))],
  nb.ASV.ill[grep("D5", names(nb.ASV.ill))], 
  nb.ASV.ill[grep("D1|D2|D3|D4", names(nb.ASV.ill))], 
  names = c("SRF", "DCM", "DEEP"), 
  main = "Nb of ASVs - \n Illumina", las =1, cex.main=0.7
)
par(mfrow = c(1, 1))

## compare diversity by group : Shannon on ASVs
Shannon.ill=diversity(t(OTU.tab.tax.ill[,c(2:25)]))
par(mfrow = c(1, 3))
boxplot(
  Shannon.ill[grep("_08", names(Shannon.ill))],
  Shannon.ill[grep("_3", names(Shannon.ill))], 
  names = c("08-3um", ">3um"), 
  main = "Shannon ASV - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  Shannon.ill[grep("04_", names(Shannon.ill))],
  Shannon.ill[grep("15_", names(Shannon.ill))], 
  names = c("st4", "st15"), 
  main = "Shannon ASV - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  Shannon.ill[grep("D6", names(Shannon.ill))],
  Shannon.ill[grep("D5", names(Shannon.ill))], 
  Shannon.ill[grep("D1|D2|D3|D4", names(Shannon.ill))], 
  names = c("SRF", "DCM", "DEEP"), 
  main = "Shannon ASV - \n Illumina", las =1, cex.main=0.7
)
par(mfrow = c(1, 1))



# create abundance table for Species
Atab.Species.ill <- aggregate(OTU.tab.tax.ill[,c(2:25)], by=list(Species=OTU.tab.tax.ill$Species), FUN=sum)
dim(Atab.Species.ill)
# 815 25

## compare diversity by group : nb of species
nb.Species.ill=colSums(Atab.Species.ill[,c(2:25)] != 0)
par(mfrow = c(1, 3))
boxplot(
  nb.Species.ill[grep("_08", names(nb.Species.ill))],
  nb.Species.ill[grep("_3", names(nb.Species.ill))], 
  names = c("08-3um", ">3um"), 
  main = "Nb of Species - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  nb.Species.ill[grep("04_", names(nb.Species.ill))],
  nb.Species.ill[grep("15_", names(nb.Species.ill))], 
  names = c("st4", "st15"), 
  main = "Nb of Species - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  nb.Species.ill[grep("D6", names(nb.Species.ill))],
  nb.Species.ill[grep("D5", names(nb.Species.ill))], 
  nb.Species.ill[grep("D1|D2|D3|D4", names(nb.Species.ill))], 
  names = c("SRF", "DCM", "DEEP"), 
  main = "Nb of Species - \n Illumina", las =1, cex.main=0.7
)
par(mfrow = c(1, 1))


## compare diversity by group : Shannon on Species
Shannon.sp.ill=diversity(t(Atab.Species.ill[,c(2:25)]))
par(mfrow = c(1, 3))
boxplot(
  Shannon.sp.ill[grep("_08", names(Shannon.sp.ill))],
  Shannon.sp.ill[grep("_3", names(Shannon.sp.ill))], 
  names = c("08-3um", ">3um"), 
  main = "Shannon Species - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  Shannon.sp.ill[grep("04_", names(Shannon.sp.ill))],
  Shannon.sp.ill[grep("15_", names(Shannon.sp.ill))], 
  names = c("st4", "st15"), 
  main = "Shannon Species - \n Illumina", las =1, cex.main=0.7
)
boxplot(
  Shannon.sp.ill[grep("D6", names(Shannon.sp.ill))],
  Shannon.sp.ill[grep("D5", names(Shannon.sp.ill))], 
  Shannon.sp.ill[grep("D1|D2|D3|D4", names(Shannon.sp.ill))], 
  names = c("SRF", "DCM", "DEEP"), 
  main = "Shannon Species - \n Illumina", las =1, cex.main=0.7
)
par(mfrow = c(1, 1))







#### NMDS - 
# create NMDS
# more details here : https:##jonlefcheck.net/2012/10/24/nmds-tutorial-in-r/

# ASV matrix
# normalize matrix
Atab.ASV.ill.n <- prop.table(as.matrix(Atab.ASV.ill[, c(2:25)]), 2)
dim(Atab.ASV.ill.n)
rownames(Atab.ASV.ill.n) <- Atab.ASV.ill$ASV


# Hellinger transformation
# 
Atab.ASV.ill.n.NMDS <- metaMDS(t(Atab.ASV.ill.n), k=2,trymax=100)
stressplot(Atab.ASV.ill.n.NMDS)
plot(Atab.ASV.ill.n.NMDS)
# default crosses and red = species / transcripts
# round and black = samples 
Atab.ASV.ill.n.NMDS$stress

# nmds plot 1
ordiplot(Atab.ASV.ill.n.NMDS, type="n")
#### orditorp(Atab.ASV.ill.n.NMDS, display="species",col="red",air=0.01)
#### create coloartion of the species according to Division
# nmds plot 2
ordiplot(Atab.ASV.ill.n.NMDS, type="n")
orditorp(Atab.ASV.ill.n.NMDS, display="sites",cex=0.75,air=0.01)

## nmds plot Size fractions
env.col <- colnames(Atab.ASV.ill.n)
env.col.SF <- gsub("[0-9][0-9]_D._3", "SF3sup", gsub("[0-9][0-9]_D._08", "SF08-3", env.col))

ordiplot(Atab.ASV.ill.n.NMDS, type="n", main=c("ASVs Illumina NMDS"))
# orditorp(Atab.ASV.ill.n.NMDS, display="species",col="gray60",air=0.01,cex=0.75)
ordihull(Atab.ASV.ill.n.NMDS, groups=env.col.SF, draw="polygon", col=c("orange", "blue"), label=F)  # draw polygons
orditorp(Atab.ASV.ill.n.NMDS, display="sites", col=gsub("SF08-3", "orange", gsub("SF3sup", "blue", env.col.SF)), cex=0.75,air=0.01)
## and plot the stress value 
mtext(paste("stress ",round(Atab.ASV.ill.n.NMDS$stress*100,2), "%", sep=""), side=3)
legend("topleft", legend = c("SF08-3","SF3sup") , col = c('orange', 'blue') , bty = "n", pch=20 , pt.cex = 1, cex = 1, horiz = FALSE, inset=c(0.03,0.03))


## nmds plot stations
env.col.st <- gsub("04_[A-Z][0-9]_[0-9]{1,2}", "st4", gsub("15_[A-Z][0-9]_[0-9]{1,2}", "st15", env.col))
ordiplot(Atab.ASV.ill.n.NMDS, type="n", main=c("ASVs Illumina NMDS"))
# orditorp(Atab.ASV.ill.n.NMDS, display="species",col="gray60",air=0.01,cex=0.75)
ordihull(Atab.ASV.ill.n.NMDS, groups=env.col.st, draw="polygon", col=c("red", "green"), label=F)  # draw polygons
orditorp(Atab.ASV.ill.n.NMDS, display="sites", col=gsub("st4", "green", gsub("st15", "red", env.col.st)), cex=0.75,air=0.01)
## and plot the stress value 
mtext(paste("stress ",round(Atab.ASV.ill.n.NMDS$stress*100,2), "%", sep=""), side=3)
legend("topleft", legend = c("st4","st15") , col = c('green', 'red') , bty = "n", pch=20 , pt.cex = 1, cex = 1, horiz = FALSE, inset=c(0.03,0.03))


## nmds plot depth
env.col.depth <- gsub("[0-9][0-9]_D[1-4]_[0-9]{1,2}", "DEEP", gsub("[0-9][0-9]_D6_[0-9]{1,2}", "SRF", gsub("[0-9][0-9]_D5_[0-9]{1,2}", "DCM", env.col)))
ordiplot(Atab.ASV.ill.n.NMDS, type="n", main=c("ASVs Illumina NMDS"))
# orditorp(Atab.ASV.ill.n.NMDS, display="species",col="gray60",air=0.01,cex=0.75)
ordihull(Atab.ASV.ill.n.NMDS, groups=env.col.depth, draw="polygon", col=c("black", "darkblue", "yellow"), label=F)  # draw polygons
orditorp(Atab.ASV.ill.n.NMDS, display="sites", col=gsub("DEEP", "darkblue", gsub("DCM", "black", gsub("SRF", "yellow", env.col.depth))), cex=0.75,air=0.01)
## and plot the stress value 
mtext(paste("stress ",round(Atab.ASV.ill.n.NMDS$stress*100,2), "%", sep=""), side=3)
legend("topleft", legend = c("DEEP","DCM", "SRF") , col = c('darkblue', 'black', 'yellow') , bty = "n", pch=20 , pt.cex = 1, cex = 1, horiz = FALSE, inset=c(0.03,0.03))


## nmds env clusters from PCA on env data
# previous correspond to clustering on level 3


