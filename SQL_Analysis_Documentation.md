# Project 2: SQL Analysis — Mortgage Portfolio
**Database:** Mortgage_Portfolio (SQL Server)
**Tables:** tbl_stg_borrower, tbl_stg_financial, tbl_stg_loan, tbl_stg_property (linked primarily by SSN; loan and property also link via PropertyID)

## Overview
This project uses SQL to answer real business questions a mortgage lender's leadership,
marketing, and compliance teams would actually ask — using data modeled after a real
1003 mortgage application structure. Each query below pairs a business question with
the SQL that answers it, the result, and the takeaway.

---

## Query 1: Total Loan Amount by State
**Business question:** Which states have the highest loan volume?

```sql
SELECT 
    b.State,
    COUNT(l.LoanID) AS TotalApplications,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
GROUP BY b.State
ORDER BY TotalLoanAmount DESC;
```

**Finding:** California leads with 2 applications totaling $670,000. Every other state
has 1 application, ranging from $320,000 (Vermont) down to $150,000 (Arizona).

**Talking point:** "I used GROUP BY and JOIN to roll up loan volume by state, which is
exactly the kind of geographic breakdown a leadership team would use to decide where to
focus marketing spend or loan officer staffing."

---

## Query 2: Applications by Referral Source
**Business question:** Which referral source brings in the most business?

```sql
SELECT 
    l.Referral,
    COUNT(l.LoanID) AS TotalApplications,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_loan l
GROUP BY l.Referral
ORDER BY TotalApplications DESC;
```

**Finding:** Online dominates with 5 applications and $1,355,000 in total loan volume.
Zillow brings 3 applications ($820,000) with the highest average loan size ($273,333).
Email is weakest — 2 applications, $325,000 total.

**Talking point:** "This tells two different stories depending on what you're optimizing
for — Online drives the most volume, but Zillow brings higher-value borrowers per
application. A marketing team would use this to decide whether to chase volume or
value."

---

## Query 3: Average Income by Loan Purpose
**Business question:** Do refinance or purchase borrowers have higher income?

```sql
SELECT 
    l.PurposeOfLoan,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(f.MonthlyIncome AS INT)) AS AvgMonthlyIncome,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_loan l
JOIN dbo.tbl_stg_financial f ON l.SSN = f.SSN
GROUP BY l.PurposeOfLoan
ORDER BY AvgLoanAmount DESC;
```

**Finding:** Refinance borrowers earn more on average ($7,833/month) and take larger
loans ($293,333 avg) than Purchase borrowers ($5,757/month income, $231,428 avg loan).

**Talking point:** "Refinance customers are the higher-income, higher-value segment.
If a lender wants to grow revenue per loan rather than just loan count, refinance
customers are where the higher-margin opportunity is."

---

## Query 4: Rent vs Own Analysis
**Business question:** Are renters or homeowners applying for more loans?

```sql
SELECT 
    f.RentOrOwn,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount
FROM dbo.tbl_stg_financial f
JOIN dbo.tbl_stg_loan l ON f.SSN = l.SSN
GROUP BY f.RentOrOwn
ORDER BY TotalApplications DESC;
```

**Finding:** Renters account for the majority of applications (7, totaling $1,620,000)
but at a lower average loan size ($231,428). Homeowners have fewer applications (3,
totaling $880,000) but a higher average loan ($293,333) — consistent with refinance
activity from existing homeowners.

**Talking point:** "Renters make up most of our applicant volume, which makes sense for
first-time purchase loans. Homeowners bring fewer but larger loans, which lines up with
what we saw in the loan purpose breakdown — this cross-checks Query 3's finding."

---

## Query 5: Property Usage Breakdown
**Business question:** What types of properties are borrowers applying for?

```sql
SELECT 
    p.PropertyUsage,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount
FROM dbo.tbl_stg_property p
JOIN dbo.tbl_stg_loan l ON p.SSN = l.SSN
GROUP BY p.PropertyUsage
ORDER BY TotalApplications DESC;
```

**Finding:** Primary Residence dominates application count (7, $1,480,000 total) but has
the lowest average loan size ($211,428). Investment properties (2 applications) average
$300,000, and the single Secondary Residence application is the largest individual loan
at $420,000.

**Talking point:** "Primary residences drive volume, but investment and secondary
properties bring in significantly higher loan values per application. If a lender wants
to grow revenue per loan rather than application count, targeting investors and second-
home buyers is the higher-value segment."

---

## Query 6: Marital Status vs Loan Amount
**Business question:** Does marital status affect loan amounts or income levels?

```sql
SELECT 
    b.MaritalStatus,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount,
    AVG(CAST(f.MonthlyIncome AS INT)) AS AvgMonthlyIncome
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
JOIN dbo.tbl_stg_financial f ON b.SSN = f.SSN
GROUP BY b.MaritalStatus
ORDER BY AvgLoanAmount DESC;
```

