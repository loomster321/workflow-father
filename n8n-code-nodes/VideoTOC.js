// n8n Code Node to create Video TOC.
/**
 * Converts a video object with a flat array of shots into a table of contents (TOC) grouped by scene.
 * Input: Array of video objects, each with shots (array of shot objects)
 * Output: Array of scenes, each with scene_id, scene_label, and an array of shots (shot_id, shot_label, narration)
 */

// 1. Input Handling
const input = $input.first();
const video = Array.isArray(input.json) ? input.json[0] : input.json;
const shots = Array.isArray(video.shots) ? video.shots : [];

if (!Array.isArray(shots) || shots.length === 0) {
  throw new Error('Invalid input: expected a non-empty array of shot objects in the "shots" property');
}

// 2. Group shots by scene_id and scene_label
const sceneMap = new Map();

shots.forEach(shot => {
  // Prefer scene_id and scene_label from shot_data, fallback to root-level, then default
  const sceneId = shot.shot_data?.scene_id ?? shot.scene_id;
  const sceneLabel = shot.shot_data?.scene_label ?? shot.scene_label ?? `scene-${sceneId}`;
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
const scenes = Array.from(sceneMap.values());

// 4. Wrap with video_id and video_title
const toc = {
  video_id: video.video_id,
  video_title: video.video_title,
  scenes: scenes
};

// 5. Return as a single n8n item
return [{ json: toc }];
