# Next Page Path SQL (BigQuery Legacy, 2016)

[![Status: Historical Snapshot](https://img.shields.io/badge/Status-Historical%20Snapshot-yellow.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#)

This repository preserves a single SQL script I wrote around **2016** for **Next Page Path analysis** in **BigQuery Legacy SQL**.

The SQL is intentionally left **unchanged** to reflect my raw capability at the time.  
The goal is to provide a **historical snapshot** of how analysts worked with BigQuery and the Google Analytics Universal Analytics (UA) export schema.

## Schema Context

These queries were written against the **Google Analytics Universal Analytics (UA) export schema**, which has since been deprecated.  

Key assumptions in the SQL:
- Table naming: `ga_sessions_YYYYMMDD`
- Nested repeated fields: `hits.page.pagePath`, `hits.type`, `hits.time`
- Use of UA session-based model, not GA4’s event-based model

**If you are using GA4**: this query will not run without significant adaptation.  
See [BigQuery export schema for GA4](https://support.google.com/analytics/answer/9358801) for details.

More detail in [`docs/ga-ua-schema-context.md`](docs/ga-ua-schema-context.md).

---

## Running the Query (Legacy SQL)

By default, BigQuery uses **Standard SQL**. To run this script, you need to enable **Legacy SQL** mode.

Options (see [`docs/run-legacy-sql.md`](docs/run-legacy-sql.md) for full details):

1. **Add pragma in the file**  
   ```sql
   #legacySQL
   -- rest of the query

2. **BigQuery web UI** → toggle “Use Legacy SQL” in query settings

3. **bq CLI**

```bash
bq query --use_legacy_sql=true < sql/legacy/bigquery/next-page-path.sql

