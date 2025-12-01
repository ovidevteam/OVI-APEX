# APEX Page Folder Creation Prompt Template

> **Purpose:** Standard prompt template for creating APEX page folder structure
> **Version:** 1.0
> **Created:** December 2025
> **Author:** OVI Development Team

---

## Usage

Copy and customize the appropriate prompt template below based on page type.

---

## Template 1: Interactive Grid (IG) Page

```
Create APEX IG page folder structure for Page [PAGE_ID]: [PAGE_NAME]

Module: [MODULE_NAME]
Table: [MAIN_TABLE]
Form Page: [FORM_PAGE_ID] (for data entry)

Required files:
1. README.md - Page overview, folder structure, tables, filters, authorization
2. sql/[table_name]_ig_query.sql - IG query with:
   - Link_Form column (fa-info-circle icon) linking to form page
   - Hidden columns (PK, FK)
   - Display columns with LOV display values
   - Status badge columns with CSS class
   - Filter conditions using NVL
   - Comments: data type, LOV domain
3. sql/[table_name]_filter_lovs.sql - Filter LOVs with cascade support
4. docs/IMPLEMENTATION_GUIDE.md - Setup guide with columns, buttons, authorization

Note: IG pages are view-only. Data entry through Form page.

Folder structure:
P[PAGE_ID]_[PageName]/
├── js/                     # JavaScript (if needed)
├── sql/
│   ├── [table]_ig_query.sql
│   └── [table]_filter_lovs.sql
├── docs/
│   └── IMPLEMENTATION_GUIDE.md
└── README.md
```

---

## Template 2: Modal Form Page

```
Create APEX Modal Form page folder structure for Page [PAGE_ID]: [PAGE_NAME]

Module: [MODULE_NAME]
Table: [MAIN_TABLE]
Parent IG Page: [IG_PAGE_ID]

Required files:
1. README.md - Page overview, folder structure, tables, tabs, authorization
2. sql/[table_name]_form_query.sql - Form query with:
   - Columns grouped by tabs
   - Comments: data type, LOV domain, CSS class, custom attributes
   - TO_CHAR for date fields with v('G_DATE_FORMAT')
3. sql/[table_name]_form_lovs.sql - LOVs for form items
4. sql/[table_name]_[subregion]_subgrid.sql - Sub-grid queries (if any)
5. processes/[table_name]_form_process.sql - CREATE/SAVE/DELETE process
6. processes/[table_name]_workflow_actions.sql - Workflow button processes (if any)
7. docs/IMPLEMENTATION_GUIDE.md - Setup guide with tabs, items, buttons, workflow

Folder structure:
P[PAGE_ID]_[PageName]/
├── js/                     # JavaScript (if needed)
├── processes/
│   ├── [table]_form_process.sql
│   └── [table]_workflow_actions.sql
├── sql/
│   ├── [table]_form_query.sql
│   ├── [table]_form_lovs.sql
│   └── [table]_subgrid.sql
├── docs/
│   └── IMPLEMENTATION_GUIDE.md
└── README.md
```

---

## Template 3: Dashboard/Report Page

```
Create APEX Dashboard page folder structure for Page [PAGE_ID]: [PAGE_NAME]

Module: [MODULE_NAME]
Regions: [LIST_REGIONS]

Required files:
1. README.md - Page overview, regions, data sources
2. sql/[region_name]_query.sql - Query for each region
3. js/[page_name]_charts.js - Chart initialization (if using charts)
4. docs/IMPLEMENTATION_GUIDE.md - Setup guide with regions, charts, navigation

Folder structure:
P[PAGE_ID]_[PageName]/
├── js/
│   └── [page]_charts.js
├── sql/
│   ├── [region1]_query.sql
│   └── [region2]_query.sql
├── docs/
│   └── IMPLEMENTATION_GUIDE.md
└── README.md
```

---

## Standard Query Comments

