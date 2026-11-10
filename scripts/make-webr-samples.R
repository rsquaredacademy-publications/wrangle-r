# scripts/make-webr-samples.R
# Build small in-browser datasets for {webr-r} live cells.
# Requires: readr, dplyr
# Inputs: remote web.csv / mock_strings.csv / transact.csv (rsquaredacademy/datasets)
# Outputs: data-webr/ecom_sample.csv, mockstrings_sample.csv, transact_sample.csv (each < 40 KB)

library(readr)
library(dplyr)

dir.create("data-webr", showWarnings = FALSE)

web <- read_csv("https://raw.githubusercontent.com/rsquaredacademy-publications/datasets/master/web.csv",
  col_types = cols_only(
    device = col_factor(levels = c("laptop", "tablet", "mobile")),
    referrer = col_factor(levels = c("bing", "direct", "social", "yahoo", "google")),
    purchase = col_logical(), n_pages = col_double(), n_visit = col_double(),
    duration = col_double(), order_value = col_double(), order_items = col_double()))

set.seed(42)
ecom_sample <- slice_sample(web, n = 400) # adjust n until file < 40 KB
write_csv(ecom_sample, "data-webr/ecom_sample.csv")
stopifnot(file.size("data-webr/ecom_sample.csv") < 40 * 1024)

mock <- read_csv("https://raw.githubusercontent.com/rsquaredacademy-publications/datasets/master/mock_strings.csv")
mock_sample <- mock |>
  select(id, email, imageurl, url) |> # columns used in Ch 9: email domains, image extensions, url protocol/file type
  slice_sample(n = 40) # ~830 bytes/row (long urls); keeps file < 40 KB with margin
write_csv(mock_sample, "data-webr/mockstrings_sample.csv")
stopifnot(file.size("data-webr/mockstrings_sample.csv") < 40 * 1024)

transact <- read_csv("https://raw.githubusercontent.com/rsquaredacademy-publications/datasets/master/transact.csv")
transact_sample <- transact |> slice_sample(n = 300)
write_csv(transact_sample, "data-webr/transact_sample.csv")
stopifnot(file.size("data-webr/transact_sample.csv") < 40 * 1024)

message("done: ", paste(list.files("data-webr", full.names = TRUE), collapse = ", "))
