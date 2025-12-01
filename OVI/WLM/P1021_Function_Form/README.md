# Page 1021: Function Form (Modal Dialog)

> **Module:** WLM - Workload Management
> **Page ID:** 1021
> **Page Type:** Modal Dialog Form
> **Dialog Width:** 1000px
> **Author:** tuannt
> **Created:** December 2025

---

## Folder Structure

```
P1021_Function_Form/
├── js/                     # JavaScript files (if needed)
├── processes/              # PL/SQL processes
│   ├── function_form_process.sql
│   └── function_workflow_actions.sql
├── sql/                    # SQL queries and LOVs
│   ├── function_form_query.sql
│   ├── function_form_lovs.sql
│   ├── function_tasks_subgrid.sql
│   └── function_comments_subgrid.sql
├── docs/                   # Documentation
│   └── IMPLEMENTATION_GUIDE.md
└── README.md
```

---

## Tables

| Table | Purpose | Operation |
|-------|---------|-----------|
| WLM_FUNCTIONS | Main table | INSERT/UPDATE/DELETE |
| WLM_MODULES | LOV for Module | SELECT |
| WLM_PROJECTS | LOV cascade | SELECT |
| EMPLOYEES | LOV for BA, Leader, QA | SELECT |
| WLM_COMMENTS | Tab Comments | SELECT/INSERT |
| WLM_TASKS | Tab Tasks (sub-region) | SELECT |

---

## Tabs Structure

| Tab | Name | Content |
|-----|------|---------|
| 1 | General Information | Function basic info |
| 2 | Assignment | BA, Leader, QA assignment |
| 3 | Progress | Hours and dates |
| 4 | Tasks & Comments | Sub-regions for tasks and comments |

---

## Workflow Buttons

| Button | Condition | Action |
|--------|-----------|--------|
| CREATE | P1021_FUN_ID IS NULL | Insert new function |
| SAVE | Always | Update function |
| Send to Leader | Step='BA' AND Role=BA | Step -> LED |
| Assign DEV | Step='LED' AND Role=LED | Navigate 1030 |
| Reject | Step='LED' AND Role=LED | Step -> BA |
| Pass | Step='QA' AND Role=QA | Step -> DON |
| Fail | Step='QA' AND Role=QA | Step -> DEV |
| Close | Step='DON' AND Role=BA | Final close |
| Reopen | Step='DON' AND Role=BA | Step -> DEV |
| DELETE | Role=ADM | Delete function |

---

## Authorization

| Role | Access |
|------|--------|
| ADM | Full (All buttons) |
| BA | Full (except Delete) |
| LED | Edit (Assign DEV, Reject) |
| DEV | View only |
| QA | Edit (Pass, Fail) |

---

## Related Pages

- Page 1020: Functions (IG) - Parent page
- Page 1030: Tasks - For assigning tasks


