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

  python3 - <<'PY'
  from pathlib import Path
  import html

  raw = Path("${llm_response}").read_text(encoding="utf-8", errors="replace").strip()
  escaped = html.escape(raw)

  # Use MultiQC's own styling classes to match CSS
  block = '''
  <div class="report_comment mqc-section-comment" id="llm-qc-summary">
    <div style="display:flex; align-items:center; justify-content:space-between; gap:10px;">
      <h2 style="margin:0;">LLM QC Summary</h2>
      <button class="btn btn-default btn-xs" type="button"
              data-toggle="collapse" data-target="#llm_qc_collapse"
              aria-expanded="true" aria-controls="llm_qc_collapse">
        Toggle
      </button>
    </div>

    <div id="llm_qc_collapse" class="collapse in" style="margin-top:10px;">
      <pre style="margin:0; max-height:240px; overflow:auto; white-space:pre-wrap; background:transparent; border:0; padding:0;">__ESCAPED__</pre>
    </div>
  </div>
  '''.replace('__ESCAPED__', escaped)

  Path("llm_block.html").write_text(block, encoding="utf-8")
  PY

  # Inject inside the report content (right after <div class="mainpage">),
  # not right after <body>
  awk '
    BEGIN { inserted=0 }
    /<div class="mainpage">/ && inserted==0 {
      print
      while ((getline line < "llm_block.html") > 0) print line
      close("llm_block.html")
      inserted=1
      next
    }
    { print }
    END {
      if (inserted==0) {
        print "ERROR: <div class=\\"mainpage\\"> not found; no injection done." > "/dev/stderr"
        exit 1
      }
    }
  ' "${multiqc_html}" > multiqc_report_with_llm.html
  """
}
