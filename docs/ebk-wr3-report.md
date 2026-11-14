# Fix round report: Data Wrangling with R (ebk-wr3)

Branch `task/wr-style-1114`, fixing the findings in `F:/pm/notes/2026-11-14-pkgs/ebk-wr-audit.md`
against the combined wr1+wr2 head `ffcf40b`. Local commits only; no push, branch switch or other
worktree was touched. The audit file is left uncommitted at `docs/ebk-wr-audit.md`.

Environment: R 4.6.1 (readr 2.2.0, dplyr 1.2.1, tibble 3.3.1, stringr 1.6.0, lubridate 1.9.5,
forcats 1.0.1), Quarto 1.6.39. R probes ran with `Rscript --vanilla` from
`C:/Users/DELL/AppData/Local/Temp/ebk-wr3`, outside any renv project, with
`RENV_CONFIG_AUTOLOADER_ENABLED=false` for renders. Renders ran in a throwaway
`git archive HEAD` copy through `bash ~/.claude/bin/heavy-slot.sh ebk-wr3`.

## H1 - data source/worked example mismatch

**`01-import-1.qmd:140`, `:150`** (explanation `:143-149`).

- Before: both `skip_1` and `skip` read
  `https://raw.githubusercontent.com/rsquaredacademy-publications/datasets/master/hsb4.csv`.
  The remote file has a 25-line preamble, so `skip = 3` produced **222 x 11** character columns
  named `...1`-`...11`, with metadata in the records.
- After: both chunks read
  `https://raw.githubusercontent.com/rsquaredacademy-publications/wrangle-r/master/hsb4.csv`,
  which has exactly the three documented comment lines before its header.

Real output of the `skip = 3` chunk:

```text
Rows: 200 Columns: 11
Delimiter: ","
dbl (11): id, female, race, ses, schtyp, prog, read, write, math, science, s...

# A tibble: 200 × 11
      id female  race   ses schtyp  prog  read write  math science socst
   <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl> <dbl>
 1    70      0     4     1      1     1    57    52    41      47    57
 2   121      1     4     2      1     3    68    59    53      63    61
 3    86      0     4     3      1     1    44    33    54      58    31
# ℹ 190 more rows
```

The preceding no-skip chunk now gives `203 × 1`, the intended before picture for a file whose
first three lines are not data. The chapter HTML contains both `203 × 1` and `200 × 11`.
Unchanged prose says the first three lines contain information about the data set, which is true of
the new file. No chunk label or option changed.

## M1-M5 - requested correctness and scope fixes

### M1 - AOV examples averaged all visits

**`04-dplyr-1.qmd:319-327`, `:334`, `:349`.**

- Before: `select(ecom, referrer, order_value)` averaged every visit; bing was **316**.
- After: the text says AOV is per order and starts from the purchasers in `ecom1`; both `across()`
  examples use `select(ecom1, referrer, order_value)`.
- Evidence, same data and code from a neutral folder:

```text
# all visits (before)
1 bing            316.
2 direct          441.

# purchasers (after)
1 bing           1148.
2 direct         1701.
```

The mean/median version now returns purchaser-only values (bing 1148 / 764, direct 1701 / 1729,
and so on). Only the two `select()` inputs and the lead-in sentence changed.

### M2 - dead CrowdFlower links

**`04-dplyr-1.qmd:9`.**

- Before: `[survey](http://visit.crowdflower.com/...CrowdFlower_DataScienceReport_2016.pdf)` and
  `[CrowdFlower](https://www.crowdflower.com/)`; both returned **503**.
- After: `2016 [CrowdFlower survey](https://www.forbes.com/sites/gilpress/2016/03/23/data-preparation-most-time-consuming-least-enjoyable-data-science-task-survey-says/)
  reported by [Forbes](https://www.forbes.com/)`.
- Evidence: both new targets return **200** from `curl -L`; the claim is unchanged.

### M3 - unsupported syllabus promises

**`06-dplyr-3.qmd:10-16`.**

- Before: the bullet list promised "arrange rows", "compare tables" and
  "extract/mutate data using predicate functions".
- After: those three bullets are removed. The chapter has no such sections or examples; the
  remaining bullets match sections it does have.
- Evidence: source scan and the rendered chapter TOC.

### M4 - "how many" over a logical vector

**`06-dplyr-3.qmd:239-241`.**

- Before: "we check how many visits browsed between 5 and 15 pages", while the chunk returns a
  logical vector.
- After: "we check which visits browsed between 5 and 15 pages."
- Evidence: the chunk still returns 30 logical values (10 `TRUE` when summed) for an unseeded
  30-row sample; no code changed, and the prose now describes that output.

