#!/usr/bin/env python3
"""
ai-workbench CLI Entry Point
This script acts as the main router for the `ai` commands.
"""

import sys
import os

# Add the src directory to the path so we can import modules
script_path = os.path.realpath(__file__)
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(script_path), '..', 'src')))

from cli import main

if __name__ == "__main__":
    main()
