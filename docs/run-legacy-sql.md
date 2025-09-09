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
