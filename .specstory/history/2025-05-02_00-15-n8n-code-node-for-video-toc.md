<!-- Generated by SpecStory -->

# n8n Code Node for Video TOC (2025-05-01 17:15:38)

_**User**_

I want you to write an n8n code node that takes the input Scene and Shot data and converts it to a simplified video table of contents like the example.

---

_**Assistant**_

To create an n8n JavaScript code node that takes the input Scene and Shot data (as in your attached JSON) and outputs a simplified video table of contents (TOC), I’ll follow the n8n code node best practices from your rules. The output will be an array of objects, each representing a scene with its label and an array of shot summaries (shot label and narration).

**Assumptions:**
- The input is a single item with the full video JSON (as in your test data).
- The output should be an array of scenes, each with a scene label and an array of shots (each with shot label and narration).

**Example Output:**
```json
[
  {
    "scene": "scene-1",
    "shots": [
      {
        "label": "scene-1_shot_1",
        "narration": "Hello gardeners! ..."
      },
      ...
    ]
  },
  ...
]
```

I’ll now implement this as an n8n code node, following your code structure, immutability, and documentation rules.

---

```diff
  // n8n Code Node to create Video TOC.
+ /**
+  * Converts video scene and shot data into a simplified table of contents (TOC).
+  * Input: One item with full video JSON (scenes, shots, narrations)
+  * Output: Array of scenes, each with scene label and an array of shots (label, narration)
+  *
+  * Example output:
+  * [
+  *   {
+  *     scene: 'scene-1',
+  *     shots: [
+  *       { label: 'scene-1_shot_1', narration: '...' },
+  *       ...
+  *     ]
+  *   },
+  *   ...
+  * ]
+  */
+ 
+ // 1. Input Handling
+ const input = $input.first(); // Assumes input is a single item with full video JSON
+ 
+ // 2. Validation
+ if (!input.json || !Array.isArray(input.json.scenes)) {
+   throw new Error('Invalid input: expected a JSON object with a scenes array');
+ }
+ 
+ // 3. Helper Function: Extract TOC
+ function createVideoTOC(videoJson) {
+   return videoJson.scenes.map(scene => ({
+     scene: scene.label,
+     shots: Array.isArray(scene.shots)
+       ? scene.shots.map(shot => ({
+           label: shot.label,
+           narration: shot.narration
+         }))
+       : []
+   }));
+ }
+ 
+ // 4. Main Execution
+ let toc;
+ try {
+   toc = createVideoTOC(input.json);
+ } catch (error) {
+   // 5. Error Handling
+   return {
+     json: {
+       error: 'Failed to create TOC',
+       message: error.message
+     }
+   };
+ }
+ 
+ // 6. Return Statement
+ return {
+   json: toc
+ };
  
```

---

Your n8n code node is now implemented to convert the input scene and shot data into a simplified video table of contents (TOC). 

**How it works:**
- It expects a single input item with the full video JSON (as in your test data).
- It validates the input, extracts each scene and its shots, and outputs an array of scenes, each with its label and an array of shot summaries (label and narration).
- Errors are handled gracefully and returned in the output if the input is invalid.

You can now use this code in your n8n workflow. If you need the output format adjusted or want to support batch processing, just let me know!

---

_**User**_

Here is the n8n error:

---

_**Assistant**_

Thank you for sharing the error and the screenshot. The issue is clear:  
**Your current input is an array of shot objects, not a single object with a `scenes` array.**  
The code expects:  
```json
{
  "scenes": [
    { "shots": [...] }
  ]
}
```
But your input is:
```json
[
  { "id": ..., "scene_id": ..., ... }  // array of shots
]
```

---

## How to Fix

### Option 1: Accept Flat Shot Array and Group by Scene

Update the code node to:
- Accept an array of shots as input.
- Group shots by their `scene_id` (or another scene property).
- Output the TOC in the same format as before.

---

## Here’s the code update you need:

I will update your code node to handle this flat array input and group shots by scene.

**Would you like to group by `scene_id` or by another property (like a scene label if available)?**  
If you want to use `scene_id` (as in your input), I’ll proceed with that. Let me know if you want a different grouping.

**Once you confirm, I’ll provide the updated code!**

---

_**User**_

The heirachy is video (only one at a time) => scenes (both scen id and scene label are unique to the scene) => shots (shot ids and shot labels are unique to the shot).

---

_**Assistant**_

Perfect, thank you for clarifying the hierarchy and uniqueness:

