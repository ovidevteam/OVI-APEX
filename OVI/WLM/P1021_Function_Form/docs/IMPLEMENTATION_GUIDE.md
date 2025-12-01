# Page 1021: Function Form - Implementation Guide

> **Page ID:** 1021
> **Page Name:** Function Form
> **Page Type:** Modal Dialog Form
> **Dialog Width:** 1000px
> **Author:** tuannt

---

## 1. Page Setup

### 1.1 Create Page
- Page Number: 1021
- Name: Function Form
- Page Mode: Modal Dialog
- Dialog Width: 1000px
- Navigation: None (Modal)

### 1.2 Page Items (Hidden)
| Item | Type | Source |
|------|------|--------|
| P1021_FUN_ID | Hidden | Primary Key |
| P1021_PRJ_ID | Hidden | For cascade LOV |

---

## 2. Tabs Structure

### 2.1 Tab Container
- Type: Sub Regions (Tabs)
- Static ID: FUNCTION_TABS

### 2.2 Tabs

| Tab | Name | Static ID |
|-----|------|-----------|
| 1 | General Information | TAB_GENERAL |
| 2 | Assignment | TAB_ASSIGNMENT |
| 3 | Progress | TAB_PROGRESS |
| 4 | Tasks & Comments | TAB_TASKS_COMMENTS |

---

## 3. Tab 1: General Information

### Page Items

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1021_MOD_ID | Module | Select List | LOV_WLM_MODULES_CASCADE | Y | required-field |
| P1021_FUNCTION_CODE | Function Code | Text | - | Y | required-field |
| P1021_FUNCTION_NAME | Function Name | Text | - | Y | required-field |
| P1021_DESCRIPTION | Description | Rich Text Editor | - | N | - |
| P1021_TECHNICAL_DESC | Technical Description | Rich Text Editor | - | N | - |
| P1021_PRIORITY | Priority | Radio Group | WLM_PRIORITY | Y | - |

### Default Values
- P1021_PRIORITY: 'M' (Medium)

---

## 4. Tab 2: Assignment

### Page Items

| Item | Label | Type | LOV | Required | CSS |
|------|-------|------|-----|----------|-----|
| P1021_BA_EMP_ID | BA | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_LEAD_EMP_ID | DEV Leader | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_QA_EMP_ID | QA | Popup LOV | LOV_EMPLOYEES | N | - |
| P1021_CURRENT_STEP | Current Step | Display Only | WLM_WORKFLOW_STEP | - | disable |
| P1021_STATUS | Status | Display Only | WLM_FUNCTION_STATUS | - | disable |

### Display with Badge
For P1021_CURRENT_STEP and P1021_STATUS, use HTML Expression:
```html
<span class="&P1021_CURRENT_STEP_CSS.">&P1021_CURRENT_STEP_DISPLAY.</span>
<span class="&P1021_STATUS_CSS.">&P1021_STATUS_DISPLAY.</span>
```

---

## 5. Tab 3: Progress

### Page Items

| Item | Label | Type | LOV | Required | CSS | Custom |
|------|-------|------|-----|----------|-----|--------|
| P1021_ESTIMATED_HOURS | Estimated Hours | Number | - | N | - | - |
| P1021_ACTUAL_HOURS | Actual Hours | Number | - | - | disable | tabindex="-1" |
| P1021_START_DATE | Start Date | Date Picker | - | N | - | - |
| P1021_DEADLINE | Deadline | Date Picker | - | N | - | - |
| P1021_COMPLETED_DATE | Completed Date | Date Picker | - | - | disable | tabindex="-1" |

### Date Format
- All date fields: Format Mask = &G_DATE_FORMAT.

---

## 6. Tab 4: Tasks & Comments

### 6.1 Tasks Sub-Region
- Type: Interactive Grid (Read-Only or Editable based on role)
- Static ID: TASKS_SUBGRID
- Source: `sql/function_tasks_subgrid.sql`

