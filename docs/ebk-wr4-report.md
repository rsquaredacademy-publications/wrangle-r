# ebk-wr4 — fix round report

Branch `task/wr-style-1114`, started at `3a0ebe7` (the head audited by
`docs/ebk-wr-reaudit.md`). Scope: the five open Medium findings (R-M1–R-M5), the four Low
findings (R-L1–R-L4), the remaining H1 verification, the protected-inline-code/zero-edit
reconciliation (old M6), and a status check of the inherited accuracy items (old M7–M14).
No other prose, heading, anchor or chunk option was changed.

R checks used `Rscript --vanilla` from
`C:/Users/DELL/AppData/Local/Temp/ebk-wr4`, outside the worktree and any renv project.
R 4.6.1; readr 2.2.0, readxl 1.6.0, dplyr 1.2.1, tibble 3.3.1, stringr 1.6.0,
lubridate 1.9.5, forcats 1.0.1. Renders used a throwaway `git archive` copy under
`C:/Users/DELL/AppData/Local/Temp/ebk-wr4/archive` with the working-tree diff applied,
one `quarto render <file>.qmd --to html` per chapter through
`bash ~/.claude/bin/heavy-slot.sh ebk-wr4`, with `RENV_CONFIG_AUTOLOADER_ENABLED=false`.
`roadmap/` is already in `.gitignore`; the untracked `docs/*audit.md` files were left
untouched.

## Disposition summary

| Finding | File:line | Status |
| --- | --- | --- |
| H1 data source / worked example | `01-import-1.qmd:140`, :150 | Verified; already fixed at `e974df0` (wr3). No source change needed. |
| R-M1 printed coercion described as changing `rating` | `12-factors-fundamentals.qmd:402` | Fixed |
| R-M2 wrong helper `cell_limit()` | `02-import-2.qmd:107` | Fixed |
| R-M3 wrong `str_sub()` argument `stop` | `09-stringr.qmd:409` | Fixed |
| R-M4 legacy readr 1,000-row sampling rule | `01-import-1.qmd:172` | Fixed |
| R-M5 `fct_count()` answer omits `sort = TRUE` | `14-solutions.qmd:364`–366, :370 | Fixed |
| R-L1 over-exclusive `seq.Date()` input rule | `10-lubridate-parsing.qmd:1113` | Fixed |
| R-L2 empty `TZ` requires manual configuration | `11-lubridate-arithmetic.qmd:162` | Fixed |
| R-L3 reports do not reconcile counts/scope | `docs/ebk-wr2-report.md`, `docs/ebk-wr3-report.md` | Fixed |
| R-L4 `pull()` text says `ecom`, call uses `ecom_mini` | `06-dplyr-3.qmd:205` | Fixed |
| Old M6 protected inline code | see below | 3 wr2 removals already restored; remaining removals are audit-endorsed content repairs. Reports corrected. |
| Old M7–M14 inherited accuracy | see below | Verified at HEAD; M11/M12/M13 are covered by R-L1/R-M1/R-M5. No further source change. |

## H1 — data source / worked example

`01-import-1.qmd:140`, :150 already use
`https://raw.githubusercontent.com/rsquaredacademy-publications/wrangle-r/master/hsb4.csv`
with `skip = 3`, the source the re-audit probed. The prose says the first three lines
contain information about the data set. No edit was needed.

Neutral probe:

```
skip=3 dim: 200 11
names: id,female,race,ses,schtyp,prog,read,write,math,science,socst
classes: numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric
problems: 0
no-skip dim: 203 1
```

Rendered chapter output from the actual chunk:

```
# A tibble: 200 × 11
      id female  race   ses schtyp  prog  read write  math science socst
   <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl> <dbl>
1     70      0     4     1      1     1    57    52    41      47    57
...
# ℹ 190 more rows
```

The preceding no-skip chunk renders `# A tibble: 203 × 1`, matching the text that readr
treats the preamble as data when it is not skipped.

## R-M1–R-M5 — the five Medium corrections

### R-M1 — describe the returned factor, not a mutation of `rating`