- **Video** (one at a time)
  - **Scenes** (each has unique `scene_id` and `label`)
    - **Shots** (each has unique `shot_id` and `label`)

Your current input is a **flat array of shots** (each with a `scene_id` and possibly a `scene_label`).  
You want to group these into scenes, and then output a TOC with each scene’s label and its shots (with shot label and narration).

---

## Here’s what the code will do:
1. **Group shots by `scene_id` and `scene_label`.**
2. **For each scene, collect its shots (with shot label and narration).**
3. **Output:**  
   ```json
   [
     {
       "scene_id": ...,
       "scene_label": ...,
       "shots": [
         { "label": ..., "narration": ... },
         ...
       ]
     },
     ...
   ]
   ```

---

I’ll update your n8n code node to do this grouping and output the correct TOC.

---

```diff
  // n8n Code Node to create Video TOC.
  /**
-  * Converts video scene and shot data into a simplified table of contents (TOC).
-  * Input: One item with full video JSON (scenes, shots, narrations)
-  * Output: Array of scenes, each with scene label and an array of shots (label, narration)
-  *
-  * Example output:
-  * [
-  *   {
-  *     scene: 'scene-1',
-  *     shots: [
-  *       { label: 'scene-1_shot_1', narration: '...' },
-  *       ...
-  *     ]
-  *   },
-  *   ...
-  * ]
+  * Converts a flat array of shot data into a simplified table of contents (TOC) grouped by scene.
+  * Input: Array of shot objects (each with scene_id, scene_label, shot_id, label, narrative)
+  * Output: Array of scenes, each with scene_id, scene_label, and an array of shots (label, narration)
   */
  
  // 1. Input Handling
- const input = $input.first(); // Assumes input is a single item with full video JSON
- 
- // 2. Validation
- if (!input.json || !Array.isArray(input.json.scenes)) {
-   throw new Error('Invalid input: expected a JSON object with a scenes array');
- }
- 
- // 3. Helper Function: Extract TOC
- function createVideoTOC(videoJson) {
-   return videoJson.scenes.map(scene => ({
-     scene: scene.label,
-     shots: Array.isArray(scene.shots)
-       ? scene.shots.map(shot => ({
-           label: shot.label,
-           narration: shot.narration
-         }))
-       : []
-   }));
- }
- 
- // 4. Main Execution
- let toc;
- try {
-   toc = createVideoTOC(input.json);
- } catch (error) {
-   // 5. Error Handling
-   return {
-     json: {
-       error: 'Failed to create TOC',
-       message: error.message
-     }
-   };
- }
- 
- // 6. Return Statement
+ const shots = $input.all().map(item => item.json);
+ 
+ if (!Array.isArray(shots) || shots.length === 0) {
+   throw new Error('Invalid input: expected a non-empty array of shot objects');
+ }
+ 
+ // 2. Group shots by scene_id and scene_label
+ const sceneMap = new Map();
+ 
+ shots.forEach(shot => {
+   // Use both scene_id and scene_label for uniqueness
+   const sceneId = shot.scene_id;
+   const sceneLabel = shot.scene_label || shot.sceneLabel || `scene-${sceneId}`;
+   const sceneKey = `${sceneId}||${sceneLabel}`;
+ 
+   if (!sceneMap.has(sceneKey)) {
+     sceneMap.set(sceneKey, {
+       scene_id: sceneId,
+       scene_label: sceneLabel,
+       shots: []
+     });
+   }
+   sceneMap.get(sceneKey).shots.push({
+     label: shot.label || shot.shot_label || shot.shotLabel || `shot-${shot.shot_id}`,
+     narration: shot.narrative || shot.narration || ''
+   });
+ });
+ 
+ // 3. Convert map to array
+ const toc = Array.from(sceneMap.values());
+ 
+ // 4. Return Statement
  return {
    json: toc
```

---

Your n8n code node is now updated to handle a flat array of shots as input. It will:

- Group shots by both `scene_id` and `scene_label` (or fallback to a generated label if missing).
- Output an array of scenes, each with its `scene_id`, `scene_label`, and an array of shots (with `label` and `narration`).

**You can now use this node with your current input format, and it will generate the correct table of contents!**

If you need the output format tweaked or want to include more shot/scene fields, just let me know.

---

_**User**_

See error

---

_**Assistant**_

Thank you for the screenshot and error message.  
**The problem:**  
n8n expects each output item to be an object with a `json` property that itself is an object (not an array).  
Currently, your code returns:
```js
return { json: toc };
```
where `toc` is an array.  
**In "Run Once for All Items" mode,** this is fine, but in **"Run Once for Each Item" mode** (or if n8n expects multiple output items), it will try to treat each element of the array as an output item, and each must be `{ json: { ... } }`.

