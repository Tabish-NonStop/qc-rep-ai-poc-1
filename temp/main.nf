nextflow.enable.dsl = 2

params.model = 'qwen2.5:3b'
params.system = 'You are a helpful bioinformatics assistant. You only respond in HTML divs. NO <!DOCTYPE HTML> or any other stuff. Just start with <div> and end with </div>'
params.user = 'Summarize the main QC issues you expect in low-quality FASTQ data.'

process LLM_CALL {
    
    tag "${params.model}"

    output:
        path "response.txt"

    script:
    """
    set -euo pipefail
    python3 - << 'PY'
    
import requests

url = "http://localhost:11434/api/chat"
payload = {
    "model": "${params.model}",
    "messages": [
        {"role": "system", "content": "${params.system}"},
        {"role": "user", "content": "${params.user}"}
    ],
    "stream": False
}
r = requests.post(url, json=payload, timeout=600)
r.raise_for_status()

with open("response.txt", "w", encoding="utf-8") as f:
    f.write(r.json()["message"]["content"].strip() + "\\n")
PY
    """
}

workflow {
    LLM_CALL()
}