# .devcontainer

This is a devcontainer configuration for setting up a Data Science development environment with Python and R in Visual Studio Code.

## Main Features

### Base Environment
- Based on Jupyter minimal-notebook image
- Complete development environment for Python and R
- Pre-installed Quarto v1.6.39 documentation tool

### Python Environment
- Includes common data analysis packages:
  - scanpy
  - leidenalg
  - pandas, numpy, and other basic packages

### R Environment
- Full R development support, including radian terminal
- Pre-installed bioinformatics and data analysis packages:
  - tidyverse suite
  - Seurat and extensions
  - DESeq2
  - harmony
  - targets workflow tool
  - and other analysis packages

### Development Tool Configuration
- Git preset configuration
- R language server formatting settings
- lintr code checking configuration
- VSCode extensions and settings

### System Tools
- Basic development tools: vim, htop, parallel, etc.
- Complete build environment: build-essential
- GitHub CLI tools

## Usage Instructions

The container automatically configures all necessary environments, including:
- R package installation and configuration
- Development environment permissions
- VSCode integration setup

Runs as `jovyan` user by default, with sudo privileges for environment configuration.

The container executes postCreateCommand.sh for final configuration upon creation.