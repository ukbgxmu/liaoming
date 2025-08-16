setwd("/Users/maoyan/Library/CloudStorage/SynologyDrive-ukbA/data/liaoming")
library(readr)
a<-read_tsv("meta_analysis_ukbb_R11_UKBB_N.tsv")
colnames(a)
head(a)

a$case<-a$fg_n_cases+a$ukbb_n_cases; a$control<-a$fg_n_controls+a$ukbb_n_controls

library(UpSetR)
library(dplyr)
# Filter rows where a$case > 10000
filtered_a <- a %>% filter(case > 10000)

# Summarize and sort data
a_summary <- filtered_a %>%
    group_by(category) %>%
    arrange(desc(case), .by_group = TRUE) %>%
    summarise(names = list(name), case = sum(case))

# Create a binary matrix for UpSetR
binary_matrix <- table(filtered_a$name, filtered_a$category)
binary_matrix <- as.data.frame.matrix(binary_matrix)

# Modify binary matrix to include categories
binary_matrix <- binary_matrix %>%
    mutate(category = rownames(binary_matrix)) %>%
    relocate(category)


    # Find the endpoint with the maximum cases for each category
    max_case_endpoints <- filtered_a %>%
        group_by(category) %>%
        slice_max(order_by = case, n = 1) %>%
        select(category, endpoint, case)

    max_case_endpoints