# Supabase Data Definition

-- Table for storing video metadata
CREATE TABLE videos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Table for storing video segments (acts, sequences, scenes, shots, beats)
CREATE TABLE video_segments (
  id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  video_id integer REFERENCES videos(id) ON DELETE CASCADE,
  label text NOT NULL, -- e.g., 'act-1_seq-2_scene-3'
  type text NOT NULL CHECK (type IN ('act', 'sequence', 'scene', 'shot', 'beat')),
  title text, -- Only for act, sequence, scene
  description text NOT NULL,
  semantic_tags jsonb NOT NULL DEFAULT '[]',
  word_count integer NOT NULL,
  estimated_duration numeric NOT NULL, -- seconds
  narration_text text, -- Only for scene, shot, beat
  parent_id integer REFERENCES video_segments(id), -- parent segment id (int); NULL for root (video)
  original_text text, -- always store the original segment text
  created_at timestamptz DEFAULT now(),
  CONSTRAINT label_type_unique UNIQUE (label, type)
);

-- Index for fast lookup by video and type
CREATE INDEX idx_video_segments_video_type ON video_segments (video_id, type);

-- Optionally, you can add a foreign key constraint for part_of if you want strict referential integrity, but since it's a label reference, it's left as text for flexibility.

