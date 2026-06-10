# CFDash

## Overview

CFDash is a lightweight command-line dashboard tool written in Python that provides quick insights into your system and personal data. It includes features such as rating histograms, recommendation generation, and tag management.

## Installation

```bash
# Navigate to the cfdash directory
cd ~/.config/cfdash

# (Optional) Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install required dependencies
pip install -r requirements.txt  # If a requirements file exists
```

## Usage

Run the main script to launch the dashboard:

```bash
python main.py
```

Additional commands are available via the helper scripts:
- `stats.py` – View statistical summaries.
- `tags.py` – Manage tags for your entries.
- `recommendations.py` – Generate recommendations based on your data.

## Contributing

Feel free to open issues or submit pull requests to improve CFDash.
