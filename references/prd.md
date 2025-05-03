# 📝 Product Requirements Document (PRD)

> For stack and architecture decisions, see [tech-stack.md](./tech-stack.md). For project phases and implementation checklist, see [task-list.md](./task-list.md).

---

## See Also

- [Tech Stack & Architecture](./tech-stack.md)
- [Project Tasklist](./task-list.md)
- [User Flow Diagrams](./user-flow-diagrams.md)
- [RTU Image Review App.jpg](./RTU%20Image%20Review%20App.jpg)
- [UI/UX Guidelines](./ui-ux-guidelines.md)
- [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md)

---

## 📌 Project Title: RTU Shot Control Panel

---

## 1. 🎯 Purpose

The RTU Shot Control Panel is a specialized application designed to streamline the video production workflow for Retail Therapy Unplugged (RTU). It focuses on managing AI-generated images that serve as starting points for B-roll video generation. The app dramatically reduces video production time from weeks to under a day by integrating image selection, refinement, and video generation into a single coherent interface, eliminating the need to manually coordinate multiple tools like ChatGPT, Midjourney, Kling, Airtable, Adobe Premiere, and Adobe After Effects.

---

## 2. 👥 Target Users

- **Video Editors** - Primary users who select and refine images for B-roll generation
- **Marketing Team** - Users who review and approve visual content for marketing videos and course materials
- **Content Creators** - May use the system to generate visuals for educational content

---

## 3. 🧭 Goals & Success Metrics

### ✅ Primary Goals

- Reduce video production time from 6 weeks to under 1 day for a 5-minute video
- Create a unified interface for managing AI-generated images and videos
- Integrate with N8N workflows for automated image and video generation
- Enable natural language interaction with AI tools without requiring platform-specific prompt engineering
- Streamline the selection and refinement process for B-roll starting images

### 📊 Success Metrics

- Production time reduction: 6 weeks → <1 day for a 5-minute video
- User satisfaction with interface and workflow
- Reduction in context-switching between different tools
- Quality of final B-roll output compared to previous methods

---

## 4. 🔄 User Flows

### Image Selection Workflow

1. User views scrollable grid of AI-generated images categorized as Standard, Enhanced, and Viral
2. User pins (selects) promising images for further refinement
3. User can trigger "Roll the Dice" to archive unpinned images, keep selections, and generate new images using different prompt structures via backend agent
4. User can use the Image Chat to refine selected images by describing desired changes in natural language
5. N8N agent translates natural language requests into optimized Midjourney prompts
6. New refined images are generated and displayed for review
7. User selects final image for video generation

### Video Generation Workflow

1. User selects a final image to use as starting point for video generation
2. Image appears in the Video Gen Playback area
3. User describes desired video characteristics via Video Gen Convo in natural language
4. N8N agent translates requests into optimized prompts for video generators (Kling, Runway, etc.)
5. Generated video appears in playback area for review (asynchronously)
6. User can request refinements via natural language until satisfied with result

---

## 5. 🧱 Core Features

| Feature                        | Description                                                                 | Priority |
|-------------------------------|-----------------------------------------------------------------------------|----------|
| 📋 RTU Shot Control Panel UI | Main interface with image grid, chat areas, and video playback | High |
| 🖼️ Image Grid Display | Scrollable grid of Midjourney-generated images categorized as Standard, Enhanced, and Viral | High |
| 📌 Image Selection | Ability to pin/select images for further refinement | High |
| 🎲 "Roll the Dice" | Archive unpinned images, keep selections, and generate new images with different prompt structures | High |
| 💬 Image Chat Convo | Natural language interface to refine images without technical prompts | High |
| 🎬 Video Gen Convo | Natural language interface to create and refine videos | Medium |
| 📺 Video Gen Playback | Area to display and review generated videos | Medium |
| 🔄 N8N Integration | Two-way integration with N8N workflows for image and video generation via MCP | Medium |
| 🔍 Metadata Display | Show Midjourney prompts and other relevant metadata | High |
| 🔢 Reference Numbers | Unique, unchangeable reference numbers for all images (prefix + sequence) | High |
| ⏳ Async Generation | Background processing of image and video generation with placeholders | High |
| 📱 Responsive Design | Mobile-friendly interface for on-the-go reviews | Low |

