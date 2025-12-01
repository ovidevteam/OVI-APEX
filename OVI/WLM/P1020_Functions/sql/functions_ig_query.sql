-- =====================================================
-- Page 1020: Functions - IG Query
-- Purpose: Query for Interactive Grid listing all functions
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

SELECT
	-- =====================================================
	-- Region 1: Hidden Columns
	-- =====================================================
	F.Fun_Id,                                                           -- NUMBER, PK, Hidden
	F.Mod_Id,                                                           -- NUMBER, FK to WLM_MODULES, Hidden
	M.Prj_Id,                                                           -- NUMBER, FK to WLM_PROJECTS, Hidden (for filter)
	-- =====================================================
	-- Region 2: Link Column (Open Form)
	-- =====================================================
	'<a href="' || APEX_PAGE.GET_URL(p_page => 1021, p_items => 'P1021_FUN_ID', p_values => F.Fun_Id) || '" class="t-Button t-Button--icon t-Button--info t-Button--small" title="View Details"><span class="fa fa-info-circle"></span></a>' AS Link_Form,  -- HTML Link, Column Type: HTML Expression
	-- =====================================================
	-- Region 3: Project/Module Info
	-- =====================================================
	P.Project_Name,                                                     -- VARCHAR2(200), Display Only
	M.Module_Name,                                                      -- VARCHAR2(200), Display Only
	-- =====================================================
	-- Region 3: Function Info
	-- =====================================================
	F.Function_Code,                                                    -- VARCHAR2(50), Text, Required
	F.Function_Name,                                                    -- VARCHAR2(200), Text, Required
	F.Description,                                                      -- VARCHAR2(4000), Textarea
	F.Technical_Desc,                                                   -- VARCHAR2(4000), Textarea
	-- =====================================================
	-- Region 4: Assignment
	-- =====================================================
	F.Ba_Emp_Id,                                                        -- NUMBER, LOV: EMPLOYEES, Hidden
	E1.Name AS Ba_Name,                                                 -- VARCHAR2(200), Display Only
	F.Lead_Emp_Id,                                                      -- NUMBER, LOV: EMPLOYEES, Hidden
	E2.Name AS Lead_Name,                                               -- VARCHAR2(200), Display Only
	F.Qa_Emp_Id,                                                        -- NUMBER, LOV: EMPLOYEES, Hidden
	E3.Name AS Qa_Name,                                                 -- VARCHAR2(200), Display Only
	-- =====================================================
	-- Region 5: Workflow Status
	-- =====================================================
	F.Current_Step,                                                     -- VARCHAR2(3), LOV: WLM_WORKFLOW_STEP (BA/LED/DEV/QA/DON), Hidden
	Pkg_Adm.Get_Lov_Value_Language('WLM_WORKFLOW_STEP', F.Current_Step) AS Step_Display,    -- Step_Display, HTML Badge
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_WORKFLOW_STEP', F.Current_Step) AS Step_Css,       -- Step_Css, CSS Class
	F.Status,                                                           -- VARCHAR2(1), LOV: WLM_FUNCTION_STATUS (P/I/C/R), Hidden
	Pkg_Adm.Get_Lov_Value_Language('WLM_FUNCTION_STATUS', F.Status) AS Status_Display,      -- Status_Display, HTML Badge
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_FUNCTION_STATUS', F.Status) AS Status_Css,         -- Status_Css, CSS Class
	F.Priority,                                                         -- VARCHAR2(1), LOV: WLM_PRIORITY (L/M/H/C), Hidden
	Pkg_Adm.Get_Lov_Value_Language('WLM_PRIORITY', F.Priority) AS Priority_Display,         -- Priority_Display, HTML Badge
	Pkg_Adm.Get_Value_Set_Css_Style('WLM_PRIORITY', F.Priority) AS Priority_Css,            -- Priority_Css, CSS Class
	-- =====================================================
	-- Region 6: Schedule
	-- =====================================================
	F.Estimated_Hours,                                                  -- NUMBER, Number Field
	F.Actual_Hours,                                                     -- NUMBER, Number Field, Display Only
	TO_CHAR(F.Start_Date, v('G_DATE_FORMAT')) AS Start_Date_Display,    -- DATE, Display Only
	F.Start_Date,                                                       -- DATE, Date Picker
	TO_CHAR(F.Deadline, v('G_DATE_FORMAT')) AS Deadline_Display,        -- DATE, Display Only
	F.Deadline,                                                         -- DATE, Date Picker
	TO_CHAR(F.Completed_Date, v('G_DATE_FORMAT')) AS Completed_Date_Display,  -- DATE, Display Only
	F.Completed_Date,                                                   -- DATE, Date Picker, Display Only
	-- =====================================================
	-- Region 7: Audit
	-- =====================================================
	TO_CHAR(F.Created_Date, v('G_DATE_FORMAT')) AS Created_Date_Display,    -- DATE, Display Only
	F.Created_By                                                        -- VARCHAR2(50), Display Only
FROM WLM_FUNCTIONS F
JOIN WLM_MODULES M ON M.Mod_Id = F.Mod_Id
JOIN WLM_PROJECTS P ON P.Prj_Id = M.Prj_Id
LEFT JOIN EMPLOYEES E1 ON E1.Emp_Id = F.Ba_Emp_Id
LEFT JOIN EMPLOYEES E2 ON E2.Emp_Id = F.Lead_Emp_Id
LEFT JOIN EMPLOYEES E3 ON E3.Emp_Id = F.Qa_Emp_Id
WHERE M.Prj_Id = NVL(:P1020_PRJ_ID, M.Prj_Id)
	AND F.Mod_Id = NVL(:P1020_MOD_ID, F.Mod_Id)
	AND F.Status = NVL(:P1020_STATUS, F.Status)
	AND F.Current_Step = NVL(:P1020_CURRENT_STEP, F.Current_Step)
-- NOTE: Do NOT add ORDER BY - configure sorting in APEX IG properties

