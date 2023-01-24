# DESCRIPTION: Adjust the datasets
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-01-23
# DATE LAST MODIFIED:

# SETUP ----
library(medicaldata)
library(tidyverse)
library(here)

# READ DATA ----
data(indo_rct)
indo_rct <- as_tibble(indo_rct)

skimr::skim(indo_rct)

data(abm)
abm <- as_tibble(abm)

skimr::skim(abm)

# MANIPULATE ----
## first - indo_rct ----
indo_rct_adj <- indo_rct %>%
  mutate(
    gender_female = if_else(
      gender == "1_female", TRUE, FALSE
    ),
    type = as.factor(if_else(
      type != "0_no SOD",
      as.character(type),
      NA_character_
    )),
    sod_any = if_else(
      sod == "1_yes", TRUE, FALSE
    ),
    sodsom_documented = if_else(
      sodsom == "1_yes", TRUE, FALSE
    ),
    across(
      c(pep, recpanc, difcan, precut, paninj, psphinc, acinar, bsphinc, amp,
        pdstent, train),
      ~ if_else(.x == "1_yes", TRUE, FALSE)
    )
  ) %>%
  select(-gender, -sod, -sodsom)
skimr::skim(indo_rct_adj)

## next - opt ----
abm %>% glimpse()

explanatory <- names(abm)[c(-1,-22)]
explanatory
dependent <- "abm"

all_glmuni_results <- finalfit::glmuni(abm, dependent, explanatory)
all_glmuni_results_tidy <- map(
  all_glmuni_results,
  ~ broom::tidy(.x, conf.int = TRUE, exp = TRUE)
) %>% 
  bind_rows() %>%
  filter(term != "(Intercept)")

all_glmuni_results_tidy

# SAVE DATA ----
write_delim(
  indo_rct_adj,
  here("2023-01-27_automagical_tables", "DATA", "indo_rct_adjusted.txt"),
  delim = "\t"
)
