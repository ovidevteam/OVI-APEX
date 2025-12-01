-- =====================================================
-- Page 1021: Function Form - Tasks Sub-Grid Query
-- Purpose: Query for Tasks sub-region in Tab 4
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

SELECT
	-- =====================================================
	-- Hidden Columns
	-- =====================================================
	T.Tas_Id,                                               -- NUMBER, PK, Hidden
	T.Fun_Id,                                               -- NUMBER, FK to WLM_FUNCTIONS, Hidden
	-- =====================================================
	-- Task Info
	-- =====================================================
	T.Task_Name,                                            -- VARCHAR2(200), Text
	T.Description,                                          -- VARCHAR2(4000), Textarea
	-- =====================================================
	-- Assignment
	-- =====================================================
	T.Assigned_To_Emp_Id,                                   -- NUMBER, LOV: EMPLOYEES, Hidden
	E1.Name AS Assigned_To_Name,                            -- VARCHAR2(200), Display Only
	T.Assigned_By_Emp_Id,                                   -- NUMBER, LOV: EMPLOYEES, Hidden
	E2.Name AS Assigned_By_Name,                            -- VARCHAR2(200), Display Only
	-- =====================================================
	-- Status
	-- =====================================================
	T.Status,                                               -- VARCHAR2(1), LOV: WLM_TASK_STATUS (A/I/C/B), Hidden
	Pkg_Adm.Get_Lov_Value_Language('WLM_TASK_STATUS', T.Status) AS Status_Display,    -- Status_Display, HTML Badge
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_TASK_STATUS', T.Status) AS Status_Css,       -- Status_Css, CSS Class
	-- =====================================================
	-- Schedule
	-- =====================================================
	TO_CHAR(T.Start_Date, v('G_DATE_FORMAT')) AS Start_Date_Display,    -- DATE, Display Only
	TO_CHAR(T.End_Date, v('G_DATE_FORMAT')) AS End_Date_Display,        -- DATE, Display Only
	T.End_Date,                                             -- DATE, Date Picker
	CASE
		WHEN T.End_Date < SYSDATE AND T.Status != 'C'
		THEN 'Y'
		ELSE 'N'
	END AS Is_Overdue,                                      -- VARCHAR2(1), Overdue flag
	-- =====================================================
	-- Notes
	-- =====================================================
	T.Notes,                                                -- VARCHAR2(4000), Textarea
	-- =====================================================
	-- Audit
	-- =====================================================
	TO_CHAR(T.Created_Date, v('G_DATE_FORMAT')) AS Created_Date_Display   -- DATE, Display Only
FROM WLM_TASKS T
LEFT JOIN EMPLOYEES E1 ON E1.Emp_Id = T.Assigned_To_Emp_Id
LEFT JOIN EMPLOYEES E2 ON E2.Emp_Id = T.Assigned_By_Emp_Id
WHERE T.Fun_Id = :P1021_FUN_ID
-- NOTE: Do NOT add ORDER BY - configure sorting in APEX IG properties