### 6.2 Comments Sub-Region
- Type: Interactive Grid
- Static ID: COMMENTS_SUBGRID
- Source: `sql/function_comments_subgrid.sql`

---

## 7. Audit Fields (Tab 3 or Collapsible Region)

### Page Items

| Item | Label | Type | CSS | Custom |
|------|-------|------|-----|--------|
| P1021_CREATED_DATE | Created Date | Display Only | disable | tabindex="-1" |
| P1021_CREATED_BY | Created By | Display Only | disable | tabindex="-1" |
| P1021_MODIFY_DATE | Modified Date | Display Only | disable | tabindex="-1" |
| P1021_MODIFIED_BY | Modified By | Display Only | disable | tabindex="-1" |

---

## 8. Buttons

### 8.1 Standard Form Buttons

| Button | Label | Position | Request | Condition | CSS |
|--------|-------|----------|---------|-----------|-----|
| CREATE | Create | Create | CREATE | :P1021_FUN_ID IS NULL | t-Button--hot |
| SAVE | Save | Change | SAVE | :P1021_FUN_ID IS NOT NULL | t-Button--hot |
| DELETE | Delete | Delete | DELETE | :P1021_FUN_ID IS NOT NULL AND :G_WLM_ROLE = 'ADM' | t-Button--danger |
| CANCEL | Cancel | Close | - | Always | - |

### 8.2 Workflow Buttons

| Button | Label | Position | Request | Condition | CSS |
|--------|-------|----------|---------|-----------|-----|
| SEND_TO_LEADER | Send to Leader | Change | SEND_TO_LEADER | :P1021_CURRENT_STEP = 'BA' AND :G_WLM_ROLE = 'BA' | t-Button--success |
| ASSIGN_DEV | Assign DEV | Change | - (Navigate) | :P1021_CURRENT_STEP = 'LED' AND :G_WLM_ROLE = 'LED' | t-Button--info |
| REJECT | Reject | Change | REJECT | :P1021_CURRENT_STEP = 'LED' AND :G_WLM_ROLE = 'LED' | t-Button--warning |
| PASS | Pass | Change | PASS_QA | :P1021_CURRENT_STEP = 'QA' AND :G_WLM_ROLE = 'QA' | t-Button--success |
| FAIL | Fail | Change | FAIL_QA | :P1021_CURRENT_STEP = 'QA' AND :G_WLM_ROLE = 'QA' | t-Button--danger |
| CLOSE | Close | Change | CLOSE | :P1021_CURRENT_STEP = 'DON' AND :G_WLM_ROLE = 'BA' | t-Button--success |
| REOPEN | Reopen | Change | REOPEN | :P1021_CURRENT_STEP = 'DON' AND :G_WLM_ROLE = 'BA' | t-Button--warning |

---

## 9. Processes

### 9.1 Form Processing
- Point: Processing
- Type: PL/SQL Code
- PL/SQL Code: Contents of `processes/function_form_process.sql`
- Condition: Request IN (CREATE, SAVE, DELETE)

### 9.2 Workflow Processes
Create separate processes for each workflow action:

| Process | Request | Source |
|---------|---------|--------|
| Send to Leader | SEND_TO_LEADER | `processes/function_workflow_actions.sql` (SEND_TO_LEADER section) |
| Reject | REJECT | `processes/function_workflow_actions.sql` (REJECT section) |
| Pass QA | PASS_QA | `processes/function_workflow_actions.sql` (PASS_QA section) |
| Fail QA | FAIL_QA | `processes/function_workflow_actions.sql` (FAIL_QA section) |
| Close | CLOSE | `processes/function_workflow_actions.sql` (CLOSE section) |
| Reopen | REOPEN | `processes/function_workflow_actions.sql` (REOPEN section) |

---

## 10. Branches

