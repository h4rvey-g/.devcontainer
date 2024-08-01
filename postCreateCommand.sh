pip install ipykernel ipywidgets

if [ -f requirements.txt* ]; then
    pip install -r requirements.txt
else pip install pandas numpy matplotlib seaborn scikit-learn; fi
# fix permission issue
sudo chmod 777 /usr/local/lib/R/site-library/_cache/
# enable vscode R support
echo 'if (interactive() && Sys.getenv("RSTUDIO") == "") {
  source(file.path(Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"), ".vscode-R", "init.R"))
}' >>~/.Rprofile
# add library(tidyverse) and library(qs) to .Rprofile
echo 'library(tidyverse)
library(qs)' >>~/.Rprofile
# add github hosts
curl https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts | sudo tee -a /etc/hosts
