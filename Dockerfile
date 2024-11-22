ARG REGISTRY=quay.io
ARG OWNER=jupyter
ARG BASE_IMAGE=$REGISTRY/$OWNER/minimal-notebook
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    ed \
    gpg-agent \
    ca-certificates \
    htop \
    vim \
    parallel \
    && wget -q -O - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
    | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc  \
    && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    && add-apt-repository --yes "ppa:marutter/rrutter4.0" \
    && add-apt-repository --yes "ppa:edd/misc" \
    && echo "deb [trusted=yes] https://r2u.stat.illinois.edu/ubuntu noble main" | tee -a /etc/apt/sources.list.d/r2u.list
## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
## This was not needed before but we need it now
ENV DEBIAN_FRONTEND noninteractive

## Otherwise timedatectl will get called which leads to 'no systemd' inside Docker
ENV TZ UTC

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    littler \
    r-base \
    r-base-dev \
    r-recommended \
    r-cran-docopt \
    && chmod a+ws "/usr/local/lib/R/site-library" \
    && ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && ln -s /usr/lib/R/site-library/littler/examples/update.r /usr/local/bin/update.r \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/*

# add ${NB_UID} to NOPASSWD sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/added-by-start-script
RUN apt-get update && apt-get install -y build-essential libsz2 libhdf5-dev gh libgmp-dev

USER ${NB_USER}
RUN pip install --no-cache-dir radian && \
    Rscript -e 'install.packages("pak", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")'
RUN Rscript -e 'pak::pkg_install(c("tidyverse", "rliger", "Seurat", "qs", "targets", "crew", "skimr", "tidyseurat", "languageserver", "tidySummarizedExperiment", "httpgd", "gittargets", "huayc09/SeuratExtend", "harmony"))'

# RUN mamba install --yes \
#     bioconda::r-liger \
#     conda-forge::r-seurat \
#     conda-forge::r-qs \
#     conda-forge::r-targets \
#     conda-forge::r-crew \
#     conda-forge::r-skimr \
#     conda-forge::r-tidyseurat \
#     bioconda::bioconductor-tidysummarizedexperiment \
#     conda-forge::r-languageserver && \
#     mamba clean --all -f -y && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"