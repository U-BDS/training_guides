# General Notes:
* Use at minimum 3 samples when running a sample. Some pipelines will not be able to complete successfully when running only a single sample.

# Pipeline-specific Notes:
## nf-core/rnaseq:
* Per the creators/maintainers of the pipeline, it is recommended building the transcript fasta ahead of time using `gffread`, even though the pipeline can generate its own fasta file.
    - This is especially recommended when using GENCODE files, as the pipeline currently cannot correctly process the off-the-shelf transcript fasta due to the sequence name format.