---

## 6. 🔍 Functional Requirements

### UI Components

- **Header Area**: Video Name, Scene Number, Shot Number, A-Roll/B-Roll toggle
- **Shot Narrative**: Text display for the narrator's spoken words
- **Image Options**: Scrollable grid display with three columns (Standard, Enhanced, Viral)
- **Image Chat Convo**: Chat interface for image refinement with N8N agent
- **Video Gen Convo**: Chat interface for video generation with N8N agent
- **Video Gen Playback**: Display area for generated videos
- **Roll the Dice Button**: Function to archive unpinned images and generate new ones with different prompt structures

### Data Model

```sql
-- Postgres Schema

-- The 'projects' table has been deferred. See the Deferred Requirements section.

CREATE TABLE videos (
  id SERIAL PRIMARY KEY,
  -- project_id INTEGER REFERENCES projects(id), -- deferred
  title TEXT NOT NULL,
  version NUMERIC(3,1) DEFAULT 1.0, -- Numeric type with one decimal place (e.g., 1.0, 1.5, 2.0)
  script TEXT, -- full video script
  status TEXT CHECK (status IN ('not_started', 'in_progress', 'completed', 'archived')),
  description TEXT,
  toc JSONB, -- Table of contents for the video
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE scenes (
  id SERIAL PRIMARY KEY,
  video_id INTEGER REFERENCES videos(id),
  scene_number INTEGER NOT NULL,
  scene_label TEXT, -- Short label for the scene (for UI or quick reference)
  narrative TEXT,
  scene_word_count INTEGER,
  scene_estimated_duration NUMERIC(6,1), -- seconds with one decimal place
  scene_data JSON
);

CREATE TABLE shots (
  id SERIAL PRIMARY KEY,
  scene_id INTEGER REFERENCES scenes(id),
  video_id INTEGER REFERENCES videos(id), -- Redundant foreign key for easier queries
  shot_number INTEGER NOT NULL,
  is_broll BOOLEAN NOT NULL, -- TRUE for B-Roll, FALSE for A-Roll
  narrative TEXT, -- Narrator's spoken words
  word_count INTEGER,
  estimated_duration NUMERIC(6,1), -- seconds with one decimal place
  shot_data JSONB
);

-- New table for visual narratives
CREATE TABLE visual_narratives (
  id SERIAL PRIMARY KEY,
  shot_id INTEGER REFERENCES shots(id),
  vn_data JSONB, -- Flexible field for additional narrative data
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX idx_visual_narratives_shot_id ON visual_narratives(shot_id);
-- Optionally, add a unique constraint if needed:
-- ALTER TABLE visual_narratives ADD CONSTRAINT unique_shot_type UNIQUE (shot_id, narrative_type);

-- The visual_narratives table stores narrative descriptions and metadata for each shot, supporting multiple narrative types (e.g., visual, audio, context). It is linked to the shots table via shot_id and allows for flexible storage of additional data in the vn_data JSONB field.

CREATE TABLE generated_images (
  id SERIAL PRIMARY KEY,
  shot_id INTEGER REFERENCES shots(id),
  url TEXT,
  thumbnail_url TEXT,
  prompt TEXT,
  concept_type TEXT CHECK (concept_type IN ('standard', 'enhanced', 'viral')),
  variation_type TEXT, -- e.g., 'core', 'lighting', 'environment', 'mood', etc.
  reference_number TEXT, -- S/E/V prefix + sequence number
  is_pinned BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  generated_by TEXT, -- e.g., "midjourney"
  is_generating BOOLEAN DEFAULT FALSE -- Flag for async generation
);

CREATE TABLE generated_videos (
  id SERIAL PRIMARY KEY,
  shot_id INTEGER REFERENCES shots(id),
  base_image_id INTEGER REFERENCES generated_images(id),
  url TEXT NOT NULL,
  positive_prompt TEXT,
  negative_prompt TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  generated_by TEXT, -- e.g., "kling", "runway"
  is_generating BOOLEAN DEFAULT FALSE -- Flag for async generation
);

CREATE TABLE conversations (
  id SERIAL PRIMARY KEY,
  type TEXT CHECK (type IN ('image_chat', 'video_chat', 'ideation_chat')),
  shot_id INTEGER REFERENCES shots(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  conversation_id INTEGER REFERENCES conversations(id),
  chat_msg TEXT NOT NULL, -- The message content
  sender TEXT NOT NULL, -- Indicates who sent the message (e.g., user ID, name, or 'system'/'ai' for automated responses)
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_user_message BOOLEAN DEFAULT TRUE, -- TRUE if sent by a user, FALSE if sent by system/AI
  form_data JSONB -- Stores form schemas (for prompts) or form responses (for user submissions)
);

-- Indexes for common queries
CREATE INDEX idx_videos_video_id ON videos(video_id);
CREATE INDEX idx_scenes_video_id ON scenes(video_id);
CREATE INDEX idx_shots_scene_id ON shots(scene_id);
CREATE INDEX idx_generated_images_shot_id ON generated_images(shot_id);
CREATE INDEX idx_generated_videos_shot_id ON generated_videos(shot_id);
CREATE INDEX idx_conversations_shot_id ON conversations(shot_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);

CREATE TABLE agent_logging (
  id BIGINT NOT NULL PRIMARY KEY,
  agent_name TEXT NOT NULL, -- Name of the AI agent (e.g., 'image_agent', 'video_agent')
  event_data JSONB, -- Detailed log of the agent's thought process and actions
  shot_id INTEGER, -- Related shot ID (if applicable)
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW() -- When the log entry was created
);

CREATE INDEX idx_agent_logging_shot_id ON agent_logging(shot_id);
CREATE INDEX idx_agent_logging_created_at ON agent_logging(created_at);

CREATE TABLE shot_ideas (
  id SERIAL PRIMARY KEY,
  shot_id INTEGER,
  creative_direction TEXT NOT NULL,
  idea_data JSONB DEFAULT '{}'::jsonb,
  version_number INTEGER,
  created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  vn_data JSONB -- Visual narrative data for the shot idea
);
```

