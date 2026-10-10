# Metabase: Bike Store Sales Overview

Step-by-step guide to build the owner dashboard in Metabase on top of the `mart` schema.
The card queries are in [`dashboard_cards.sql`](dashboard_cards.sql): one plain SQL question per block.

```
SQL Server ──► Meltano ──► raw ──► dbt ──► staging ──► mart ──► Metabase (this guide)
```

## Contents

1. [Prerequisites](#1-prerequisites)
2. [Validate](#2-start-metabase)
3. [First-time setup](#3-first-time-setup)
4. [Create the questions](#4-create-the-questions)
5. [Build the dashboard](#5-build-the-dashboard)
6. [Known limitations](#7-known-limitations)
7. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

Make sure you have run the implementation guide in README.md

## 2. Validate

Optional check that the read-only login works and is restricted to `mart`:

```bash
docker compose exec postgres psql -U metabase_reader -d dwh -c "SELECT count(*) FROM mart.fct_order_items;"   # 4725
docker compose exec postgres psql -U metabase_reader -d dwh -c "SELECT 1 FROM staging.stg_orders LIMIT 1;"    # permission denied
```

## 3. First-time setup

Open http://localhost:3000.

1. Create the admin account (name, email, password).
2. **Add your data** → **PostgreSQL**:

   | Field | Value |
   |---|---|
   | Display name | `Bike Store DWH` |
   | Host | `postgres` (Compose service name, not `localhost`) |
   | Port | `5432` |
   | Database name | `dwh` |
   | Username | `metabase_reader` |
   | Password | `metabase123` (`METABASE_READER_PASSWORD` in `.env`) |
   | Schemas | **Only these…** → `mart` |

3. Finish the wizard. Metabase syncs the 7 `mart` tables.
4. Create a collection: **+ New → Collection** → `Bike Store`.

## 4. Create the questions

Create **one question per block** in `dashboard_cards.sql` (a question holds exactly one SQL query; pasting the whole file runs only the first one).

For each block:

1. **+ New → SQL query** → database `Bike Store DWH`.
2. Paste **one** block (from `SELECT` to `;`) → **Run** (▶ or Ctrl+Enter).
3. **Visualization** (bottom left) → choose the type from the table below → ⚙️ for the settings.
4. **Save** → name from the table → collection `Bike Store`.

| # | Question name | Visualization | Settings (⚙️) |
|---|---|---|---|
| 1 | Booked revenue | Number | Formatting → Style: **Currency** (USD) |
| 2 | Completed revenue | Number | Formatting → Style: **Currency** (USD) |
| 3 | Booked orders | Number | – |
| 4 | Revenue trend by month | Line | X-axis: `month`; Y-axis: `booked_revenue`, `completed_revenue`; Currency on both series |
| 5 | Orders by status per month | Bar | X-axis: `month`; Series breakout: `order_status`; Y-axis: `orders`; Display → **Stack** |
| 6 | Booked revenue by category | Row | Y-axis (category): `category`; X-axis: `booked_revenue`; Currency |


## 5. Build the dashboard

1. **+ New → Dashboard** → name `Bike Store - Sales Overview` → collection `Bike Store`.
2. Click ✏️ (edit) → **+** (add a question) → add the 6 saved questions.
3. Arrange them (drag the corners to resize):

   ```
   ┌───────────────────────┬───────────────────────┬───────────────────────┐
   │ Booked revenue (1)    │ Completed revenue (2) │ Booked orders (3)     │
   ├───────────────────────┴───────────────────────┴───────────────────────┤
   │ Revenue trend by month (4)          — line: booked vs completed       │
   ├────────────────────────────────────┬──────────────────────────────────┤
   │ Orders by status per month (5)     │ Booked revenue by category (6)   │
   │ — stacked bar                      │ — row chart                      │
   ├────────────────────────────────────┴──────────────────────────────────┤
   ```

4. **Save**.


## 6. Known limitations

| Limitation | Why | Upgrade path |
|---|---|---|
| **No dashboard filters** (date, store, category, status) | Plain SQL questions without `{{variables}}` cannot receive dashboard filters | Add a dbt model `mart.rpt_sales_lines` (fact joined to all dimensions) and rebuild the cards with the query builder; filters then connect by picking a column, no field-filter setup |
| Trend cards have a **fixed range** (until 2018-04-30) | Hard-coded `WHERE order_date < '2018-05-01'` | Same as above (date filter), or edit the SQL |
| **Status lag** — completed revenue and order status can be up to 7 days old | Daily incremental load + weekly full reload  | Shorter full-reload interval |
| KPI cards are all-time | No date filter | Same as the first row |

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| Metabase cannot connect to the database | Host must be `postgres` (not `localhost`); password is `metabase123` |
| `permission denied for table ...` in a question | Table is not in `mart`, or created before the grants: re-run `docker compose up -d` (re-applies grants) |
| New/changed `mart` columns don't appear | Admin → Databases → `Bike Store DWH` → **Sync database schema now** |
| Question shows only the first query | One question = one SQL block; create a separate question per block |
| Numbers differ from section 6 | Re-run dbt (`run` → `test`) and check the Meltano loads; then compare with the cross-check query |
