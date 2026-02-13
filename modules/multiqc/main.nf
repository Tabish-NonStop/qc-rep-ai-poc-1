#!usr/bin/env nextflow
nextflow.enable.dsl=2

process MULTIQC {
    container 'ewels/multiqc:dev'

    publishDir "${params.outdir}/multiqc", mode: 'copy'
    
    input:
    path fastqc_reports

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    echo "Running MultiQC on FASTQC reports"
    multiqc .
    echo "MultiQC report generated"
    """
}