create table hospital_data (
Hospital_name varchar (50) ,
Locations varchar (50) ,
Department varchar (50) ,
Doctors_Count int ,
Patients_Count int ,
Admission_Date date ,
Discharge_Date date ,
Medical_Expenses Decimal (10,2)

);
-- ============================================================
-- PROJECT   : Hospital Data Analysis
-- AUTHOR    : Rupesh Gupta
-- TOOL      : PostgreSQL
-- DATE      : March 2026
-- DATASET   : 100 hospital records across 10 Indian cities
-- ============================================================
 
DROP TABLE IF EXISTS hospital_data;
 
create table hospital_data (
Hospital_name varchar (50) ,
Locations varchar (50) ,
Department varchar (50) ,
Doctors_Count int ,
Patients_Count int ,
Admission_Date date ,
Discharge_Date date ,
Medical_Expenses Decimal (10,2)

);
 
-- ================================
-- Q1: City-wise Medical Burden
-- ================================
SELECT locations AS city,
       SUM(medical_expenses) AS total_expenses,
       SUM(patients_count) AS total_patients
FROM hospital_data
GROUP BY locations
ORDER BY total_expenses DESC;
 
/* Q1 Key Insights:
- Ahmedabad = highest expenses (₹5.2L) but Jaipur = most patients (1505)
- Jaipur is more cost efficient than Ahmedabad
- Pune: only 555 patients but high expenses = overcharging risk
- Recommendation: Study Jaipur low-cost model for other cities */
 
-- ================================
-- Q2: Long Stay Low Expense Cases
-- ================================

SELECT *, (discharge_date - admission_date) AS days_stay
FROM hospital_data
WHERE (discharge_date - admission_date) > 10
AND medical_expenses < 15000
ORDER BY locations DESC;
 
/* Q2 Key Insights:
- 11 cases found with 10+ day stay but expenses under ₹15,000
- Heritage Hospital Urology: 172 patients, 12 days = only ₹40/patient/day
- Jaipur has most anomaly cases (4 out of 11)
- Recommendation: Audit Heritage Hospital & Jaipur billing records */
 
-- ================================
-- Q3: Avg Expenses Per Department
-- ================================

SELECT department,
       ROUND(AVG(medical_expenses), 2) AS avg_expenses
FROM hospital_data
GROUP BY department
ORDER BY avg_expenses DESC;
 
/* Q3 Key Insights:
- Orthopedics = most expensive (₹35,124) = surgeries & implants drive costs
- Cardiology = most cost efficient (₹21,702) = lowest avg expenses
- Gap = ₹13,421 = significant variation (Cardiology treats heart patients yet cheapest)
- Recommendation: Investigate why Orthopedics costs 60% more than Cardiology */
 
-- =================================
-- Q4: Cities With Patients > 1000
-- =================================

SELECT locations,
       SUM(patients_count) AS total_patients
FROM hospital_data
GROUP BY locations
HAVING SUM(patients_count) > 1000
ORDER BY total_patients DESC;
 
/* Q4 Key Insights:
- Only 4 of 10 cities crossed 1000 patients = concentrated medical burden
- Jaipur (1505) most patients yet cost efficient = best practice model
- Ahmedabad (1467) high patients + highest expenses (Q1) = double crisis
- Recommendation:
  1. Apply Jaipur cost model to Ahmedabad immediately
  2. Add beds, doctors, hospitals in all 4 cities
  3. Investigate top diseases + run prevention camps */
 
-- ==================================================
-- Q5: Hospital Benchmarking (Highest vs Lowest Cost)
-- ==================================================

SELECT hospital_name,
       ROUND(AVG(medical_expenses), 2) AS avg_expenses
FROM hospital_data
GROUP BY hospital_name
ORDER BY avg_expenses DESC
LIMIT 1;
 
SELECT hospital_name,
       ROUND(AVG(medical_expenses), 2) AS avg_expenses
FROM hospital_data
GROUP BY hospital_name
ORDER BY avg_expenses ASC
LIMIT 1;
 
/* Q5 Key Insights:
- City Hospital = highest avg expenses (₹34,798) = most expensive
- Green Valley = lowest avg expenses (₹20,273) = most cost efficient
- Gap = ₹14,525 = benchmarking opportunity
- Recommendation: City Hospital should adopt Green Valley's
  cost model to reduce expenses by 30% */
 
-- =====================================
-- Q6: Cities With Total Patients > 1200
-- =====================================

SELECT locations AS city,
       SUM(patients_count) AS total_patients
FROM hospital_data
GROUP BY locations
HAVING SUM(patients_count) > 1200
ORDER BY total_patients DESC;
 
/* Q6 Key Insights:
- 4 cities crossed 1200 patients = Jaipur, Ahmedabad, Lucknow, Hyderabad
- High patients not always negative = better infrastructure attracts patients
- Good connectivity + health awareness = more hospital visits
- Cities with low patients (Delhi, Mumbai) may have access issues
- Recommendation: Build similar infrastructure in low-patient
  cities to improve healthcare access */
 
-- ===================================================
-- Q7: Hospitals Above Overall Avg Expenses (Subquery)
-- ===================================================

SELECT hospital_name,
       ROUND(AVG(medical_expenses), 2) AS avg_expenses
FROM hospital_data
GROUP BY hospital_name
HAVING AVG(medical_expenses) > (
    SELECT AVG(medical_expenses)
    FROM hospital_data
)
ORDER BY avg_expenses DESC;
 
/* Q7 Key Insights:
- Overall avg expenses = ₹27,173
- 5 out of 9 hospitals are above overall average
- City Hospital highest (₹34,798) = ₹7,625 above average
- Heritage & Green Valley below average = cost efficient hospitals
- Recommendation: Top 5 hospitals should audit billing practices
  and benchmark against Heritage & Green Valley */
 
-- ============================================
-- Q8: Hospital Expense Ranking (Window Function)
-- ============================================

SELECT hospital_name,
       SUM(medical_expenses) AS total_expenses,
       RANK() OVER (ORDER BY SUM(medical_expenses) DESC) AS expense_rank,
       MAX(SUM(medical_expenses)) OVER () -
           SUM(medical_expenses) AS diff_from_top,
       ROUND(SUM(medical_expenses) * 100.0 /
           MAX(SUM(medical_expenses)) OVER (), 2) AS pct_of_top
FROM hospital_data
GROUP BY hospital_name
ORDER BY total_expenses DESC;
 
/* Q8 Key Insights:
- Healing Touch = Rank 1 (₹3.52L) vs Green Valley = Rank 10 (₹1.62L)
- Gap = ₹1.89L = 46% difference between top and bottom hospital
- Such a large gap needs investigation = possible overbilling or underfunding
- Mid-ranked hospitals (Apollo, Sunrise) are close to average = stable
- Recommendation: Audit Healing Touch billing practices and
  investigate why Green Valley expenses are 46% lower than top */