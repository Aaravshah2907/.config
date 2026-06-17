import webview

html=open("/tmp/shortcut_hub.html").read()

window=webview.create_window(
    "⌨️ Shortcut Hub",
    html=html,
    width=1200,
    height=800
)

webview.start()
