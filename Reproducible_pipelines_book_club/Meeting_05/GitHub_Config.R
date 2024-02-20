
# How to easily get authentication with your GitHub account:

install.packages("devtools")
library(devtools)
usethis::use_git_config(
  user.name="Harry Potter",
  user.email="heyharry@example.com"
)
usethis::create_github_token()
gitcreds::gitcreds_set()
