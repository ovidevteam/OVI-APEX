-- =====================================================
-- Page 1021: Function Form - Comments Sub-Grid Query
-- Purpose: Query for Comments sub-region in Tab 4
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

SELECT
	-- =====================================================
	-- Hidden Columns
	-- =====================================================
	C.Com_Id,                                               -- NUMBER, PK, Hidden
	C.Fun_Id,                                               -- NUMBER, FK to WLM_FUNCTIONS, Hidden
	C.Tas_Id,                                               -- NUMBER, FK to WLM_TASKS (optional), Hidden
	C.Parent_Com_Id,                                        -- NUMBER, FK to WLM_COMMENTS (reply), Hidden
	-- =====================================================
	-- Comment Info
	-- =====================================================
	C.Comment_Text,                                         -- VARCHAR2(4000), Rich Text Editor or Textarea
	-- =====================================================
	-- Author
	-- =====================================================
	C.Emp_Id,                                               -- NUMBER, LOV: LOV_EMPLOYEES, Hidden
	E.Name AS Author_Name,                                  -- VARCHAR2(200), Display Only
	E.Emp_Number AS Author_Code,                            -- VARCHAR2(50), Display Only
	-- =====================================================
	-- Task Reference (if comment is on a task)
	-- =====================================================
	T.Task_Name AS Task_Reference,                          -- VARCHAR2(200), Display Only
	-- =====================================================
	-- Audit
	-- =====================================================
	TO_CHAR(C.Created_Date, v('G_DATE_FORMAT') || ' HH24:MI') AS Created_Date_Display,   -- DATE + Time, Display Only
	C.Created_By                                            -- VARCHAR2(50), Display Only
FROM WLM_COMMENTS C
LEFT JOIN EMPLOYEES E ON E.Emp_Id = C.Emp_Id
LEFT JOIN WLM_TASKS T ON T.Tas_Id = C.Tas_Id
WHERE C.Fun_Id = :P1021_FUN_ID
-- NOTE: Do NOT add ORDER BY - configure sorting in APEX IG properties (recommend: Created_Date DESC)

