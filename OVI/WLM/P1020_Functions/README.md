# Page 1020: Functions (Interactive Grid)

> **Module:** WLM - Workload Management
> **Page ID:** 1020
> **Page Type:** Interactive Grid
> **Static ID:** WLM_FUNCTIONS_IG
> **Author:** tuannt
> **Created:** December 2025

---

## Folder Structure

```
P1020_Functions/
├── js/                     # JavaScript files (if needed)
├── processes/              # PL/SQL processes
│   └── functions_ig_dml.sql
├── sql/                    # SQL queries and LOVs
│   ├── functions_ig_query.sql
│   └── functions_filter_lovs.sql
├── docs/                   # Documentation
│   └── IMPLEMENTATION_GUIDE.md
└── README.md
```

---

## Tables

| Table | Alias | Purpose | Join |
|-------|-------|---------|------|
| WLM_FUNCTIONS | F | Main table | - |
| WLM_MODULES | M | Module name | JOIN M.Mod_Id = F.Mod_Id |
| WLM_PROJECTS | P | Project name | JOIN P.Prj_Id = M.Prj_Id |
| EMPLOYEES | E1 | BA name | LEFT JOIN E1.Emp_Id = F.Ba_Emp_Id |
| EMPLOYEES | E2 | Leader name | LEFT JOIN E2.Emp_Id = F.Lead_Emp_Id |
| EMPLOYEES | E3 | QA name | LEFT JOIN E3.Emp_Id = F.Qa_Emp_Id |

---

## Filter Items

| Item | Label | Type | LOV | Cascade |
|------|-------|------|-----|---------|
| P1020_PRJ_ID | Project | Select List | LOV_WLM_PROJECTS | - |
| P1020_MOD_ID | Module | Select List | LOV_WLM_MODULES_CASCADE | From P1020_PRJ_ID |
| P1020_STATUS | Status | Select List | WLM_FUNCTION_STATUS | - |
| P1020_CURRENT_STEP | Step | Select List | WLM_WORKFLOW_STEP | - |

---

## Authorization

| Role | Access |
|------|--------|
| ADM | Full (Add, Edit, Delete) |
| BA | Full (Add, Edit) |
| LED | Edit |
| DEV | View |
| QA | View |

---

## Related Pages

- Page 1021: Function Form (Modal)
- Page 1030: Tasks


