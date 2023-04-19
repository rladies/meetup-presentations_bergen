# DESCRIPTION: Re-creating the process of plot re-desing
# AUTHOR: Julia Romanowska
# DATE CREATED: 2023-04-17
# DATE LAST MODIFIED: 2023-04-19

# SETUP ----
library(tidyverse)
library(here)
library(ggrepel)

# READ DATA ----
data_about_AI_publications <- read_csv(
  here("2023-04-20_intro_vis_ggplot2",
       "DATA",
       "artificial-intelligence-training-computation.csv")
)
data_about_AI_publications

data_about_AI_publications_by_res <- read_csv(
  here("2023-04-20_intro_vis_ggplot2",
       "DATA",
       "artificial-intelligence-training-computation-by-researcher-affiliation.csv")
)
data_about_AI_publications_by_res

# EXPLORE A BIT ----
skimr::skim(data_about_AI_publications)
# all missing in 'Code' - delete that
data_about_AI_publications <- data_about_AI_publications %>%
  select(-Code) %>%
  left_join(
    data_about_AI_publications_by_res %>%
      select(-Code)
  )
data_about_AI_publications

janitor::tabyl(
  data_about_AI_publications,
  Domain,
  Researcher_affiliation
)

# there's a typo in one data point! VIsion -> Vision
data_about_AI_publications <- data_about_AI_publications %>%
  mutate(Domain = if_else(
    Domain == "VIsion",
    "Vision",
    Domain
  ))
janitor::tabyl(
  data_about_AI_publications,
  Domain,
  Researcher_affiliation
)

# we will have 'Training_computation_petaflop' on y-axis, so the NAs will be
#  removed anyway
data_about_AI_publications %>%
  filter(!is.na(Training_computation_petaflop)) %>%
  janitor::tabyl(
    Domain,
    Researcher_affiliation
  )

# PLOT ----
data_for_plotting <- data_about_AI_publications %>%
  filter(!is.na(Training_computation_petaflop))

## Plot 1 - show the data ----
empty_plot <- data_for_plotting %>%
  ggplot(
    aes(
      x = Day,
      y = Training_computation_petaflop
    )
  )
empty_plot

points_standard <- empty_plot +
  geom_point(
    aes(
      color = Domain
    )
  )
points_standard

min_y_petaflops <- min(data_for_plotting$Training_computation_petaflop)*0.1
max_y_petaflops <- max(data_for_plotting$Training_computation_petaflop)*10

points_log_scale <- points_standard +
  scale_y_continuous(
    trans = "log",
    labels = ~ sprintf("%1.1e", .x),
    expand = expansion(),
    limits = c(min_y_petaflops, max_y_petaflops)
  )
points_log_scale

points_log_scale_labeled <- points_log_scale +
  xlab("Publication date") +
  ylab("petaFLOP") +
  labs(
    title = "Development of AI"
  ) +
  theme_minimal()
points_log_scale_labeled

ggsave(
  filename = here("2023-04-20_intro_vis_ggplot2",
                  "FIGURES", "01_show_the_data.png"),
  plot = points_log_scale_labeled
)

## Plot 2 - break up information ----
points_log_scale_labeled +
  facet_grid(
    rows = vars(Researcher_affiliation)
  )

# more resembling original:
points_log_scale_labeled_facets <- points_log_scale_labeled +
  facet_grid(
    rows = vars(Researcher_affiliation),
    switch = "both"
  ) +
  theme(
    strip.placement = "outside",
    plot.title.position = "plot",
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.title = element_text(face = "bold")
  )
points_log_scale_labeled_facets

ggsave(
  filename = here("2023-04-20_intro_vis_ggplot2",
                  "FIGURES", "02_break_up_information.png"),
  plot = points_log_scale_labeled_facets,
  height = 10
)

## Plot 3 - design with grey ----
new_color_vals <- c(rep("grey70", 7), "orange")
names(new_color_vals) <- sort(unique(data_for_plotting$Domain))

gray_points <- points_log_scale_labeled_facets +
  scale_color_manual(
    values = new_color_vals
  )
gray_points

ggsave(
  filename = here("2023-04-20_intro_vis_ggplot2",
                  "FIGURES", "03_design_with_gray.png"),
  plot = gray_points,
  height = 10
)

