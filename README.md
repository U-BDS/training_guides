# General Notes:
* Use at minimum 3 samples when running a pipeline (even for minimal testing purposes). Some pipelines will not be able to complete successfully when running only a single sample.
* Although not a requirement, we advise to not use the iGenomes option suggested in a number of pipelines due to the lack of information on versioning linked to each assembly which may compromise reproducibility to a small degree. Instead pass on a reference (genome, and annotation file(s)) from a source and version that is suitable to your needs.

# Pipeline-specific Notes:
## nf-core/rnaseq:
* The `transcript_fasta` used at the Salmon steps, should be a transcriptome file generated from `gffread` as opoosed to one downloaded from GENCODE or Ensembl. Issues linked to Ensembl transcriptomes are derieved from the fact that the transcriptome files (even after coding and non-coding RNA concatenation) have less transcripts than the GTF file. The issues linked to GENCODE files are linked to an issue in the pipeline which prevents it from correctly processing the off-the-shelf transcript fasta due to the sequence name format (despite enabling the `--gencode` parameter).
    * It should be noted the current recommended way to use reference files generally is to provide the `--fasta` and `--gtf` along with `--save_reference` the first time you run the pipeline and then let it generate all of the downstream artifacts like the transcriptome and indices to be recycled thereafter via including them in them as params in the yml. This is the way recommended by the authors, per conversation in the nf-core/rnaseq channel on 1/20/22.

`gffread` example:

```
samtools faidx Mus_musculus.GRCm38.dna.primary_assembly.fa

gffread -w Mus_musculus.GRCm38_GTF_matched_transcripts.fa -g ./Mus_musculus.GRCm38.dna.primary_assembly.fa Mus_musculus.GRCm38.102.gtf
```

From the example above, the newly generated transcriptome `Mus_musculus.GRCm38_GTF_matched_transcripts.fa` would be passed on to the pipeline.

We recommend to creata a conda environment with both dependencies and record the versions.

`gffread` documentation can be found from: http://ccb.jhu.edu/software/stringtie/gff.shtml#gffread

## nf-core/nanoseq:
* The version of nanoplot that is used by this pipeline (1.38) causes the pipeline to crash. Per the author, the issue is with a package that is used to convert html files into png files. However, nanoseq expects there to be png files which causes crash. In order to get around this issue, you can create a custom config and override the container that nanoseq would pull down for Nanoplot. Values specified in configs passed via the commandline take priority over the defaults that are specified in the pipeline proper.
    * This problem is currently being tracked here: https://github.com/nf-core/nanoseq/issues/141

container override example:
```
process {
    withName: NANOPLOT {
        container = 'https://depot.galaxyproject.org/singularity/nanoplot:1.32.1--py_0'
    }
}
```
Place the above lines in a file called `custom.config`. When the pipleine is run, specify a new command-line parameter `-c path/to/custom.config` to the nextflow command, where `path/to/custom.config` would be the path to the custom config file.