### M5 - "one realistic ecommerce dataset" scope claim

**`_quarto.yml:22`, `index.qmd:2`, `README.md:3`, `README.md:11`.**

- Before: "on one realistic ecommerce dataset" / "on a single ecommerce schema".
- After: "on realistic web analytics, ecommerce and business datasets" (README:11: "on realistic
  web analytics, ecommerce and business datasets").
- Evidence: the book uses web/ecom, customer/order, hsb, mock strings, transactions, receivables,
  HR, analytics and built-in data. The inherited promotional "drills the hardest 20%" wording was
  left alone; it is tone, not a false scope claim.

## M6 - protected inline code and the zero-edit claim

Restored exactly at `90425d8`:

- **`04-dplyr-1.qmd:243`**: "we group the selected data by device type" -> "we need to group the
  selected `order_value` by device type." The sentence is true in both forms, so the protected span
  is back.
- **`10-lubridate-parsing.qmd:200`**: "If you check its class" -> "If you check the class of
  `Sys.Date()`". The antecedent was correct, but the span is restored.
- **`10-lubridate-parsing.qmd:1208-1211`**: the deleted "i.e. the length of value supplied to
  `along.with` is also the length of the sequence" clause is back; it was a true repetition.

Kept, because the audit records them as real error fixes:

- **`06-dplyr-3.qmd`** (old `:187-192`): the deleted "I am using `head`..." sentence was false;
  neither the sample chunk nor the pull examples call `head`.
- **`09-stringr.qmd:504-512`**: the paragraph now uses the delimiter and pattern `://` and drops
  the claim that `:` must be escaped; the chunk splits on `://` without escaping, so the old text
  was wrong. The removal of three `:` spans and the `\\` span, and the two `://` insertions, remain.

Report correction, **`docs/ebk-wr2-report.md:8-10` and `:490-497`**:

- Before: "No ... inline code ... was edited" and "Inline-code spans ... **0 edited**".
- After: the report states that wr2 removed eight occurrences and inserted two `://` spans across
  four files, that ebk-wr3 restored three of those removals, that five removals and two insertions
  remain, and that the remaining wr2 changes were content corrections that exceeded the protected
  scope. It also records the four inline spans added by this round's prose corrections
  (`across()`, `ecom1`, `to`, `length.out`).
- Independent span comparison (`90425d8` vs working tree, outside fences): `04` 0 removed;
  `06` 1 removed (`head`); `09` 4 removed, 2 added; `10` 0 removed.

## Low items

- **L1 `13-forcats-manipulation.qmd:27`**: "and and on the [forcats]" -> "and on the [forcats]".
- **L2 `14-solutions.qmd:290`**: comma splice "(... *ordered*, see ...)" -> "(... *ordered*; see ...)".
- **L3 `07-tibbles.qmd:74`**: "`tibble()` never prints all the rows and clutters your console." ->
  "`tibble()` prints only the first rows of a large tibble, so it does not clutter your console."
  This also removes the absolute "never".
- **L4 `docs/ebk-wr2-report.md:17-38`, `:294`, `:379`, `:425`**: the summary column is now
  "Sentences", with a note that chapter tables list edit-group rows and do not sum to the sentence
  total. The three wrong captions now match their tables: Parsing 36 rows/28 other, Factors 32
  rows/2 other, forcats 32 rows/4 other. The 323-sentence total is unchanged and now labelled as
  sentences rather than rows.

## M7-M14 - inherited accuracy corrections

| ID | File:line | Before -> after | Evidence |
| --- | --- | --- | --- |
| M7 | `01-import-1.qmd:186-189`, `:218-221` | "we have to specify the types for all the columns ... not just ... wrongly determined" -> "we can specify the types for just the columns whose type was wrongly determined; the rest can still be guessed". "If we do not specify the data type for all the columns, `readr` returns an error" -> "Specifying types for only some of the columns is allowed: `readr` uses the types we supply and guesses the rest." | `read_csv(url, col_types = list(col_integer()))` returns 200 x 11; unspecified columns are guessed. |
| M8 | `07-tibbles.qmd:52-53` | "... not converted to factor, unlike a data.frame, where you need to set `stringsAsFactors` to `FALSE`." -> "... not converted to a factor." | `stringsAsFactors` defaults to `FALSE` since R 4.0; the book requires R >= 4.1. |
| M9 | `06-dplyr-3.qmd:185` | "dplyr verbs always return a tibble" -> "dplyr verbs return a tibble when the input is a tibble". | `filter(tibble(...))` returns `tbl_df`; `filter(data.frame(...))` returns `data.frame`. |
| M10 | `09-stringr.qmd:110-111` | "default truncation happens at the beginning" -> "at the end (the right side)". | `str_trunc("abcdefghijklmnop", 10)` gives `abcdefg...`; `side = "left"` truncates the beginning. |
| M11 | `10-lubridate-parsing.qmd:1112-1115` | "from date as the bare minimum ... sequence up to the current date" -> "supply the from date and either `to` or `length.out`; there is no implicit current-date endpoint, so an incomplete call returns an error." | `seq.Date(from = as.Date("2010-01-01"))` errors; adding only `by = "year"` errors; `from` plus `length.out` works. |
| M12 | `12-factors-fundamentals.qmd:402`, `:408` | "displayed in order of appearance in the data" -> "displayed in alphabetical order"; "(**D**esktop, **M**obile, **T**able)" -> "(**D**islike, **L**ike, **N**eutral)". | `levels(as.ordered(c("Neutral", "Like", "Dislike")))` is `Dislike`, `Like`, `Neutral`. |
| M13 | `14-solutions.qmd:370-371` | "`fct_count()` sorts most-frequent-first." -> "`fct_count()` lists levels in their current level order; set `sort = TRUE` to order them by frequency." | `fct_count(factor(c("z", "z", "a")))` returns `a` then `z`; `sort = TRUE` returns `z` then `a`. |
| M14 | `12-factors-fundamentals.qmd:293` | "Membership testing functions always have the prefix `is_`" -> "use the prefix `is.` in base R (as in `is.factor()`) or `is_` in many tidyverse packages (as in `is_tibble()`)". | The chapter's own example is `is.factor()`, which uses a dot. |

No M7-M14 item needed a structural rewrite; each was a one-line (or one-sentence) correction.

## Checks

Changed chapter sources: `01-import-1.qmd`, `04-dplyr-1.qmd`, `06-dplyr-3.qmd`,
`07-tibbles.qmd`, `09-stringr.qmd`, `10-lubridate-parsing.qmd`, `12-factors-fundamentals.qmd`,
`13-forcats-manipulation.qmd`, `14-solutions.qmd`.

Each was rendered with `quarto render <file>.qmd --to html` in the archive copy:

```text
01-import-1 EXIT=0 (the first run also built all formats, HTML/PDF/EPUB)
04-dplyr-1 EXIT=0
06-dplyr-3 EXIT=0
07-tibbles EXIT=0
09-stringr EXIT=0
10-lubridate-parsing EXIT=0
12-factors-fundamentals EXIT=0
13-forcats-manipulation EXIT=0
14-solutions EXIT=0
```

No new render error or warning was emitted; every log contains one `Output created`. As the audit
noted, a chapter path in a Quarto book can build the whole book; the first command did that (HTML,
PDF and EPUB, `docs\index.html`). The later per-chapter commands used `--to html` and wrote each
chapter HTML in about 20 seconds. Rendered HTML confirms `203 × 1` / `200 × 11` in the import
chapter, purchaser AOV values in the dplyr chapter, and the vetted factor levels in the factors
chapter.

Link check: the two replacement M2 targets return **200**.

## Follow-ups (not done in this round)

1. **`pull(ecom_mini, 1)` described as "from `ecom`"** (`06-dplyr-3.qmd:207-209`): text and chunk
   disagree. Left as written; needs a content decision, not a prose patch.
2. **Heading typos** (`09-stringr`): `### Extract Image Dimesion from URL` and
   `#### Step 3: Detect the staritng position of file type`. Renaming needs the redirect that CI
   checks.
3. **`round_dates()`** (`11-lubridate-arithmetic:580`) is inline code for `round_date()`.
4. **`geom_bar(stat = "identity")`** (`08-tidyr:106`, `13-forcats` plots) is code; `geom_col()` is
   the idiom.
5. **`separate()` in the tidyr solution** (`14-solutions`) contradicts chapter 8's
   `separate_wider_delim()`; it is a code rewrite.
6. **Learner-review asks not in this scope**: a seed for random samples, a more instructive
   `pick()` example, newer `case_when()`/`separate()`/`geom_col()` idioms, renaming data to avoid
   masking `utils::data`, course re-keying, a missing-values lesson, join pitfalls, and Part I/II
   restructuring.
7. **Promotional tone** in the book description ("drills the hardest 20%") remains; it is inherited
   wording, not a false statement, and changing it is a positioning decision.
8. **Appendix prose** was outside the wr2 style pass and remains outside this correctness round.
