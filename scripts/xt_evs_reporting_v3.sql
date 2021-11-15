SELECT
	btj.BTJobID AS JOB_ID,
	btjcrt.Name AS JOB_CREATE_REASON_TYPE,
	initial_priority_status_type.InitialPriorityStatusType AS INITIAL_PRIORITY_STATUS_TYPE,
	c.CampusID AS CAMPUS_ID,
	c.Name AS CAMPUS_NAME,
	e.EnterpriseID AS ENTERPRISE_ID,
	e.Name AS ENTERPRISE,
	discipline.DisciplineID AS DISCIPLINE_ID,
	discipline.DisciplineName AS DISCIPLINE_NAME,
	b.BuildingID AS BUILDING_ID,
	b.Name AS BUILDING,
	location_info.UnitID AS UNIT_ID,
	location_info.UnitName AS UNIT_NAME,
	location_info.UnitCategoryID AS UNIT_CATEGORY_ID,
	location_info.UnitCategoryName AS UNIT_CATEGORY,
	location_info.LocationID AS LOCATION_ID,
	location_info.LocationName AS LOCATION_NAME,
	location_info.FloorID AS FLOOR_ID,
	location_info.FloorName AS FLOOR_NAME,
	location_info.RoomID AS ROOM_ID,
	location_info.RoomName AS ROOM_NAME,
	btj.CreatedDate AS EVENT_TIMESTAMP,
	btj.CreatedDate AS CREATED_TIMESTAMP,
	btj.LastModDate AS LastModDate,
	inprogress_timestamp.InprogressTimestamp AS INPROGRESS_TIMESTAMP,
	first_delay_reason.FirstDelayTimestamp AS FIRST_DELAY_TIMESTAMP,
	first_delay_reason.FirstDelayReason AS FIRST_DELAY_REASON,
	first_suspended_reason.FirstSuspendedTimestamp AS FIRST_SUSPENDED_TIMESTAMP,
	first_suspended_reason.FirstSuspendedReason AS FIRST_SUSPENDED_REASON,
	DATEDIFF(minute, first_delay_reason.FirstDelayTimestamp, inprogress_timestamp.InprogressTimestamp) AS DELAY_TO_INPROGRESS,
	DATEDIFF(minute, first_suspended_reason.FirstSuspendedTimestamp, inprogress_timestamp.InprogressTimestamp) AS SUSPEND_TO_INPROGRESS,
	bt_job_summary.CancelledDateTime AS CANCELLED_TIMESTAMP,
	cancelled_reason.CancelledReason AS CANCELLED_REASON,
	CASE
		WHEN cancelled_by_user.FirstName = '' AND cancelled_by_user.LastName = '' THEN NULL
		WHEN cancelled_by_user.FirstName = '' THEN cancelled_by_user.LastName
		ELSE CONCAT(cancelled_by_user.LastName, ', ', cancelled_by_user.FirstName)
	END AS CANCELLED_BY_USER,
	bt_job_summary.CompleteDateTime AS COMPLETED_TIMESTAMP,
	CASE
		WHEN completed_by_user.FirstName = '' AND completed_by_user.LastName = '' THEN NULL
		WHEN completed_by_user.FirstName = '' THEN completed_by_user.LastName
		ELSE CONCAT(completed_by_user.LastName, ', ', completed_by_user.FirstName)
	END AS COMPLETED_BY_USER,
	CAST(ROUND(bt_job_summary.TotalInProgressTime / 60.0, 2) AS NUMERIC(36,2)) AS TOTAL_INPROGRESS_TIME,
	CAST(ROUND(bt_job_summary.OverallTurnTime / 60.0, 2) AS NUMERIC(36,2)) AS OVERALL_TURN_TIME,
	CAST(ROUND(bt_job_summary.OriginalResponseTime / 60.0, 2) AS NUMERIC(36,2)) AS ORIGINAL_RESPONSE_TIME,
	CASE
		WHEN bt_job_summary.TotalInProgressTime <= 300 OR bt_job_summary.TotalInProgressTime > 3600 OR bt_job_summary.OriginalResponseTime >= 7200 THEN 'Y'
		ELSE 'N'
	END AS ADJUSTED_CLEANS_FLAG,
	btjst.BTJobStatusTypeID AS JOB_STATUS_TYPE_ID,
	btjst.Name AS JOB_STATUS_TYPE,
	btjt.BTJobTypeID AS JOB_TYPE_ID,
	btjt.Name AS JOB_TYPE,
	bt_job_source.AccessPointName AS BT_JOB_SOURCE,
	CASE
		WHEN eu.FirstName = '' THEN eu.LastName
		ELSE CONCAT(eu.LastName, ', ', eu.FirstName)
	END AS REQUESTER,
	employee_category.EmployeeCategoryName AS EMPLOYEE_CATEGORY,
	isolation_type.IsolationType AS ISOLATION_TYPE,
	spill_clean_type.NAME AS SPILL_CLEAN_TYPE,
	CASE
		WHEN udef.CurrentStatusTypeName = 'Udef8' THEN 'Y'
		ELSE 'N'
	END AS UDEF8,
	CASE
		WHEN udef.CurrentStatusTypeName = 'Udef9' THEN 'Y'
		ELSE 'N'
	END AS UDEF9,
	CASE
		WHEN blocked_bed_reason.BTStatusMappingTypeName = 'Blocked' THEN blocked_bed_reason.ReasonCode
		ELSE NULL
	END AS BLOCKED_BED_REASON,
	CASE
		WHEN last_upgrade_status.BTStatusMappingTypeName IN ('Blocked', 'Udef9', 'Udef8', 'Stat', 'Next') THEN last_upgrade_status.BTStatusMappingTypeName
		ELSE NULL
	END AS LAST_UPGRADE_STATUS