### UI to Data Model Mapping

#### Header Area UI Components

- **Video Selector**: Maps to `videos` table (displays `title` field for each video)
- **Scene Selector**: Maps to `scenes` table (filtered by selected `video_id`)
- **Shot Selector**: Maps to `shots` table (filtered by selected `scene_id`)
- **A/B-Roll Toggle**: Updates `is_broll` field in selected shot record
- **Shot Narrative Display**: Shows `narrative` field from selected shot record

#### Image Grid UI Components

- **Standard Column**: Maps to `generated_images` table (filtered by `shot_id` and `concept_type = 'standard'`)
- **Enhanced Column**: Maps to `generated_images` table (filtered by `shot_id` and `concept_type = 'enhanced'`)
- **Viral Column**: Maps to `generated_images` table (filtered by `shot_id` and `concept_type = 'viral'`)
- **Reference Numbers**: Shows `reference_number` field in generated image records
- **Pin Icons**: Toggle `is_pinned` field in generated image records
- **Roll the Dice Button**: Triggers update to set `is_archived = true` for unpinned generated images
- **Prompts Display**: Shows `prompt` field under each generated image

#### Chat & Video Areas UI Components

- **Image Chat Convo**: Maps to `conversations` table (filtered by `type = 'image_chat'` and `shot_id`)
- **Image Chat Messages**: Maps to `messages` table (filtered by `conversation_id`)
- **Video Gen Convo**: Maps to `conversations` table (filtered by `type = 'video_chat'` and `shot_id`)
- **Video Gen Messages**: Maps to `messages` table (filtered by `conversation_id`)
- **Video Playback Area**: Maps to `generated_videos` table (filtered by `shot_id`)
- **Dynamic Forms**: If a message has a `form_data` field with a schema, the UI renders a form for the user to fill out. If a message has a `form_data` field with a response, it displays the user's submitted data.

#### Storage Integration

- **Image Files**: `url` fields in database tables point to external storage locations
- **Video Files**: `url` fields in database tables point to external storage locations
- **Thumbnails**: `thumbnailUrl` fields generated by Vercel serverless functions for preview images

#### Authentication Integration

