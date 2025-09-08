#legacySQL
-- Next Page Path analysis (written ~2016, preserved as-is)
-- This query uses BigQuery Legacy SQL syntax and is against the now depracated GA Universal Analytics schema. See /docs/ for notes.

SELECT
step, IF(nextStep IS NULL,'> EXIT SITE',nextStep)  as nextStep,
stepOnePageviews,
pageviews AS nextStepPageviews,
ROUND((pageviews/stepOnePageviews)*100,2) AS percToNextStep
FROM (
SELECT 
step, nextStep,
EXACT_COUNT_DISTINCT(sessionId) as uniquePageviews,
EXACT_COUNT_DISTINCT(sessionHitId) as pageviews,
SUM(uniquePageviews) OVER (PARTITION BY step) stepOneUniquePageviews,
SUM(pageviews) OVER (PARTITION BY step) stepOnePageviews,
FROM (
SELECT
sessionId, hitNumber,
CONCAT(STRING(sessionId),STRING(hitNumber)) as sessionHitId,
step, nextStep
FROM (
SELECT 
CONCAT(STRING(fullVisitorId),
STRING(visitId)) as sessionId, hits.hitNumber as hitNumber,
hits.type as hitType, hits.page.pagePath as step,
-- optional to use ROW_NUMBER() if you wish to add detailed conditions 
ROW_NUMBER() OVER (PARTITION BY sessionId ORDER BY hitNumber ASC) rowNumber,  
LEAD(step, 1) OVER (PARTITION BY sessionId ORDER BY hitNumber ASC) nextStep
FROM
(TABLE_DATE_RANGE([XXXXXXXX.ga_sessions_],
DATE_ADD(CURRENT_TIMESTAMP(), -30, 'DAY'),
CURRENT_TIMESTAMP()))
WHERE hits.type = 'PAGE' )
WHERE step = 'www.example.com/page-path' )
GROUP BY step, nextStep
)
ORDER BY pageviews DESC
