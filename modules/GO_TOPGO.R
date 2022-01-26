#Get input arguments
arg = commandArgs(trailingOnly=TRUE)

#Test if there is a inputfile argument
if (length(args)!=1) {
  stop("You have to enter the full path to your source file as parameter!", call.=FALSE)
}

#Load package and set path
library("topGO")
library("org.Hs.eg.db")
library("ggplot2")

#Load data from input file
data <- data.table::fread(arg[1])
data$GeneID <- substr(data$GeneID, 1, 18)

#Define significance threshold
up.idx <- which(data$padj < 0.05 & data$log2fc > 0) # FDR < 0.05 and logFC > 0
dn.idx <- which(data$padj < 0.05 & data$log2fc < 0) # FDR < 0.05 and logFC < 0

#Define significant genes
all.genes <- data$GeneSymbol
up.genes <- data[up.idx,]$GeneSymbol
dn.genes <- data[dn.idx,]$GeneSymbol
##Alternative if you have only Ensembl gene ID
#all.genes <- data$GeneID
#up.genes <- data[up.idx,]$GeneID
#dn.genes <- data[dn.idx,]$GeneID

#Decide the sub-ontology to test
ontology <- "BP"  #(Biological Process)
#ontology <- "CC" #(Cellular Component)
#ontology <- "MF" #(Molecular Function)

#Decide test algorithm
algorithm <- "weight01"
#algorithm <- "classic"
#algorithm <- "elim"
#algorithm <- "weight"
#algorithm <- "lea"
#algorithm <- "parentchild"

#Define the statistical test used
#For tests based on gene counts
statistic <- "fisher"      # Fischer's exact test
#For tests based on gene scores or gene ranks
#statistic <- "ks"         # Kolmogorov-Smirnov test
#statistic <- "t"          # t-test
#For tests based on gene expression
#statistic <- "globaltest" # globaltest

#Set outfile prefix
outTitle <- paste0("topGO_GO-", ontology, "_ORA_", algorithm,"_", statistic)

#Prepare input data
#Produce list of up's
upList <- factor(as.integer(all.genes %in% up.genes))
names(upList) <- all.genes
#Produce list of dn's
dnList <- factor(as.integer(all.genes %in% dn.genes))
names(dnList) <- all.genes

#Create topGOdata object
#Of up
upGOdata <- new("topGOdata", ontology = ontology, allGenes = upList,geneSel = function(x)(x == 1), 
                nodeSize = 10, annot = annFUN.org, mapping = "org.Hs.eg.db", ID = "SYMBOL")
#Of down 
dnGOdata <- new("topGOdata", ontology = ontology, allGenes = dnList,geneSel = function(x)(x == 1), 
                nodeSize = 10, annot = annFUN.org, mapping = "org.Hs.eg.db", ID = "SYMBOL")

#Test for enrichment
#Test up
upRes <- runTest(upGOdata, algorithm = algorithm, statistic = statistic)
#Test dn
dnRes <- runTest(dnGOdata, algorithm = algorithm, statistic = statistic)

#Plot enrichment
#Up-regulated genes
png(paste0(outTitle, "_up.png"), width = 8, height = 6, units = "in", res = 300)
enrichment_barplot(upGOdata, upRes, showTerms = 20, numChar = 50, orderBy = "Scores", 
                   title = paste0("GO-", ontology," ORA of up-regulated genes"))
invisible(dev.off())
#Down-regulated genes
png(paste0(outTitle, "_dn.png"), width = 8, height = 6, units = "in", res = 300)
enrichment_barplot(dnGOdata, dnRes, showTerms = 20, numChar = 50, orderBy = "Scores",
                   title = paste0("GO-", ontology," ORA of down-regulated genes"))
invisible(dev.off())

#Create result table
#Build up result table
up.tab <- GenTable(upGOdata, Pval = upRes, topNodes = 20)
#Build down result table 
dn.tab <- GenTable(dnGOdata, Pval = dnRes, topNodes = 20)

#Update table with full GO term name
#Uupdate up table 
up.tab$Term <- sapply(up.tab$"GO.ID", function(go) Term(GO.db::GOTERM[[go]]))
#Update down table
dn.tab$Term <- sapply(dn.tab$"GO.ID", function(go) Term(GO.db::GOTERM[[go]]))

#Add gene symbol to result table to obtain the list of significant genes
up.sigGenes <- sigGenes(upGOdata)
dn.sigGenes <- sigGenes(dnGOdata)

#Retrieve gene symbols for each GO from the test result
up.AnnoList <- lapply(up.tab$"GO.ID", 
                      function(x) as.character(unlist(genesInTerm(object = upGOdata, whichGO = x))))
dn.AnnoList <- lapply(dn.tab$"GO.ID", 
                      function(x) as.character(unlist(genesInTerm(object = dnGOdata, whichGO = x))))
up.SigList <- lapply(up.AnnoList, function(x) intersect(x, up.sigGenes))
dn.SigList <- lapply(dn.AnnoList, function(x) intersect(x, dn.sigGenes))

#Coerce gene list to a comma-separated vector
up.tab$Genes <- sapply(up.SigList, paste, collapse = ",")
dn.tab$Genes <- sapply(dn.SigList, paste, collapse = ",")

#Cbind first 5 up 
cbind(head(up.tab$Genes, 5))

#Cbind first 5 down
cbind(head(dn.tab$Genes, 5))

#Output results to files
write.table(up.tab, file = paste0(outTitle, "_up.txt"), sep = "\t", quote = F, 
            row.names = F, col.names = T)
write.table(dn.tab, file = paste0(outTitle, "_dn.txt"), sep = "\t", quote = F, 
            row.names = F, col.names = T)
