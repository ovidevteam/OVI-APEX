-- =====================================================
-- Page 1021: Function Form - Workflow Progress Bar
-- Purpose: Dynamic content showing workflow steps
-- Type: PL/SQL Function Body returning CLOB
-- Created: December 2025
-- Author: tuannt (OVI Development Team)
-- =====================================================

DECLARE
	v_html CLOB;
	v_current_step VARCHAR2(3) := :P1021_CURRENT_STEP;
	v_step_num NUMBER := 0;
BEGIN
	-- Determine step number (1-5)
	v_step_num := CASE v_current_step
		WHEN 'BA'  THEN 1
		WHEN 'LED' THEN 2
		WHEN 'DEV' THEN 3
		WHEN 'QA'  THEN 4
		WHEN 'DON' THEN 5
		ELSE 1
	END;
	v_html := '
<style>
.wlm-progress-container {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 10px 20px;
	background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
	border-radius: 12px;
	margin-bottom: 0px;
	box-shadow: 0 2px 8px rgba(0,0,0,0.06);
	position: sticky;
	top: 0;
	z-index: 100;
}
.wlm-step {
	display: flex;
	flex-direction: column;
	align-items: center;
	position: relative;
	flex: 1;
}
.wlm-step-circle {
	width: 40px;
	height: 40px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 600;
	font-size: 14px;
	transition: all 0.3s ease;
	border: 3px solid #cbd5e1;
	background: #ffffff;
	color: #64748b;
}
.wlm-step.completed .wlm-step-circle {
	background: linear-gradient(135deg, #10b981 0%, #059669 100%);
	border-color: #059669;
	color: #ffffff;
}
.wlm-step.active .wlm-step-circle {
	background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
	border-color: #1d4ed8;
	color: #ffffff;
	box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.3);
	transform: scale(1.1);
}
.wlm-step-label {
	margin-top: 8px;
	font-size: 12px;
	font-weight: 500;
	color: #64748b;
	text-align: center;
	white-space: nowrap;
}
.wlm-step.completed .wlm-step-label,
.wlm-step.active .wlm-step-label {
	color: #1e293b;
	font-weight: 600;
}
.wlm-step-line {
	position: absolute;
	top: 20px;
	left: calc(50% + 24px);
	width: calc(100% - 48px);
	height: 3px;
	background: #cbd5e1;
	z-index: 0;
}
.wlm-step.completed .wlm-step-line {
	background: linear-gradient(90deg, #10b981 0%, #059669 100%);
}
.wlm-step:last-child .wlm-step-line {
	display: none;
}
.wlm-step-icon {
	font-size: 16px;
}
</style>
<div class="wlm-progress-container">
	<div class="wlm-step ' || CASE WHEN v_step_num > 1 THEN 'completed' WHEN v_step_num = 1 THEN 'active' ELSE '' END || '">
		<div class="wlm-step-circle">
			' || CASE WHEN v_step_num > 1 THEN '<span class="fa fa-check"></span>' ELSE '<span class="fa fa-file-text-o"></span>' END || '
		</div>
		<div class="wlm-step-label">BA Review</div>
		<div class="wlm-step-line"></div>
	</div>
	<div class="wlm-step ' || CASE WHEN v_step_num > 2 THEN 'completed' WHEN v_step_num = 2 THEN 'active' ELSE '' END || '">
		<div class="wlm-step-circle">
			' || CASE WHEN v_step_num > 2 THEN '<span class="fa fa-check"></span>' ELSE '<span class="fa fa-user-circle-o"></span>' END || '
		</div>
		<div class="wlm-step-label">DEV Leader</div>
		<div class="wlm-step-line"></div>
	</div>
	<div class="wlm-step ' || CASE WHEN v_step_num > 3 THEN 'completed' WHEN v_step_num = 3 THEN 'active' ELSE '' END || '">
		<div class="wlm-step-circle">
			' || CASE WHEN v_step_num > 3 THEN '<span class="fa fa-check"></span>' ELSE '<span class="fa fa-code"></span>' END || '
		</div>
		<div class="wlm-step-label">Development</div>
		<div class="wlm-step-line"></div>
	</div>
	<div class="wlm-step ' || CASE WHEN v_step_num > 4 THEN 'completed' WHEN v_step_num = 4 THEN 'active' ELSE '' END || '">
		<div class="wlm-step-circle">
			' || CASE WHEN v_step_num > 4 THEN '<span class="fa fa-check"></span>' ELSE '<span class="fa fa-bug"></span>' END || '
		</div>
		<div class="wlm-step-label">QA Testing</div>
		<div class="wlm-step-line"></div>
	</div>
	<div class="wlm-step ' || CASE WHEN v_step_num = 5 THEN 'completed' ELSE '' END || '">
		<div class="wlm-step-circle">
			' || CASE WHEN v_step_num = 5 THEN '<span class="fa fa-check-circle"></span>' ELSE '<span class="fa fa-flag-checkered"></span>' END || '
		</div>
		<div class="wlm-step-label">Done</div>
	</div>
</div>';
	RETURN v_html;
EXCEPTION
	WHEN OTHERS THEN
		RETURN '<div style="color:#c00;padding:10px;">Error: ' || SQLERRM || '</div>';
END;

