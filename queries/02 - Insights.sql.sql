-- KPIs
-- Number of Patients
SELECT count(distinct table1.patient_id) from table1;
SELECT count(distinct table2.patient_id) from table2;

-- Number of lesions
SELECT count(table2.lesion_id) from table2;

--Lesion Distribution
SELECT diagnostic, count (*) as "LesionCount"
FROM table2
Group BY diagnostic;


-- BIOPSY ANALYSIS
-- No of biopsed cases vs non-biopsed cases
SELECT 
  CASE 
    WHEN biopsed = TRUE THEN 'Biopsied'
    WHEN biopsed = FALSE THEN 'Not Biopsied'
    ELSE 'Unknown'
  END AS "BiopsyStatus",
  COUNT(*) AS "LesionCount",
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) || '%' AS "PctOfTotal"
FROM table2
GROUP BY biopsed;

-- Unconfirmed lesion
Select l.diagnostic,
	count(*) as "LesionCount"
from table2 l
Where l.biopsed = False
Group By l.diagnostic 
ORDER By "LesionCount" DESC;

-- Biopsy confirmation rate per lesion type
SELECT 
  diagnostic,
  COUNT(*) AS "TotalLesions",
  COUNT(*) FILTER (WHERE biopsed = TRUE) AS "BiopsiedCount",
  ROUND(100.0 * COUNT(*) FILTER (WHERE biopsed = TRUE) / COUNT(*), 1) || '%' AS "BiopsyRate"
FROM table2
GROUP BY diagnostic
ORDER BY "BiopsyRate";

-- Categorized Lesion TYPES
SELECT diagnostic, 
  CASE 
    WHEN l.diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'Malignant'
    WHEN l.diagnostic = 'ACK' THEN 'Pre-Malignant'
    WHEN l.diagnostic IN ('NEV', 'SEK') THEN 'Benign'
  END AS "LesionType",
  COUNT(*) AS "LesionCount",
  round(100 * count(*)/sum(count(*)) OVER (), 1)|| '%' as "LesionPct"
from table2 l
GROUP BY l.diagnostic
Order By "LesionType", "LesionCount" Desc;


-- Lesion Classifications
-- How many confirmed lesions per patient are present in the dataset?
SELECT diagnostic, fitspatrick, COUNT(*) AS "LesionCount"
FROM table2
WHERE biopsed = TRUE
GROUP BY fitspatrick, diagnostic
Having COUNT(*) > 4
ORDER BY diagnostic, fitspatrick ASC;

-- Average Lesion Size by Skin Cancer Type
SELECT 
  diagnostic,
  ROUND(AVG((diameter_1 + diameter_2) / 2.0)::numeric, 2) AS "AvgDiameter"
FROM table2
GROUP BY diagnostic
ORDER BY "AvgDiameter" DESC;


-- Symptomatic Patterns by Skin cancer Categorization


-- Develop a SQL database for students to practice joining clinical and lesion
-- data for effective skin cancer analysis.
SELECT * from table1
JOIN table2 ON table1.patient_id = table2.patient_id;

-- 1. Join Clinical and Lesion Data for Effective Analysis
-- Which patients have had biopsy-confirmed lesions?
SELECT count(patient_id) as "BiopsedCount"
from table2
where biopsed = TRUE;


-- What is the average lesion size by skin type?
SELECT fitspatrick, diagnostic,
	round(CAST(PI() * (avg(diameter_1)/2) * (avg(diameter_2)/2)as numeric), 2)
		as "EstLesionArea"
FROM table2
WHERE biopsed = true
GROUP BY fitspatrick, diagnostic
ORDER BY diagnostic, fitspatrick;

--Compare Estimated Lesion Area by Diagnostic Type Only
SELECT diagnostic,
	round(CAST(PI() * (avg(diameter_1)/2) * (avg(diameter_2)/2)as numeric), 2)
		as "EstLesionArea"
FROM table2
WHERE biopsed = true and fitspatrick between 1 and 6
GROUP BY diagnostic
ORDER BY "EstLesionArea";



-- 2. Identify Environmental & Demographic Risk Factors
-- Is there a correlation between environmental factors and lesion types?
SELECT * from table2

