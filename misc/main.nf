#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process LLM_INFER {

  publishDir "${params.outdir}/llm_response", mode: 'copy'
  container 'python:3.11-slim'

  input:
  path prompt_file

  output:
  path "llm_response.json"
  path "response.html"

  script:
  """
  set -euo pipefail

  python - <<'PY'
  import json, os
  import urllib.request

  model = os.environ.get("OLLAMA_MODEL", "qwen2.5:7b")
  url   = os.environ.get("OLLAMA_URL", "http://host.docker.internal:11434/api/generate")

  system_prompt = os.environ.get(
      "LLM_SYSTEM_PROMPT",
      "You are an expert bioinformatics QC analyst. Return ONLY one complete HTML file (including <!doctype html>, <html>, <head>, <style>, <body>, and optional <script>). No markdown. No backticks. No extra text."
  )

  with open("${prompt_file}", "r", encoding="utf-8", errors="replace") as f:
      user_prompt = f.read()

  payload = {
    "model": model,
    "system": system_prompt,
    "prompt": user_prompt + "\\n\\nReturn ONLY the HTML document. End exactly with </html>.",
    "stream": False,
    "options": {
      "stop": ["</html>"]
    }
  }

  req = urllib.request.Request(
      url,
      data=json.dumps(payload).encode("utf-8"),
      headers={"Content-Type": "application/json"},
      method="POST"
  )

  with urllib.request.urlopen(req) as resp:
      data = json.loads(resp.read().decode("utf-8"))

  # Save raw response JSON
  with open("llm_response.json", "w", encoding="utf-8") as f:
      json.dump(data, f, indent=2, ensure_ascii=False)

  # Extract HTML into a file
  html = data.get("response", "")
  html = html.strip()
  if not html.lower().startswith("<!doctype html"):
      # If model omits doctype, still write it, but prepend for a valid file
      html = "<!doctype html>\\n" + html

  # Ensure stop token is included (since stop cuts it off)
  if not html.lower().endswith("</html>"):
      html = html + "\\n</html>\\n"

  with open("response.html", "w", encoding="utf-8") as f:
      f.write(html)

  print("Saved llm_response.json and response.html")
  PY
  """
}
