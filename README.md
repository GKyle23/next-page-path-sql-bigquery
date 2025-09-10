# Next Page Path SQL (BigQuery Legacy, 2016)

[![Status: Historical Snapshot](https://img.shields.io/badge/Status-Historical%20Snapshot-yellow.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#)

This repository preserves two SQL scripts I wrote around **2016** for **Next Page Path analysis** in **BigQuery Legacy SQL**.

The SQL is intentionally left **unchanged** to reflect my raw capability at the time.  
The goal is to provide a **historical snapshot** of how analysts worked with BigQuery and the Google Analytics Universal Analytics (UA) export schema.

## Schema Context

These queries were written against the **Google Analytics Universal Analytics (UA) export schema**, which has since been deprecated.  

**If you are using GA4**: this query will not run without significant adaptation.  
See [BigQuery export schema for GA4](https://support.google.com/analytics/answer/9358801) for details.


---

## Running the Query (Legacy SQL)

see [`docs/run-legacy-sql.md`](docs/run-legacy-sql.md) for full details



## What this repository is not

- It’s not a production-ready analytics package.
- It’s not a modern BigQuery Standard SQL implementation.
- It’s not accepting PRs that rewrite the SQL to Standard SQL.

## Background

This was originally put together to answer questions like:
- “When a user views page X, what’s the next step?”
- “What’s the step-to-step drop-off in a simple registration funnel?”
- “How can I inspect event paths at a session level quickly?”

It also demonstrates techniques users commonly tried in early GA→BigQuery workflows (e.g., `TABLE_DATE_RANGE` over GA export tables and simple pathing via `LEAD` + `ROW_NUMBER()`).