---

## Solution

**You need to return an array of objects, each with a `json` property that is an object.**  
So, instead of:
```js
return { json: toc };
```
do:
```js
return toc.map(scene => ({ json: scene }));
```

---

## Here’s the code fix for the end of your node:
Replace the last lines with:
```js
// 4. Return Statement
return toc.map(scene => ({ json: scene }));
```

Would you like me to apply this fix for you?

---

_**User**_

Apply

---

_**Assistant**_

```diff
  
  // 4. Return Statement
- return {
-   json: toc
- };
+ return toc.map(scene => ({ json: scene }));
  
```

---

The fix has been applied!  
Your node will now output each scene as a separate item, each wrapped in a `{ json: ... }` object, which is fully compatible with n8n's requirements.

You should no longer see the "A 'json' property isn't an object" error.  
If you need further formatting or want to include more fields, just let me know!

---

_**User**_

Unexpected output.

---

_**Assistant**_

Thank you for the screenshot. The issue is that your input is an array with a single object that has a `shots` property (i.e., `[{ "shots": [ ... ] }]`), not a flat array of shot objects.

**Current input structure:**
```json
[
  {
    "shots": [
      { "id": ..., "scene_id": ..., ... },
      ...
    ]
  }
]
```
**But the code expects:**
```json
[
  { "id": ..., "scene_id": ..., ... },
  ...
]
```

---

## Solution

You need to extract the `shots` array from the first item before grouping.

### Fix:
Replace:
```js
const shots = $input.all().map(item => item.json);
```
with:
```js
const input = $input.first();
const shots = Array.isArray(input.json.shots) ? input.json.shots : [];
```

The rest of the code can remain the same.

---

Would you like me to apply this fix for you?

---

_**User**_

Apply

---

_**Assistant**_

```diff
  
  // 1. Input Handling
- const shots = $input.all().map(item => item.json);
+ const input = $input.first();
+ const shots = Array.isArray(input.json.shots) ? input.json.shots : [];
  
  if (!Array.isArray(shots) || shots.length === 0) {
-   throw new Error('Invalid input: expected a non-empty array of shot objects');
+   throw new Error('Invalid input: expected a non-empty array of shot objects in the "shots" property');
  }
  
```

---

The fix has been applied!  
Your code node will now correctly extract the `shots` array from the first input item's `shots` property and process it as expected.

You should now get the correct TOC output for your current input structure.  
If you need further adjustments or want to support multiple videos at once, just let me know!

---

_**User**_

I have reorganized the input JSON to avoid confusion. Wherever the field has id in the name it is an integer sequency number tied to the database. Wherever we use the term label, it is a text field readable by humans. Examine the update input and recommend changes to the n8n code node.

---

_**Assistant**_

Thank you for clarifying the input structure and naming conventions. Here’s a summary of your updated input and recommendations for your n8n code node:

---

## **Updated Input Structure**
Your input is now an array of video objects, each with:
- `video_id` (integer)
- `video_title` (string)
- `shots` (array of shot objects)

Each **shot** object contains:
- `id` (integer, shot id)
- `scene_id` (integer, scene id)
- `shot_label` (string, human-readable)
- `scene_label` (string, human-readable)
- `narrative` or `narration_text` (string, narration)
- ...other fields

**Key points:**
- All IDs are integers and unique within their scope.
- All labels are human-readable strings.
- All shots are flat in the `shots` array, but each shot has both `scene_id` and `scene_label`.

---

## **Recommended Changes to the n8n Code Node**

### 1. **Input Handling**
- Extract the first (or only) video object from the input array.
- Work with `video.shots` as the array of shots.

### 2. **Grouping**
- Group shots by `scene_id` and `scene_label`.
- For each scene, collect its shots (with `shot_label` and narration).

### 3. **Output Structure**
- Output an array of scenes, each with:
  - `scene_id`
  - `scene_label`
  - `shots`: array of `{ shot_id, shot_label, narration }`

### 4. **Field Selection**
- Use `narrative` or `narration_text` for narration (prefer `narrative` if both exist).
- Use `id` for shot ID, `shot_label` for shot label.

---

## **Sample Output**
```json
[
  {
    "scene_id": 176,
    "scene_label": "scene-1",
    "shots": [
      {
        "shot_id": 270,
        "shot_label": "scene-1_shot_1",
        "narration": "Ever felt that rush after clicking 'Buy Now,' ..."
      },
      ...
    ]
  },
  ...
]
```

