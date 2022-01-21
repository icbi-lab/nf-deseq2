# code for preprocessing of the samplesheets

# At the very beginning of the pipeline, we need to verify that the samplesheet makes sense, and sanitize it.
# For instance, the samplesheet used by nf-core/rnaseq can contain multiple rows for the same sample 
# (in case multiple fastq files need to be merged).

# Input: samplesheet as provided by user
# Output: cleaned samplesheet with one row per sample.

library (dplyr)

# load input files, e.g. test data

sampleAnnotation <- read_csv("https://raw.githubusercontent.com/icbi-lab/nf-deseq2/main/tests/testdata/example_nfcore/rnaseq_samplesheet_nfcore-3.1.csv")
geneCounts <- read_tsv("https://raw.githubusercontent.com/icbi-lab/nf-deseq2/main/tests/testdata/example_nfcore/salmon.merged.gene_counts.subset.tsv")

### notes: 
### check gene counts for column names with samples
### take it and filter samplesheets based on that - i.e. output samplesheet will have only 6 lines in total, only those, that are different

cond_col = "group"
# sample_col = NULL
contrast = c("group", "grpA", "grpB")

sampleAnnotation2 <- filter(sampleAnnotation, get(cond_col) %in% contrast[2:3])

#### end end end
