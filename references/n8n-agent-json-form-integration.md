# N8N Agent JSON Form Integration

This document provides guidance for configuring the n8n agent to generate JSON schemas that can be used with React Hook Form and Zod for dynamic form generation in the RTU Shot Control Panel.

## Overview

The RTU Shot Control Panel requires the ability to render dynamic forms based on JSON responses from the n8n agent. This allows the agent to collect structured information from the user through dynamically generated forms rather than through free-form chat alone.

## Communication Architecture

Instead of using direct webhooks for communication between the application and n8n, we'll use Supabase Realtime subscriptions with database tables as the communication medium. This provides several benefits:

- Built-in persistence of all communications
- Support for offline processing
- Automatic history tracking
- Simplified state management
- Leveraging existing Supabase infrastructure
- Enhanced reliability with database as durable message queue

### Data Flow

1. User submits a message or form → App inserts record into `agent_requests` table
2. N8N polls for new requests or uses Supabase webhooks to detect new entries
3. N8N processes the request and inserts result into `agent_responses` table
4. App receives response via Supabase Realtime subscription
5. App updates UI and conversation history based on response

### Database Tables

```sql
CREATE TABLE agent_requests (
  id SERIAL PRIMARY KEY,
  conversation_id INTEGER REFERENCES conversations(id),
  content TEXT NOT NULL,
  form_data JSONB,
  status TEXT CHECK (status IN ('pending', 'processing', 'completed', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE agent_responses (
  id SERIAL PRIMARY KEY,
  request_id INTEGER REFERENCES agent_requests(id),
  content TEXT,
  form_data JSONB,
  generated_content_refs JSONB, -- references to generated images, videos, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX idx_agent_requests_conversation_id ON agent_requests(conversation_id);
CREATE INDEX idx_agent_requests_status ON agent_requests(status);
CREATE INDEX idx_agent_responses_request_id ON agent_responses(request_id);
```

## JSON Response Structure

When the n8n agent needs to collect structured information from the user, it should insert a response into the `agent_responses` table with the following JSON structure in the `form_data` field:

```json
{
  "message": "I need some additional information to help you with this task.",
  "formData": {
    "schema": {
      "type": "object",
      "properties": {
        "fieldName1": {
          "type": "string",
          "title": "Field Label 1",
          "description": "Help text for this field",
          "minLength": 2,
          "maxLength": 50
        },
        "fieldName2": {
          "type": "number",
          "title": "Field Label 2",
          "minimum": 0,
          "maximum": 100
        },
        "fieldName3": {
          "type": "boolean",
          "title": "Field Label 3",
          "default": false
        },
        "fieldName4": {
          "type": "string",
          "title": "Field Label 4",
          "enum": ["option1", "option2", "option3"],
          "enumNames": ["Option 1", "Option 2", "Option 3"]
        }
      },
      "required": ["fieldName1", "fieldName2"]
    },
    "uiSchema": {
      "fieldName1": {
        "placeholder": "Enter text here",
        "className": "mt-1 block w-full rounded-md border-gray-300 shadow-sm"
      },
      "fieldName3": {
        "conditional": {
          "dependsOn": "fieldName2",
          "showWhen": "value > 50"
        }
      }
    },
    "defaultValues": {
      "fieldName1": "",
      "fieldName2": 0,
      "fieldName3": false,
      "fieldName4": "option1"
    }
  }
}
```

This structure includes:
- A chat `message` that will be displayed to the user
- A `formData` object containing:
  - `schema`: The formal definition of form fields and their validation rules
  - `uiSchema`: UI-specific configurations like placeholders and conditional rendering
  - `defaultValues`: Initial values for the form fields

## Supported Field Types

The following field types are supported:

| Type | Description | Additional Properties |
|------|-------------|----------------------|
| string | Text input | minLength, maxLength, pattern |
| number | Numeric input | minimum, maximum, multipleOf |
| boolean | Checkbox | default |
| array | Multi-select | items, minItems, maxItems |
| object | Nested form fields | properties |
| enum (string) | Dropdown/radio selection | enum, enumNames |

## Conditional Fields

