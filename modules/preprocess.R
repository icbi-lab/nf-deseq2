# code for preprocessing of the samplesheets

# At the very beginning of the pipeline, we need to verify that the samplesheet makes sense, and sanitize it.
# For instance, the samplesheet used by nf-core/rnaseq can contain multiple rows for the same sample 
# (in case multiple fastq files need to be merged).

# Input: samplesheet as provided by user
# Output: cleaned samplesheet with one row per sample.

library (dplyr)

# load input files, e.g. test data

sampleAnnotation <- read_csv("https://raw.githubusercontent.com/icbi-lab/nf-deseq2/main/tests/testdata/example_nfcore/rnaseq_samplesheet_nfcore-3.1.csv", show_col_types = FALSE)
geneCounts <- read_tsv("https://raw.githubusercontent.com/icbi-lab/nf-deseq2/main/tests/testdata/example_nfcore/salmon.merged.gene_counts.subset.tsv", show_col_types = F)

sampleAnnotation2 <- sampleAnnotation %>%
  select(-fastq_1, -fastq_2) %>%
  distinct()      # filter distinct rows

# another approach
geneCounts2 <- select(geneCounts, -gene_id, -gene_name) %>%
  colnames()
outputSheet <- filter(sampleAnnotation, sample==geneCounts2) # this preserves two more columns


# output cleaned samplesheets
print(sampleAnnotation2)
print(outputSheet)
