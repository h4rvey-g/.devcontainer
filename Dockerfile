FROM quay.io/jupyter/r-notebook:latest

USER root
# add ${NB_UID} to NOPASSWD sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/added-by-start-script
RUN apt-get update && apt-get install -y build-essential libsz2 libhdf5-dev gh libgmp-dev && \
    ln -s /usr/lib/x86_64-linux-gnu/libsz.* /opt/conda/lib/

USER ${NB_USER}
RUN pip install --no-cache-dir radian && \
    Rscript -e 'install.packages("pak", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")' && \
    mamba install --yes \
    bioconda::bioconductor-rhtslib && \
    # conda-forge::r-leidenalg && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
RUN Rscript -e 'pak::pkg_install(c("rliger", "Seurat", "qs", "targets", "crew", "skimr", "tidyseurat", "languageserver", "tidySummarizedExperiment"))'

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