FROM [dbo].BTJob AS btj
INNER JOIN [dbo].BTJobCreateReasonType AS btjcrt
ON btj.BTJobCreateReasonTypeID = btjcrt.BTJobCreateReasonTypeID
INNER JOIN [dbo].Campus AS c
ON btj.CampusID = c.CampusID
INNER JOIN [dbo].Enterprise AS e
ON c.EnterpriseID = e.EnterpriseID
INNER JOIN [dbo].Building AS b
ON c.CampusID = b.BuildingID
INNER JOIN
(
	SELECT
		btj.BTJobID,
		l.LocationID AS LocationID,
		l.Name AS LocationName,
		r.RoomID AS RoomID,
		r.Name AS RoomName,
		f.FloorID AS FloorID,
		f.Name AS FloorName,
		u.UnitID AS UnitID,
		u.Name AS UnitName,
		uct.UnitCategoryTypeID AS UnitCategoryID,
		uct.Name AS UnitCategoryName
	FROM [dbo].BTJob AS btj
	INNER JOIN [dbo].Location AS l
	ON btj.LocationID = l.LocationID
	INNER JOIN [dbo].Room AS r
	ON l.RoomID = r.RoomID
	INNER JOIN [dbo].[Floor] AS f
	ON r.FloorID = f.FloorID
	INNER JOIN [dbo].Unit AS u
	ON r.UnitID = u.UnitID
	LEFT JOIN [dbo].UnitCategoryType AS uct
	ON u.UnitCategoryTypeID = uct.UnitCategoryTypeID
) AS location_info
ON btj.BTJobID = location_info.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		btjs.CancelledDateTime AS CancelledDateTime,
		btjs.CompleteDateTime AS CompleteDateTime,
		btjs.TotalInProgressTime AS TotalInProgressTime,
		btjs.OverallTurnTime AS OverallTurnTime,
		btjs.OriginalResponseTime AS OriginalResponseTime
	FROM [dbo].BTJob AS btj
	LEFT JOIN [dbo].BTJobSummary AS btjs
	ON btj.BTJobID = btjs.BTJobID
) AS bt_job_summary
ON btj.BTJobID = bt_job_summary.BTJobID
INNER JOIN [dbo].BTJobStatusType btjst
ON btj.BTJobStatusTypeID = btjst.BTJobStatusTypeID
INNER JOIN [dbo].BTJobType btjt
ON btj.BTJobTypeID = btjt.BTJobTypeID
LEFT JOIN
(
	SELECT
		btjh.BTJobID AS BTJobID,
		MAX(btjh.BTJobHistoryID) AS BTJobHistoryID,
		MAX(btjh.LastModDate) AS LastModDate,
		MIN(btjh.BTJobHistoryID) AS MinBTJobHistoryID
	FROM [dbo].BTJobHistory AS btjh
	GROUP BY btjh.BTJobID
) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
LEFT JOIN [dbo].BTJobHistory AS latest_job_history_Dtls
ON latest_job_history.BTJobHistoryID = latest_job_history_Dtls.BTJobHistoryID
LEFT JOIN
(
	SELECT 
		btshcr.BTJobHistoryID AS BTJobHistoryID,
		MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID,
		MIN(btshcr.BTStatusHistoryCrossRefID) AS MinBTStatusHistoryCrossRefID
	FROM [dbo].BTStatusHistoryCrossRef AS btshcr
	GROUP BY btshcr.BTJobHistoryID
) AS latest_cross_ref
ON latest_job_history.BTJobHistoryID = latest_cross_ref.BTJobHistoryID
/*
INNER JOIN
(
	SELECT
		btj.BTJobID,
		apt.[Name] AS AccessPointName
	FROM [dbo].BTJob btj
	INNER JOIN
	(
		SELECT
			btj.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJob AS btj
		INNER JOIN [dbo].BTJobHistory AS btjh
		ON btj.BTJobID = btjh.BTJobID
		GROUP BY btj.BTJobID
	) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
	LEFT JOIN
	(
		SELECT 
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_ref
	ON latest_job_history.BTJobHistoryID = latest_cross_ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].AccessPointType AS apt
	ON btshcr.AccessPointTypeID = apt.AccessPointTypeID
) AS bt_job_source
ON btj.BTJobID = bt_job_source.BTJobID*/
LEFT JOIN
(
	SELECT
		btshcr.BTStatusHistoryCrossRefID AS BTStatusHistoryCrossRefID,
		apt.[Name] AS AccessPointName
	FROM [dbo].BTStatusHistoryCrossRef AS btshcr	
	LEFT JOIN [dbo].AccessPointType AS apt
	ON btshcr.AccessPointTypeID = apt.AccessPointTypeID
) AS bt_job_source
ON latest_cross_ref.BTStatusHistoryCrossRefID = bt_job_source.BTStatusHistoryCrossRefID

