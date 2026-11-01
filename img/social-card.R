#!/usr/bin/env Rscript
# Share card for links to the book: img/social-card.png, exactly 1200 x 630 px.
#
# Referenced from `book: image:` in _quarto.yml, so Quarto puts it in the
# og:image / twitter:image tags of every page.
#
#   Rscript --vanilla img/social-card.R      # from the project root
#
# Needs ggplot2 + ragg, which are not part of the book's renv library, so run
# it with --vanilla rather than through .Rprofile.

library(ggplot2)

# --- canvas ----------------------------------------------------------------
W   <- 1200          # px
H   <- 630           # px
DPI <- 100           # 12 x 6.3 in at 100 dpi = exactly 1200 x 630 px
PAD <- 72            # keep all ink at least this far from every edge (>= 40)

ink      <- "#0f172a"  # title
slate    <- "#475569"  # subtitle, domain
brand    <- "#2563eb"  # accent bar
hairline <- "#e2e8f0"

# --- copy ------------------------------------------------------------------
title_1  <- "Data Wrangling"
title_2  <- "with R"
# One line, drawn from the book description ("joins, grouped summaries, ...
# strings ... factors").
subtitle <- "Joins, grouped summaries, strings and factors"
domain   <- "rsquaredacademy.com"

# --- helpers ---------------------------------------------------------------
# ggplot2 sizes text in millimetres; at 100 dpi one mm is 100/25.4 px.
mm <- function(px) px * 25.4 / DPI

# Width of a string in px at 100 dpi, used to auto-fit the type.
text_px <- function(label, size_px, bold = FALSE) {
  textshaping::shape_text(
    label,
    family = "sans",
    weight = if (bold) "bold" else "normal",
    size   = size_px,
    res    = DPI
  )$metrics$width
}

# Shrink `size` until `label` fits in `max_w` (never enlarge).
fit_px <- function(label, size, max_w, bold = FALSE) {
  w <- text_px(label, size, bold)
  if (w > max_w) floor(size * max_w / w) else size
}

# --- type ------------------------------------------------------------------
col_w      <- 980                            # text column, right of the bar
title_size <- fit_px(title_1, 150, col_w, bold = TRUE)
sub_size   <- fit_px(subtitle, 40, col_w)
dom_size   <- 30
line_gap   <- 4                              # extra leading between title lines

stopifnot(title_size >= 48)                  # the brief: title >= 48 px
stopifnot(text_px(title_1, title_size, TRUE) <= col_w)

# --- layout, measured from the top-left corner -----------------------------
x_text        <- PAD + 40                    # 112
y_title_1     <- 84                          # top of the first title line
y_title_2     <- y_title_1 + title_size * 1.02 + line_gap
y_sub         <- 400
y_rule        <- 496
y_domain      <- 552                         # bottom of the domain line
bar_x         <- c(PAD, PAD + 14)
bar_y         <- c(112, 368)

# Text is anchored by its top edge, so flip the y coordinate (ggplot's y grows
# upwards) and use vjust = 1; the domain line is anchored by its bottom edge.
top_y <- function(y) H - y

card <- ggplot() +
  # brand-blue accent bar, level with the title
  annotate("rect",
    xmin = bar_x[1], xmax = bar_x[2],
    ymin = top_y(bar_y[2]), ymax = top_y(bar_y[1]),
    fill = brand, colour = NA
  ) +
  annotate("text",
    x = x_text, y = top_y(y_title_1), label = title_1,
    hjust = 0, vjust = 1, size = mm(title_size),
    fontface = "bold", colour = ink, lineheight = 0.95
  ) +
  annotate("text",
    x = x_text, y = top_y(y_title_2), label = title_2,
    hjust = 0, vjust = 1, size = mm(title_size),
    fontface = "bold", colour = ink, lineheight = 0.95
  ) +
  annotate("text",
    x = x_text, y = top_y(y_sub), label = subtitle,
    hjust = 0, vjust = 1, size = mm(sub_size),
    colour = slate
  ) +
  annotate("segment",
    x = PAD, xend = W - PAD, y = top_y(y_rule), yend = top_y(y_rule),
    colour = hairline, linewidth = 0.6
  ) +
  annotate("text",
    x = PAD, y = top_y(y_domain), label = domain,
    hjust = 0, vjust = 0, size = mm(dom_size),
    colour = slate
  ) +
  coord_cartesian(xlim = c(0, W), ylim = c(0, H), expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = rep(grid::unit(0, "pt"), 4)
  )

out <- "img/social-card.png"
ggsave(
  out, card,
  device = ragg::agg_png, width = W / DPI, height = H / DPI,
  units = "in", dpi = DPI, bg = "white"
)
message("wrote ", out, " (", W, "x", H, "), title ", round(title_size), " px")

# --- self-check ------------------------------------------------------------
# Fail loudly if the rendered file is the wrong size or if any ink comes
# closer than 40 px to an edge.
if (requireNamespace("png", quietly = TRUE)) {
  img <- png::readPNG(out)
  stopifnot(dim(img)[2] == W, dim(img)[1] == H)
  rgb  <- img[, , 1:3]
  ink_rows <- which(apply(rgb, 1, min) < 0.97)
  ink_cols <- which(apply(rgb, 2, min) < 0.97)
  margins <- c(
    top = min(ink_rows) - 1, bottom = H - max(ink_rows),
    left = min(ink_cols) - 1, right = W - max(ink_cols)
  )
  message("ink margins (px): ",
          paste(names(margins), margins, sep = "=", collapse = " "))
  stopifnot(min(margins) >= 40)
}