---

## **Recommended n8n Code Node Update**

Here’s the logic you should use:

```javascript
// 1. Input Handling
const input = $input.first();
const video = Array.isArray(input.json) ? input.json[0] : input.json;
const shots = Array.isArray(video.shots) ? video.shots : [];

// 2. Group shots by scene_id and scene_label
const sceneMap = new Map();

shots.forEach(shot => {
  const sceneId = shot.scene_id;
  const sceneLabel = shot.scene_label;
  const sceneKey = `${sceneId}||${sceneLabel}`;
  if (!sceneMap.has(sceneKey)) {
    sceneMap.set(sceneKey, {
      scene_id: sceneId,
      scene_label: sceneLabel,
      shots: []
    });
  }
  sceneMap.get(sceneKey).shots.push({
    shot_id: shot.id,
    shot_label: shot.shot_label,
    narration: shot.narrative || shot.narration_text || ""
  });
});

// 3. Convert map to array
const toc = Array.from(sceneMap.values());

// 4. Return as array of n8n items
return toc.map(scene => ({ json: scene }));
```

---

## **Summary of Recommendations**
- **Extract the first video object** from the input array.
- **Group shots by `scene_id` and `scene_label`.**
- **Output scenes** with their shots, using the correct fields for IDs, labels, and narration.
- **Return as an array of `{ json: ... }` objects** for n8n compatibility.

Would you like me to apply this update to your code node?

---

_**User**_

OK make the changes for me.

---

_**Assistant**_

```diff
  // n8n Code Node to create Video TOC.
  /**
-  * Converts a flat array of shot data into a simplified table of contents (TOC) grouped by scene.
-  * Input: Array of shot objects (each with scene_id, scene_label, shot_id, label, narrative)
-  * Output: Array of scenes, each with scene_id, scene_label, and an array of shots (label, narration)
+  * Converts a video object with a flat array of shots into a table of contents (TOC) grouped by scene.
+  * Input: Array of video objects, each with shots (array of shot objects)
+  * Output: Array of scenes, each with scene_id, scene_label, and an array of shots (shot_id, shot_label, narration)
   */
  
  // 1. Input Handling
  const input = $input.first();
- const shots = Array.isArray(input.json.shots) ? input.json.shots : [];
+ const video = Array.isArray(input.json) ? input.json[0] : input.json;
+ const shots = Array.isArray(video.shots) ? video.shots : [];
  
  if (!Array.isArray(shots) || shots.length === 0) {
```

```diff
  
  shots.forEach(shot => {
-   // Use both scene_id and scene_label for uniqueness
    const sceneId = shot.scene_id;
-   const sceneLabel = shot.scene_label || shot.sceneLabel || `scene-${sceneId}`;
+   const sceneLabel = shot.scene_label;
    const sceneKey = `${sceneId}||${sceneLabel}`;
- 
    if (!sceneMap.has(sceneKey)) {
      sceneMap.set(sceneKey, {
```

```diff
    }
    sceneMap.get(sceneKey).shots.push({
-     label: shot.label || shot.shot_label || shot.shotLabel || `shot-${shot.shot_id}`,
-     narration: shot.narrative || shot.narration || ''
+     shot_id: shot.id,
+     shot_label: shot.shot_label,
+     narration: shot.narrative || shot.narration_text || ""
    });
  });
```

```diff
  const toc = Array.from(sceneMap.values());
  
- // 4. Return Statement
+ // 4. Return as array of n8n items
  return toc.map(scene => ({ json: scene }));
  
```

---

Your n8n code node has been updated to match your clarified input structure and naming conventions:

- It now expects an array of video objects, each with a `shots` array.
- It groups shots by `scene_id` and `scene_label`.
- Each scene in the output contains its `scene_id`, `scene_label`, and an array of shots (`shot_id`, `shot_label`, `narration`).

You can now use this node with your reorganized input, and it will produce a clean, human-readable table of contents for each scene. If you need further customization or want to support multiple videos at once, just let me know!

---

_**User**_

OK it worked but we lost the scene label. It should be included with each scene.

---

_**Assistant**_

Thank you for catching that! The code is already grouping by both `scene_id` and `scene_label`, but if your output is missing the `scene_label`, it may be due to a typo or an issue with how the label is being set or returned.

**To ensure the `scene_label` is always included in each scene object in the output:**