**Finding:** Married borrowers combine high income ($7,125/month avg) with high loan
amounts ($300,000 avg). Divorced borrowers have the same average loan amount ($300,000)
despite lower income ($5,750/month). Single borrowers have the most applications (4) but
the lowest average loan ($173,333) and lowest income ($5,433/month).

**Talking point:** "This kind of breakdown is also relevant from a compliance
standpoint — a fair lending team would run an analysis like this to confirm no
demographic group is being approved for systematically different loan terms without
a legitimate income-based reason."

---

## Query 7: Top 5 Highest Loan Amounts
**Business question:** Who are our highest-value borrowers?

```sql
SELECT TOP 5
    b.BorrowerFirstName,
    b.BorrowerLastName,
    b.State,
    l.PurposeOfLoan,
    CAST(l.LoanAmount AS INT) AS LoanAmount,
    l.Referral
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
ORDER BY CAST(l.LoanAmount AS INT) DESC;
```

**Finding:** Buck Socia ($420,000 refinance, CA, via Zillow) tops the list, followed by
Wilbur Royals ($320,000 purchase, VT), James Carter ($310,000 purchase, TX), Robert
Taylor ($280,000 refinance, GA), and Cris Hassen ($250,000 purchase, CA). 4 of the top 5
came through the Online referral channel.

**Talking point:** "This is the kind of quick executive-level view — 'who are our
biggest deals and where did they come from' — that's easy to hand to leadership without
requiring them to dig through a full report."

---

## Query 8: Risk Level Analysis
**Business question:** Which borrowers are stretching themselves financially relative to
their income?

```sql
SELECT 
    b.BorrowerFirstName,
    b.BorrowerLastName,
    CAST(f.MonthlyIncome AS INT) AS MonthlyIncome,
    CAST(l.LoanAmount AS INT) AS LoanAmount,
    ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) 
        AS LoanToAnnualIncomeRatio,
    CASE 
        WHEN ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) > 4.0 
            THEN 'High Risk'
        WHEN ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) > 3.0 
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskLevel
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_financial f ON b.SSN = f.SSN
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
ORDER BY LoanToAnnualIncomeRatio DESC;
```

**Finding:** Wilbur Royals (5.93x annual income) and Cris Hassen (4.17x) are flagged
High Risk. Buck, Michael, Robert, and James fall into Medium Risk (3.0–4.0x). Linda,
Patricia, Melani, and Delisa are Low Risk, all under 3.0x.

**Talking point:** "I built a calculated risk score using a loan-to-annual-income ratio
and a CASE statement to bucket borrowers into High/Medium/Low risk — the same basic
logic a compliance or underwriting team uses to flag applications that need closer
review before approval."

---

## Query 9: Executive Summary View
**Business question:** What does a complete borrower profile look like, combining every
data point into one view?

```sql
SELECT 
    b.BorrowerFirstName + ' ' + b.BorrowerLastName AS BorrowerName,
    b.State,
    b.MaritalStatus,
    f.RentOrOwn,
    l.PurposeOfLoan,
    l.Referral,
    CAST(l.LoanAmount AS INT) AS LoanAmount,
    p.PropertyUsage,
    CAST(f.MonthlyIncome AS INT) AS MonthlyIncome,
    ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) 
        AS LoanToIncomeRatio,
    CASE 
        WHEN ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) > 4.0 
            THEN 'High Risk'
        WHEN ROUND(CAST(l.LoanAmount AS INT) / (CAST(f.MonthlyIncome AS INT) * 12.0), 2) > 3.0 
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskLevel
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_financial f ON b.SSN = f.SSN
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
JOIN dbo.tbl_stg_property p ON b.SSN = p.SSN
ORDER BY CAST(l.LoanAmount AS INT) DESC;
```

**Finding:** A single query joining all 4 staging tables into one row per borrower —
every borrower's state, marital status, rent/own status, loan purpose, referral source,
loan amount, property usage, income, and calculated risk level, all in one place.

**Talking point:** "This is the master view I used as the data source for my Power BI
dashboard — instead of connecting Power BI to 4 separate tables and building
relationships there, I pre-joined everything in SQL into one clean, denormalized view
that's ready for reporting. It's also the single query I'd point to if someone asked
'walk me through the whole dataset in one shot.'"

---

## Skills demonstrated across this project
- INNER JOIN across 2, 3, and 4 tables
- GROUP BY with multiple aggregate functions (COUNT, SUM, AVG)
- CAST for handling text-stored numeric data (a real-world data quality issue, not just
  a textbook exercise)
- CASE statements for calculated business logic (risk scoring)
- ORDER BY and TOP N for ranking/executive-level views
- Writing SQL that answers a stated business question, not just "showing the data"
