/**
 * ICD-10 Lookup Tool for MediSafe-MAS v3
 * 
 * This tool provides ICD-10 code lookup functionality for the n8n workflow.
 * It uses the WHO ICD-10 API or a local fallback database.
 * 
 * Usage in n8n Code Tool:
 * - Copy this code into a Code Tool node
 * - Set tool name: "icd10_lookup"
 * - Set description: "Look up ICD-10 codes for medical conditions. Input: condition name as string. Returns ICD-10 code and description."
 */

// ICD-10 Lookup Tool Implementation
const conditionQuery = typeof query === 'object' ? (query.condition || query.query || JSON.stringify(query)) : String(query);

// Fallback ICD-10 database for common conditions
const ICD10_DATABASE = {
  // Cardiovascular
  "myocardial infarction": { code: "I21.9", description: "Acute myocardial infarction, unspecified" },
  "mi": { code: "I21.9", description: "Acute myocardial infarction, unspecified" },
  "heart attack": { code: "I21.9", description: "Acute myocardial infarction, unspecified" },
  "stemi": { code: "I21.3", description: "ST elevation myocardial infarction" },
  "nstemi": { code: "I21.4", description: "Non-ST elevation myocardial infarction" },
  "angina": { code: "I20.9", description: "Angina pectoris, unspecified" },
  "unstable angina": { code: "I20.0", description: "Unstable angina" },
  "atrial fibrillation": { code: "I48.91", description: "Atrial fibrillation, unspecified" },
  "heart failure": { code: "I50.9", description: "Heart failure, unspecified" },
  "hypertension": { code: "I10", description: "Essential (primary) hypertension" },
  "stroke": { code: "I63.9", description: "Cerebral infarction, unspecified" },
  "ischemic stroke": { code: "I63.9", description: "Cerebral infarction, unspecified" },
  "hemorrhagic stroke": { code: "I61.9", description: "Intracerebral hemorrhage, unspecified" },
  
  // Respiratory
  "pneumonia": { code: "J18.9", description: "Pneumonia, unspecified organism" },
  "copd": { code: "J44.9", description: "Chronic obstructive pulmonary disease, unspecified" },
  "asthma": { code: "J45.909", description: "Unspecified asthma, uncomplicated" },
  "pulmonary embolism": { code: "I26.99", description: "Pulmonary embolism without acute cor pulmonale" },
  "pe": { code: "I26.99", description: "Pulmonary embolism without acute cor pulmonale" },
  "bronchitis": { code: "J40", description: "Bronchitis, not specified as acute or chronic" },
  "respiratory failure": { code: "J96.90", description: "Respiratory failure, unspecified" },
  
  // Gastrointestinal
  "appendicitis": { code: "K35.80", description: "Unspecified acute appendicitis" },
  "cholecystitis": { code: "K81.9", description: "Cholecystitis, unspecified" },
  "pancreatitis": { code: "K85.90", description: "Acute pancreatitis without necrosis or infection, unspecified" },
  "gastroenteritis": { code: "K52.9", description: "Gastroenteritis and colitis, unspecified" },
  "peptic ulcer": { code: "K27.9", description: "Peptic ulcer, site unspecified" },
  "bowel obstruction": { code: "K56.60", description: "Unspecified intestinal obstruction" },
  "diverticulitis": { code: "K57.92", description: "Diverticulitis of intestine, unspecified" },
  
  // Neurological
  "seizure": { code: "R56.9", description: "Unspecified convulsions" },
  "epilepsy": { code: "G40.909", description: "Epilepsy, unspecified, not intractable" },
  "migraine": { code: "G43.909", description: "Migraine, unspecified, not intractable" },
  "meningitis": { code: "G03.9", description: "Meningitis, unspecified" },
  "encephalitis": { code: "G04.90", description: "Encephalitis, unspecified" },
  "tia": { code: "G45.9", description: "Transient cerebral ischemic attack, unspecified" },
  "transient ischemic attack": { code: "G45.9", description: "Transient cerebral ischemic attack, unspecified" },
  
  // Infectious
  "sepsis": { code: "A41.9", description: "Sepsis, unspecified organism" },
  "septic shock": { code: "R65.21", description: "Severe sepsis with septic shock" },
  "urinary tract infection": { code: "N39.0", description: "Urinary tract infection, site not specified" },
  "uti": { code: "N39.0", description: "Urinary tract infection, site not specified" },
  "cellulitis": { code: "L03.90", description: "Cellulitis, unspecified" },
  "influenza": { code: "J11.1", description: "Influenza with other respiratory manifestations" },
  "covid-19": { code: "U07.1", description: "COVID-19" },
  
  // Metabolic/Endocrine
  "diabetes mellitus": { code: "E11.9", description: "Type 2 diabetes mellitus without complications" },
  "diabetes": { code: "E11.9", description: "Type 2 diabetes mellitus without complications" },
  "type 1 diabetes": { code: "E10.9", description: "Type 1 diabetes mellitus without complications" },
  "type 2 diabetes": { code: "E11.9", description: "Type 2 diabetes mellitus without complications" },
  "diabetic ketoacidosis": { code: "E10.10", description: "Type 1 diabetes mellitus with ketoacidosis" },
  "dka": { code: "E10.10", description: "Type 1 diabetes mellitus with ketoacidosis" },
  "hypoglycemia": { code: "E16.2", description: "Hypoglycemia, unspecified" },
  "hyperglycemia": { code: "R73.9", description: "Hyperglycemia, unspecified" },
  "hypothyroidism": { code: "E03.9", description: "Hypothyroidism, unspecified" },
  "hyperthyroidism": { code: "E05.90", description: "Thyrotoxicosis, unspecified" },
  
  // Renal
  "acute kidney injury": { code: "N17.9", description: "Acute kidney failure, unspecified" },
  "aki": { code: "N17.9", description: "Acute kidney failure, unspecified" },
  "chronic kidney disease": { code: "N18.9", description: "Chronic kidney disease, unspecified" },
  "ckd": { code: "N18.9", description: "Chronic kidney disease, unspecified" },
  "renal failure": { code: "N19", description: "Unspecified kidney failure" },
  
  // Trauma
  "head injury": { code: "S09.90", description: "Unspecified injury of head" },
  "concussion": { code: "S06.0X0A", description: "Concussion without loss of consciousness" },
  "fracture": { code: "T14.8", description: "Other injury of unspecified body region" },
  "chest trauma": { code: "S29.9", description: "Unspecified injury of thorax" },
  "abdominal trauma": { code: "S39.91", description: "Unspecified injury of abdomen" },
  
  // Hematologic
  "anemia": { code: "D64.9", description: "Anemia, unspecified" },
  "thrombocytopenia": { code: "D69.6", description: "Thrombocytopenia, unspecified" },
  "dvt": { code: "I82.90", description: "Deep vein thrombosis, unspecified" },
  "deep vein thrombosis": { code: "I82.90", description: "Deep vein thrombosis, unspecified" },
  
  // Psychiatric
  "depression": { code: "F32.9", description: "Major depressive disorder, single episode, unspecified" },
  "anxiety": { code: "F41.9", description: "Anxiety disorder, unspecified" },
  "psychosis": { code: "F29", description: "Unspecified psychosis not due to a substance" },
  "delirium": { code: "F05", description: "Delirium due to known physiological condition" },
  
  // Other common presentations
  "chest pain": { code: "R07.9", description: "Chest pain, unspecified" },
  "abdominal pain": { code: "R10.9", description: "Abdominal pain, unspecified" },
  "shortness of breath": { code: "R06.02", description: "Shortness of breath" },
  "dyspnea": { code: "R06.02", description: "Shortness of breath" },
  "fever": { code: "R50.9", description: "Fever, unspecified" },
  "syncope": { code: "R55", description: "Syncope and collapse" },
  "altered mental status": { code: "R41.82", description: "Altered mental status, unspecified" },
  "shock": { code: "R57.9", description: "Shock, unspecified" },
  "hypotension": { code: "I95.9", description: "Hypotension, unspecified" }
};

// Normalize query for lookup
const normalizedQuery = conditionQuery.toLowerCase().trim();

// Try exact match first
if (ICD10_DATABASE[normalizedQuery]) {
  const result = ICD10_DATABASE[normalizedQuery];
  return JSON.stringify({
    condition: conditionQuery,
    icd10_code: result.code,
    description: result.description,
    source: "local_database",
    confidence: "high"
  });
}

// Try partial match
for (const [key, value] of Object.entries(ICD10_DATABASE)) {
  if (normalizedQuery.includes(key) || key.includes(normalizedQuery)) {
    return JSON.stringify({
      condition: conditionQuery,
      icd10_code: value.code,
      description: value.description,
      source: "local_database",
      confidence: "medium",
      note: `Partial match for '${key}'`
    });
  }
}

// No match found
return JSON.stringify({
  condition: conditionQuery,
  icd10_code: null,
  description: "No ICD-10 code found in database",
  source: "local_database",
  confidence: "none",
  note: "Consider manual coding or using external ICD-10 API"
});
