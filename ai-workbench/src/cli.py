import argparse
import os
import json
from datetime import datetime
import engine

CONFIG_DIR = os.path.expanduser("~/.config/ai-workbench")
PARENT_DIR = os.path.expanduser("~/.config")

def read_file(path):
    if not os.path.exists(path):
        return f"Error: File {path} not found."
    with open(path, 'r') as f:
        return f.read().strip()

def read_state():
    state_file = os.path.join(CONFIG_DIR, 'state.json')
    if not os.path.exists(state_file):
        return {}
    with open(state_file, 'r') as f:
        return json.load(f)

def write_state(state):
    state_file = os.path.join(CONFIG_DIR, 'state.json')
    with open(state_file, 'w') as f:
        json.dump(state, f, indent=2)

def status_cmd():
    state = read_state()
    print("=== AI Workbench Status ===")
    print(f"Current Session: {state.get('current_session', 'None')}")
    print(f"Last Updated: {state.get('last_updated', 'None')}")

def memory_cmd():
    print(read_file(os.path.join(CONFIG_DIR, 'memory.md')))

def tasks_cmd():
    print(read_file(os.path.join(CONFIG_DIR, 'tasks.md')))

def logs_cmd():
    print(read_file(os.path.join(PARENT_DIR, 'ai_workbench_build_log.md')))

def _read_json_list(filename):
    path = os.path.join(CONFIG_DIR, filename)
    if not os.path.exists(path):
        return []
    with open(path, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return []

def _write_json_list(filename, data):
    path = os.path.join(CONFIG_DIR, filename)
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)

def providers_cmd():
    data = _read_json_list('providers.json')
    print(json.dumps(data, indent=2))

def accounts_cmd():
    data = _read_json_list('accounts.json')
    print(json.dumps(data, indent=2))

def provider_add_cmd(name):
    providers = _read_json_list('providers.json')
    if name in providers:
        print(f"Provider '{name}' already exists.")
        return
    providers.append(name)
    _write_json_list('providers.json', providers)
    print(f"Added provider '{name}'.")

def provider_remove_cmd(name):
    providers = _read_json_list('providers.json')
    if name not in providers:
        print(f"Provider '{name}' not found.")
        return
    providers.remove(name)
    _write_json_list('providers.json', providers)
    print(f"Removed provider '{name}'.")

def account_add_cmd(provider, nickname, email, auth_type, notes):
    accounts = _read_json_list('accounts.json')
    # Check if nickname exists
    if any(acc.get('nickname') == nickname for acc in accounts):
        print(f"Account with nickname '{nickname}' already exists.")
        return
    
    account = {
        "provider": provider,
        "nickname": nickname,
        "email": email,
        "auth_type": auth_type,
        "notes": notes,
        "last_used": None
    }
    accounts.append(account)
    _write_json_list('accounts.json', accounts)
    print(f"Added account '{nickname}' for provider '{provider}'.")

def account_remove_cmd(nickname):
    accounts = _read_json_list('accounts.json')
    new_accounts = [acc for acc in accounts if acc.get('nickname') != nickname]
    if len(accounts) == len(new_accounts):
        print(f"Account '{nickname}' not found.")
        return
    _write_json_list('accounts.json', new_accounts)
    print(f"Removed account '{nickname}'.")

def session_start_cmd(session_name):
    state = read_state()
    timestamp = datetime.utcnow().isoformat() + "Z"
    state['current_session'] = session_name
    state['last_updated'] = timestamp
    write_state(state)
    
    session_dir = os.path.join(CONFIG_DIR, 'sessions')
    session_file = os.path.join(session_dir, f"{session_name}.md")
    if not os.path.exists(session_file):
        with open(session_file, 'w') as f:
            f.write(f"# Session: {session_name}\nStarted at: {timestamp}\n\n")
    print(f"Started session '{session_name}'.")

def session_stop_cmd():
    state = read_state()
    if state.get('current_session'):
        print(f"Stopped session '{state['current_session']}'.")
        state['current_session'] = None
        state['last_updated'] = datetime.utcnow().isoformat() + "Z"
        write_state(state)
    else:
        print("No active session.")

def resume_cmd():
    state = read_state()
    session = state.get('current_session')
    if not session:
        print("Warning: No active session. Use 'ai session start <name>' to start one.")
    
    print(f"Resuming session: {session if session else 'None'}")
    print("Please copy the following prompt to your AI worker:")
    print("-" * 50)
    print("Please resume the current ai-workbench session.")
    print(f"1. Read {os.path.join(CONFIG_DIR, 'memory.md')}")
    print(f"2. Read {os.path.join(CONFIG_DIR, 'tasks.md')}")
    print(f"3. Read {os.path.join(CONFIG_DIR, 'state.json')}")
    print(f"4. Read {os.path.join(PARENT_DIR, 'ai_workbench_build_log.md')}")
    print("Please assess the current status and let me know what you will work on next.")
    print("-" * 50)

