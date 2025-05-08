# Script Structure Critic: Evaluation Criteria & Scoring Rubric

## 1. Core Evaluation Criteria

The Critic should assess the structured script on the following dimensions:

### A. Hierarchical Completeness
- Are all required levels present (Acts, Sequences, Scenes, Shots, [Beats if needed])?
- Are any levels missing or skipped where they would add clarity?

### B. Granularity & Segmentation
- Are scenes, shots, and (if present) beats appropriately segmented (not too long, not too short)?
- Are shots within the recommended duration/word count (e.g., 2–5 seconds for B-roll, 10–15 words max)?
- Are montages or complex actions broken into beats or multiple shots?

### C. Semantic Annotation Quality
- Are semantic tags present and meaningful at each level?
- Do tags help downstream agents (e.g., "montage", "dialogue", "reaction")?
- Are tags consistent and non-redundant?

### D. Narrative Flow & Logical Structure
- Does the structure follow a logical narrative arc (setup, development, climax, resolution)?
- Are transitions between acts/sequences/scenes clear and purposeful?
- Is there a clear beginning, middle, and end?

### E. Production Suitability
- Is each shot or beat suitable for downstream production (e.g., can be visualized with a single image or asset)?
- Are there any "problematic" segments (e.g., shots that are too long, ambiguous, or unvisualizable)?

### F. Annotation & Field Completeness
- Are all required fields filled at each level (titles, descriptions, narration, tags)?
- Are there any placeholders, empty fields, or missing data?

### G. Consistency & Naming
- Are IDs, labels, and titles consistent and unique?
- Is the naming scheme clear and traceable throughout the hierarchy?

---

## 2. Scoring Rubric

Each criterion can be scored on a 1–5 scale:

| Score | Description                                                                 |
|-------|-----------------------------------------------------------------------------|
| 5     | Excellent: Fully meets or exceeds expectations, no issues                   |
| 4     | Good: Minor issues, but overall strong                                      |
| 3     | Adequate: Some issues, but structure is usable with minor revision          |
| 2     | Poor: Significant issues, needs major revision                              |
| 1     | Unacceptable: Fails to meet requirements, not usable for production         |

**Total Score:**  
- Add up all category scores for a total (e.g., 7 categories × 5 = 35 max).
- Optionally, provide a percentage or letter grade.

---

## 3. Example Evaluation Table

| Criterion                  | Score (1–5) | Notes/Feedback                                      |
|----------------------------|-------------|-----------------------------------------------------|
| Hierarchical Completeness  | 4           | All levels present, but one sequence is missing     |
| Granularity & Segmentation | 3           | Some shots too long, needs more beats in montage    |
| Semantic Annotation        | 5           | Tags are clear and helpful                          |
| Narrative Flow             | 4           | Good arc, but Act 2 transition is abrupt            |
| Production Suitability     | 3           | One shot is too complex for a single image          |
| Field Completeness         | 5           | All fields filled                                   |
| Consistency & Naming       | 5           | IDs and labels are consistent                       |
| **Total**                  | **29/35**   |                                                     |

---

## 4. Pass/Fail and Iteration Guidance

- **Pass:** Total score ≥ 28/35 (or all categories ≥ 4)
- **Revise:** Any category ≤ 3, or total score < 28
- **Fail:** Any category ≤ 2, or total score < 21

**Feedback:**  
- For each criterion, provide specific, actionable feedback.
- If "Revise" or "Fail," list the top 2–3 issues to address in the next iteration.

---

## 5. Optional: Weighting

If some criteria are more important (e.g., segmentation, production suitability), you can assign weights. For most workflows, equal weighting is sufficient.

---

## 6. Critic Output Structure (Example)

```json
{
  "scores": {
    "hierarchical_completeness": 4,
    "granularity_segmentation": 3,
    "semantic_annotation": 5,
    "narrative_flow": 4,
    "production_suitability": 3,
    "field_completeness": 5,
    "consistency_naming": 5
  },
  "total_score": 29,
  "pass_fail": "revise",
  "feedback": [
    "Some shots are too long; consider splitting into beats.",
    "Act 2 transition is abrupt; clarify the narrative flow.",
    "One shot is too complex for a single image—split or clarify."
  ]
}
```

---

## 7. How to Use

- The Critic agent should output both the **scoring table** and **actionable feedback**.
- The Script Structure Agent uses this feedback to revise and resubmit, up to the allowed number of iterations.