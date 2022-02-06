FROM bioconductor/bioconductor_docker:RELEASE_3_10

# LABEL adds metadata to an image:
LABEL maintainer="Lara Ianov <lianov@uab.edu>"
LABEL description="An environment for running DESeq2 from Bioconductor 3.10"

# a location to mount ...(again optional to do this in the Dockerfile)
RUN mkdir /home/rstudio/DESeq2_analysis

# Install Bioconductor and other commonly used CRAN packages in DESeq2...
# NOTE that you can install CRAN packages with BiocManager::install, but below
# installing CRAN with install.packages as example
RUN R -e 'BiocManager::install(c("DESeq2", "pasilla"))'
RUN R -e 'install.packages(c("readr","ggrepel","pheatmap"))'