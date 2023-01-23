# DESCRIPTION: Example of using {flextable} to create pretty tables
#   that are automatically populated with correct numbers.
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-29
# DATE LAST MODIFIED:

# SETUP ----
library(medicaldata)
library(tidyverse)
library(finalfit)
library(flextable)
library(here)

# READ DATA ----
data(cath)

cath <- as_tibble(cath)

# ANALYSIS ----
# logistic regression:
explanatory <- c("age", "sex", "choleste", "cad_dur")
dependent <- "sigdz" #significant coronary heart disease
model_signif_coronary_dis <- colon_s %>%
  finalfit(dependent, explanatory)
model_signif_coronary_dis

# CREATE TABLE ----
model_signif_coronary_dis %>%
  flextable()
