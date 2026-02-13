#!usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads = "${projectDir}/data/dataset.fastq"
params.outdir = "${projectDir}/results"

include { FASTQC }          from './modules/fastqc/main.nf'
include { MULTIQC }         from './modules/multiqc/main.nf'
include { FASTQ_HEADER }    from './modules/fastq_header/main.nf'
include { PROMPT_BUILDER }  from './modules/prompt_builder/main.nf'

workflow {

  // Input FASTQ
  Channel.fromPath(params.reads).set { reads_ch }

  // Extract FASTQ header line (stdout -> value)
  fastq_header_ch = FASTQ_HEADER(reads_ch)

  // Run FastQC (emits html, zip, fastqc_data.txt, summary.txt)
  fastqc_out_ch = FASTQC(reads_ch)

  // Split outputs
  fastqc_data_ch    = fastqc_out_ch.map { html, zip, data, summary -> data }
  fastqc_summary_ch = fastqc_out_ch.map { html, zip, data, summary -> summary }
  fastqc_dir_ch     = fastqc_data_ch.map { it.parent }

  // MultiQC expects a directory containing FastQC outputs
  multiqc_out_ch = MULTIQC(fastqc_dir_ch.collect())

  // Grab multiqc_data.json from MULTIQC outputs
  multiqc_json_ch = multiqc_out_ch.map { report_html, data_dir, json_file -> json_file }

  // Build a single prompt.txt
  PROMPT_BUILDER(
    fastq_header_ch,
    fastqc_data_ch.collect(),
    fastqc_summary_ch.collect(),
    multiqc_json_ch
  )
}