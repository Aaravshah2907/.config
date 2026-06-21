import webview
import sys
import subprocess

class API:
    def __init__(self):
        self._window = None

    def close(self):
        if self._window:
            self._window.destroy()
        sys.exit(0)

    def execute(self, cmd_type, command):
        try:
            if cmd_type == "menubar":
                # Run AppleScript to click menu item
                parts = [p.strip() for p in command.split(">")]
                if not parts:
                    return
                n = len(parts)
                if n == 1:
                    script_body = f'click menu bar item "{parts[0]}" of menu bar 1'
                else:
                    script_body = f'click menu item "{parts[-1]}"'
                    for i in range(n - 2, 0, -1):
                        script_body += f' of menu "{parts[i]}" of menu item "{parts[i]}"'
                    script_body += f' of menu "{parts[0]}" of menu bar item "{parts[0]}" of menu bar 1'
                
                # Get the frontmost app name
                app_name_script = 'tell application "System Events" to return name of first application process whose frontmost is true'
                app_name = subprocess.check_output(["osascript", "-e", app_name_script], text=True).strip()
                
                applescript = f'''
                tell application "System Events"
                    tell process "{app_name}"
                        {script_body}
                    end tell
                end tell
                '''
                subprocess.Popen(["osascript", "-e", applescript])
            else:
                # Run shell command
                subprocess.Popen(command, shell=True)
            
            # Automatically close dashboard after executing a command
            self.close()
        except Exception as e:
            print(f"Execution failed: {e}")
            sys.exit(1)

html = open("/tmp/shortcut_hub.html").read()

api = API()
window = webview.create_window(
    "⌨️ Shortcut Hub",
    html=html,
    width=1200,
    height=800,
    js_api=api
)
api._window = window

webview.start()
