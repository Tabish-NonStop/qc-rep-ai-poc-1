import requests

OLLAMA_URL = "http://localhost:11434/api/generate"

system_prompt = "You are a helpful bioinformatics assistant. You only respond in HTML divs. NO <!DOCTYPE HTML> or any other stuff. Just start with <div> and end with </div>"
user_prompt = "Explain variant calling in simple terms."

payload = {
    "model": "qwen2.5:3b",
    "prompt": f"<|system|>\n{system_prompt}\n<|user|>\n{user_prompt}\n<|assistant|>",
    "stream": False
}

response = requests.post(OLLAMA_URL, json=payload)

if response.status_code == 200:
    print(response.json()["response"])
else:
    print("Error:", response.text)