## Plot 4 - declutter ----
decluttered <- gray_points +
    theme(
    strip.placement = "inside",
    strip.text.y.left = element_text(
      angle = 0,
      vjust = 0.9,
      hjust = 0.1,
      margin = margin(t = 0, r = -130, b = 0, l = 0, unit = "pt"),
      face = "bold"
    ),
    strip.clip = "off",
    strip.switch.pad.wrap = unit(0, units = "cm"),
    legend.position = c(1.1, 0.8),
    plot.margin = margin(t = 10, l = 10, r = 100, unit = "pt"),
    axis.line = element_line(
      linewidth = 0.1, colour = "black"
    )
  ) +
  geom_hline(
    yintercept = min_y_petaflops,
    color = "gray30",
    linewidth = 0.1
  )
decluttered

ggsave(
  filename = here("2023-04-20_intro_vis_ggplot2",
                  "FIGURES", "04_declutter.png"),
  plot = decluttered,
  height = 10
)

## Plot 5 - text + vis
y_axis_highlight <- 10e6

data_for_plotting_annotations <- data_for_plotting %>%
  mutate(
    year_label = if_else(
      (year == 2010 &
        Researcher_affiliation == "Academia" & Domain == "Vision") |
        (year == 2015 &
           Researcher_affiliation == "Industry" & Domain == "Vision"),
      year,
      NA_real_
    ),
    point_label = if_else(
      Training_computation_petaflop > 10e6 &
        Researcher_affiliation %in% c("Academia", "Industry") &
        Domain == "Vision",
      paste0(Entity, " (", year, ")"),
      NA_character_
    )
  ) %>%
  filter(!is.na(year_label) | !is.na(point_label))
data_for_plotting_annotations

decluttered +
  labs(
    title = "Recent years show industry leading in computation used to train
AI vision systems, although academia led the first push.",
    subtitle = "Computation is measured in total petaFLOP, which is 10^15 floating-point operations."
  ) +
  geom_text_repel(
    data = data_for_plotting_annotations,
    aes(
      x = Day,
      y = Training_computation_petaflop,
      label = point_label
    ),
    # box.padding = 0.5,
    max.overlaps = Inf, 
    #nudge_x = 1, direction = "y", hjust = "right",
    xlim = c(as.Date("2021-01-01"), NA),
    ylim = c(6.5e7, NA),
    color = "gray40"
  ) +
  coord_cartesian(clip = "off") +
  geom_hline(yintercept = 1e06, linewidth = 0.5, color = "gray") +
  geom_segment(
    data = tibble(
      xmin = c(as.Date("2010-01-01"), as.Date("2015-01-01")),
      xmax = c(as.Date("2010-01-01"), as.Date("2015-01-01")),
      ymin = min_y_petaflops,
      ymax = max_y_petaflops,
      Researcher_affiliation = c("Academia", "Industry")
    ),
    aes(x = xmin, xend = xmax, y = ymin, yend = ymax),
    color = "gray",
    inherit.aes = FALSE,
    linewidth = 0.5
  ) +
  geom_label(
    data = tibble(
      x = c(as.Date("2011-01-01"), as.Date("2016-01-01")),
      y = c(3e-9, 3e-6),
      label = c(
        "2010-15 shows a rush of
Academia-affiliated AI
vision training",
        "Industry shows a rush five years
later than the academia, but the
present computational power far
exceeds academic initiatives"
      ),
      Researcher_affiliation = c("Academia", "Industry")
    ),
    aes(x, y, label = label, hjust = 0),
    inherit.aes = FALSE,
    color = "gray40"
  ) +
  geom_text(
    data = tibble(
      x = c(as.Date("2011-01-01"), as.Date("2016-01-01")),
      y = 6.6e7,
      label = c("2010", "2015"),
      Researcher_affiliation = c("Academia", "Industry")
    ),
    aes(x, y, label = label, hjust = 1, vjust = -1),
    inherit.aes = FALSE,
    color = "gray40"
  ) +
  geom_text(
    data = tibble(
      x = rep(as.Date("2021-01-01"), 2),
      y = y_axis_highlight,
      label = "1 mill. petaFLOP",
      Researcher_affiliation = c("Academia", "Industry")
    ),
    aes(x, y, label = label, hjust = -0.5, vjust = 1),
    inherit.aes = FALSE,
    color = "gray40"
  ) +
  theme(
    legend.position = "none",
    plot.margin = margin(t = 10, l = 10, r = 100, unit = "pt"),
    panel.grid.minor.y = element_blank(),
    panel.spacing.y = unit(20, units = "pt")
  )

ggsave(
  filename = here("2023-04-20_intro_vis_ggplot2",
                  "FIGURES", "05_vis_and_text.png"),
  height = 10
)
