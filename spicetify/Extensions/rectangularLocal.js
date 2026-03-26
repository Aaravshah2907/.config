(function localRectFix() {
    // Function to apply or remove the rectangular styles
    function updateArtStyle() {
        const isLocal = Spicetify.Player.data.item.isLocal;
        const styleId = 'local-rect-override';
        let styleTag = document.getElementById(styleId);

        if (isLocal) {
            if (!styleTag) {
                styleTag = document.createElement('style');
                styleTag.id = styleId;
                // Force contain and auto aspect ratio ONLY for the FS canvas
                styleTag.innerHTML = `
                    #full-screen-canvas .cover-art-image {
                        object-fit: contain !important;
                        aspect-ratio: auto !important;
                        width: auto !important;
                        height: auto !important;
                        max-width: 80vw !important;
                        max-height: 80vh !important;
                    }
                    #full-screen-canvas .cover-art {
                        width: auto !important;
                        height: auto !important;
                    }
                `;
                document.head.appendChild(styleTag);
            }
        } else {
            if (styleTag) {
                styleTag.remove();
            }
        }
    }

    // Listen for song changes
    Spicetify.Player.addEventListener("songchange", updateArtStyle);
    
    // Initial check in case it's already playing
    updateArtStyle();
})();
