nextflow.enable.dsl=2

process EMBED_LLM {

    publishDir "${params.outdir}/multiqc_with_llm", mode: 'copy'

    input:
        path multiqc_html
        path llm_response

    output:
        path "multiqc_report_with_llm.html"

    script:
    """
    set -euo pipefail

    RAW_RESPONSE=\$(cat "${llm_response}")

    # Wrap in a styled div only if not already wrapped
    if echo "\$RAW_RESPONSE" | grep -qE '^[[:space:]]*<div[^>]*>'; then
        printf '%s' "\$RAW_RESPONSE" > llm_block.html
    else
        printf '<div style="margin:20px;padding:20px;border:2px solid #444;border-radius:8px;background:#111;color:white;">%s</div>' "\$RAW_RESPONSE" > llm_block.html
    fi

    # Use getline to safely read the HTML block from a file instead of
    # passing it as an awk -v variable (which breaks on newlines/special chars)
    awk '
        /<body[^>]*>/ {
            print
            while ((getline line < "llm_block.html") > 0) {
                print line
            }
            close("llm_block.html")
            next
        }
        { print }
    ' "${multiqc_html}" > multiqc_report_with_llm.html
    """
}
