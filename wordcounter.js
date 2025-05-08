// Simplified word counter tool for n8n
const input = $input.all()[0];

// Extract narration_text from input
let narrationText = "";

if (input && input.json && input.json.query) {
  narrationText = input.json.query;
}

// Count words by splitting on whitespace
const words = narrationText.trim().split(/\s+/).filter(Boolean);
const word_count = words.length;

// Return a simple object with the word count
return { word_count }; 