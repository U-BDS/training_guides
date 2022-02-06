# Sample DESeq2 script using data from vignette examples in Docker container
# A real data analysis script should have much more than what is shown here :)

library(DESeq2)
library(pasilla)

pasCts <- system.file("extdata",
                      "pasilla_gene_counts.tsv",
                      package="pasilla", mustWork=TRUE)

pasAnno <- system.file("extdata",
                       "pasilla_sample_annotation.csv",
                       package="pasilla", mustWork=TRUE)

cts <- as.matrix(read.csv(pasCts,sep="\t",row.names="gene_id"))
head(cts)

coldata <- read.csv(pasAnno, row.names=1)
coldata <- coldata[,c("condition","type")]
coldata

coldata$condition <- factor(coldata$condition)
coldata$type <- factor(coldata$type)

# re-ordering sample names to match b/t coldata and counts

rownames(coldata) <- sub("fb", "", rownames(coldata))
all(rownames(coldata) %in% colnames(cts))

all(rownames(coldata) == colnames(cts))

cts <- cts[, rownames(coldata)]
all(rownames(coldata) == colnames(cts)) # now TRUE

# make DESeqDataSet object

dds <- DESeqDataSetFromMatrix(countData = cts,
                              colData = coldata,
                              design = ~ condition)
dds

# PCA

rld <- rlog(dds, blind=FALSE)

plotPCA(rld, intgroup=c("condition", "type"))


# simple diff. expression

dds <- DESeq(dds)
res <- results(dds)
res
