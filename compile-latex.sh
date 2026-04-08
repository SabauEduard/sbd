#!/bin/bash
# ============================================
# LaTeX Compilation Script for Project Document
# ============================================

echo "=========================================="
echo "Compiling LaTeX Document"
echo "=========================================="
echo ""

# Check if pdflatex is installed
if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex not found!"
    echo "Please install MacTeX: brew install --cask mactex"
    exit 1
fi

# Compile LaTeX document (run twice for TOC)
echo "First pass..."
pdflatex -interaction=nonstopmode proiect-sbd.tex

echo ""
echo "Second pass (for TOC and references)..."
pdflatex -interaction=nonstopmode proiect-sbd.tex

# Clean up auxiliary files
echo ""
echo "Cleaning up auxiliary files..."
rm -f proiect-sbd.aux proiect-sbd.log proiect-sbd.out proiect-sbd.toc

echo ""
echo "=========================================="
echo "Compilation complete!"
echo "=========================================="
echo ""
echo "Output file: proiect-sbd.pdf"
echo ""

# Open PDF if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Opening PDF..."
    open proiect-sbd.pdf
fi
