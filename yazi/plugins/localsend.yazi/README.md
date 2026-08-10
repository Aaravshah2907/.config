# localsend.yazi

A Yazi plugin for sending files over the local network using [localsend-go](https://github.com/meowrain/localsend-go) - the CLI version of [LocalSend](https://localsend.org).

**Arch Linux:** `yay -S localsend-go-bin`

https://github.com/user-attachments/assets/dc87081e-fc32-4bb9-945f-06c62b2c0854

## Installation

**Via ya pkg:**
```bash
ya pkg add pakhromov/localsend
```

**Manual:**
```bash
git clone https://github.com/pakhromov/localsend.yazi ~/.config/yazi/plugins/localsend.yazi
```

Add the following to `~/.config/yazi/keymap.toml`:
```toml
[[mgr.prepend_keymap]]
on = "<C-l>"
run = "plugin localsend"
desc = "Send via LocalSend"
```

## Usage

Pressing `Ctrl+L` sends either the current selection of files/folders, or the currently hovered file/folder if no selection is made.

> [!NOTE]
> LocalSend cannot send multiple individual files directly - it can only send a whole directory. If multiple files are selected, the plugin creates a temporary directory in `/tmp`, copies the selection into it, and sends that directory. If you want to send several large files, put them all in one folder and send it directly instead of selecting files individually.