`12-factors-fundamentals.qmd:402`.

- Before: “Now `rating` is ordered, but the order of the levels is not correct.”
- After: “The call does not change `rating`; the returned factor is ordered, but the order
  of its levels is not correct.”

Evidence: `as.ordered(rating)` returns class `ordered,factor` with levels
`Dislike,Like,Neutral`; after the same call `is.ordered(rating)` is `FALSE` and
`class(rating)` is `character`. The following `factor(rating, ...)` examples therefore
still operate on the character vector, as the chapter describes.

### R-M2 — `cell_limits()` is the exported helper

`02-import-2.qmd:107`.

- Before: “In this method, we use `cell_limit()` and specify the two ends…”
- After: “In this method, we use `cell_limits()` and specify the two ends…”

Evidence: after loading readxl, `exists("cell_limit", mode = "function")` is `FALSE` and
`exists("cell_limits", mode = "function")` is `TRUE`; the working chunk already calls
`cell_limits(c(1, 1), c(6, 4))`. This is a recorded protected-inline-code exception.

### R-M3 — `str_sub()` uses `end`, not `stop`

`09-stringr.qmd:409`.

- Before: “The index positions are specified using `start` and `stop`.”
- After: “The index positions are specified using `start` and `end`.”

Evidence: `str_sub("abcdef", start = 1, end = 3)` returns `"abc"`;
`str_sub("abcdef", start = 1, stop = 3)` errors with
`unused argument (stop = 3)`. The chunk already uses `end = 3`. Recorded
protected-inline-code exception.

### R-M4 — current readr also checks a spread sample

`01-import-1.qmd:172`.

- Before: “`readr` determines the type of each column from the first 1000 rows of data.”
- After: “`readr` guesses the type of each column from the first 1,000 rows, then checks
  that guess against a sample spread through the file.”

Evidence: a 1,001-line probe with 1,000 empty values followed by `2` is read as one
numeric column with value `2` and zero parser problems. The current readr column-type
vignette describes the first-1,000 guess plus the spread sample; the old first-1,000-only
rule is the pre-2.0 description. No example code changed.

### R-M5 — the frequency answers now sort

`14-solutions.qmd:364`–366, with the explanation at :370.

- Before: three bare `fct_count()` calls and “`fct_count()` lists levels in their current
  level order; set `sort = TRUE` to order them by frequency.”
- After: `fct_count(sort = TRUE)` in all three Q1 calls and “`fct_count()` lists levels in
  their current level order; `sort = TRUE` orders them by descending frequency.”

Evidence on the book's `analytics.rds`:

```
device       default first2: Desktop 177282 / Mobile 63482
device       sorted  first2: Desktop 177282 / Mobile 63482
landing_page default first2: Accessories 4529 / Apparel 32234
landing_page sorted  first2: Home 135485 / Apparel 32234
exit_page    default first2: Accessories 4856 / Apparel 38318
exit_page    sorted  first2: Home 88051 / Apparel 38318
```

The rendered chapter now shows `Home 135485` first for `landing_page` and `Home 88051`
first for `exit_page`; `device` was already descending. This is a recorded correctness
change to chunk bodies, not a chunk-option change.

## Old M6 — protected inline code and the zero-edit claim

The three true references restored in ebk-wr3 are still exactly at `90425d8`:
`` `order_value` `` (`04-dplyr-1.qmd:243`), `` `Sys.Date()` `` (`10-lubridate-parsing.qmd:200`)
and `` `along.with` `` (`10-lubridate-parsing.qmd:1208`–1211). No false prose was restored.

An independent ordered span comparison outside fences (`90425d8` vs HEAD) gives
**10 removals / 13 insertions**. The wr2 delta was 8/2; wr3 restored three and added eight
new spans while removing `stringsAsFactors`/`FALSE`; wr4 added three one-for-one content
corrections. Per file:

| File | Removed vs wr1 | Inserted vs wr1 | Reason |
| --- | --- | --- | --- |
| `02-import-2.qmd` | `cell_limit()` | `cell_limits()` | R-M2 real API error |
| `04-dplyr-1.qmd` | — | `ecom1`, `across()` | wr1/wr3 correctness |
| `06-dplyr-3.qmd` | `head`, `ecom` | `ecom_mini` | false `head` claim; R-L4 |
| `07-tibbles.qmd` | `stringsAsFactors`, `FALSE` | — | obsolete R < 4.0 contrast |
| `09-stringr.qmd` | `stop`, `:` ×3, `\\` | `end`, `://` ×2 | R-M3; false regex-escape claim |
| `10-lubridate-parsing.qmd` | — | `to`, `length.out` | old M11 |
| `12-factors-fundamentals.qmd` | — | `is.`, `is.factor()`, `is_tibble()` | old M14 |
| `14-solutions.qmd` | — | `sort = TRUE` | R-M5 |

The remaining removals are content repairs the audit endorses; restoring them would
re-break a worked example or re-add a false explanation. The wr2 report now states the
10/13 inventory and the per-file reasons, “Not done” no longer contradicts the guard, and
the wr3 report records the wr3 delta as 2/11 and the current wr1-to-HEAD delta as 10/13.

## R-L1–R-L4 — Low items

### R-L1 — qualify the `seq.Date()` inputs

`10-lubridate-parsing.qmd:1113`.

- Before: “We need to supply the from date and either an end date (`to`) or a length
  (`length.out`); there is no implicit current-date endpoint, so an incomplete call
  returns an error.”
- After: “For the first examples, we supply the from date and either an end date (`to`) or
  a length (`length.out`); there is no implicit current-date endpoint.”

Evidence: `seq.Date(from = as.Date("2010-01-01"), to = as.Date("2010-01-03"))` works, as
do `from` + `length.out`, `from` + `along.with`, and `to` + `length.out`. `from` with only
`by` errors (`exactly two of 'to', 'from' and 'length.out'/'along.with' must be
specified`). The text now scopes the rule to the first examples, and the later
`along.with` section remains the place that teaches that alternative.

### R-L2 — an empty `TZ` falls back to the system timezone

`11-lubridate-arithmetic.qmd:162`.

- Before: “If nothing is returned, we have to set the timezone. Use `Sys.setenv()` to set
  the timezone, as shown below.”
- After: “If nothing is returned, R uses the system timezone. Use `Sys.setenv()` to
  override it when needed, as shown below.”

Evidence: with `TZ` empty, `Sys.timezone()` returns `Asia/Calcutta` and `Sys.time()` works;
`Sys.setenv(TZ = "Asia/Calcutta")` is an explicit override, which the existing example
still demonstrates.

### R-L3 — reports reconcile counts and exceptions

- `docs/ebk-wr2-report.md`: the summary column is now **Edit-group rows**, with the
  displayed table-row counts: Import Basics 20, Pipe Operator 18, dplyr Basics 25,
  Parsing 36, Categorical 32, forcats 32, total **292**. The counts are reproducible from
  the tables; the unreconciled 323-sentence total is no longer claimed.
- Guard: full wr1-to-HEAD inline delta is **10 removals / 13 insertions**, with the wr2,
  wr3 and wr4 deltas and per-file reasons stated. “Not done” now describes the same ten
  removals instead of the contradictory “four removed occurrences”.
- `docs/ebk-wr3-report.md`: the report correction records the wr3 2/11 delta, the wr3
  per-file comparison, and a note that ebk-wr4's three content pairs raise the current
  wr1-to-HEAD delta to 10/13. The L4 bullet records the new row labels and total.

### R-L4 — name the sampled object

`06-dplyr-3.qmd:205`.

- Before: “Let us extract the first column from `ecom` using column position instead of
  name.”
- After: “Let us extract the first column from `ecom_mini` using column position instead
  of name.”

Evidence: the chunk is `pull(ecom_mini, 1)`, and the rendered paragraph now names
`ecom_mini`. Recorded protected-inline-code exception.

## Old M7–M14 — inherited accuracy status

No source change was needed beyond R-M1, R-M5 and R-L1, which finish old M12, M13 and M11.
Probes at HEAD:

