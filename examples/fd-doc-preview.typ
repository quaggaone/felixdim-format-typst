#import "../template/fd-doc.typ": conf

#show: doc => conf(
  title: [felixdim doc preview],
  author: "Felix Dimmerling",
  description: [example document showcasing the fd-doc template],
  date: datetime.today(),
  lang: "en",
  region: "eu",
  doc
)

= Heading 1

Lorem ipsum dolor sit amet, *consectetur* adipiscing elit, sed do _eiusmod tempor_ incididunt ut `labore et dolore`. magnam aliquam quaerat voluptatem.
Ut enim aeque doleamus animo, cum corpore dolemus, fieri.

$ integral f(x) thin d x = alpha^2 gamma $

== Heading 2

#lorem(30)

=== Heading 3

#lorem(30)

- item 1
- item 2
  - sub-item 1
    - sub-sub-item 1
      - sub-sub-sub-item 1
- item 3

==== Heading 4

#lorem(30)

```r
common_sample <- abb_stock |>
  inner_join(
    msci_world_index,
    by = "date",
    suffix = c("_abb", "_msci")
  ) |>
  inner_join(risk_free, by = "date")

# drop all data except the first day of the month (to get monthly data)
common_sample_monthly <- common_sample |>
  filter(format(date, "%d") == "01")
```

===== Heading 5

#lorem(30)

====== Heading 6

#lorem(230)
