#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
})

meta <- readr::read_csv("data/clusters_metadata.csv", show_col_types = FALSE) %>%
  mutate(cluster_id = as.character(cluster_id))

cols <- intersect(c("pca_img", "rda_img", "heatmap_img", "network_img"), names(meta))

missing <- meta %>%
  select(cluster_id, all_of(cols)) %>%
  pivot_longer(-cluster_id, names_to = "type", values_to = "path") %>%
  filter(!is.na(path), path != "") %>%
  mutate(exists = file.exists(path)) %>%
  filter(!exists)

if (nrow(missing) == 0) {
  message("All referenced asset files exist. ✅")
} else {
  message("Missing asset files (pages will show 'not found yet'):\n")
  print(missing, n = Inf)
  
  if (!interactive()) {
    quit(status = 1)
  }
}

