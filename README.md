# Example scripts for next page or event path analysis using SQL/BigQuery
Here are some example scripts using both [BigQuery SQL](#BigQuery) and [PostgreSQL (Amazon Redshift)](#Redshift) dialects. Scripts will follow a common business question.

##BigQuery

**1) What are our conversion rates for users starting registration through to purchase at a session level?**

*(Example includes the inclusion of Google Analytics custom dimensions and an expression to evaluate a landing page)*

```sql
SELECT 
a.date as date,
a.user AS userId,
a.sessionId as sessionId,
b.clientId as clientId,
b.promo_code as promo_code,
a.geo_country as geo_country,
a.device_category as device_category,
a.operating_system as operating_system, 
a.browser as browser,
CASE WHEN a.medium ="cpc" THEN "PPC" WHEN a.medium = "organic" THEN "SEO" 
WHEN a.source = "(direct)" and a.medium = "(none)" THEN "Direct" WHEN a.medium = "referral" THEN "Referral"
WHEN a.medium = "Email" THEN "Email"
ELSE "Others"
END as channel_grouping,
b.landing_page as landing_page,
EXACT_COUNT_DISTINCT(a.sessionId) as session,
COUNT (CASE WHEN LOWER(a.event_action) = "started registration" THEN a.event_action END ) as StartReg_count,
COUNT (CASE WHEN LOWER(a.event_action) = "completed registration" THEN a.event_action END ) as EndReg_count,
COUNT (CASE WHEN LOWER(a.event_action) = "purchased" THEN a.event_action END ) as Purchase_count,
COUNT (CASE WHEN LOWER(a.event_action) = "registration blocked" THEN a.event_action END ) as Block_count,
COUNT (CASE WHEN LOWER(a.event_action) = "registration error" THEN a.event_action END ) as Error_count,
COUNT (CASE WHEN LOWER(a.event_label) = "email_already_registered" THEN a.event_label END ) as Email_reject,
COUNT (CASE WHEN REGEXP_MATCH(GROUP_CONCAT_UNQUOTED (LOWER(a.event_action)),
r"(started registration)") THEN a.sessionId END ) as StartReg,
COUNT (CASE WHEN REGEXP_MATCH(GROUP_CONCAT_UNQUOTED (LOWER(a.event_action)),
r"(started registration,completed registration)") THEN a.sessionId END ) as StartReg_EndReg,
COUNT (CASE WHEN REGEXP_MATCH(GROUP_CONCAT_UNQUOTED (LOWER(a.event_action)),
r"(started registration,completed registration,purchased)") THEN a.sessionId END ) as StartReg_EndReg_Purchase,
GROUP_CONCAT (a.event_action) as event_action_hit_path -- provides a check
FROM (
  SELECT
  date,
  CONCAT([fullVisitorId], STRING([visitId])) as a.sessionId,
  fullVisitorId AS user,
  geoNetwork.country as geo_country,
  trafficSource.source as source,
  trafficSource.medium as medium,
  device.deviceCategory as device_category,
  device.operatingSystem as operating_system,
  device.browser as browser,
  LOWER(hits.eventInfo.eventAction) as event_action,
  LOWER(hits.eventInfo.eventLabel) as event_label 
  FROM (TABLE_DATE_RANGE([XXXXXXXX.ga_sessions_], 
  TIMESTAMP("2016-07-10"),TIMESTAMP("2016-07-08")))  
  WHERE LOWER(hits.eventInfo.eventAction) 
  IN ("started registration","completed registration","email already registered",
  "registration error", "purchased")
  GROUP EACH BY date, user, a.sessionId, geo_country, source, medium, device_category, 
  operating_system, browser, event_action, event_label
  ORDER BY a.sessionId ASC
) a
JOIN EACH(
  SELECT
  CONCAT([fullVisitorId], STRING([visitId])) as b.sessionId,
  --MAX(IF(... provides a workaround for custom dimensions which are nested within the hits field
  MAX(IF(hits.customDimensions.index=1,hits.customDimensions.value,NULL)) AS clientId, 
  MAX(IF(customDimensions.index=65,customDimensions.value,NULL)) AS promo_code,
  --evaluate landing page with the 'FIRST' function
  FIRST(CASE WHEN hits.type = "PAGE" THEN hits.page.pagePath ELSE "UNKNOWN" END) as landing_page 
  FROM (TABLE_DATE_RANGE([XXXXXXXX.ga_sessions_], TIMESTAMP("2016-07-10"),
  TIMESTAMP("2016-07-08")))   
  GROUP EACH BY b.sessionId
) b
ON a.sessionId = b.sessionId
GROUP EACH BY date, geo_country, userId, sessionId, a.sessionId, clientId, promo_code, channel_grouping,
landing_page, device_category, operating_system, browser
HAVING StartReg > 0;
```
**2) When a user views a certain page, where do they go?**

```sql
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
SELECT sessionId, hitNumber, CONCAT(STRING(sessionId),STRING(hitNumber)) as sessionHitId, step, nextStep
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
```
 
