# Devcontainer for Data Science (Python & R)

This is a devcontainer configuration for setting up a comprehensive Data Science development environment with Python and R in Visual Studio Code.

## Main Features

### Base Environment
- **Image:** Based on the `quay.io/jupyter/minimal-notebook` image.
- **User:** Runs as the `jovyan` user with `sudo` NOPASSWD privileges.
- **OS:** Ubuntu with a full build environment (`build-essential`).
- **Locale:** Configured for `en_US.UTF-8`.

### Python Environment (via Conda)
- **Core Packages:** `scanpy`, `leidenalg`, `pyarrow`, `hdf5`.
- **Terminal:** `radian` is configured as the default R terminal for an enhanced console experience.

### R Environment
- **Installation:** A comprehensive set of R packages for bioinformatics and data analysis is pre-installed using `pak` for efficiency.
- **Key Packages:**
  - **Core:** `tidyverse`, `Seurat`, `DESeq2`, `harmony`
  - **Workflow:** `targets`, `gittargets`, `crew`
  - **Single-cell:** `tidyseurat`, `tidySummarizedExperiment`, `tidybulk`, `scuttle`, `scDblFinder`, `SingleCellExperiment`, `sccomp`, `mojaveazure/seurat-disk`, `scCustomize`, `cellgeni/schard`
  - **Utilities:** `skimr`, `httpgd`, `languageserver`, `qs`, `cmdstanr`
  - **Plotting:** `EnhancedVolcano`, `RColorBrewer`, `ggalign`
  - **Community/Custom:** `huayc09/SeuratExtend`, `saezlab/liana`

### Development Tools
- **Quarto:** Pre-installed version `1.6.39` for scientific and technical publishing.
- **System Tools:** `htop`, `vim`, `parallel`, `gh` (GitHub CLI), `x-cmd`.
- **R Configuration (`.Rprofile` & `.lintr`):**
  - **VSCode Integration:** R language server support is automatically configured.
  - **Default Packages:** `tidyverse`, `targets`, `skimr`, and `gittargets` are loaded by default.
  - **Formatting:** Custom `styler` settings are configured for the R language server.
  - **Linting:** A `.lintr` file is created to disable specific linters for a cleaner coding experience.
- **Git:** User name (`h4rvey-g`) and email are pre-configured globally.

### Host-Container Integration
- **SSH Access to Host:** An `initialize-host.sh` script runs on the host to create and authorize an SSH key (`~/.ssh/devcontainer_id_rsa`). This allows the container to securely connect back to the host via `ssh ${HOST_USER}@host.docker.internal`.
- **Docker Socket:** The Docker socket is mounted, enabling Docker-in-Docker capabilities.
- **SSH Key Mount:** The host's SSH key is mounted into the container at `/home/jovyan/.ssh/id_rsa`.

### VSCode Integration
- **Default Settings:** Pre-configured for Python (formatter, path) and R (terminal, path).
- **Extensions:** A curated list of extensions for Python, R, Jupyter, Docker, Git, and general productivity is automatically installed. See `devcontainer.json` for the full list.

## Usage Instructions
1.  **Open in Dev Container:** Open this repository in Visual Studio Code and use the "Reopen in Container" command.
2.  **Initialization:**
    - On the **host machine**, the `initialize-host.sh` script will run once to set up SSH keys.
    - After the container is created, the `postCreateCommand.sh` script runs inside the container to finalize the environment setup (configuring Git, R profiles, SSH permissions, etc.).
3.  **Start Coding:** The environment is ready for use. All tools and packages are pre-installed and configured.