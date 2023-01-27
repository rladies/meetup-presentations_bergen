# DESCRIPTION: Example of using {flextable} to create pretty tables
#   that are automatically populated with correct numbers.
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-23
# DATE LAST MODIFIED: 2023-01-24

# SETUP ----
library(medicaldata)
library(tidyverse)
library(finalfit)
library(flextable)
library(here)

# READ DATA ----
data(cath)

cath <- as_tibble(cath)
cath
# this is data about Cardiac Catheterization (check more online:
#   https://higgi13425.github.io/medicaldata/reference/cath.html or by
#   executing `?cath`)

# sometimes it's useful to set factors where we know these can help
cath <- cath %>%
  mutate(across(c(sex, sigdz, tvdlm), ~ factor(.x)))

skimr::skim(cath)

# ANALYSIS ----
# logistic regression:
explanatory <- c("age", "sex", "choleste", "cad_dur")
dependent <- "sigdz" #significant coronary heart disease
model_signif_coronary_dis <- cath %>%
  finalfit(dependent, explanatory)
model_signif_coronary_dis

# if you want more information about the fitted model, try:
# model_signif_coronary_dis <- cath %>%
#   finalfit(dependent, explanatory, metrics = TRUE)
# model_signif_coronary_dis
## NOTE: this gives you a list, where the first element is the table and
##       the second is text you may put in a footnote of a table

# CREATE TABLE ----
# basic table
results_cath_regression <- model_signif_coronary_dis %>%
  flextable()

results_cath_regression

# nicer table
nicer_results_cath_regression <- 
  results_cath_regression %>%
  set_header_labels(
    `Dependent: sigdz` = '',
    `0` = "no",
    `1` = "yes"
  ) %>%
  add_header_row(
    values = c("", "significant coronary artery disease:", "estimate (95% CI, p-value)"),
    colwidths = c(2, 2, 2)
  ) %>%
  bold(
    part = "header"
  ) %>%
  width(
    j = c(1, 5:6),
    width = 2
  ) %>%
  italic(
    j = 2
  )
  
nicer_results_cath_regression

# coloring of results?
nicer_results_cath_regression <- nicer_results_cath_regression %>%
  vline(
    j = c(1:2, 4),
    part = "body"
  ) %>%
  bg(
    part = "body",
    j = 6,
    i = c(1, 3, 4),
    bg = "grey80"
  ) %>%
  align(
    j = 5:6,
    align = "center",
    part = "header"
  )
nicer_results_cath_regression

# finally - maybe a nicer theme?
theme_zebra(nicer_results_cath_regression)

# EXPORT ----
save_as_docx(
  nicer_results_cath_regression,
  path = here("2023-01-27_automagical_tables", "RESULTS", "Table02_log_regr_cath.docx")
)

save_as_html(
  nicer_results_cath_regression,
  path = here("RESULTS", "Table02_log_regr_cath.html")
)
