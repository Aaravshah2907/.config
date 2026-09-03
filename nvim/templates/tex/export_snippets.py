#!/usr/bin/env python3
"""
LaTeX Snippet Exporter & CPKB Exporter Utility
Exports UI/Note LaTeX snippets and documents into JSON format matching the CPKB export format schema.
"""

import json
import argparse
import sys
import os
from pathlib import Path
from datetime import datetime, timezone

LATEX_SNIPPETS = [
    {
        "id": "LATEX-000001",
        "title": "tcolorbox Info Box Callout",
        "description": "A sleek modern info box callout with custom header and colored border.",
        "use_case": "Highlighting key formulas, executive summaries, or crucial notes in AI summaries.",
        "tags": "latex, ui, callout, box, notes",
        "code": """\\begin{tcolorbox}[
  enhanced,
  colback=slate!5!white,
  colframe=royalblue,
  boxrule=0.8pt,
  arc=3pt,
  left=10pt,right=10pt,top=8pt,bottom=8pt,
  title=\\textbf{Note Title},
  coltitle=white,
  attach boxed title to top left={yshift=-2mm, xshift=4mm},
  boxed title style={colback=royalblue, arc=2pt, boxrule=0pt}
]
Your summary content or key information goes here.
\\end{tcolorbox}"""
    },
    {
        "id": "LATEX-000002",
        "title": "tcolorbox Warning Alert Box",
        "description": "An urgent alert/warning box styled with soft red background.",
        "use_case": "Displaying warnings, common pitfalls, or critical pre-requisites.",
        "tags": "latex, ui, alert, warning, box",
        "code": """\\begin{tcolorbox}[
  enhanced,
  colback=red!5!white,
  colframe=red!75!black,
  boxrule=0.8pt,
  arc=3pt,
  title=\\textbf{Warning: Critical Constraint},
  coltitle=white,
  attach boxed title to top left={yshift=-2mm, xshift=4mm},
  boxed title style={colback=red!75!black, arc=2pt, boxrule=0pt}
]
Important warning message regarding edge cases or system limits.
\\end{tcolorbox}"""
    },
    {
        "id": "LATEX-000003",
        "title": "Fancyhdr Header & Footer Setup",
        "description": "Configures modern running headers and footers with custom rules and page counts.",
        "use_case": "Adding professional page numbering and document titles to PDF notes.",
        "tags": "latex, ui, header, footer, pagination",
        "code": """\\usepackage{fancyhdr}
\\pagestyle{fancy}
\\fancyhf{}
\\rhead{\\textcolor{primary}{\\small \\textbf{Document Title}}}
\\lhead{\\textcolor{darkslate}{\\small \\leftmark}}
\\rfoot{\\textcolor{darkslate}{\\small Page \\thepage\\ of \\pageref{LastPage}}}
\\renewcommand{\\headrulewidth}{0.5pt}
\\renewcommand{\\footrulewidth}{0.5pt}"""
    },
    {
        "id": "LATEX-000004",
        "title": "Professional Booktabs Table",
        "description": "Clean, publication-quality table format avoiding ugly vertical rules.",
        "use_case": "Tabulating benchmarks, experimental results, or metric comparisons.",
        "tags": "latex, table, formatting, booktabs",
        "code": """\\begin{table}[h]
\\centering
\\caption{Comparative Performance Metrics}
\\label{tab:metrics}
\\begin{tabular}{@{}lrr@{}}
\\toprule
\\textbf{Algorithm} & \\textbf{Time (ms)} & \\textbf{Memory (MB)} \\\\
\\midrule
Baseline           & 124.5               & 48.2                  \\\\
Optimized          & 18.2                & 12.1                  \\\\
\\bottomrule
\\end{tabular}
\\end{table}"""
    },
    {
        "id": "LATEX-000005",
        "title": "Minted / Listings Code Box",
        "description": "Custom tcolorbox container for code snippets with language headers.",
        "use_case": "Presenting code listings cleanly inside LaTeX PDFs.",
        "tags": "latex, code, syntax, listing, box",
        "code": """\\begin{tcolorbox}[
  colback=black!85!white,
  colframe=black!90!white,
  arc=3pt,
  title=\\small\\textbf{Python Pseudocode},
  coltitle=green!40!white
]
\\begin{verbatim}
def compute_fibonacci(n: int) -> int:
    if n <= 1:
        return n
    return compute_fibonacci(n - 1) + compute_fibonacci(n - 2)
\\end{verbatim}
\\end{tcolorbox}"""
    },
    {
        "id": "LATEX-000006",
        "title": "Beamer Side-by-Side Comparison Columns",
        "description": "Two-column frame layout for Beamer presentation slides.",
        "use_case": "Comparing two options or displaying diagram alongside description.",
        "tags": "latex, beamer, presentation, columns, slides",
        "code": """\\begin{frame}{Comparison of Approaches}
  \\begin{columns}[T]
    \\begin{column}{0.48\\textwidth}
      \\begin{block}{Traditional Method}
        \\begin{itemize}
          \\item Higher complexity
          \\item Sequential processing
        \\end{itemize}
      \\end{block}
    \\end{column}
    
    \\begin{column}{0.48\\textwidth}
      \\begin{alertblock}{Modern Pipeline}
        \\begin{itemize}
          \\item Zero-copy allocations
          \\item Parallel execution
        \\end{itemize}
      \\end{alertblock}
    \\end{column}
  \\end{columns}
\\end{frame}"""
    },
    {
        "id": "LATEX-000007",
        "title": "Custom Color Palette Definition",
        "description": "Defines hex color palette (Slate, Royal Blue, Teal, Amber).",
        "use_case": "Standardizing visual colors across all document components.",
        "tags": "latex, ui, colors, palette, design",
        "code": """\\usepackage[table]{xcolor}
\\definecolor{royalblue}{HTML}{003366}
\\definecolor{tealaccent}{HTML}{008080}
\\definecolor{darkslate}{HTML}{1E293B}
\\definecolor{amberalert}{HTML}{D97706}
\\definecolor{lightbg}{HTML}{F8FAFC}"""
    },
    {
        "id": "LATEX-000008",
        "title": "Hyperref Clickable PDF Setup",
        "description": "Configures hyperref for colored PDF links and PDF metadata.",
        "use_case": "Making section links and URLs interactive in compiled PDFs.",
        "tags": "latex, pdf, hyperref, links",
        "code": """\\usepackage{hyperref}
\\hypersetup{
    colorlinks=true,
    linkcolor=royalblue,
    citecolor=tealaccent,
    urlcolor=royalblue,
    pdftitle={Technical Synthesis Document},
    pdfauthor={Aarav Shah}
}"""
    }
]