def setup_cmd():
    print("Running ai-workbench setup...")
    
    # 1. Create directories
    dirs = ['memory', 'tasks', 'providers', 'accounts', 'logs', 'sessions', 'scripts', 'config', 'src', 'docs']
    for d in dirs:
        dir_path = os.path.join(CONFIG_DIR, d)
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
            print(f"Created directory: {d}/")
            
    # 2. Create core files if they don't exist
    files = {
        'state.json': '{}',
        'providers.json': '[]',
        'accounts.json': '[]',
        'memory.md': '# AI Workbench Memory\n\nThis file serves as the persistent memory for the workbench.',
        'tasks.md': '# AI Workbench Tasks\n\nThis file tracks the active and pending tasks.',
        'todolist.md': '# ai-workbench Todolist\n\nThis file serves as the backlog.'
    }
    for filename, content in files.items():
        file_path = os.path.join(CONFIG_DIR, filename)
        if not os.path.exists(file_path):
            with open(file_path, 'w') as f:
                f.write(content)
            print(f"Created core file: {filename}")
            
    # Interactive JSON file setup
    print("\n--- Interactive JSON Setup ---")
    
    # 1. Setup Providers
    providers = _read_json_list('providers.json')
    if providers:
        print(f"\nCurrently configured providers: {', '.join(providers)}")
    else:
        print("\nNo providers configured.")
        
    while True:
        add_prov = input("Would you like to add a new provider? (y/n): ").strip().lower()
        if add_prov == 'y':
            prov_name = input("Enter provider name (e.g., OpenAI, Anthropic): ").strip()
            if prov_name:
                provider_add_cmd(prov_name)
                providers = _read_json_list('providers.json') # Refresh list
        else:
            break
    
    # 2. Setup Accounts
    accounts = _read_json_list('accounts.json')
    if accounts:
        print(f"\nCurrently configured accounts: {', '.join(acc.get('nickname', 'Unknown') for acc in accounts)}")
    else:
        print("\nNo accounts configured.")
        
    if providers:
        while True:
            add_acc = input("Would you like to add a new account? (y/n): ").strip().lower()
            if add_acc == 'y':
                print(f"Available providers: {', '.join(providers)}")
                prov = input("Enter provider: ").strip()
                if prov not in providers:
                    print("Invalid provider. Skipping.")
                    continue
                nick = input("Enter account nickname: ").strip()
                if not nick:
                    continue
                email = input("Enter email (optional): ").strip()
                auth = input("Enter auth type (optional): ").strip()
                account_add_cmd(prov, nick, email, auth, "")
            else:
                break
    else:
        print("\nSkipping account setup because no providers exist.")

    # 3. Create global symlink
    bin_dir = os.path.expanduser("~/.local/bin")
    if not os.path.exists(bin_dir):
        os.makedirs(bin_dir)
        print(f"Created directory: {bin_dir}")
        
    symlink_path = os.path.join(bin_dir, 'ai')
    target_script = os.path.join(CONFIG_DIR, 'scripts', 'ai.py')
    
    # Ensure script is executable
    os.chmod(target_script, 0o755)
    
    try:
        if os.path.exists(symlink_path) or os.path.islink(symlink_path):
            os.remove(symlink_path)
        os.symlink(target_script, symlink_path)
        print(f"Created global symlink: {symlink_path} -> {target_script}")
        print("Setup complete! You can now use the `ai` command from anywhere.")
    except Exception as e:
        print(f"Failed to create symlink: {e}")

