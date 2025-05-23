<!-- Generated by SpecStory -->

# Improving Metadata Clarity in OpenAI (2025-04-08 18:55:06)

_**User**_

OpenAI is including bogus metadata which I think is due to the example. For the metadata only I propose including comments on what the semantic of the field represent rather than examples.

---

_**Assistant**_

I'll modify the metadata section to use comments that explain the semantics of each field rather than example values. This will help prevent confusion with bogus metadata.

---

```diff
    ],
    "metadata": {
-     "id": "string (unique identifier)",
-     "model": "string (model identifier)",
-     "created": "number (unix timestamp)",
-     "system_fingerprint": "string (system identifier)",
-     "service_tier": "string (service level identifier)",
-     "object": "string (object type)",
-     "finish_reason": "string (completion status)",
-     "timestamp": "string (ISO timestamp)",
-     "process_time_ms": "number (processing time in milliseconds)",
+     "id": "// Unique identifier for the B-Roll concept document",
+     "model": "// Identifier of the AI model used to generate concepts",
+     "created": "// Unix timestamp when the document was created",
+     "system_fingerprint": "// System identifier for tracking purposes",
+     "service_tier": "// Service level identifier",
+     "object": "// Object type descriptor",
+     "finish_reason": "// Completion status indicator",
+     "timestamp": "// ISO-formatted timestamp",
+     "process_time_ms": "// Processing time in milliseconds",
      "token_usage": {
-       "input_tokens": "number (token count for input)",
-       "output_tokens": "number (token count for output)",
-       "total_tokens": "number (sum of input and output tokens)"
+       "input_tokens": "// Count of tokens in the input",
+       "output_tokens": "// Count of tokens in the output",
+       "total_tokens": "// Total token count (input + output)"
      }
    }
    ],
    "metadata": {
-     "id": "broll_ideation_12345",
-     "model": "gpt-4-turbo",
-     "created": 1715291750,
-     "system_fingerprint": "fp_44de1b7f5b",
-     "service_tier": "standard",
-     "object": "broll_concepts",
-     "finish_reason": "stop",
-     "timestamp": "2024-05-09T15:49:10Z",
-     "process_time_ms": 2453,
+     "id": "// Unique identifier for the B-Roll concept document",
+     "model": "// Identifier of the AI model used to generate concepts",
+     "created": "// Unix timestamp when the document was created",
+     "system_fingerprint": "// System identifier for tracking purposes",
+     "service_tier": "// Service level identifier",
+     "object": "// Object type descriptor",
+     "finish_reason": "// Completion status indicator",
+     "timestamp": "// ISO-formatted timestamp",
+     "process_time_ms": "// Processing time in milliseconds",
      "token_usage": {
-       "input_tokens": 1245,
-       "output_tokens": 987,
-       "total_tokens": 2232
+       "input_tokens": "// Count of tokens in the input",
+       "output_tokens": "// Count of tokens in the output",
+       "total_tokens": "// Total token count (input + output)"
      }
    }
```

---

The metadata sections have been updated with comments explaining the purpose of each field rather than example values. This should prevent any confusion with bogus metadata being included in the actual output. The comments clearly describe what each field represents without providing specific examples that might be mistakenly included in generated content.

---



---

