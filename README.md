# General Notes:
* Use at minimum 3 samples when running a pipeline (even for minimal testing purposes). Some pipelines will not be able to complete successfully when running only a single sample.

# Pipeline-specific Notes:
## nf-core/rnaseq:
* The `transcript_fasta` used at the Salmon steps, should be a transcriptome file generated from `gffread` as opoosed to one downloaded from GENCODE or Ensembl. Issues linked to Ensembl transcriptomes are derieved from the fact that the transcriptome files (even after coding and non-coding RNA concatenation) have less transcripts than the GTF file. The issues linked to GENCODE files are linked to an issue in the pipeline which prevents it from correctly processing the off-the-shelf transcript fasta due to the sequence name format (despite enabling the `--gencode` parameter).

`gffread` example:

```
samtools faidx Mus_musculus.GRCm38.dna.primary_assembly.fa

gffread -w Mus_musculus.GRCm38_GTF_matched_transcripts.fa -g ./Mus_musculus.GRCm38.dna.primary_assembly.fa Mus_musculus.GRCm38.102.gtf
```

From the example above, the newly generated transcriptome `Mus_musculus.GRCm38_GTF_matched_transcripts.fa` would be passed on to the pipeline.

We recommend to creata a conda environment with both dependencies and record the versions.

`gffread` documentation can be found from: http://ccb.jhu.edu/software/stringtie/gff.shtml#gffread
