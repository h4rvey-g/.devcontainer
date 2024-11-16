# .devcontainer

This is a devcontainer configuration file for setting up a development environment for Data Science projects using Python and R in Visual Studio Code.

The container is named "Data Science (Python and R)" and is built using a Dockerfile located in the same directory as this devcontainer.json file.

Features:
- Adds R support with full VSCode integration, radian, and without the VSC debugger.
- Additional features for installing specific R packages and apt packages are commented out.

The container is configured to not shut down automatically when VS Code is closed.

A post-create command is specified to run a script after the container is created.

Customizations for VS Code:
- Python settings: Sets the default interpreter path, formatter, and enables format on type/save.
- Jupyter settings: Configures theme for Matplotlib plots and widget script sources.
- R settings: Configures radian as the R terminal and enables bracketed paste.

Extensions to be installed in the container:
- Jupyter
- Python
- R support
- GitHub Copilot and Copilot Chat
- Black formatter for Python
- Maximize Terminal

The container connects as the user "jovyan" by default.