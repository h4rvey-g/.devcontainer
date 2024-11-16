FROM quay.io/jupyter/r-notebook:latest

USER root
# add ${NB_UID} to NOPASSWD sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/added-by-start-script
RUN apt-get update && apt-get install -y build-essential

USER ${NB_USER}
RUN pip install --no-cache-dir radian && \
    Rscript -e 'install.packages("pak", repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")'

RUN mamba install --yes \
    bioconda::r-liger \
    conda-forge::r-seurat \
    conda-forge::r-qs \
    conda-forge::r-targets \
    conda-forge::r-crew \
    conda-forge::r-skimr \
    conda-forge::r-tidyseurat \
    bioconda::bioconductor-tidysummarizedexperiment \
    conda-forge::r-languageserver && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"