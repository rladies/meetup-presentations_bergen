# DESCRIPTION: Example of using {gt} and {gtsummary} to create pretty tables
#   that are automatically populated with correct numbers.
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-23
# DATE LAST MODIFIED: 2023-01-24

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
    rowname_col = "label"
  ) %>%
  tab_row_group(
    label = "Clinical suspicion of sphincter of Oddi dysfunction",
    rows = 3:8,
    id = "group1"
  ) %>%
  tab_stubhead(
    label = md("**Characteristic**")
  )
nicer_descr_table_gt

nicer_descr_table_gt 


# columns width
final_descr_table <- nicer_descr_table_gt %>%
  cols_width(
    starts_with("stat") ~ px(90)
  ) %>%
  tab_stub_indent(
    rows = 3:8,
    indent = 3
  ) %>%
  tab_stub_indent(
    rows = 6:8,
    indent = 5
  ) %>%
  fmt_markdown(columns = everything())
final_descr_table

# EXTRAS ----
# if you want, you can play around with {gtExtras} package - adding colors, 
#   icons, etc., or applying whole themes to your gt table:
#   https://jthomasmock.github.io/gtExtras/reference/index.html#themes

# EXPORT ----
# simple - just use a needed file extension to specify type of output!
gtsave(
  final_descr_table,
  file = here("RESULTS", "Table01_description.html")
)

gtsave(
  final_descr_table,
  file = here("RESULTS", "Table01_description.docx")
)

gtsave(
  final_descr_table,
  file = here("RESULTS", "Table01_description.tex")
)


