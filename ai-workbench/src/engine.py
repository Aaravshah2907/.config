import os
import json
import urllib.request
import urllib.error
import subprocess

CONFIG_DIR = os.path.expanduser("~/.config/ai-workbench")

def get_account(nickname=None):
    accounts_file = os.path.join(CONFIG_DIR, 'accounts.json')
    if not os.path.exists(accounts_file):
        return None
    
    try:
        with open(accounts_file, 'r') as f:
            accounts = json.load(f)
    except json.JSONDecodeError:
        return None
    
    if not accounts:
        return None
    
    if nickname:
        for acc in accounts:
            if acc.get('nickname') == nickname:
                return acc
        return None
    else:
        # Default to first account
        return accounts[0]

def build_context():
    context = "=== AI WORKBENCH CONTEXT ===\n"
    
    memory_path = os.path.join(CONFIG_DIR, 'memory.md')
    if os.path.exists(memory_path):
        with open(memory_path, 'r') as f:
            context += f"\n--- MEMORY ---\n{f.read()}\n"
            
    tasks_path = os.path.join(CONFIG_DIR, 'tasks.md')
    if os.path.exists(tasks_path):
        with open(tasks_path, 'r') as f:
            context += f"\n--- CURRENT TASKS ---\n{f.read()}\n"
            
    return context

def ask_engine(prompt_list, account_nickname=None):
    prompt = " ".join(prompt_list)
    account = get_account(account_nickname)
    
    if not account:
        print("Error: No accounts configured. Use `ai account add` to set one up.")
        return

    context = build_context()
    provider = account.get('provider', '').lower()
    
    full_prompt = f"{context}\n\n=== USER PROMPT ===\n{prompt}"
    
    print(f"Routing request to provider: {account.get('provider')} (Account: {account.get('nickname')})")
    
    if provider == "openai":
        api_key = os.environ.get("OPENAI_API_KEY")
        if not api_key:
            print("Error: OPENAI_API_KEY environment variable not set.")
            print("Please set it: export OPENAI_API_KEY='your-key'")
            return
            
        data = {
            "model": "gpt-4o",  # Can be made configurable later
            "messages": [
                {"role": "system", "content": context},
                {"role": "user", "content": prompt}
            ]
        }
        
        req = urllib.request.Request(
            "https://api.openai.com/v1/chat/completions",
            data=json.dumps(data).encode("utf-8"),
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {api_key}"
            }
        )
        
        print("Waiting for response...")
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode("utf-8"))
                reply = result['choices'][0]['message']['content']
                print("\n=== AI RESPONSE ===\n")
                print(reply)
                print("\n===================\n")
        except urllib.error.URLError as e:
            print(f"API Request Failed: {e}")
            if hasattr(e, 'read'):
                print(e.read().decode('utf-8'))
    elif provider == "agy":
        print("Waiting for response from Antigravity (agy)...")
        try:
            result = subprocess.run(["agy", "--print", full_prompt], capture_output=True, text=True, check=True)
            print("\n=== AI RESPONSE ===\n")
            print(result.stdout.strip())
            print("\n===================\n")
        except subprocess.CalledProcessError as e:
            print("Antigravity Request Failed!")
            print(e.stderr)
        except FileNotFoundError:
            print("Error: The `agy` command was not found in your PATH.")
    elif provider == "ollama":
        # Hardcoded models based on the local installation
        AVAILABLE_OLLAMA_MODELS = ["qwen3:8b", "qwen3-coder:30b"]
        
        model_name = account.get('notes')
        if not model_name or model_name not in AVAILABLE_OLLAMA_MODELS:
            model_name = "qwen3:8b" # Default to local qwen3:8b if unspecified or invalid
            
        print(f"Waiting for response from local Ollama (Model: {model_name})...")
        data = {
            "model": model_name,
            "messages": [
                {"role": "system", "content": context},
                {"role": "user", "content": prompt}
            ],
            "stream": False
        }
        req = urllib.request.Request(
            "http://localhost:11434/api/chat",
            data=json.dumps(data).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(req) as response:
                result = json.loads(response.read().decode("utf-8"))
                reply = result.get('message', {}).get('content', '')
                print("\n=== AI RESPONSE ===\n")
                print(reply)
                print("\n===================\n")
        except urllib.error.URLError as e:
            print(f"Ollama Request Failed: {e}")
            print("Make sure Ollama is running locally on port 11434 (run `ollama serve`).")
    elif provider == "aider":
        print("Passing prompt to Aider for code operations...")
        try:
            # Aider manages its own file context, so we pass the user's raw prompt 
            # rather than the full workbench memory to avoid confusing it.
            subprocess.run(["aider", "--message", prompt])
        except FileNotFoundError:
            print("Error: The `aider` command was not found in your PATH.")
    else:
        print(f"Provider '{provider}' is not yet supported by the engine.")
