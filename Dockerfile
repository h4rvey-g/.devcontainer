ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Consolidate apt-get installs and cleanups
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    ed \
    gpg-agent \
    ca-certificates \
    htop \
    vim \
    parallel \
    # For R
    littler \
    r-base \
    r-base-dev \
    r-recommended \
    r-cran-docopt \
    # For hdf5r and other compiled packages
    build-essential \
    libsz2 \
    gh \
    libgmp-dev \
    libcurl4-openssl-dev \
    libhdf5-dev \
    libopenblas-dev \
    # For Quarto dependencies if any (e.g. libfontconfig1) - check Quarto docs if needed
    libfontconfig1 \
    && wget -q -O - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
    | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc  && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    add-apt-repository --yes "ppa:marutter/rrutter4.0" && \
    add-apt-repository --yes "ppa:edd/misc" && \
    echo "deb [trusted=yes] https://r2u.stat.illinois.edu/ubuntu noble main" | tee -a /etc/apt/sources.list.d/r2u.list && \
    # Locale setup
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 && \
    # R littler symlinks
    chmod a+ws "/usr/local/lib/R/site-library" && \
    ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r && \
    ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r && \
    ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r && \
    ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r && \
    ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r && \
    ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r && \
    # CRITICAL: Clean up apt caches and lists
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# add ${NB_UID} to NOPASSWD sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/added-by-start-script
# Ensure libhdf5-dev is installed if hdf5r needs to compile against system HDF5
# Already included in the consolidated apt-get install above.

USER ${NB_USER}

# Conda installations and cleanup
RUN conda install --yes \
    radian \
    'conda-forge::hdf5=1.14' \
    conda-forge::scanpy \
    conda-forge::leidenalg && \
    # CRITICAL: Conda cleanup
    conda clean --all -f -y && \
    # Remove user-level conda cache if any
    rm -rf /home/${NB_USER}/.cache/conda/* && \
    # General cache cleanup for the user
    rm -rf /home/${NB_USER}/.cache/*

# Diagnostic for HDF5, keep if useful for debugging, can remove later
RUN find /opt/conda/lib -name "libhdf5_hl*"

# R Package Installation and CRITICAL Cleanup
RUN Rscript -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$pkgType, R.Version()$os, R.Version()$arch))' && \
    # Ensure PATH includes /usr/bin for h5cc if needed during hdf5r configure
    # The --with-hdf5 configure arg for hdf5r might need adjustment based on where h5cc is.
    # If conda's hdf5 is preferred, you might need to point to conda's lib/include.
    # For system hdf5 (libhdf5-dev), /usr/bin/h5cc should be fine.
    PATH=/usr/bin:$PATH Rscript -e 'install.packages("hdf5r", configure.args="--with-hdf5=/usr/bin/h5cc")' && \
    Rscript -e ' \
    pak::pkg_install(c( \
    "tidyverse", \
    "Seurat", \
    "targets", \
    "crew", \
    "skimr", \
    "tidyseurat", \
    "languageserver", \
    "tidySummarizedExperiment", \
    "tidybulk", \
    "nx10/httpgd", \
    "gittargets", \
    "huayc09/SeuratExtend", \
    "harmony", \
    "DESeq2", \
    "scuttle", \
    "tidyplots", \
    "saezlab/liana", \
    "scDblFinder", \
    "foreach", \
    "SingleCellExperiment", \
    "BiocParallel", \
    "EnhancedVolcano", \
    "RColorBrewer", \
    "ggalign", \
    "scCustomize" \
    )); \
    remotes::install_cran("qs2", type = "source", configure.args = "--with-TBB --with-simd=AVX2"); \
    pak::pak_cleanup(force = TRUE) \
    '

RUN eval "$(curl https://get.x-cmd.com)"
RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-amd64.deb -O /tmp/quarto.deb && sudo dpkg -i /tmp/quarto.deb && rm /tmp/quarto.deb

