# DESCRIPTION: Example of using {gt} and {gtsummary} to create pretty tables
#   that are automatically populated with correct numbers.
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-29
# DATE LAST MODIFIED:

# SETUP ----
library(medicaldata)
library(tidyverse)
library(gtsummary)

# READ DATA ----
data(indo_rct)

indo_rct <- as_tibble(indo_rct)
# check more information on the webpage:
#    https://higgi13425.github.io/medicaldata/reference/indo_rct.html
# or by executing `?indo_rct`

# CREATE TABLE ----
# we want to reproduce Table 1 in: https://www.nejm.org/doi/full/10.1056/NEJMoa1111103

# basic
selected_columns <- indo_rct %>%
  select(
    age, gender,
    sod, # this is 'Any' in 'Clinical suspicion of sphincter...'
    sodsom, # this is 'Documented on manometry'
    type, # this is type of sphincter of Oddi dysfunction
    pep,
    recpanc,
    difcan,
    precut,
    paninj,
    psphinc,
    acinar,
    bsphinc,
    amp,
    pdstent,
    train,
    rx
  )
basic_descr_table <- selected_columns %>%
  tbl_summary(
    by = "rx"
  )
basic_descr_table

# re-label the factors

# nicer
nicer_descr_table <- selected_columns %>%
  tbl_summary(
    by = "rx",
    label = list(
      age ~ "Age - yr",
      
    )
  )

# EXPORT ----