- **User Authentication**: Google login via Supabase Auth
- **User Access**: All users have the same access level (no need for complex permissions)
- **User Activity**: Can be tracked in user-specific tables if needed

### Chat Functionality

- **Image Chat**:
  - Interpret natural language requests for image refinement
  - N8N agent translates into optimized Midjourney prompts
  - Track conversation history for context
  - Trigger N8N workflows for image generation via MCP
  - Allow selection, archiving, and refinement of images
  - Providing feedback on an image automatically pins it
  - Support for dynamic form generation based on agent responses (using `form_data` in messages)

- **Video Chat**:
  - Interpret natural language requests for video generation/refinement
  - N8N agent translates into optimized Kling/Runway prompts
  - Track conversation history for context
  - Trigger video generation via MCP
  - Allow refinement of generated videos
  - Support for dynamic form generation based on agent responses (using `form_data` in messages)

### Dynamic Form Generation

- **Form Generation**:
  - React Hook Form with Zod integration for dynamic form handling
  - Support for rendering JSON-defined forms returned by n8n agent (stored in `form_data` of messages)
  - Type-safe validation using Zod schemas generated from agent responses
  - Real-time form validation with immediate feedback
  - Support for various form field types (text, select, checkbox, radio, etc.)
  - Conditional field rendering based on previous input values (see [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#conditional-fields) for details)
  - Submission of form data back to n8n agent for processing (as a new message with `form_data.response`)
  - Tailwind CSS integration for form styling (see [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#tailwind-css-integration))

- **Supported Field Types**:
  - string (text input, minLength, maxLength, pattern)
  - number (numeric input, minimum, maximum, multipleOf)
  - boolean (checkbox, default)
  - array (multi-select, items, minItems, maxItems)
  - object (nested form fields, properties)
  - enum (dropdown/radio selection, enum, enumNames)
  - See [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#supported-field-types) for full details and examples.

- **Agent Interaction Flow**:
  1. User sends a message to the agent via chat interface
  2. Agent responds with text and may include a JSON schema for form generation in the `form_data` field
  3. Application dynamically renders a form using React Hook Form based on the JSON schema
  4. User completes the form with required information
  5. Form data is validated using Zod before submission
  6. Validated form data is sent back to the agent for processing as a new message with `form_data.response`
  7. Agent processes form data and provides next steps or results
  - For JSON schema structure and real-world examples, see [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#json-structure-for-forms)

- **Form Schema Structure**:
  - JSON structure defines form fields, types, validation rules, and dependencies
  - Support for field grouping and organization
  - Ability to define conditional logic for field visibility
  - Custom styling capabilities through Tailwind CSS class integration
  - See [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#json-structure-for-forms) for schema and UI examples

### Agent Communication Model

- **Architecture**:
  - Using Supabase Realtime subscriptions for n8n agent communication
  - Database-mediated communication pattern instead of direct webhooks
  - Persistent storage of all agent interactions for history and reliability
  - Decoupled systems allowing for asynchronous processing
  - See [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#communication-architecture) for implementation details

- **Data Flow**:
  1. User submits a message or form → App inserts a record into the `messages` table (with optional `form_data` for form responses)
  2. N8N agent polls for new messages or uses Supabase webhooks to detect new entries in the `messages` table
  3. N8N agent processes the message and, if needed, inserts a new message with a form schema in the `form_data` field (as an AI/system message)
  4. App receives the new message via Supabase Realtime subscription
  5. App updates UI and conversation history based on the new message, rendering a form if a schema is present in `form_data`

- **Benefits of This Approach**:
  - Built-in persistence of all agent interactions
  - Support for offline processing (n8n can work when user is offline)
  - Automatic history tracking through database records
  - Simplified state management with all chat and form data in a single table
  - Leverages existing Supabase infrastructure
  - Enhanced reliability with database as durable message queue

### Integration Requirements

- **MCP (Message Communication Protocol)**:
  - Standard protocol for all system communications
  - Used for integration between UI, N8N, and AI services
  - Provides flexibility and expandability

- **N8N Workflow Integration**:
  - Trigger image generation workflows
  - Trigger video generation workflows
  - Receive and display generated content
  - Send refinement prompts
  - Update content metadata
  - See [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md#implementing-in-n8n) for workflow and code examples

- **AI Image Generation**:
  - Midjourney integration via N8N
  - Asynchronous generation with placeholder indicators
  - Store and display generated images with prompts and reference numbers

- **AI Video Generation**:
  - Kling/Runway integration via N8N
  - Generate videos from selected starting images
  - Asynchronous generation with placeholder indicators
  - Store and display generated videos

---

## 7. 🚧 Non-Functional Requirements

### Performance

- Image loading time < 1 second
- Chat response time < 2 seconds
- Video playback buffering < 3 seconds
- Support for scrollable grid with unlimited images

### Scalability

- Support for multiple concurrent users
- Handle multiple projects/videos simultaneously
- Efficient storage and retrieval of images and videos
- Background processing for all generation tasks

### Security

- Supabase Auth (Google login) for user access
- Secure API key management for AI services via Vercel environment variables
- No special data access controls needed (all users have same access)

### Usability

- Intuitive interface requiring minimal training
- Clear visual indicators for image status (pinned, archived, generating)
- Responsive design that works on desktop and tablet
- Clear feedback for system actions

---

## 8. 📅 Timeline & Milestones

### Detailed Development Schedule

| Phase                            | Milestone                         | Date       | Priority | Dependencies |
|----------------------------------|----------------------------------|------------|----------|--------------|
| **Phase 0: Design & Planning**   | PRD & Requirements Complete        | Week 1     | High     | None         |
|                                  | User Flow Diagrams Complete       | Week 1     | High     | PRD          |
|                                  | UI-to-Data Model Mapping          | Week 1     | High     | PRD          |
|                                  | Wireframes Approval               | Week 1     | High     | None         |
| **Phase 1: Project Setup**       | Supabase project creation         | Week 1     | High     | PRD          |
|                                  | Vercel project setup              | Week 1     | High     | PRD          |
|                                  | Repository setup                  | Week 1     | High     | None         |
| **Phase 2: Authentication**      | Supabase Auth implementation      | Week 1     | High     | Supabase setup |
|                                  | Google login UI                   | Week 1     | Medium   | Supabase Auth |
| **Phase 3: Database Setup**      | Postgres schema creation          | Week 1     | High     | Supabase setup |
|                                  | Real-time subscriptions setup     | Week 1     | High     | Postgres schema |
|                                  | Database access configuration     | Week 1     | Medium   | Postgres schema |
| **Phase 4: API & Serverless**    | Vercel serverless functions       | Week 2     | High     | Supabase setup |
|                                  | Image/video processing setup      | Week 2     | High     | Serverless functions |
| **Phase 5: Core UI**             | Header implementation             | Week 2     | High     | Postgres schema |
|                                  | Image Grid development            | Week 2     | High     | Postgres schema |
|                                  | Pinning functionality             | Week 2     | High     | Image Grid |
|                                  | "Roll the Dice" implementation    | Week 2     | High     | Pinning functionality |
|                                  | Chat UI components                | Week 2     | Medium   | Postgres schema |
|                                  | Video Playback UI                 | Week 2     | Medium   | Postgres schema |
| **Phase 6: AI Integration**      | N8N Integration - Basic           | Week 3     | Medium   | Core UI |
|                                  | Image Chat AI Integration         | Week 3     | Medium   | Chat UI |
|                                  | Video Generation Integration      | Week 3     | Low      | Video Playback UI |
|                                  | Vercel Serverless for AI          | Week 3     | Medium   | N8N Integration |
| **Phase 7: Final Testing**       | User Acceptance Testing           | Week 4     | High     | All features |
|                                  | Performance Optimization          | Week 4     | Medium   | All features |
|                                  | Bug Fixes                         | Week 4     | High     | UAT |
|                                  | Final Deployment                  | Week 4     | High     | Bug Fixes |

### Key Milestones Summary

| Delivery                         | Target Date | Status    |
|----------------------------------|-------------|-----------|
| Phase 0: Product Definition Complete | End of Week 1 | In Progress |
| Phase 1-3: Project Foundation      | End of Week 1 | Not Started |
| Phase 4-5: Core Functionality      | End of Week 2 | Not Started |
| Phase 6: AI Integration            | End of Week 3 | Not Started |
| Phase 7: Production-Ready Release  | End of Week 4 | Not Started |

---

## 9. 📎 Out of Scope (for now)

- Advanced user management (beyond basic authentication)
- Complex approval workflows with multiple stakeholders
- Public sharing of content
- Advanced video editing tools
- Detailed analytics dashboard
- Integration with project management tools
- Multi-language support
- Mobile application (focus on desktop/tablet web app)

---

## 10. 🤝 Stakeholders

| Role               | Name or Placeholder   | Responsibilities |
|--------------------|------------------------|------------------|
| Product Owner      | TBD                    | Overall requirements and vision |
| Frontend Developer | TBD                    | UI implementation |
| Backend Developer  | TBD                    | Supabase, Vercel, N8N integration |
| AI Integration     | TBD                    | GPT, Midjourney, and video AI integration |
| Video Editor       | TBD                    | Testing and feedback |
| Marketing          | TBD                    | Testing and feedback |

---

## 11. 🔗 Resources

- Figma Link: [To be provided by design team]
- GitHub Repo: [To be created during Phase 1]
- Supabase Console: [To be created during Phase 1]
- Supabase Studio: [To be set up during Phase 1]
- Vercel Dashboard: [To be set up during Phase 1]
- N8N Workflow: [To be configured during Phase 6]
- AI Service Keys: [To be securely stored in Vercel during Phase 1]

---

## 12. 🛠️ Technical Stack

| Component          | Technology               |
|--------------------|--------------------------|
| Frontend           | React / Next.js (Vercel) |
| Backend            | Supabase (Postgres, Auth, Realtime) |
| Database           | Supabase Postgres        |
| Authentication     | Supabase Auth (Google only) |
| Storage            | External/native storage for images/videos |
| Serverless Functions | Vercel                 |
| Real-time          | Supabase real-time subscriptions |
| Database Management| Supabase Studio          |
| Hosting            | Vercel                   |
| Integration Protocol | MCP (Message Communication Protocol) |
| Workflow Automation | N8N (via webhooks or MCP) |
| AI Chat Integration | OpenAI API or Claude API |
| Image Generation   | Midjourney via N8N       |
| Video Generation   | Kling/Runway via N8N     |
| Form Management    | React Hook Form with Zod |
| Testing            | Unit, integration, E2E (tools TBD) |
| CI/CD              | Vercel                   |
| N8N Agent JSON Form Integration | See [N8N Agent JSON Form Integration](./n8n-agent-json-form-integration.md) for implementation details |

### Data Model Notes

- All data will be stored in Supabase Postgres tables, with relationships managed via foreign keys.
- Example: `generated_images` table with `id` (primary key), `shot_id` (foreign key), etc.
- The 'projects' table and project-level organization are deferred. See Deferred Requirements.

### Real-time Features

- Real-time updates for image grid, chat, and video status will use Supabase real-time subscriptions.

### Storage

- Images and videos are stored in their native/external locations.
- Thumbnails and transformations are handled by Vercel serverless functions.

### Integrations

- Integrations with N8N, Midjourney, and other AI/video services will use Supabase Realtime for communication.
- N8N will interact with the application through database tables rather than direct HTTP endpoints.
- Dynamic form generation will use JSON schemas transmitted through Supabase database tables.

### Testing

- The project will include unit, integration, and end-to-end (E2E) testing. Specific tools will be selected later.

---

## 13. 🧪 Testing Strategy

- Component testing for UI elements
- Integration testing for N8N and AI service connections
- End-to-end testing of primary user flows
- Performance testing for image loading
- Asynchronous generation testing
- User acceptance testing with video editors

---

## 14. Deferred Requirements

### Project-level Organization

The concept of a 'projects' table and project-level organization is deferred for now. In the future, a 'projects' table could be introduced to allow grouping of videos, scenes, and shots under distinct projects. This would enable management of multiple video production efforts, campaigns, or clients within the same system. The table would store basic information such as project name, description, and timestamps, and other entities (videos, scenes, etc.) would reference the project for organizational purposes. For the current phase, all features and data are managed at the video level or below.

---

## ✅ Approval

- [ ] Product Owner: _______________________
- [ ] Technical Lead: _______________________
- [ ] Design Lead: _________________________