### 10.1 After Form Submit
- Target: Page 1020 (Functions IG)
- Condition: Request IN (CREATE, SAVE, DELETE, SEND_TO_LEADER, REJECT, PASS_QA, CLOSE, REOPEN)

### 10.2 Assign DEV Navigation
- Target: Page 1030 (Tasks)
- Parameters: P1030_FUN_ID = &P1021_FUN_ID.
- Condition: Request = ASSIGN_DEV (or button action)

---

## 11. Workflow State Diagram

```
              ┌─────────────────────────────────────────────────────────┐
              │                                                         │
              ▼                                                         │
    ┌─────────────┐     Send to      ┌─────────────┐     Assign     ┌─────────────┐
    │     BA      │ ───────────────► │     LED     │ ─────────────► │     DEV     │
    │   Review    │                  │   Assign    │                │ Development │
    └─────────────┘                  └─────────────┘                └─────────────┘
          ▲                                │                              │
          │                                │                              │
          │ Reject                         │                              │
          └────────────────────────────────┘                              │
                                                                          │
                                                                          │ All Tasks
                                                                          │ Completed
                                                                          ▼
    ┌─────────────┐     Close        ┌─────────────┐      Pass      ┌─────────────┐
    │    DON      │ ◄─────────────── │     DON     │ ◄────────────── │     QA      │
    │   (Final)   │                  │  Completed  │                 │   Testing   │
    └─────────────┘                  └─────────────┘                 └─────────────┘
          │                                ▲                              │
          │ Reopen                         │                              │ Fail
          └────────────────────────────────┼──────────────────────────────┘
                                           │
                                      (Back to DEV)
```

---

## 12. Authorization Matrix

| Role | View | Create | Edit | Delete | Send to Leader | Assign DEV | Reject | Pass | Fail | Close | Reopen |
|------|------|--------|------|--------|----------------|------------|--------|------|------|-------|--------|
| ADM | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| BA | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| LED | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| DEV | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| QA | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |

---

## 13. CSS Classes Used

From `APEX Status Colors CSS.css`:
- `status-active` - Green badge (Active)
- `status-pending` - Orange badge (Pending)
- `status-progress` - Yellow badge (In Progress)
- `status-completed` - Green badge (Completed)
- `status-rejected` - Red badge (Rejected)
- `status-info` - Blue badge (Info)
- `required-field` - Required field indicator
- `disable` - Disabled field styling
- `region-beautiful` - Beautiful region styling
- `t-Button--hot` - Primary button
- `t-Button--success` - Success button (green)
- `t-Button--warning` - Warning button (orange)
- `t-Button--danger` - Danger button (red)
- `t-Button--info` - Info button (blue)

---

## 14. Testing Checklist

### Form Operations
- [ ] Create new function works
- [ ] Save existing function works
- [ ] Delete function works (ADM only)
- [ ] Cancel closes modal

### Workflow Buttons
- [ ] Send to Leader shows only for BA when Step = BA
- [ ] Assign DEV shows only for LED when Step = LED
- [ ] Reject shows only for LED when Step = LED
- [ ] Pass shows only for QA when Step = QA
- [ ] Fail shows only for QA when Step = QA
- [ ] Close shows only for BA when Step = DON
- [ ] Reopen shows only for BA when Step = DON

### Workflow Transitions
- [ ] Send to Leader changes Step to LED, Status to I
- [ ] Reject changes Step to BA, Status to R
- [ ] Assign DEV navigates to Page 1030
- [ ] Pass changes Step to DON, Status to C
- [ ] Fail changes Step to DEV, creates bug task
- [ ] Close adds audit comment
- [ ] Reopen changes Step to DEV, Status to I

### Sub-Regions
- [ ] Tasks sub-grid loads correctly
- [ ] Comments sub-grid loads correctly
- [ ] Add comment works

### Authorization
- [ ] ADM can do everything
- [ ] BA cannot delete
- [ ] LED can only Assign/Reject
- [ ] DEV can only view
- [ ] QA can only Pass/Fail


