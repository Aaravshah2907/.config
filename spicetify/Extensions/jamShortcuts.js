(function jam() {
    async function init() {
        if (!Spicetify.Keyboard || !Spicetify.Platform || !Spicetify.Player) {
            setTimeout(init, 500);
            return;
        }
        Spicetify.Keyboard.registerShortcut(
            { key: Spicetify.Keyboard.KEYS.J, ctrl: false, shift: true, alt: false, meta: true },
            () => { startOrCopyJam(); }
        );
    }

    async function startOrCopyJam() {
        // 1. Open the Devices menu
        const connectBtn = document.querySelector('button[aria-label="Connect to a device"]') || 
                           document.querySelector('[data-testid="control-button-connect-device"]');
        
        if (connectBtn) connectBtn.click();

        // 2. Wait for the Devices menu to load
        setTimeout(() => {
            const allElements = Array.from(document.querySelectorAll('button, a, span'));

            // A. Check for "Start a Jam" button
            const startJamBtn = allButtons().find(btn => btn.innerText.trim() === "Start a Jam");
            if (startJamBtn) {
                startJamBtn.click();
                Spicetify.showNotification("Starting a New Jam...");
                return;
            }

            // B. Look for a link/element with the word 'Jam'
            const jamLink = allElements.find(el => el.innerText.includes("Jam"));
            if (jamLink) {
                jamLink.click();
                
                // C. Wait for the Jam panel to open, then search for 'Copy link' button
                setTimeout(() => {
                    const copyLinkBtn = allButtons().find(btn => 
                        btn.innerText.trim().toLowerCase() === "copy link" || 
                        btn.textContent.trim().toLowerCase() === "copy link"
                    );

                    if (copyLinkBtn) {
                        copyLinkBtn.click();
                        Spicetify.showNotification("Jam Link Copied!");
                        // Close devices menu if it's still open
                        if (connectBtn) connectBtn.click(); 
                    } else {
                        Spicetify.showNotification("Found Jam, but 'Copy link' button not visible.");
                    }
                }, 800);
            }
        }, 600);
    }

    function allButtons() {
        return Array.from(document.querySelectorAll('button'));
    }

    init();
})();