SELECT l.diagnostic, COUNT(*) AS "LesionCount",
	Sum(Case When p.pesticide = true then 1 ELSE 0 END) as "PesticideExposed",
	round(sum(case when p.pesticide = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "PestExpPerct",
	Sum(Case When p.smoke = true then 1 ELSE 0 END) as "SmokeExposed",
	round(sum(case when p.smoke = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "SmokeExpPerct",
	Sum(Case When p.drink = true then 1 ELSE 0 END) as "DrinkExposed",
	round(sum(case when p.drink = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "DrinkExpPerct",
	Sum(Case When p.has_piped_water = false then 1 ELSE 0 END) as "NoPipedWater",
	round(sum(case when p.has_piped_water = false then 1 ELSE 0 END)*100/count (*))::text ||'%' as "NoPipedWaterPerct",
	Sum(Case When p.has_sewage_system = false then 1 ELSE 0 END) as "NoSewage",
	round(sum(case when p.has_sewage_system = false then 1 ELSE 0 END)*100/count (*))::text ||'%' as "NoSewagePerct"
FROM table1 p
JOIN table2 l ON p.patient_id = l.patient_id
WHERE l.diagnostic IS NOT NULL
GROUP BY diagnostic
ORDER BY diagnostic;


-- Is there a correlation between environmental factors and categorized lesion types?
SELECT 
  CASE 
    WHEN l.diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'Malignant'
    WHEN l.diagnostic IN ('NEV', 'SEK') THEN 'Benign'
    WHEN l.diagnostic = 'ACK' THEN 'Pre-malignant'
  END AS "LesionType",
  COUNT(*) AS "LesionCount",
	Sum(Case When p.pesticide = true then 1 ELSE 0 END) as "PesticideExposed",
	round(sum(case when p.pesticide = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "PestExpPerct",
	Sum(Case When p.smoke = true then 1 ELSE 0 END) as "SmokeExposed",
	round(sum(case when p.smoke = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "SmokeExpPerct",
	Sum(Case When p.drink = true then 1 ELSE 0 END) as "DrinkExposed",
	round(sum(case when p.drink = true then 1 ELSE 0 END)*100/count (*))::text ||'%' as "DrinkExpPerct",
	Sum(Case When p.has_piped_water = false then 1 ELSE 0 END) as "NoPipedWater",
	round(sum(case when p.has_piped_water = false then 1 ELSE 0 END)*100/count (*))::text ||'%' as "NoPipedWaterPerct",
	Sum(Case When p.has_sewage_system = false then 1 ELSE 0 END) as "NoSewage",
	round(sum(case when p.has_sewage_system = false then 1 ELSE 0 END)*100/count (*))::text ||'%' as "NoSewagePerct"
FROM table1 p
JOIN table2 l ON p.patient_id = l.patient_id
GROUP BY "LesionType"
ORDER BY "LesionType";


--malignant VS Benign (Symptomatic Cases)
SELECT 
  CASE 
    WHEN diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'Malignant'
    WHEN diagnostic IN ('NEV', 'SEK') THEN 'Benign'
    WHEN diagnostic = 'ACK' THEN 'Pre-malignant'
  END AS "LesionType",
  COUNT(*) AS "LesionCount",
  SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) AS "GrewCount",
  ROUND(SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctGrew",
  SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) AS "BleedCount",
  ROUND(SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctBleed",
  SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) AS "ItchCount",
  ROUND(SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctItch",
  SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) AS "HurtCount",
  ROUND(SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctHurt",
  SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) AS "ChangedCount",
  ROUND(SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctChanged",
  SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) AS "ElevationCount",
  ROUND(SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctElevation"
FROM table2
GROUP BY "LesionType";



-- Do demographic factors and patients with a family history of cancer have more malignant lesions?
SELECT 
  CASE 
    WHEN l.diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'Malignant'
    WHEN l.diagnostic IN ('NEV', 'SEK') THEN 'Benign'
    WHEN l.diagnostic = 'ACK' THEN 'Pre-Malignant'
  END AS "LesionType",
  COUNT(*) AS "LesionCount",
  CASE 
  	WHEN p.age < 18 THEN 'Children'
	WHEN p.age < 30 THEN 'Young Adult'
  	WHEN p.age BETWEEN 30 AND 50 THEN 'Middle Aged'
  	ELSE 'Aged'
 END AS "Age_Group",
  SUM(CASE WHEN p.skin_cancer_history = TRUE THEN 1 ELSE 0 END) AS "SkinCancerHistCount",
  ROUND(SUM(CASE WHEN p.skin_cancer_history = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctSkinCancer",
  SUM(CASE WHEN p.cancer_history = TRUE THEN 1 ELSE 0 END) AS "CancerHistCount",
  ROUND(SUM(CASE WHEN p.cancer_history = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::text || '%' AS "PctCancerHist"
FROM table2 l
JOIN table1 p ON l.patient_id = p.patient_id
GROUP BY "LesionType", "Age_Group"
ORDER BY "Age_Group";

-- Gender distribution
SELECT p.gender,
	CASE 
    WHEN l.diagnostic IN ('BCC', 'SCC', 'MEL') THEN 'Malignant'
    WHEN l.diagnostic IN ('NEV', 'SEK') THEN 'Benign'
    WHEN l.diagnostic = 'ACK' THEN 'Pre-Malignant'
  END AS "LesionType",
  COUNT(*) AS "LesionCount",
  round(100* count (*)/sum(count(*)) OVER (), 1)|| '%' as "PerCount"
FROM table1 p
JOIN table2 l on l.patient_id = p.patient_id
GROUP BY p.gender,"LesionType"
ORDER By p.gender DESC;


-- Are certain ethnic backgrounds associated with a higher number of lesions?
SELECT l.diagnostic,
	   p.background_father,
	   p.background_mother,
	   COUNT(*) AS lesion_count
FROM table1 p
JOIN table2 l ON l.patient_id = p.patient_id
WHERE biopsed = TRUE
GROUP BY p.background_father, p.background_mother, diagnostic
ORDER BY lesion_count DESC
LIMIT 10;




-- 3. Analyze Lesion Characteristics for Patterns
-- Do lesions that hurt or bleed correlate with malignancy?
SELECT 
  CASE 
    WHEN diagnostic IN ('BCC', 'MEL', 'SCC') THEN 'Malignant'
    WHEN diagnostic IN ('NEV', 'SEK') THEN 'Benign'
    WHEN diagnostic = 'ACK' THEN 'Pre-malignant'
  END AS LesionType,
  COUNT(*) AS LesionCount,
  SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) AS GrewCount,
  ROUND(SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctGrew,
  SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) AS BleedCount,
  ROUND(SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctBleed,
  SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) AS ItchCount,
  ROUND(SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctItch,
  SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) AS HurtCount,
  ROUND(SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctHurt,
  SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) AS ChangedCount,
  ROUND(SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctChanged,
  SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) AS ElevationCount,
  ROUND(SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctElevation
FROM table2
GROUP BY LesionType
ORDER BY LesionType;


-- Which body regions are most frequently affected by BCC or MEL?
SELECT 
  region, diagnostic,
  'Malignant' AS LesionType,
  COUNT(*) AS LesionCount,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) || '%' AS PctOfTotal
FROM table2
WHERE diagnostic IN ('BCC', 'MEL')
GROUP BY region, diagnostic
ORDER BY pctoftotal DESC;

  

-- 4. Create ML-Ready Structured Data
Select * from table2
Select l.patient_id, l.lesion_id, p.age, p.gender, l.fitspatrick, p.smoke, p.drink, p.pesticide,
	l.itch, l.bleed, l.grew, l.changed, l.diagnostic, l.region, l.biopsed
	ROUND(AVG((l.diameter_1 + l.diameter_2) / 2.0)::numeric) AS "AvgDiameter"
from table1 p
JOIN table2 l ON l.patient_id = p.patient_id
GROUP BY l.patient_id, l.lesion_id, p.age, p.gender, l.fitspatrick, p.smoke, p.drink, p.pesticide,
	l.itch, l.bleed, l.grew, l.changed, l.diagnostic;

-- 5. Enhance Dermatological Research

-- How common is biopsy confirmation for each lesion type?
Select l.diagnostic, count (*) as "ConfirmedBiopsed"
from table2 l
Where l.biopsed = true
GROUP BY l.diagnostic, l.biopsed;



-- Are certain lesion symptoms more prevalent in younger vs. older patients?
SELECT l.itch,l.bleed,l.changed,l.hurt,
	Case
		When p.age < 18 THEN 'Children'
		When p.age < 30 THEN 'YoungAdult'
		When p.age < 50 THEN 'MiddleAged'
		Else 'Aged' END as "AgeGroup",
	count (*) AS "LesionCount"
FROM table1 p
JOIN table2 l on l.patient_id = p.patient_id
WHERE l.itch = true and l.bleed = true and l.hurt = true and l.changed = True
GROUP BY l.itch, l.bleed, l.changed, l.hurt, "AgeGroup";


-- Does lesion location vary by gender?
SELECT l.region,
	Case
		When p.age < 18 THEN 'Children'
		When p.age < 30 THEN 'YoungAdult'
		When p.age < 50 THEN 'MiddleAged'
		Else 'Aged' END as "AgeGroup",
	count (*) AS "LesionCount",
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY l.region), 1) || '%' AS "PctCount"
FROM table1 p
JOIN table2 l on l.patient_id = p.patient_id
GROUP BY l.region, "AgeGroup";
		

-- Unconfirmed Lesion Vs Symptoms
Select l.diagnostic, l.fitspatrick,
	count(*) as "LesionCount",
SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) AS GrewCount,
  ROUND(SUM(CASE WHEN grew = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctGrew,
  SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) AS BleedCount,
  ROUND(SUM(CASE WHEN bleed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctBleed,
  SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) AS ItchCount,
  ROUND(SUM(CASE WHEN itch = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctItch,
  SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) AS HurtCount,
  ROUND(SUM(CASE WHEN hurt = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctHurt,
  SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) AS ChangedCount,
  ROUND(SUM(CASE WHEN changed = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctChanged,
  SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) AS ElevationCount,
  ROUND(SUM(CASE WHEN elevation = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) || '%' AS PctElevation
  from table2 l
Where l.biopsed = False
Group By l.diagnostic, l.fitspatrick
ORDER By l.fitspatrick;