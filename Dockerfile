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
RUN apt-get update && apt-get install -y build-essential libsz2 gh libgmp-dev libcurl4-openssl-dev libhdf5-dev

USER ${NB_USER}
RUN conda install --yes \
    radian \
    'conda-forge::hdf5=1.14' \
    conda-forge::scanpy \
    conda-forge::leidenalg && \
    conda clean --all -f -y
# *** DIAGNOSTIC STEP - Add this to your Dockerfile ***
RUN find /opt/conda/lib -name "libhdf5_hl*"
RUN Rscript -e 'install.packages("pak", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")'
# RUN mkdir -p /usr/local/lib/R/etc && \
#     touch /usr/local/lib/R/etc/Renviron.site && \
#     echo 'R_LD_LIBRARY_PATH=/opt/conda/lib:$R_LD_LIBRARY_PATH' >> /usr/local/lib/R/etc/Renviron.site
RUN PATH=/usr/bin:$PATH Rscript -e 'install.packages("hdf5r", configure.args="--with-hdf5=/usr/bin/h5cc")'
RUN Rscript -e 'pak::pkg_install(c( \
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
    "samuel-marsh/scCustomize@release/3.0.0" \
    ))' && \
    Rscript -e 'remotes::install_cran("qs2", type = "source", configure.args = "--with-TBB --with-simd=AVX2")'
RUN eval "$(curl https://get.x-cmd.com)"
RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-amd64.deb -O /tmp/quarto.deb && sudo dpkg -i /tmp/quarto.deb && rm /tmp/quarto.deb
# RUN quarto install tinytex