To create conditional fields that appear based on other field values, use the `conditional` property in the `uiSchema`:

```json
"uiSchema": {
  "fieldName": {
    "conditional": {
      "dependsOn": "otherFieldName",
      "showWhen": "value === 'specificValue'"
    }
  }
}
```

The `showWhen` property contains a JavaScript expression (as a string) that will be evaluated to determine if the field should be displayed.

## Tailwind CSS Integration

The form fields will automatically use Tailwind CSS classes for styling. You can provide additional classes using the `className` property in the `uiSchema`:

```json
"uiSchema": {
  "fieldName": {
    "className": "mt-1 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
  }
}
```

## Implementing in n8n

### Configuring Supabase Database Access

1. Set up Supabase API credentials in n8n
2. Create a Supabase node in your workflow to connect to your database
3. Use the Supabase node to query for new requests and insert responses

### Using the Function Node with Supabase

```javascript
// Example Function node code to process a request and create a response
const supabase = $input.all()[0].json; // Assuming Supabase node is connected
const request = supabase.body;

// Process the request
const response = {
  request_id: request.id,
  content: "Please provide some additional details:",
  form_data: {
    schema: {
      type: "object",
      properties: {
        name: {
          type: "string",
          title: "Name",
          minLength: 2
        },
        age: {
          type: "number",
          title: "Age",
          minimum: 18
        }
      },
      required: ["name", "age"]
    },
    uiSchema: {
      name: {
        placeholder: "Enter your name"
      }
    },
    defaultValues: {
      name: "",
      age: 25
    }
  }
};

// Return the response to be inserted into agent_responses table
return [{
  json: response
}];
```

### Using the Code Node (for more complex logic)

```javascript
// Example Code node to poll for new requests
const Supabase = require('@supabase/supabase-js');

// Initialize Supabase client (stored in n8n credentials)
const supabaseUrl = $node.credentials.supabaseUrl;
const supabaseKey = $node.credentials.supabaseApiKey;
const supabase = Supabase.createClient(supabaseUrl, supabaseKey);

// Function to process requests
async function processRequests() {
  // Get pending requests
  const { data: pendingRequests, error } = await supabase
    .from('agent_requests')
    .select('*')
    .eq('status', 'pending')
    .order('created_at', { ascending: true })
    .limit(5);
  
  if (error) {
    throw new Error(`Error fetching pending requests: ${error.message}`);
  }
  
  // Process each request
  const responses = [];
  for (const request of pendingRequests) {
    // Update request status to processing
    await supabase
      .from('agent_requests')
      .update({ status: 'processing' })
      .eq('id', request.id);
    
    // Process request (example logic)
    const generateForm = (context) => {
      // ... existing form generation logic ...
    };
    
    // Generate response
    const formResponse = generateForm(request.content);
    
    // Insert response
    const { data: response, error: responseError } = await supabase
      .from('agent_responses')
      .insert([{
        request_id: request.id,
        content: formResponse.message,
        form_data: formResponse.formData
      }])
      .select();
    
    if (responseError) {
      console.error(`Error inserting response: ${responseError.message}`);
      continue;
    }
    
    // Update request status to completed
    await supabase
      .from('agent_requests')
      .update({ status: 'completed' })
      .eq('id', request.id);
    
    responses.push(response[0]);
  }
  
  return responses;
}

// Call the function
return processRequests()
  .then(responses => {
    return [{ json: { success: true, responses } }];
  })
  .catch(error => {
    return [{ json: { success: false, error: error.message } }];
  });
```

### Setting up a Trigger for New Requests

1. Use a Supabase trigger node or a Cron node to periodically check for new requests
2. Configure the trigger to detect new records in the `agent_requests` table
3. Connect the trigger to your processing workflow

## Processing Form Submissions

When the user submits a form, the frontend will add the form data to the `agent_requests` table:

```javascript
// Example n8n workflow to process form submission
const request = $input.all()[0].json;
const formData = request.form_data;

// Process the submitted data
let responseContent;
if (formData.name && formData.age) {
  responseContent = `Thank you, ${formData.name}! We've recorded that you are ${formData.age} years old.`;
} else {
  responseContent = "Please complete all required fields.";
}

