-- MediSafe-MAS v3 Audit Log Schema
-- PostgreSQL initialization script for clinical AI pipeline audit logging
-- This table tracks all pipeline stages for compliance, debugging, and quality assurance

CREATE TABLE IF NOT EXISTS medisafe_audit_log (
    id SERIAL PRIMARY KEY,
    case_id VARCHAR(50) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    stage VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Input stage fields (logged at INPUT_RECEIVED)
    input_length INTEGER,
    injection_flag BOOLEAN,
    pipeline_version VARCHAR(50),
    
    -- Safety stage fields (logged at SAFETY_EVALUATED)
    safety_score INTEGER,
    approved BOOLEAN,
    quality_badge TEXT,
    
    -- Report stage fields (logged at REPORT_DELIVERED)
    report_snippet TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_case_id ON medisafe_audit_log(case_id);
CREATE INDEX IF NOT EXISTS idx_session_id ON medisafe_audit_log(session_id);
CREATE INDEX IF NOT EXISTS idx_stage ON medisafe_audit_log(stage);
CREATE INDEX IF NOT EXISTS idx_timestamp ON medisafe_audit_log(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_approved ON medisafe_audit_log(approved) WHERE approved IS NOT NULL;

-- View for case timeline analysis
CREATE OR REPLACE VIEW v_case_timeline AS
SELECT 
    case_id,
    session_id,
    stage,
    timestamp,
    safety_score,
    approved,
    quality_badge,
    LEAD(timestamp) OVER (PARTITION BY case_id ORDER BY timestamp) - timestamp AS stage_duration
FROM medisafe_audit_log
ORDER BY case_id, timestamp;

-- View for safety metrics dashboard
CREATE OR REPLACE VIEW v_safety_metrics AS
SELECT 
    DATE(timestamp) AS date,
    COUNT(*) AS total_cases,
    COUNT(*) FILTER (WHERE approved = true) AS approved_cases,
    COUNT(*) FILTER (WHERE approved = false) AS rejected_cases,
    AVG(safety_score) FILTER (WHERE safety_score IS NOT NULL) AS avg_safety_score,
    COUNT(*) FILTER (WHERE injection_flag = true) AS injection_attempts
FROM medisafe_audit_log
WHERE stage = 'SAFETY_EVALUATED'
GROUP BY DATE(timestamp)
ORDER BY date DESC;

-- View for pipeline performance
CREATE OR REPLACE VIEW v_pipeline_performance AS
SELECT 
    case_id,
    MIN(timestamp) AS pipeline_start,
    MAX(timestamp) AS pipeline_end,
    MAX(timestamp) - MIN(timestamp) AS total_duration,
    COUNT(DISTINCT stage) AS stages_completed,
    MAX(safety_score) AS final_safety_score,
    MAX(approved) AS final_approved
FROM medisafe_audit_log
GROUP BY case_id
ORDER BY pipeline_start DESC;

-- Grant permissions (adjust user as needed)
GRANT SELECT, INSERT ON medisafe_audit_log TO PUBLIC;
GRANT SELECT ON v_case_timeline, v_safety_metrics, v_pipeline_performance TO PUBLIC;

-- Sample queries for verification and monitoring

-- Query 1: Recent audit entries
-- SELECT * FROM medisafe_audit_log ORDER BY timestamp DESC LIMIT 10;

-- Query 2: Case timeline for specific case
-- SELECT * FROM v_case_timeline WHERE case_id = 'CASE-1234567890-ABC123';

-- Query 3: Daily safety metrics
-- SELECT * FROM v_safety_metrics LIMIT 7;

-- Query 4: Pipeline performance summary
-- SELECT * FROM v_pipeline_performance LIMIT 10;

-- Query 5: Injection detection alerts
-- SELECT case_id, session_id, timestamp 
-- FROM medisafe_audit_log 
-- WHERE injection_flag = true 
-- ORDER BY timestamp DESC;

-- Query 6: Low safety score cases requiring review
-- SELECT case_id, safety_score, quality_badge, timestamp
-- FROM medisafe_audit_log
-- WHERE stage = 'SAFETY_EVALUATED' AND safety_score < 7
-- ORDER BY timestamp DESC;
