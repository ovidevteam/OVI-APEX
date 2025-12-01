# Page 1020: Functions - Implementation Guide

> **Page ID:** 1020
> **Page Name:** Functions
> **Page Type:** Interactive Grid
> **Static ID:** WLM_FUNCTIONS_IG
> **Author:** tuannt

---

## 1. Page Setup

### 1.1 Create Page
- Page Number: 1020
- Name: Functions
- Page Mode: Normal
- Navigation: Breadcrumb

### 1.2 Regions

| Region | Type | Static ID | Source |
|--------|------|-----------|--------|
| Filter Region | Static Content | FILTER_REGION | - |
| Functions Grid | Interactive Grid | WLM_FUNCTIONS_IG | `sql/functions_ig_query.sql` |

---

## 2. Filter Items

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1020_PRJ_ID | Project | Select List | WLM_PROJECTS | N | - |
| P1020_MOD_ID | Module | Select List | WLM_MODULES_CASCADE | N | - |
| P1020_STATUS | Status | Select List | WLM_FUNCTION_STATUS | N | - |
| P1020_CURRENT_STEP | Step | Select List | WLM_WORKFLOW_STEP | N | - |

### Cascade Configuration
- **P1020_MOD_ID** cascades from **P1020_PRJ_ID**
- Set "Cascading LOV Parent Item(s)" = P1020_PRJ_ID

---

## 3. Interactive Grid Columns

### 3.1 Hidden Columns
| Column | Type | Purpose |
|--------|------|---------|
| Fun_Id | NUMBER | Primary Key |
| Mod_Id | NUMBER | FK to Modules |
| Prj_Id | NUMBER | FK to Projects (for filter) |
| Ba_Emp_Id | NUMBER | LOV return value |
| Lead_Emp_Id | NUMBER | LOV return value |
| Qa_Emp_Id | NUMBER | LOV return value |
| Current_Step | VARCHAR2(3) | LOV return value |
| Status | VARCHAR2(1) | LOV return value |
| Priority | VARCHAR2(1) | LOV return value |

### 3.2 Link Column (First visible column)
| Column | Label | Type | Width | Settings |
|--------|-------|------|-------|----------|
| Link_Form | - | HTML Expression | 50 | Escape Special Characters: No |

**HTML Expression:** (Already in query)
```html
<a href="..." class="t-Button t-Button--icon t-Button--info t-Button--small" title="View Details">
  <span class="fa fa-info-circle"></span>
</a>
```

### 3.3 Display Columns
| Column | Label | Type | Width | Editable |
|--------|-------|------|-------|----------|
| Link_Form | - | HTML | 50 | N |
| Project_Name | Project | Display | 150 | N |
| Module_Name | Module | Display | 150 | N |
| Function_Code | Code | Display | 100 | N |
| Function_Name | Function Name | Display | 200 | N |
| Ba_Name | BA | Display | 120 | N |
| Lead_Name | Leader | Display | 120 | N |
| Qa_Name | QA | Display | 120 | N |
| Step_Display | Step | HTML | 100 | N |
| Status_Display | Status | HTML | 100 | N |
| Priority_Display | Priority | HTML | 80 | N |
| Deadline_Display | Deadline | Display | 100 | N |
| Estimated_Hours | Est. Hours | Number | 80 | N |
| Actual_Hours | Act. Hours | Number | 80 | N |

### 3.4 HTML Expression for Badge Columns
For Step_Display, Status_Display, Priority_Display:
```html
<span class="&STEP_CSS.">&STEP_DISPLAY.</span>
<span class="&STATUS_CSS.">&STATUS_DISPLAY.</span>
<span class="&PRIORITY_CSS.">&PRIORITY_DISPLAY.</span>
```

---

## 4. Buttons & Actions

### 4.1 Page Buttons

| Button | Label | Position | Action | Condition |
|--------|-------|----------|--------|-----------|
| ADD_FUNCTION | Add Function | Right of IG Title | Open Modal 1021 | Role IN (BA, ADM) |
| SEARCH | Search | Filter Region | Submit Page | Always |
| RESET | Reset | Filter Region | Redirect to Page 1020 | Always |

### 4.2 Row Actions

