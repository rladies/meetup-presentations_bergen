# DESCRIPTION: Example of using {gt} and {gtsummary} to create pretty tables
#   that are automatically populated with correct numbers.
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-29
# DATE LAST MODIFIED:

# SETUP ----
library(medicaldata)
library(tidyverse)
library(gtsummary)
library(gt)
library(here)

# READ DATA ----
indo_rct <- read_delim(
  here("2023-01-27_automagical_tables", "DATA", "indo_rct_adjusted.txt"),
  delim = "\t"
)
# check more information on the webpage:
#    https://higgi13425.github.io/medicaldata/reference/indo_rct.html
# or by executing `?indo_rct`

# CREATE TABLE ----
# we want to reproduce Table 1 in: https://www.nejm.org/doi/full/10.1056/NEJMoa1111103

# basic
selected_columns <- indo_rct %>%
  select(
    age, gender_female,
    sod_any, # this is 'Any' in 'Clinical suspicion of sphincter...'
    sodsom_documented, # this is 'Documented on manometry'
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

# nicer
nicer_descr_table <- selected_columns %>%
  tbl_summary(
    by = "rx",
    label = list(
      age ~ "Age - yr",
      gender_female ~ "Female sex",
      sod_any ~ "Any",
      sodsom_documented ~ "Documented on manometry",
      type ~ "Type",
      pep ~ "History of post-ERCP pancreatitis",
      recpanc ~ "History of recurrent pancreatitis",
      difcan ~ "Difficult cannulation (>8 attempts)",
      precut ~ "Precut sphincterotomy",
      paninj ~ "Pancreatography",
      psphinc ~ "Therapeutic pancreatic sphincterotomy",
      acinar ~ "Pancreatic acinarization",
      bsphinc ~ "Therapeutic biliary sphincterotomy",
      amp ~ "Ampullectomy",
      pdstent ~ "Placement of pancreatic stent",
      train ~ "Trainee involvement in ERCP"
    ),
    missing = "no",
    statistic = list(
      all_continuous() ~ "{mean} +/- {sd}"
    )
  )
nicer_descr_table

# change the header names:
show_header_names(nicer_descr_table)

nicer_descr_table <- nicer_descr_table %>%
  modify_header(
    stat_1 ~ "**Placebo,\n (N = {n})**",
    stat_2 ~ "**Indomethacin,\n (N = {n})**"
  ) %>%
  modify_caption(
    "**Table 1. Characteristics of the Patients at Baseline.**"
  )
nicer_descr_table

# adding rows grouping - switching to {gt} package
nicer_descr_table_gt <- nicer_descr_table %>%
  as_gt(
    rowname_col = "Characteristic"
  ) %>%
  tab_row_group(
    label = "Clinical suspicion of sphincter of Oddi dysfunction",
    rows = 3:8,
    id = "group1"
  )
nicer_descr_table_gt

# columns width
nicer_descr_table_gt %>%
  cols_width(
    starts_with("stat") ~ px(90)
  ) %>%
  text_transform(
    locations = cells_row_groups(groups = "group1"),
    fn = function(x){paste0("   ", x)}
  ) %>%
  fmt_markdown(columns = everything())

# EXPORT ----
