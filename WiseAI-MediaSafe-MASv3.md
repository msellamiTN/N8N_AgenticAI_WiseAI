---
title: Untitled

---

# Hands-On Lab: Building MediSafe-MAS
## Responsible Multi-Agent Clinical Triage with n8n & Ollama

**Target Audience:** Clinical Informatics Students, AI Engineers  
**Lab Duration:** 60 Minutes  
**Prerequisites:** n8n [NIGHTLY] installed, Ollama running locally (`llama3.2:latest`)

---

## Lab Overview

In this lab, you will build **MediSafe-MAS**, a responsible multi-agent clinical triage system. You will learn to orchestrate specialized AI agents that prioritize **explainability**, **epistemic honesty**, and **regulatory compliance**.

### The Architecture
![Workflow Overview](https://i.imgur.com/8Q8pY9z.png)
*The sequential pipeline: Patient Input → Feature Extraction → Differential Diagnosis → Risk Stratification → Safety Audit → Synthesis.*

---

## Step 1: Initialize the Patient Chat Interface

The entry point is a Chat Trigger node. It handles the session management and receives the clinician's free-text input.

1.  Add a **Chat Trigger** node (labeled `🏥 Patient Input`).
2.  Set **Session ID** to `Connected Chat Trigger Node`.
3.  Ensure it is connected to the **Clinical Session Memory** and the first AI Agent.

![Step 1 Config](https://i.imgur.com/mO2X1J3.png)

---

## Step 2: Configure Clinical Session Memory

Inter-agent communication requires shared state. We use a dedicated memory node to store the patient's context across the pipeline.

1.  Add a **Clinical Session Memory** node.
2.  Set **Context Window Length** to `6`.
3.  Map the **Session Key** to `{{ $json.sessionId }}`.

![Step 2 Memory](https://i.imgur.com/G3P2J1G.png)

---

## Step 3: Implement the Feature Extraction Agent (Epistemic Honesty)

The first agent's job is to structure data **without diagnosing**.

1.  Add an **AI Agent** node (labeled `🔬 Feature Extraction Agent`).
2.  Connect an **Ollama Chat Model** node (Model: `llama3.2:latest`).
3.  **Critical System Prompt:**
    > Your SOLE role is to parse the clinician's free-text patient description and extract structured clinical features. You do NOT diagnose. You do NOT recommend. You ONLY structure the input.
    >
    > **RULES:**
    > 1. Extract ONLY information explicitly stated.
    > 2. If a field is not mentioned, set it to `null`.
    > 3. Preserve exact symptom terms.

![Step 3 Agent](https://i.imgur.com/K5P2U9B.png)

---

## Step 4: Add the Differential Diagnosis Agent

This agent performs clinical reasoning based on the structured features.

1.  Add an **AI Agent** node (labeled `🧠 Differential Diagnosis Agent`).
2.  **System Prompt Requirements:**
    - Generate a ranked differential diagnosis.
    - Provide **ICD-10 codes**.
    - For each diagnosis, list **Supporting Features** AND **Counter-Evidence**.
    - Assign a confidence level (`High`, `Medium`, `Low`).

![Step 4 Agent](https://i.imgur.com/T4N2W2Q.png)

---

## Step 5: Implement Risk Stratification (Emergency Frameworks)

1.  Add an **AI Agent** node (labeled `⚠️ Risk Stratification Agent`).
2.  Instruct the agent to use the **Manchester Triage System (MTS)** logic.
3.  Output requirements: `Triage Level`, `Triage Color`, `Maximum Wait Minutes`, and `Immediate Actions`.

![Step 5 Agent](https://i.imgur.com/V9X2S3H.png)

---

## Step 6: The Safety Gate (Safety & Compliance Agent)

This is the most critical node for **Responsible AI**. It audits the entire pipeline's output.

1.  Add an **AI Agent** node (labeled `🛡️ Safety & Compliance Agent`).
2.  **System Prompt Focus:**
    - Score the output from 0-10 (`safety_score`).
    - Evaluate **Hallucination Risk**, **Omission Risk**, and **Bias**.
    - Check for **EU AI Act compliance**.
    - **Approval Threshold:** Set a logic gate where `approved = true` only if `safety_score >= 7`.

![Step 6 Safety](https://i.imgur.com/X4P2Y6I.png)

---

## Step 7: Final Report Synthesis

1.  Add an **AI Agent** node (labeled `📋 Clinical Report Synthesizer`).
2.  Instruct it to combine all previous agent outputs into a professional, structured clinical report.
3.  Ensure the **AI-Assisted Decision Support** warning is prominently displayed.

![Step 7 Synthesis](https://i.imgur.com/L5P2Z7J.png)

---

## Step 8: Running a Test Case

1.  Click **Test Chat** in the bottom right.
2.  Input the following case:
    > Male, 58yo. Sudden severe chest pain radiating to left arm, 45 min ago. Diaphoresis, nausea. No cardiac history. BP unknown. HR ~110. SpO2 unknown.
3.  Monitor the **Logs** tab to see the agent chain in action.

![Step 8 Test](https://i.imgur.com/N6P2A8K.png)

---

## Summary of Responsible Design Patterns Learned

- **Epistemic Honesty:** Using `null` for missing vitals instead of hallucinating values.
- **Role Separation:** Dedicated agents for extraction vs. diagnosis vs. safety.
- **Auditability:** Every diagnosis requires counter-evidence and a safety score.
- **Human-in-the-loop:** The system flags when human review is required based on risk scores.

---

*This lab guide was generated for clinical triage informatics students using the ICCSIC 2026 MediSafe-MAS workflow.*