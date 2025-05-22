# if [ -f requirements.txt* ]; then
#   pip install -r requirements.txt
# else pip install pandas numpy matplotlib seaborn scikit-learn; fi
# fix permission issue
sudo chmod 777 /usr/local/lib/R/site-library/_cache/
# enable vscode R support
echo 'if (interactive() && Sys.getenv("RSTUDIO") == "") {
  source(file.path(Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"), ".vscode-R", "init.R"))
}' >>~/.Rprofile
# add github hosts
# sudo sh -c 'curl https://hosts.gitcdn.top/hosts.txt >> /etc/hosts'
# use pak to install "rliger,Seurat,qs,targets"
# add library(tidyverse) and library(qs) to .Rprofile
echo 'options(defaultPackages=c(getOption("defaultPackages"), "tidyverse", "targets", "skimr", "gittargets"))' >>~/.Rprofile
echo 'options(languageserver.formatting_style = function(options) {
    style <- styler::tidyverse_style(indent_by = options$tabSize)
    style$token$force_assignment_op <- NULL
    style
})' >>~/.Rprofile
touch ~/.lintr
echo 'linters: linters_with_defaults(
  line_length_linter    = NULL, # note: vscode-R default is 120
  cyclocomp_linter      = NULL, # same as vscode-R
  object_name_linter    = NULL, # same as vscode-R
  object_usage_linter   = NULL, # same as vscode-R
  commented_code_linter = NULL,
  assignment_linter     = NULL,
  single_quotes_linter  = NULL,
  semicolon_linter      = NULL,
  seq_linter            = NULL,
  indentation_linter    = NULL
)' >>~/.lintr
# set git user name "h4rvey-g" and email "babaolanqiu@gmail.com"
git config --global user.name "h4rvey-g"
git config --global user.email "babaolanqiu@gmail.com"
export PATH=~/bin:$PATH
