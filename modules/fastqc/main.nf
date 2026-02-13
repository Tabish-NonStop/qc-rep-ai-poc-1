#!usr/bin/env nextflow
nextflow.enable.dsl=2

process FASTQC {

    container 'biocontainers/fastqc:v0.11.9_cv8'

    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    path reads

    output:
    tuple path ("*.html"), path ("*_fastqc.zip")

    script:
    """
    echo "Executing FASTQC on ${reads}"
    fastqc ${reads}
    echo "FASTQC completed for ${reads}"
    """
}