// Insert response into agent_responses table
const response = {
  request_id: request.id,
  content: responseContent,
  form_data: null // No form needed in response
};

return [{ json: response }];
```

## Documentation References

For more information, consult these resources:

1. **React Hook Form**: 
   - [Main documentation](https://react-hook-form.com/docs)
   - [API reference](https://react-hook-form.com/api)

2. **Zod Documentation**:
   - [Official documentation](https://zod.dev/)

3. **n8n Documentation**:
   - [Supabase node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/)
   - [Function node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.function/)
   - [Code node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.code/)
   - [Webhook and Supabase integration](https://n8n.io/integrations/webhook/and/supabase/)

4. **Supabase Documentation**:
   - [JavaScript client](https://supabase.com/docs/reference/javascript/introduction)
   - [Realtime](https://supabase.com/docs/guides/realtime)

5. **Tailwind CSS**:
   - [Form styling](https://tailwindcss.com/docs/plugins#forms)

## Examples

### Simple Contact Form Example

```json
{
  "message": "Please fill out this contact form:",
  "formData": {
    "schema": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string",
          "title": "Full Name",
          "minLength": 2,
          "maxLength": 100
        },
        "email": {
          "type": "string",
          "title": "Email Address",
          "format": "email"
        },
        "message": {
          "type": "string",
          "title": "Message",
          "minLength": 10
        },
        "urgent": {
          "type": "boolean",
          "title": "Is this urgent?",
          "default": false
        }
      },
      "required": ["name", "email", "message"]
    },
    "uiSchema": {
      "name": {
        "placeholder": "John Doe"
      },
      "email": {
        "placeholder": "john@example.com"
      },
      "message": {
        "widget": "textarea",
        "rows": 4,
        "placeholder": "Enter your message here..."
      }
    },
    "defaultValues": {
      "name": "",
      "email": "",
      "message": "",
      "urgent": false
    }
  }
}
```

### Image Generation Form Example

```json
{
  "message": "I'll help you create an image. Please provide the following details:",
  "formData": {
    "schema": {
      "type": "object",
      "properties": {
        "prompt": {
          "type": "string",
          "title": "Image Description",
          "description": "Describe what you want to see in the image",
          "minLength": 10
        },
        "style": {
          "type": "string",
          "title": "Art Style",
          "enum": ["photorealistic", "cartoon", "painting", "sketch", "abstract"],
          "enumNames": ["Photorealistic", "Cartoon", "Painting", "Sketch", "Abstract"]
        },
        "mood": {
          "type": "string",
          "title": "Mood/Atmosphere",
          "enum": ["happy", "serious", "mysterious", "dramatic", "calm"],
          "enumNames": ["Happy", "Serious", "Mysterious", "Dramatic", "Calm"]
        },
        "aspectRatio": {
          "type": "string",
          "title": "Aspect Ratio",
          "enum": ["1:1", "16:9", "4:3", "9:16"],
          "default": "1:1"
        },
        "colors": {
          "type": "array",
          "title": "Dominant Colors",
          "items": {
            "type": "string",
            "enum": ["red", "blue", "green", "yellow", "purple", "orange", "black", "white"],
            "enumNames": ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Black", "White"]
          },
          "minItems": 1,
          "maxItems": 3
        },
        "nsfw": {
          "type": "boolean",
          "title": "Contains mature content?",
          "default": false
        }
      },
      "required": ["prompt", "style"]
    },
    "uiSchema": {
      "prompt": {
        "widget": "textarea",
        "rows": 3,
        "placeholder": "A detailed description of what you want to see..."
      },
      "colors": {
        "conditional": {
          "dependsOn": "style",
          "showWhen": "value !== 'abstract'"
        }
      },
      "nsfw": {
        "className": "mt-4"
      }
    },
    "defaultValues": {
      "prompt": "",
      "style": "photorealistic",
      "mood": "calm",
      "aspectRatio": "1:1",
      "colors": ["blue"],
      "nsfw": false
    }
  }
} 