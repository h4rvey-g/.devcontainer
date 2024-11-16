FROM quay.io/jupyter/r-notebook:latest

USER root
# add ${NB_UID} to NOPASSWD sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/added-by-start-script \
    echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${NB_USER}