/*INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		latest_isolation_type.IsolationType AS IsolationType
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			l.LocationID AS LocationID,
			it.Name AS IsolationType
		FROM [dbo].Location AS l
		INNER JOIN [dbo].BTLocation AS btl
		ON l.LocationID = btl.LocationID
		INNER JOIN [dbo].IsolationType it
		ON btl.LastPatientIsolationTypeID = it.IsolationTypeID
	) AS latest_isolation_type
	ON btj.LocationID = latest_isolation_type.LocationID
) AS isolation_type
ON btj.BTJobID = isolation_type.BTJobID*/
LEFT JOIN
(
	SELECT
		btl.LocationID AS LocationID,
		it.Name AS IsolationType --latest_isolation_type
	FROM [dbo].BTLocation AS btl
	INNER JOIN [dbo].IsolationType it
	ON btl.LastPatientIsolationTypeID = it.IsolationTypeID
) AS isolation_type 
ON location_info.LocationID = isolation_type.LocationID 
INNER JOIN [dbo].EnterpriseUser eu
ON btj.RequesterID = eu.EnterpriseUserID
/*INNER JOIN
(
	SELECT
		btj.BTJobID,
		st.Name AS SpillCleanType
	FROM [dbo].BTJob AS btj
	LEFT JOIN [dbo].SpillType AS st
	ON btj.CampusID = st.CampusID AND btj.SpillTypeID = st.SpillTypeID
) AS spill_clean_type
ON btj.BTJobID = spill_clean_type.BTJobID*/
LEFT JOIN [dbo].SpillType AS spill_clean_type
ON  btj.CampusID = spill_clean_type.CampusID 
AND btj.SpillTypeID = spill_clean_type.SpillTypeID
INNER JOIN
(
	SELECT
		btj.BTJobID,
		lsh.CurrentStatusTypeID AS CurrentStatusTypeID,
		lst.Name AS CurrentStatusTypeName
	FROM [dbo].BTJob btj
	INNER JOIN
	(
		SELECT
			btj.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJob AS btj
		INNER JOIN [dbo].BTJobHistory AS btjh
		ON btj.BTJobID = btjh.BTJobID
		GROUP BY btj.BTJobID
	) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
	LEFT JOIN
	(
		SELECT 
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_ref
	ON latest_job_history.BTJobHistoryID = latest_cross_ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].LocationStatusHistory lsh
	ON btshcr.LocationStatusHistoryID = lsh.LocationStatusHistoryID
	LEFT JOIN [dbo].LocationStatusType lst
	ON lsh.CurrentStatusTypeID = lst.LocationStatusTypeID
) AS udef
ON btj.BTJobID = udef.BTJobID
/*INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		d.DisciplineID AS DisciplineID,
		d.Name AS DisciplineName
	FROM [dbo].BTJob AS btj
	INNER JOIN [dbo].Location AS l
	ON btj.LocationID = l.LocationID
	INNER JOIN [dbo].Room AS r
	ON l.RoomID = r.RoomID
	INNER JOIN [dbo].Unit AS u
	ON r.UnitID = u.UnitID
	INNER JOIN [dbo].PATUnitSetting AS pus
	ON u.UnitID = pus.UnitID
	INNER JOIN [dbo].Discipline AS d
	ON pus.DisciplineID = d.DisciplineID
) AS discipline
ON btj.BTJobID = discipline.BTJobID*/
INNER JOIN
(
	SELECT
		pus.UnitID AS UnitID,
		d.DisciplineID AS DisciplineID,
		d.Name AS DisciplineName
	FROM [dbo].PATUnitSetting AS pus
	INNER JOIN [dbo].Discipline AS d
	ON pus.DisciplineID = d.DisciplineID
) AS discipline
ON location_info.UnitID = discipline.UnitID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		rc.CodeName AS ReasonCode,
		CASE btshcr.BTStatusMappingTypeID
			WHEN 9 THEN 'Next'
			WHEN 14 THEN 'Stat'
			WHEN 19 THEN 'Udef6'
			WHEN 24 THEN 'Udef9'
			WHEN 30 THEN 'Blocked'
		END AS BTStatusMappingTypeName
	FROM [dbo].BTJob btj
	LEFT JOIN
	(
		SELECT
			btj.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID,
			MAX(btjh.LastModDate) AS LastModDate
		FROM [dbo].BTJob AS btj
		INNER JOIN [dbo].BTJobHistory AS btjh
		ON btj.BTJobID = btjh.BTJobID
		GROUP BY btj.BTJobID
	) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
	LEFT JOIN
	(
		SELECT 
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID,
			MAX(btshcr.LastModDate) AS LastModDate
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_ref
	ON latest_job_history.BTJobHistoryID = latest_cross_ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].ReasonCode rc
	ON btshcr.ReasonCodeID = rc.ReasonCodeID
) AS blocked_bed_reason
ON btj.BTJobID = blocked_bed_reason.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		eu.FirstName AS FirstName,
		eu.LastName AS LastName
	FROM [dbo].BTJob AS btj
	LEFT JOIN [dbo].BTJobSummary AS btjs
	ON btj.BTJobID = btjs.BTJobID
	LEFT JOIN [dbo].EnterpriseUser AS eu
	ON btjs.CancelledByUserID = eu.EnterpriseUserID
) AS cancelled_by_user
ON btj.BTJobID = cancelled_by_user.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		eu.FirstName AS FirstName,
		eu.LastName AS LastName
	FROM [dbo].BTJob AS btj
	LEFT JOIN [dbo].BTJobSummary AS btjs
	ON btj.BTJobID = btjs.BTJobID
	LEFT JOIN [dbo].EnterpriseUser AS eu
	ON btjs.CompletedByUserID = eu.EnterpriseUserID
) AS completed_by_user
ON btj.BTJobID = completed_by_user.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		btshcr.CreatedDate AS CreatedDate,
		CASE btshcr.BTStatusMappingTypeID
			WHEN 9 THEN 'Next'
			WHEN 14 THEN 'Stat'
			WHEN 19 THEN 'Udef8'
			WHEN 24 THEN 'Udef9'
			WHEN 30 THEN 'Blocked'
		END AS BTStatusMappingTypeName,
		CASE
			WHEN btshcr.BTStatusMappingTypeID IN (9, 14, 19, 24, 30) THEN 1
			ELSE 0
		END AS IsUpgradedJob
	FROM [dbo].BTJob AS btj
	INNER JOIN
	(
		SELECT
			btj.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID,
			MAX(btjh.LastModDate) AS LastModDate
		FROM [dbo].BTJob AS btj
		INNER JOIN [dbo].BTJobHistory AS btjh
		ON btj.BTJobID = btjh.BTJobID
		GROUP BY btj.BTJobID
	) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON latest_job_history.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN
	(
		SELECT 
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID,
			MAX(btshcr.LastModDate) AS LastModDate
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_ref
	ON latest_job_history.BTJobHistoryID = latest_cross_ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
) AS last_upgrade_status
ON btj.BTJobID = last_upgrade_status.BTJobID
/*INNER JOIN
(
	SELECT
		btj.BTJobID,
		btjh.CurrentStatusStartDateTime AS InprogressTimestamp
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		WHERE btjh.CurrentStatusTypeID = 1
		GROUP BY btjh.BTJobID
	) AS inprogress_job_history
	ON btj.BTJobID = inprogress_job_history.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON inprogress_job_history.BTJobHistoryID = btjh.BTJobHistoryID
) AS inprogress_timestamp
ON btj.BTJobID = inprogress_timestamp.BTJobID*/
LEFT JOIN
(	SELECT
		btjh.BTJobID,
		btjh.CurrentStatusStartDateTime AS InprogressTimestamp
	FROM [dbo].BTJobHistory AS btjh
	INNER JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		WHERE btjh.CurrentStatusTypeID = 1
		GROUP BY btjh.BTJobID
	) AS inprogress_job_history
	ON btjh.BTJobHistoryID = inprogress_job_history.BTJobHistoryID
) AS inprogress_timestamp
ON btj.BTJobID = inprogress_timestamp.BTJobID
/*INNER JOIN
(
	SELECT
		btj.BTJobID,
		lst.[Name] AS InitialPriorityStatusType
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MIN(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		GROUP BY btjh.BTJobID
	) AS inital_job_history
	ON btj.BTJobID = inital_job_history.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON inital_job_history.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN
	(
		SELECT
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MIN(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS inital_status_history_cross_ref
	ON btjh.BTJobHistoryID = inital_status_history_cross_ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON inital_status_history_cross_ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].LocationStatusHistory AS lsh
	ON btshcr.LocationStatusHistoryID = lsh.LocationStatusHistoryID
	LEFT JOIN [dbo].LocationStatusType AS lst
	ON lsh.CurrentStatusTypeID = lst.LocationStatusTypeID
) AS initial_priority_status_type
ON btj.BTJobID = initial_priority_status_type.BTJobID*/
LEFT JOIN
(
	SELECT
		btshcr.BTJobHistoryID,
		btshcr.BTStatusHistoryCrossRefID,
		lst.[Name] AS InitialPriorityStatusType
	FROM [dbo].BTStatusHistoryCrossRef AS btshcr
	LEFT JOIN [dbo].LocationStatusHistory AS lsh
		ON btshcr.LocationStatusHistoryID = lsh.LocationStatusHistoryID	
	LEFT JOIN [dbo].LocationStatusType AS lst
		ON lsh.CurrentStatusTypeID = lst.LocationStatusTypeID
) AS initial_priority_status_type
ON latest_cross_ref.MinBTStatusHistoryCrossRefID = initial_priority_status_type.BTStatusHistoryCrossRefID
AND latest_job_history.MinBTJobHistoryID = initial_priority_status_type.BTJobHistoryID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		rc.CodeName AS CancelledReason
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		WHERE btjh.CurrentStatusTypeID = 7
		GROUP BY btjh.BTJobID
	) AS first_job_history_delay
	ON btj.BTJobID = first_job_history_delay.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON first_job_history_delay.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN
	(
		SELECT
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_Ref
	ON btjh.BTJobHistoryID = latest_cross_Ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_Ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].ReasonCode AS rc
	ON btshcr.ReasonCodeID = rc.ReasonCodeID
) AS cancelled_reason
ON btj.BTJobID = cancelled_reason.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		btjh.CurrentStatusStartDateTime AS FirstDelayTimestamp,
		rc.CodeName AS FirstDelayReason
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MIN(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		WHERE btjh.CurrentStatusTypeID = 2
		GROUP BY btjh.BTJobID
	) AS first_job_history_delay
	ON btj.BTJobID = first_job_history_delay.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON first_job_history_delay.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN
	(
		SELECT
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_Ref
	ON btjh.BTJobHistoryID = latest_cross_Ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_Ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].ReasonCode AS rc
	ON btshcr.ReasonCodeID = rc.ReasonCodeID
) AS first_delay_reason
ON btj.BTJobID = first_delay_reason.BTJobID
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		btjh.CurrentStatusStartDateTime AS FirstSuspendedTimestamp,
		rc.CodeName AS FirstSuspendedReason
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MIN(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		WHERE btjh.CurrentStatusTypeID = 3
		GROUP BY btjh.BTJobID
	) AS first_job_history_delay
	ON btj.BTJobID = first_job_history_delay.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON first_job_history_delay.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN
	(
		SELECT
			btshcr.BTJobHistoryID AS BTJobHistoryID,
			MAX(btshcr.BTStatusHistoryCrossRefID) AS BTStatusHistoryCrossRefID
		FROM [dbo].BTStatusHistoryCrossRef AS btshcr
		GROUP BY btshcr.BTJobHistoryID
	) AS latest_cross_Ref
	ON btjh.BTJobHistoryID = latest_cross_Ref.BTJobHistoryID
	LEFT JOIN [dbo].BTStatusHistoryCrossRef AS btshcr
	ON latest_cross_Ref.BTStatusHistoryCrossRefID = btshcr.BTStatusHistoryCrossRefID
	LEFT JOIN [dbo].ReasonCode AS rc
	ON btshcr.ReasonCodeID = rc.ReasonCodeID
) AS first_suspended_reason
ON btj.BTJobID = first_suspended_reason.BTJobID
/*
INNER JOIN
(
	SELECT
		btj.BTJobID AS BTJobID,
		ec.Name AS EmployeeCategoryName
	FROM [dbo].BTJob AS btj
	LEFT JOIN
	(
		SELECT
			btjh.BTJobID AS BTJobID,
			MAX(btjh.BTJobHistoryID) AS BTJobHistoryID
		FROM [dbo].BTJobHistory AS btjh
		GROUP BY btjh.BTJobID
	) AS latest_job_history
	ON btj.BTJobID = latest_job_history.BTJobID
	LEFT JOIN [dbo].BTJobHistory AS btjh
	ON latest_job_history.BTJobHistoryID = btjh.BTJobHistoryID
	LEFT JOIN [dbo].EmployeeCategorySetting AS ecs
	ON btjh.EnterpriseUserID = ecs.EnterpriseUserID
	LEFT JOIN [dbo].EmployeeCategory AS ec
	ON ecs.EmployeeCategoryID = ec.EmployeeCategoryID
) AS employee_category
ON btj.BTJobID = employee_category.BTJobID*/
LEFT JOIN
(
	SELECT
		ecs.EnterpriseUserID AS EnterpriseUserID,
		ec.Name AS EmployeeCategoryName
	FROM [dbo].EmployeeCategorySetting AS ecs
	LEFT JOIN [dbo].EmployeeCategory AS ec
	ON ecs.EmployeeCategoryID = ec.EmployeeCategoryID
) AS employee_category
ON latest_job_history_Dtls.EnterpriseUserID = employee_category.EnterpriseUserID