| Old ID | Current source | Status / evidence |
| --- | --- | --- |
| M7 | `01-import-1.qmd:187`–189, :218–220 | Pass. `col_types = list(col_integer())` reads 200 × 11 with zero problems; unspecified columns are guessed. |
| M8 | `07-tibbles.qmd:52` | Pass. `data.frame(x = letters)$x` is `character` in current R; the obsolete contrast is gone. |
| M9 | `06-dplyr-3.qmd:185` | Pass. `filter(tibble(...))` returns `tbl_df`; `filter(data.frame(...))` returns `data.frame`, matching the scoped sentence. |
| M10 | `09-stringr.qmd:110` | Pass. `str_trunc("abcdefghijklmnop", 10)` returns `abcdefg...`, i.e. truncation at the end. |
| M11 | `10-lubridate-parsing.qmd:1113` | Resolved by R-L1. |
| M12 | `12-factors-fundamentals.qmd:402` | Resolved by R-M1; levels are `Dislike,Like,Neutral`, alphabetical. |
| M13 | `14-solutions.qmd:361`–371 | Resolved by R-M5. |
| M14 | `12-factors-fundamentals.qmd:293` | Pass. `is.factor()` and `is_tibble()` both exist; the naming contrast is accurate. |

## Checks

Eight changed chapters rendered alone in the throwaway archive copy, all exit 0 with
“Output created”:

`01-import-1`, `02-import-2`, `06-dplyr-3`, `09-stringr`, `10-lubridate-parsing`,
`11-lubridate-arithmetic`, `12-factors-fundamentals`, `14-solutions`.

No source-attributable error, warning, unresolved reference or missing-file message
appeared in the logs. HTML spot checks confirmed the changed sentences, `cell_limits()` in
prose, `start`/`end`, the readr sampling sentence, the `ecom_mini` paragraph, the
`seq.Date()` qualification, the system-timezone sentence, and the sorted `Home 135485` /
`Home 88051` answer output. Headings, anchors, chunk labels/options and link targets were
not changed except the three protected inline names and the three `fct_count` chunk-body
calls required by R-M5.

## Commits

- `fix: correct five medium content errors (ebk-wr4)`
- `fix: correct low-severity text mismatches (ebk-wr4)`
- `docs: reconcile guard and count claims (ebk-wr4)`
- `docs: ebk-wr4 fix report (ebk-wr4)`

H1 produced no commit because the source already matches the audited working example.

## Follow-ups (full list, remaining)

1. **Heading typos** (`09-stringr`): `### Extract Image Dimesion from URL` and
   `#### Step 3: Detect the staritng position of file type`. Renaming needs the CI redirect
   and Aravind's call.
2. **`round_dates()`** (`11-lubridate-arithmetic:580`) is inline code for `round_date()`.
3. **`geom_bar(stat = "identity")`** (`08-tidyr:106`, `13-forcats` plots) is code;
   `geom_col()` is the idiom.
4. **`separate()` in the tidyr solution** (`14-solutions`) contradicts chapter 8's
   `separate_wider_delim()`; it is a code rewrite.
5. **Learner-review structural asks**: seed the random samples, a more instructive
   `pick()` example, newer `case_when()`/`separate()`/`geom_bar()` idioms, rename `data` to
   avoid masking `utils::data`, course hooks/re-keying, a missing-values lesson, join
   pitfalls, and a Part I/II restructure.
6. **Promotional tone**: “drills the hardest 20%” remains in `_quarto.yml:22`,
   `index.qmd:2` and `README.md:3`; “deep dive” and “rich set of functions” remain at
   `12-factors-fundamentals.qmd:30`–34. These are inherited positioning choices, not false
   statements.
7. **Em dashes in the shared webR callout** are single inherited dashes in all chapters;
   changing one means changing all seven together.
8. **Appendix prose** was outside the wr2 style pass and remains outside this correctness
   round.
9. **`docs/` HTML output** is deliberately not committed; CI owns it.
10. **PDF/EPUB** were not regenerated; the checks cover chapter HTML only. No browser
    execution of webR or visual-layout audit is claimed.
