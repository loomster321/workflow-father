# Video Hierarchical Structure Schema

## Overview

This document defines the hierarchical structure for video script segmentation and annotation, supporting advanced agentic workflows in video production. The schema enables precise breakdown and semantic tagging at every narrative level, from the entire video down to individual beats. It is designed for use by the Script Structure Agent (for generation) and the Structure Critic (for review and feedback).

---

## Table of Contents

- [Overview](#overview)
- [Hierarchy Levels](#hierarchy-levels)
  - [Video](#video)
  - [Acts](#acts)
  - [Sequences](#sequences)
  - [Scenes](#scenes)
  - [Shots](#shots)
  - [Beats](#beats)
- [Semantic Annotation](#semantic-annotation)
- [Schema Structure](#schema-structure)
- [Example JSON Schema](#example-json-schema)

---

## Hierarchy Levels

### Video
- **Fields:**
  - `video_title`: Title of the video
  - `segments`: Array of act objects

### Acts
- **Purpose:** Major narrative divisions (e.g., Setup, Confrontation, Resolution)
- **Fields:**
  - `level`: "act"
  - `label`: Unique identifier (e.g., "act-1")
  - `title`: Title for the act
  - `description`: Summary of act narrative purpose
  - `semantic_tags`: e.g., `setup`, `climax`, `resolution`
  - `word_count`: Total word count for this act
  - `estimated_duration`: Estimated duration in seconds
  - `segments`: Array of sequence objects

### Sequences
- **Purpose:** Thematic or narrative subunits within acts (e.g., Montage, Conflict, Transition)
- **Fields:**
  - `level`: "sequence"
  - `label`: Unique identifier (e.g., "act-1_seq-1")
  - `title`: Title for the sequence
  - `description`: Summary of sequence purpose
  - `semantic_tags`: e.g., `montage`, `turning point`, `flashback`
  - `word_count`: Total word count for this sequence
  - `estimated_duration`: Estimated duration in seconds
  - `segments`: Array of scene objects

### Scenes
- **Purpose:** Continuous action in a single location/time, or a distinct narrative event
- **Fields:**
  - `level`: "scene"
  - `label`: Unique identifier (e.g., "act-1_seq-1_scene-1")
  - `title`: Title for the scene
  - `description`: Summary of scene action
  - `narration_text`: Exact narration for this scene
  - `semantic_tags`: e.g., `dialogue`, `emotional high`, `reveal`
  - `word_count`: Total word count for this scene
  - `estimated_duration`: Estimated duration in seconds
  - `segments`: Array of shot objects

### Shots
- **Purpose:** Single visual unit (usually 2–5 seconds for B-roll), mapped to a single image or camera take
- **Fields:**
  - `level`: "shot"
  - `label`: Unique identifier (e.g., "act-1_seq-1_scene-1_shot-1")
  - `description`: What happens visually in this shot
  - `narration_text`: Narration for this shot, if any
  - `semantic_tags`: e.g., `close-up`, `establishing`, `montage`, `reaction`
  - `word_count`: Total word count for this shot
  - `estimated_duration`: Estimated duration in seconds
  - `segments`: Array of beat objects

### Beats
- **Purpose:** Micro-actions or narrative moments within a shot (e.g., a glance, a reveal, a gesture)
- **Fields:**
  - `level`: "beat"
  - `label`: Unique identifier (e.g., "act-1_seq-1_scene-1_shot-1_beat-1")
  - `title`: Title for the beat
  - `description`: Micro-action or narrative beat
  - `narration_text`: Narration for this beat, if any
  - `semantic_tags`: e.g., `reaction`, `transition`, `emphasis`
  - `word_count`: Total word count for this beat
  - `estimated_duration`: Estimated duration in seconds
  - `segments`: Empty array

---

## Semantic Annotation

Each level supports a `semantic_tags` array for downstream agents and production tools. Tags should be concise, standardized where possible, and relevant to the narrative or production function. Example tags:

- **Acts:** `setup`, `climax`, `resolution`, `flashback`
- **Sequences:** `montage`, `conflict`, `transition`, `dream`
- **Scenes:** `dialogue`, `reveal`, `emotional high`, `action`
- **Shots:** `close-up`, `establishing`, `POV`, `montage`, `reaction`
- **Beats:** `glance`, `reveal`, `transition`, `emphasis`, `pause`

---

## Schema Structure

The schema follows a generic, recursive structure where each level contains:

- `level`: string (e.g., "act", "sequence", "scene", "shot", "beat")
- `label`: string (unique identifier for the level, e.g., "act-1", "scene-2_shot-1")
- `title`: string (title for the level; **not present for shots**)
- `description`: string (summary of the level's content or purpose)
- `semantic_tags`: array of strings (tags relevant to the level)
- `word_count`: number (total word count for this level)
- `estimated_duration`: number (estimated duration in seconds)
- `narration_text`: string (only present for scenes, shots, and beats)
- `segments`: array of nested level objects

**Notes:**
- Only scenes, shots, and beats include a `narration_text` field
- Shots do **not** have a `title` field
- The structure is recursive: each `segments` array contains objects with the same structure

---

## Example JSON Schema

```json
{
  "video_title": "A Generic Example Video",
  "segments": [
    {
      "level": "act",
      "label": "act-1",
      "title": "Introduction",
      "description": "Establishes the main theme and introduces the context.",
      "semantic_tags": ["setup"],
      "word_count": 200,
      "estimated_duration": 60.0,
      "segments": [
        {
          "level": "sequence",
          "label": "act-1_seq-1",
          "title": "Background",
          "description": "Provides background information.",
          "semantic_tags": ["background"],
          "word_count": 100,
          "estimated_duration": 30.0,
          "segments": [
            {
              "level": "scene",
              "label": "act-1_seq-1_scene-1",
              "title": "Opening Scene",
              "description": "The opening scene sets the stage.",
              "semantic_tags": ["opening"],
              "word_count": 50,
              "estimated_duration": 15.0,
              "narration_text": "Welcome to this story. Let's begin with some background.",
              "segments": [
                {
                  "level": "shot",
                  "label": "act-1_seq-1_scene-1_shot-1",
                  "description": "A wide shot of the setting.",
                  "semantic_tags": ["wide"],
                  "word_count": 20,
                  "estimated_duration": 6.0,
                  "narration_text": "The sun rises over the city.",
                  "segments": [
                    {
                      "level": "beat",
                      "label": "act-1_seq-1_scene-1_shot-1_beat-1",
                      "title": "Figure Appearance",
                      "description": "A character enters the frame.",
                      "semantic_tags": ["action"],
                      "word_count": 5,
                      "estimated_duration": 2.0,
                      "narration_text": "A figure appears in the distance.",
                      "segments": []
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```