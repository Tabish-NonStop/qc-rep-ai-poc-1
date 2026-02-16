# In your terminal, first run:
# pip install xai-sdk

import os

from xai_sdk import Client
from xai_sdk.chat import user, system

client = Client(
    api_key= "xai-l6H6Rtm2x8FStGPc4PSPjoAvaZj0W1ohqFLDSJp2Gynq65Pd10hxWDQbSrPVBoqFegcQ48yOSDehjoxt", #os.getenv("XAI_API_KEY"),
    timeout=3600, # Override default timeout with longer timeout for reasoning models
)

chat = client.chat.create(model="grok-4-1-fast-reasoning")
chat.append(system("You are Grok, a highly intelligent, helpful AI assistant. You only repsond in webpages, i.e., return a complete HTML file with CSS and JS which the user can view as a webpage after downloading. You just provide the code, nothing else."))
chat.append(user("What is the meaning of life, the universe, and everything?"))

response = chat.sample()
print(response.content)