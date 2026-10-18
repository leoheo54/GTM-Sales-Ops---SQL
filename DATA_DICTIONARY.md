# Data Dictionary

All fields are synthetic. Dates use ISO format (`YYYY-MM-DD`). Currency is USD.

## `accounts.csv`

| Column | Type | Description |
|---|---|---|
| `account_id` | string | Unique account key |
| `account_name` | string | Fictional account name |
| `industry` | string | Industry category |
| `region` | string | North America, LATAM, EMEA, or APAC |
| `country` | string | Fictional account's country assignment |
| `company_size_segment` | string | SMB, Mid-Market, or Enterprise |
| `employee_count` | integer | Synthetic employee count consistent with segment ranges |
| `lead_source` | string | Original account acquisition source |
| `created_date` | date | Account record creation date |

## `sales_reps.csv`

| Column | Type | Description |
|---|---|---|
| `sales_rep_id` | string | Unique rep key |
| `sales_rep_name` | string | Fictional name |
| `region` | string | Rep's assigned region |
| `primary_segment` | string | Primary company-size segment |
| `hire_date` | date | Synthetic hire date |

## `opportunities.csv`

| Column | Type | Description |
|---|---|---|
| `opportunity_id` | string | Unique opportunity key |
| `account_id` | string | Foreign key to `accounts.account_id` |
| `sales_rep_id` | string | Foreign key to `sales_reps.sales_rep_id` |
| `opportunity_name` | string | Fictional opportunity label |
| `created_date` | date | Opportunity creation date |
| `close_date` | date | Actual close date for closed deals; expected close date for open deals |
| `stage` | string | Prospecting, Qualification, Discovery, Proposal, Negotiation, Closed Won, Closed Lost |
| `sales_motion` | string | Inbound, Outbound, Partner, Event, Referral |
| `product_line` | string | Product category |
| `acv_usd` | numeric | Synthetic annual contract value in USD |
| `discount_pct` | numeric | Synthetic discount percentage |
| `is_closed` | boolean | True for Closed Won or Closed Lost |
| `is_won` | boolean | True only for Closed Won |
| `lost_reason` | string | Loss reason; blank unless Closed Lost |

## `activities.csv`

| Column | Type | Description |
|---|---|---|
| `activity_id` | string | Unique activity key |
| `opportunity_id` | string | Foreign key to `opportunities.opportunity_id` |
| `activity_date` | date | Activity date |
| `activity_type` | string | Email, Call, Meeting, Demo, Proposal Sent |
| `completed` | boolean | Whether the activity was completed |
| `duration_minutes` | integer | Synthetic activity duration; zero can represent email or logged non-call work |
| `channel` | string | Email, Phone, Video Conference, In Person |

## Relationships

- `accounts.account_id` → `opportunities.account_id` (one account can have many opportunities)
- `sales_reps.sales_rep_id` → `opportunities.sales_rep_id` (one rep can own many opportunities)
- `opportunities.opportunity_id` → `activities.opportunity_id` (one opportunity can have many activities)
