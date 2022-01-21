### Load package and set path
library("topGO")
library("org.Mm.eg.db")
library("ggplot2")




#### Load data

## from file
#data <- data.table::fread("RESULTS_DEG_HNSC.txt")
#data$GeneID <- substr(data$GeneID, 1, 18)


## from web-source
data <- data.table::fread("https://raw.githubusercontent.com/ycl6/GO-Enrichment-Analysis-Demo/master/DESeq2_DEG.txt")
data$GeneID <- substr(data$GeneID, 1, 18)


## show raw-data for checking the load function
data$GeneID




### Define significance threshold
up.idx <- which(data$padj < 0.05 & data$log2fc > 0) # FDR < 0.05 and logFC > 0
dn.idx <- which(data$padj < 0.05 & data$log2fc < 0) # FDR < 0.05 and logFC < 0


## show data dimension
dim(data)


## show length of up
length(up.idx)


## show length of down
length(dn.idx)




### Define significant genes
all.genes <- data$GeneSymbol
up.genes <- data[up.idx,]$GeneSymbol
dn.genes <- data[dn.idx,]$GeneSymbol


## alternative if you have only Ensembl gene ID
#all.genes <- data$GeneID
#up.genes <- data[up.idx,]$GeneID
#dn.genes <- data[dn.idx,]$GeneID


## show the first 10 gens of up
head(up.genes, 10)


## show the first 10 gens of dn
head(dn.genes, 10)




### Decide the sub-ontology to test

## BP (Biological Process)
ontology <- "BP"


## CC (Cellular Component)
#ontology <- "CC"


## MF (Molecular Function)
#ontology <- "MF"




### Decide test algorithm
algorithm <- "weight01"
#algorithm <- "classic"
#algorithm <- "elim"
#algorithm <- "weight"
#algorithm <- "lea"
#algorithm <- "parentchild"




### Define the statistical test used

## for tests based on gene counts
statistic <- "fisher"      # Fischer's exact test


## for tests based on gene scores or gene ranks
#statistic <- "ks"         # Kolmogorov-Smirnov test
#statistic <- "t"          # t-test


## For tests based on gene expression
#statistic <- "globaltest" # globaltest



### Set outfile prefix
outTitle <- paste0("topGO_GO-", ontology, "_ORA_", algorithm,"_", statistic)

## prints outline for controlling
outTitle




### Prepare input data

## produce list of up's
upList <- factor(as.integer(all.genes %in% up.genes))
names(upList) <- all.genes


## show first 30 entrys
head(upList, 30)


## show ammount of entrys
table(upList)


## produce list of dn's
dnList <- factor(as.integer(all.genes %in% dn.genes))
names(dnList) <- all.genes


## show first 30 entrys
head(dnList, 30)


## show ammount of entrys
table(dnList)




### Create topGOdata object

## of up
upGOdata <- new("topGOdata", ontology = ontology, allGenes = upList,geneSel = function(x)(x == 1), 
                nodeSize = 10, annot = annFUN.org, mapping = "org.Mm.eg.db", ID = "SYMBOL")


## of down 
dnGOdata <- new("topGOdata", ontology = ontology, allGenes = dnList,geneSel = function(x)(x == 1), 
                nodeSize = 10, annot = annFUN.org, mapping = "org.Mm.eg.db", ID = "SYMBOL")




### Test for enrichment

## test up
upRes <- runTest(upGOdata, algorithm = algorithm, statistic = statistic)


## show up
upRes


## test dn
dnRes <- runTest(dnGOdata, algorithm = algorithm, statistic = statistic)


## show dn
dnRes




### Plot enrichment

## up-regulated genes
png(paste0(outTitle, "_up.png"), width = 8, height = 6, units = "in", res = 300)
enrichment_barplot(upGOdata, upRes, showTerms = 20, numChar = 50, orderBy = "Scores", 
                   title = paste0("GO-", ontology," ORA of up-regulated genes"))
invisible(dev.off())


## down-regulated genes
png(paste0(outTitle, "_dn.png"), width = 8, height = 6, units = "in", res = 300)
enrichment_barplot(dnGOdata, dnRes, showTerms = 20, numChar = 50, orderBy = "Scores",
                   title = paste0("GO-", ontology," ORA of down-regulated genes"))
invisible(dev.off())




### Create result table

## build up result table
up.tab <- GenTable(upGOdata, Pval = upRes, topNodes = 20)


## show up result table
up.tab


## build down result table 
dn.tab <- GenTable(dnGOdata, Pval = dnRes, topNodes = 20)


## show down result table
dn.tab




### Update table with full GO term name

## update up table 
up.tab$Term <- sapply(up.tab$"GO.ID", function(go) Term(GO.db::GOTERM[[go]]))


## show up table
up.tab$Term


#update down table
dn.tab$Term <- sapply(dn.tab$"GO.ID", function(go) Term(GO.db::GOTERM[[go]]))


## show down table
dn.tab$Term




### Add gene symbol to result table

## Obtain the list of significant genes
up.sigGenes <- sigGenes(upGOdata)
dn.sigGenes <- sigGenes(dnGOdata)

## Retrieve gene symbols for each GO from the test result
up.AnnoList <- lapply(up.tab$"GO.ID", 
                      function(x) as.character(unlist(genesInTerm(object = upGOdata, whichGO = x))))
dn.AnnoList <- lapply(dn.tab$"GO.ID", 
                      function(x) as.character(unlist(genesInTerm(object = dnGOdata, whichGO = x))))

up.SigList <- lapply(up.AnnoList, function(x) intersect(x, up.sigGenes))
dn.SigList <- lapply(dn.AnnoList, function(x) intersect(x, dn.sigGenes))

## Coerce gene list to a comma-separated vector
up.tab$Genes <- sapply(up.SigList, paste, collapse = ",")
dn.tab$Genes <- sapply(dn.SigList, paste, collapse = ",")


## cbind first 5 up 
cbind(head(up.tab$Genes, 5))


## cbind first 5 down
cbind(head(dn.tab$Genes, 5))




### Output results to files
write.table(up.tab, file = paste0(outTitle, "_up.txt"), sep = "\t", quote = F, 
            row.names = F, col.names = T)

write.table(dn.tab, file = paste0(outTitle, "_dn.txt"), sep = "\t", quote = F, 
            row.names = F, col.names = T)
