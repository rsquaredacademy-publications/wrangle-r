# Data Wrangling with R

*R for Data Science teaches the whole game. Data Wrangling with R drills the hardest 20%: joins, grouped summaries, messy strings, datetimes, and factors — on realistic web analytics, ecommerce and business datasets.*

Read the live book: https://wrangle-r.rsquaredacademy.com

## How this differs from R4DS

R4DS surveys the whole data-science workflow; this book drills data preparation
end to end (flat-file/Excel/SPSS/SAS import, dplyr verbs and joins, pipes,
tibbles, strings, datetimes, factors) on realistic web analytics, ecommerce and
business datasets. Use it as a companion drill book after or alongside R4DS.

## Build

Requires R >= 4.1 (native pipe `|>`) and dplyr >= 1.1.0 (`.by`, `slice_*()`),
plus Quarto >= 1.6. Pinned package versions live in `renv.lock`:

```r
renv::restore()             # install pinned package versions
```

```sh
quarto render                # build the book into docs/
Rscript scripts/webr-smoke.R # static check of live {webr-r} cells (<30s)
```

## License

[![CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
