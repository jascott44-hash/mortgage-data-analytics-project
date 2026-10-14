sql
-- ============================================================
-- Mortgage Portfolio Analysis Queries
-- Project 2: SQL Analysis
-- Database: Mortgage_Portfolio
-- NOTE: tbl_stg_loan columns (LoanAmount, PurchasePrice, etc.) are
-- stored as VARCHAR, so CAST(... AS INT) is used wherever math or
-- numeric comparison is needed on those columns.
-- ============================================================

USE Mortgage_Portfolio;

-- =============================================
-- Query 1: Total Loan Amount by State
-- Business Question: Which states have the highest loan volume?
-- =============================================
SELECT 
    b.State,
    COUNT(l.LoanID) AS TotalApplications,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_borrower b
JOIN dbo.tbl_stg_loan l ON b.SSN = l.SSN
GROUP BY b.State
ORDER BY TotalLoanAmount DESC;

-- =============================================
-- Query 2: Applications by Referral Source
-- Business Question: Which referral source brings in the most business?
-- =============================================
SELECT 
    l.Referral,
    COUNT(l.LoanID) AS TotalApplications,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_loan l
GROUP BY l.Referral
ORDER BY TotalApplications DESC;

-- =============================================
-- Query 3: Average Income by Loan Purpose
-- Business Question: Do refinance or purchase borrowers have higher income?
-- =============================================
SELECT 
    l.PurposeOfLoan,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(f.MonthlyIncome AS INT)) AS AvgMonthlyIncome,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount
FROM dbo.tbl_stg_loan l
JOIN dbo.tbl_stg_financial f ON l.SSN = f.SSN
GROUP BY l.PurposeOfLoan
ORDER BY AvgLoanAmount DESC;

-- =============================================
-- Query 4: Rent vs Own Analysis
-- Business Question: Are renters or homeowners applying for more loans?
-- =============================================
SELECT 
    f.RentOrOwn,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount
FROM dbo.tbl_stg_financial f
JOIN dbo.tbl_stg_loan l ON f.SSN = l.SSN
GROUP BY f.RentOrOwn
ORDER BY TotalApplications DESC;

-- =============================================
-- Query 5: Property Usage Breakdown
-- Business Question: What types of properties are borrowers applying for?
-- =============================================
SELECT 
    p.PropertyUsage,
    COUNT(l.LoanID) AS TotalApplications,
    AVG(CAST(l.LoanAmount AS INT)) AS AvgLoanAmount,
    SUM(CAST(l.LoanAmount AS INT)) AS TotalLoanAmount
FROM dbo.tbl_stg_property p
JOIN dbo.tbl_stg_loan l ON p.SSN = l.SSN
GROUP BY p.PropertyUsage
ORDER BY TotalApplications DESC;

-- =============================================
-- Query 6: Marital Status vs Loan Amount
-- Business Question: Does marital status affect loan amounts or income?
-- =============================================
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

-- =============================================
-- Query 7: Top 5 Highest Loan Amounts
-- Business Question: Who are our highest value borrowers?
-- =============================================
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

-- =============================================
-- Query 8: Risk Level Analysis
-- Business Question: Which borrowers are stretching themselves financially?
-- =============================================
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

-- =============================================
-- Query 9: Executive Summary View
-- Business Question: Complete borrower profile with risk assessment
-- =============================================
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