### IG Query Comment Format
```sql
Column_Name,                                    -- DATA_TYPE, [LOV: LOV_NAME], [Display/Hidden], [CSS: class]
```

### Form Query Comment Format
```sql
Column_Name,                                    -- DATA_TYPE, [LOV: LOV_NAME (Default: 'value')], [CSS: class, Custom: tabindex="-1"]
```

### Examples
```sql
-- IG Query
Fun_Id,                                         -- NUMBER, PK, Hidden
Function_Name,                                  -- VARCHAR2(200), Text, Required
Status,                                         -- VARCHAR2(1), LOV: WLM_FUNCTION_STATUS (P/I/C/R), Hidden
Status_Display,                                 -- VARCHAR2, HTML Badge
Status_Css,                                     -- VARCHAR2, CSS Class

-- Form Query
P1021_STATUS,                                   -- VARCHAR2(1), LOV: WLM_FUNCTION_STATUS (CSS: disable, Custom: tabindex="-1")
P1021_DEADLINE,                                 -- DATE, Date Picker (Format: &G_DATE_FORMAT)
P1021_CREATED_DATE,                             -- DATE (CSS: disable, Custom: tabindex="-1")
```

---

## Link Column HTML Template (IG Pages)

```sql
'<a href="' || APEX_PAGE.GET_URL(
    p_page => [FORM_PAGE_ID],
    p_items => 'P[FORM_PAGE_ID]_[PK_ITEM]',
    p_values => [PK_COLUMN]
) || '" class="t-Button t-Button--icon t-Button--info t-Button--small" title="View Details">'
|| '<span class="fa fa-info-circle"></span></a>' AS Link_Form
```

---

## CSS Classes Reference

### Status Badges (from APEX Status Colors CSS.css)
| Class | Color | Usage |
|-------|-------|-------|
| status-active | Green | Active/Success |
| status-pending | Orange | Pending/Waiting |
| status-progress | Yellow | In Progress |
| status-completed | Green | Completed/Done |
| status-rejected | Red | Rejected/Failed |
| status-info | Blue | Information |
| status-warning | Yellow | Warning |
| status-danger | Red | Danger/Critical |

### Form Fields
| Class | Usage |
|-------|-------|
| required-field | Required field indicator |
| disable | Disabled/Read-only field |
| region-beautiful | Beautiful region styling |

### Buttons
| Class | Color | Usage |
|-------|-------|-------|
| t-Button--hot | Primary | Main action |
| t-Button--success | Green | Success/Confirm |
| t-Button--warning | Orange | Warning/Caution |
| t-Button--danger | Red | Delete/Danger |
| t-Button--info | Blue | Information |

---

## Example Prompt (Complete)

```
Create APEX IG page folder structure for Page 1020: Functions

Module: WLM (Workload Management)
Table: WLM_FUNCTIONS
Form Page: 1021 (Function Form)

Filters:
- P1020_PRJ_ID (Project) - LOV_WLM_PROJECTS
- P1020_MOD_ID (Module) - LOV_WLM_MODULES_CASCADE (cascade from PRJ_ID)
- P1020_STATUS - WLM_FUNCTION_STATUS
- P1020_CURRENT_STEP - WLM_WORKFLOW_STEP

IG Columns:
- Link_Form (fa-info-circle icon)
- Project_Name, Module_Name (Display)
- Function_Code, Function_Name (Display)
- Ba_Name, Lead_Name, Qa_Name (Display from EMPLOYEES)
- Step_Display, Status_Display, Priority_Display (HTML Badge)
- Deadline_Display, Estimated_Hours, Actual_Hours

Authorization:
- ADM: Full access
- BA: Full (Add, Edit)
- LED: Edit
- DEV/QA: View only

Use CSS classes from APEX Status Colors CSS.css for status badges.
IG is view-only, data entry through Form page 1021.
```

---

*Version: 1.0*
*Last Updated: December 2025*
*Author: OVI Development Team*

