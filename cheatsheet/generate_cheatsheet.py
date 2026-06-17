#!/usr/bin/env python3

import os
from pathlib import Path

from translations import (
    categorise,
    prettify_keys,
    translate,
)

SKHD = Path.home() / ".config/skhd/skhdrc"

HTML = Path.home() / ".config/cheatsheet/template.html"

OUTPUT = Path("/tmp/shortcut_hub.html")


dashboard = {

    "🪟 Windows": [],

    "📦 Spaces": [],

    "🖥 Displays": [],

    "🚀 Launchers": [],

    "📌 Scratchpads": [],

    "⭐ System": [],

    "💻 Misc": [],

}


def parse_skhd():

    if not SKHD.exists():

        return


    with open(SKHD) as f:

        for line in f:

            line = line.strip()

            if not line:

                continue

            if line.startswith("#"):

                continue

            if ":" not in line:

                continue


            shortcut, command = line.split(":", 1)

            shortcut = shortcut.strip()

            command = command.strip()


            category = categorise(command)

            action = translate(command)

            keys = prettify_keys(shortcut)


            dashboard[category].append(

                (keys, action)

            )


def build_cards():

    cards = []


    for category, entries in dashboard.items():

        if not entries:

            continue


        items = []


        for key, action in entries:

            items.append(

                f"""

                <div class="item">

                    <span class="key">

                    {key}

                    </span>

                    <span>

                    {action}

                    </span>

                </div>

                """

            )


        card = f"""

        <div class="card">

        <h2>

        {category}

        </h2>

        {''.join(items)}

        </div>

        """


        cards.append(card)


    return "\n".join(cards)


def build_html():

    template = HTML.read_text()


    content = build_cards()


    final = template.replace(

        "{{CONTENT}}",

        content

    )


    OUTPUT.write_text(final)


def main():
    parse_skhd()
    build_html()


if __name__ == "__main__":
    main()