def help_cmd():
    help_text = """
=== AI Workbench CLI Help ===

[Intelligence Engine]
  ai ask <prompt>           : Send a prompt to the AI. Automatically merges memory.md and tasks.md.
    --account <nickname>    : (Optional) Specify which account to route the request through.

[Core Commands]
  ai setup                  : Run initial workbench setup and install to PATH (~/.local/bin/ai).
  ai status                 : Show workbench status, current session, and last updated time.
  ai memory                 : Display the contents of your permanent memory.md file.
  ai tasks                  : Display the contents of your active tasks.md file.
  ai logs                   : Display the build log (ai_workbench_build_log.md).

[Account & Provider Management]
  ai providers              : List all registered AI providers (e.g. OpenAI, ollama, agy, aider).
  ai accounts               : List all configured accounts and their details.
  
  ai provider add <name>    : Register a new provider type.
  ai provider remove <name> : Remove a provider type.
  
  ai account add <provider> <nickname> : Create a new account configuration.
    --email <email>         : (Optional) Email associated with account.
    --auth <type>           : (Optional) Auth type (e.g., 'API Key', 'Local').
    --notes <notes>         : (Optional) Extra info (e.g., 'qwen3:8b' for Ollama models).
  
  ai account remove <nick>  : Remove an account by its nickname.

[Session Management]
  ai session start <name>   : Start tracking a new work session.
  ai session stop           : Stop the current work session.
  ai resume                 : Resume the most recent session.
  
  ai help                   : Show this exhaustive help menu.
"""
    print(help_text.strip())

def ask_cmd(prompt, account):
    engine.ask_engine(prompt, account)

def main():
    parser = argparse.ArgumentParser(description="ai-workbench command line interface")
    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")

    subparsers.add_parser("setup", help="Run initial workbench setup and install to PATH")
    subparsers.add_parser("status", help="Show workbench status")
    subparsers.add_parser("memory", help="Show memory file")
    subparsers.add_parser("tasks", help="Show tasks file")
    subparsers.add_parser("logs", help="Show build log")
    subparsers.add_parser("providers", help="Show providers")
    subparsers.add_parser("accounts", help="Show accounts")
    
    # Provider Subparser
    provider_parser = subparsers.add_parser("provider", help="Manage providers")
    provider_subparsers = provider_parser.add_subparsers(dest="provider_command")
    
    p_add = provider_subparsers.add_parser("add", help="Add a provider")
    p_add.add_argument("name", help="Provider name")
    
    p_rm = provider_subparsers.add_parser("remove", help="Remove a provider")
    p_rm.add_argument("name", help="Provider name")

    # Account Subparser
    account_parser = subparsers.add_parser("account", help="Manage accounts")
    account_subparsers = account_parser.add_subparsers(dest="account_command")
    
    a_add = account_subparsers.add_parser("add", help="Add an account")
    a_add.add_argument("provider", help="Provider name")
    a_add.add_argument("nickname", help="Account nickname")
    a_add.add_argument("--email", default="", help="Account email")
    a_add.add_argument("--auth", default="", help="Auth type")
    a_add.add_argument("--notes", default="", help="Notes")
    
    a_rm = account_subparsers.add_parser("remove", help="Remove an account")
    a_rm.add_argument("nickname", help="Account nickname")
    
    session_parser = subparsers.add_parser("session", help="Manage sessions")
    session_subparsers = session_parser.add_subparsers(dest="session_command")
    
    start_parser = session_subparsers.add_parser("start", help="Start a new session")
    start_parser.add_argument("name", help="Session name")
    
    session_subparsers.add_parser("stop", help="Stop current session")
    
    subparsers.add_parser("resume", help="Resume current session")
    subparsers.add_parser("help", help="Show exhaustive help menu")

    ask_parser = subparsers.add_parser("ask", help="Ask the AI a question")
    ask_parser.add_argument("prompt", nargs="+", help="The prompt to send")
    ask_parser.add_argument("--account", help="The account nickname to use")

    args = parser.parse_args()

    if args.command == "setup":
        setup_cmd()
    elif args.command == "status":
        status_cmd()
    elif args.command == "memory":
        memory_cmd()
    elif args.command == "tasks":
        tasks_cmd()
    elif args.command == "logs":
        logs_cmd()
    elif args.command == "providers":
        providers_cmd()
    elif args.command == "accounts":
        accounts_cmd()
    elif args.command == "provider":
        if args.provider_command == "add":
            provider_add_cmd(args.name)
        elif args.provider_command == "remove":
            provider_remove_cmd(args.name)
        else:
            provider_parser.print_help()
    elif args.command == "account":
        if args.account_command == "add":
            account_add_cmd(args.provider, args.nickname, args.email, args.auth, args.notes)
        elif args.account_command == "remove":
            account_remove_cmd(args.nickname)
        else:
            account_parser.print_help()
    elif args.command == "session":
        if args.session_command == "start":
            session_start_cmd(args.name)
        elif args.session_command == "stop":
            session_stop_cmd()
        else:
            session_parser.print_help()
    elif args.command == "resume":
        resume_cmd()
    elif args.command == "ask":
        ask_cmd(args.prompt, args.account)
    elif args.command == "help" or args.command is None:
        help_cmd()
    else:
        print(f"Command '{args.command}' is not yet fully implemented.")


if __name__ == "__main__":
    main()
