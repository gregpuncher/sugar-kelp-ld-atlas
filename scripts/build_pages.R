#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(purrr)
})

clusters <- read_csv("data/clusters_metadata.csv", show_col_types = FALSE) %>%
  mutate(cluster_id = as.character(cluster_id))

dir.create("clusters", showWarnings = FALSE, recursive = TRUE)

write_cluster_page <- function(row) {
  out <- file.path("clusters", paste0("cluster_", row$cluster_id, ".qmd"))
  
  lines <- c(
    "---",
    paste0('title: "Cluster ', row$cluster_id, " (", row$scaffold, ": ", row$start_bp, "-", row$end_bp, ')"'),
    "---",
    "",
    "```{r echo=FALSE, message=FALSE, warning=FALSE}",
    "library(tidyverse)",
    "library(DT)",
    "",
    'meta <- readr::read_csv("../data/clusters_metadata.csv", show_col_types = FALSE) %>%',
    "  mutate(cluster_id = as.character(cluster_id)) %>%",
    paste0('  filter(cluster_id == "', row$cluster_id, '") %>%'),
    "  slice(1)",
    "",
    'ann <- readr::read_csv("../data/snp_annotations.csv", show_col_types = FALSE) %>%',
    "  mutate(cluster_id = as.character(cluster_id)) %>%",
    paste0('  filter(cluster_id == "', row$cluster_id, '")'),
    "",
    'pca_path     <- paste0("../", meta$pca_img)',
    'heatmap_path <- paste0("../", meta$heatmap_img)',
    'network_path <- paste0("../", meta$network_img)',
    "",
    "has_pca     <- file.exists(pca_path)",
    "has_heatmap <- file.exists(heatmap_path)",
    "has_network <- file.exists(network_path)",
    "```",
    "",
    "## Summary",
    "",
    "- Scaffold: `r meta$scaffold`",
    "- Region (bp): `r format(meta$start_bp, big.mark = ",")`–`r format(meta$end_bp, big.mark = ",")`",
    "- Windows: `r meta$min_win`–`r meta$max_win`",
    "- SNPs: `r meta$n_snps`",
    "",
    "## PCA",
    "",
    "```{r echo=FALSE}",
    "if (has_pca) {",
    "  knitr::include_graphics(pca_path)",
    "} else {",
    "  cat('*PCA image not found yet:* ', pca_path)",
    "}",
    "```",
    "",
    "## LD heatmap",
    "",
    "```{r echo=FALSE}",
    "if (has_heatmap) {",
    "  knitr::include_graphics(heatmap_path)",
    "} else {",
    "  cat('*LD heatmap not found yet:* ', heatmap_path)",
    "}",
    "```",
    "",
    "## LD network",
    "",
    "```{r echo=FALSE}",
    "if (has_network) {",
    "  knitr::include_graphics(network_path)",
    "} else {",
    "  cat('*LD network not found yet:* ', network_path)",
    "}",
    "```",
    "",
    "## SNP annotations",
    "",
    "```{r echo=FALSE}",
    "DT::datatable(",
    "  ann,",
    "  rownames = FALSE,",
    "  options = list(pageLength = 25, scrollX = TRUE)",
    ")",
    "```",
    ""
  )
  
  writeLines(lines, out)
}

walk(seq_len(nrow(clusters)), function(i) {
  write_cluster_page(clusters[i, ])
})

message("Done. Wrote ", nrow(clusters), " cluster pages to clusters/.")