| Action | Label | Icon | Action | Condition |
|--------|-------|------|--------|-----------|
| EDIT | Edit | fa-edit | Open Modal 1021 (P1021_FUN_ID = Fun_Id) | Always |
| SEND_TO_LEADER | Send to Leader | fa-paper-plane | Process: SEND_TO_LEADER | Current_Step = 'BA' AND Role = BA |
| ASSIGN_DEV | Assign DEV | fa-users | Navigate to 1030 | Current_Step = 'LED' AND Role = LED |
| REJECT | Reject | fa-times | Process: REJECT | Current_Step = 'LED' AND Role = LED |
| PASS | Pass | fa-check | Process: PASS_QA | Current_Step = 'QA' AND Role = QA |
| FAIL | Fail | fa-exclamation-triangle | Process: FAIL_QA | Current_Step = 'QA' AND Role = QA |
| VIEW_TASKS | View Tasks | fa-tasks | Navigate to 1030 (P1030_FUN_ID = Fun_Id) | Always |

---

## 5. Processes

> **Note:** This IG page is view-only. Data entry is handled through Form page (1021).

### 5.1 Row Action Processes

| Process | Request | PL/SQL |
|---------|---------|--------|
| SEND_TO_LEADER | SEND_TO_LEADER | `UPDATE WLM_FUNCTIONS SET Current_Step = 'LED', Status = 'I', Modify_Date = SYSDATE, Modified_By = LOWER(v('APP_USER')) WHERE Fun_Id = :FUN_ID;` |
| REJECT | REJECT | `UPDATE WLM_FUNCTIONS SET Current_Step = 'BA', Status = 'R', Modify_Date = SYSDATE, Modified_By = LOWER(v('APP_USER')) WHERE Fun_Id = :FUN_ID;` |
| PASS_QA | PASS_QA | `UPDATE WLM_FUNCTIONS SET Current_Step = 'DON', Status = 'C', Completed_Date = SYSDATE, Modify_Date = SYSDATE, Modified_By = LOWER(v('APP_USER')) WHERE Fun_Id = :FUN_ID;` |
| FAIL_QA | FAIL_QA | `UPDATE WLM_FUNCTIONS SET Current_Step = 'DEV', Modify_Date = SYSDATE, Modified_By = LOWER(v('APP_USER')) WHERE Fun_Id = :FUN_ID;` |

---

## 6. Authorization

### 6.1 Page Authorization
- Authorization Scheme: Must have WLM role

### 6.2 Role-Based Visibility

| Role | View | Add | Edit | Delete | Workflow Actions |
|------|------|-----|------|--------|------------------|
| ADM | Yes | Yes | Yes | Yes | All |
| BA | Yes | Yes | Yes | No | Send to Leader, Close, Reopen |
| LED | Yes | No | Yes | No | Assign DEV, Reject |
| DEV | Yes | No | No | No | None |
| QA | Yes | No | Yes | No | Pass, Fail |

### 6.3 Condition Examples
```sql
-- Check if user is BA
:G_WLM_ROLE = 'BA'

-- Check if user is LED
:G_WLM_ROLE = 'LED'

-- Check if user can send to leader
:G_WLM_ROLE = 'BA' AND :CURRENT_STEP = 'BA'
```

---

## 7. Dynamic Actions

### 7.1 Cascade LOV Refresh
- Event: Change on P1020_PRJ_ID
- Action: Refresh P1020_MOD_ID

### 7.2 Filter on Change
- Event: Change on any filter item
- Action: Submit Page

---

## 8. CSS Classes Used

From `APEX Status Colors CSS.css`:
- `status-active` - Green badge
- `status-pending` - Orange badge
- `status-progress` - Yellow badge
- `status-completed` - Green badge
- `status-rejected` - Red badge
- `status-info` - Blue badge
- `status-warning` - Yellow badge
- `status-danger` - Red badge

---

## 9. Navigation

| Action | Target Page | Parameters |
|--------|-------------|------------|
| Add Function | 1021 | P1021_FUN_ID = null |
| Edit Function | 1021 | P1021_FUN_ID = :FUN_ID |
| View Tasks | 1030 | P1030_FUN_ID = :FUN_ID |
| Assign DEV | 1030 | P1030_FUN_ID = :FUN_ID |

---

## 10. Testing Checklist

- [ ] Filter by Project works
- [ ] Filter by Module cascades correctly
- [ ] Filter by Status works
- [ ] Filter by Step works
- [ ] Add Function opens modal
- [ ] Edit opens modal with data
- [ ] Workflow buttons show/hide based on role
- [ ] Send to Leader changes step to LED
- [ ] Reject changes step to BA, status to R
- [ ] Pass changes step to DON, status to C
- [ ] Fail changes step to DEV
- [ ] View Tasks navigates correctly


