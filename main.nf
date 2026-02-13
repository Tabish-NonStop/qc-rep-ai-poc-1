#!usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads = "${projectDir}/data/dataset.fastq"
params.outdir = "${projectDir}/results"

include { FASTQC }  from './modules/fastqc/main.nf'
include { MULTIQC } from './modules/multiqc/main.nf'

workflow {
    reads_ch            = Channel.fromPath(params.reads)
    fastqc_reports_ch   = FASTQC(reads_ch)
    MULTIQC(fastqc_reports_ch.collect())
}