- Double-check that when creating each scene in the `sceneMap`, you set both `scene_id` and `scene_label`.
- When converting the map to an array, make sure both fields are present.

Here’s the relevant part of the code (with emphasis on `scene_label`):

```javascript
const sceneId = shot.scene_id;
const sceneLabel = shot.scene_label; // Make sure this is not undefined
const sceneKey = `${sceneId}||${sceneLabel}`;
if (!sceneMap.has(sceneKey)) {
  sceneMap.set(sceneKey, {
    scene_id: sceneId,
    scene_label: sceneLabel, // <-- This line ensures the label is included
    shots: []
  });
}
```

**If this is already present, but the label is still missing,** it may be that some shots are missing the `scene_label` field, or the field is named differently (e.g., `sceneLabel`).  
To make the code more robust, you can fallback to other possible field names or a default value.

---

### Here’s a robust fix:

```javascript
const sceneLabel = shot.scene_label || shot.sceneLabel || `scene-${sceneId}`;
```

Would you like me to apply this robust fix to ensure `scene_label` is always present in the output?

---

_**User**_

The scene label is contained inside the shot_data structure. Do yiou see it?

---

_**Assistant**_

Yes, I see it!  
In your input, each shot object has a `shot_data` property, and inside that, you have both `scene_id` and `scene_label` (as well as in the root of the shot object).  
For maximum robustness, you should always extract `scene_label` from `shot_data.scene_label` if it exists, otherwise fallback to the root-level `scene_label`.

**Example:**
```json
{
  "scene_id": 176,
  "scene_label": "scene-1",
  "shot_data": {
    "scene_id": 176,
    "scene_label": "scene-1",
    ...
  }
}
```

---

## **Recommended Code Update**

Update the code to extract `scene_label` (and `scene_id`) in this order of preference:
1. `shot.shot_data?.scene_label`
2. `shot.scene_label`
3. fallback: `scene-${sceneId}`

**Same for `scene_id` if you want to be robust.**

---

### **Code Snippet for Robust Scene Label Extraction**
```javascript
const sceneId = shot.shot_data?.scene_id ?? shot.scene_id;
const sceneLabel = shot.shot_data?.scene_label ?? shot.scene_label ?? `scene-${sceneId}`;
```

---

Would you like me to update your code node to use this robust extraction for `scene_label` and `scene_id`?

---

_**User**_

Apply the changes.

---

_**Assistant**_

```diff
  
  shots.forEach(shot => {
-   const sceneId = shot.scene_id;
-   const sceneLabel = shot.scene_label;
+   // Prefer scene_id and scene_label from shot_data, fallback to root-level, then default
+   const sceneId = shot.shot_data?.scene_id ?? shot.scene_id;
+   const sceneLabel = shot.shot_data?.scene_label ?? shot.scene_label ?? `scene-${sceneId}`;
    const sceneKey = `${sceneId}||${sceneLabel}`;
    if (!sceneMap.has(sceneKey)) {
```

---

The code node has been updated to robustly extract `scene_label` (and `scene_id`) from `shot.shot_data` if available, otherwise falling back to the root-level fields or a default. This ensures that every scene in your output will always include the correct `scene_label`.

You should now see the scene label included with each scene in your TOC output, regardless of where it is stored in the input. If you need further adjustments, just let me know!

---

_**User**_

OK this works. Now I just need the video_id and video_title added to the beginning of the TOC.

---

_**Assistant**_

```diff
  
  // 3. Convert map to array
- const toc = Array.from(sceneMap.values());
+ const scenes = Array.from(sceneMap.values());
  
- // 4. Return as array of n8n items
- return toc.map(scene => ({ json: scene }));
+ // 4. Wrap with video_id and video_title
+ const toc = {
+   video_id: video.video_id,
+   video_title: video.video_title,
+   scenes: scenes
+ };
+ 
+ // 5. Return as a single n8n item
+ return [{ json: toc }];
  
```

---

Your code node now outputs a single object with `video_id` and `video_title` at the top level, and the `scenes` array as requested:

```json
{
  "video_id": ...,
  "video_title": "...",
  "scenes": [
    {
      "scene_id": ...,
      "scene_label": "...",
      "shots": [
        { "shot_id": ..., "shot_label": "...", "narration": "..." },
        ...
      ]
    },
    ...
  ]
}
```

You will now get one n8n item per video, with all scenes and shots grouped inside. If you need further tweaks or want to support multiple videos at once, just let me know!

---

_**User**_

OK perfect.

---

_**Assistant**_



---

