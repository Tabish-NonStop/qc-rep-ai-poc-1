#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process LLM_INFER {

  publishDir "${params.outdir}/llm_response", mode: 'copy'

  container 'python:3.11-slim'

  input:
  path prompt_file

  output:
  path "llm_response.json"

  script:
  """
  set -euo pipefail

  python - <<'PY'
  import json, os
  import urllib.request

  model = os.environ.get("OLLAMA_MODEL", "qwen2.5:7b")
  url   = os.environ.get("OLLAMA_URL", "http://host.docker.internal:11434/api/generate")

  prompt_path = "${prompt_file}"
  with open(prompt_path, "r", encoding="utf-8", errors="replace") as f:
      prompt = f.read()

  payload = {
    "model": model,
    "prompt": prompt,
    "stream": False
  }

  req = urllib.request.Request(
      url,
      data=json.dumps(payload).encode("utf-8"),
      headers={"Content-Type": "application/json"},
      method="POST"
  )

  with urllib.request.urlopen(req) as resp:
      data = json.loads(resp.read().decode("utf-8"))

  # Save full raw response (includes timings + context)
  with open("llm_response.json", "w", encoding="utf-8") as f:
      json.dump(data, f, indent=2, ensure_ascii=False)

  print("Saved llm_response.json")
  PY
  """
}
