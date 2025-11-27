#import "../template/fd-doc.typ": conf

#show: doc => conf(
  title: [An Extremely Long Document Title That Definitely Spans Multiple Lines: A Comprehensive Investigation Into The Footer Layout Behavior When Dealing With Extended Titles That Exceed Normal Length Expectations And Continue For An Unreasonable Amount Of Text],
  author: "Felix Dimmerling",
  description: [test document for extreme long title footer behavior],
  date: datetime.today(),
  lang: "en",
  region: "eu",
  doc
)

= Introduction

#lorem(300)

= Second Section

#lorem(300)

= Third Section

#lorem(300)

= Fourth Section

#lorem(300)

= Fifth Section

#lorem(300)