def export_snippets_to_json(output_path: str = None) -> str:
    """Export LaTeX snippets formatted identically to CPKB JSON exports."""
    now_iso = datetime.now(timezone.utc).isoformat()
    data = []
    for s in LATEX_SNIPPETS:
        item = {
            "id": s["id"],
            "title": s["title"],
            "description": s["description"],
            "use_case": s["use_case"],
            "tags": s["tags"],
            "code": s["code"],
            "created_at": now_iso,
            "updated_at": now_iso
        }
        data.append(item)

    if not output_path:
        out_dir = Path.home() / ".local" / "share" / "cpkb" / "exports"
        out_dir.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        output_path = out_dir / f"latex_snippets_{timestamp}.json"
    else:
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

    return str(output_path)

def main():
    parser = argparse.ArgumentParser(description="Export LaTeX UI & Note Snippets to CPKB-compatible JSON format.")
    parser.add_argument("-o", "--output", help="Custom output JSON file path")
    parser.add_argument("--import-to-cpkb", action="store_true", help="Automatically import exported snippets into CPKB database")
    args = parser.parse_args()

    out_file = export_snippets_to_json(args.output)
    print(f"✅ Exported {len(LATEX_SNIPPETS)} LaTeX snippets to JSON: {out_file}")

    if getattr(args, "import_to_cpkb", False) or "--import-to-cpkb" in sys.argv:
        print("Importing snippets into CPKB database...")
        os.system(f"cpkb import {out_file} --format json")

if __name__ == "__main__":
    main()
