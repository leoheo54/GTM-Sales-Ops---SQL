-- GTM & Sales Operations SQL Portfolio
-- Target dialect: PostgreSQL 14+
-- All records are synthetic and created for portfolio demonstration.

CREATE TABLE accounts (
    account_id VARCHAR(10) PRIMARY KEY,
    account_name VARCHAR(150) NOT NULL,
    industry VARCHAR(80),
    region VARCHAR(40),
    country VARCHAR(80),
    company_size_segment VARCHAR(30),
    employee_count INTEGER,
    lead_source VARCHAR(30),
    created_date DATE
);

CREATE TABLE sales_reps (
    sales_rep_id VARCHAR(10) PRIMARY KEY,
    sales_rep_name VARCHAR(100) NOT NULL,
    region VARCHAR(40),
    primary_segment VARCHAR(30),
    hire_date DATE
);

CREATE TABLE opportunities (
    opportunity_id VARCHAR(10) PRIMARY KEY,
    account_id VARCHAR(10) REFERENCES accounts(account_id),
    sales_rep_id VARCHAR(10) REFERENCES sales_reps(sales_rep_id),
    opportunity_name VARCHAR(200),
    created_date DATE,
    close_date DATE,
    stage VARCHAR(30),
    sales_motion VARCHAR(30),
    product_line VARCHAR(50),
    acv_usd NUMERIC(12,2),
    discount_pct NUMERIC(5,2),
    is_closed BOOLEAN,
    is_won BOOLEAN,
    lost_reason VARCHAR(80)
);

CREATE TABLE activities (
    activity_id VARCHAR(12) PRIMARY KEY,
    opportunity_id VARCHAR(10) REFERENCES opportunities(opportunity_id),
    activity_date DATE,
    activity_type VARCHAR(30),
    completed BOOLEAN,
    duration_minutes INTEGER,
    channel VARCHAR(30)
);
