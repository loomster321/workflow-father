// Simplified word counter tool for n8n sub-node
// The tool input arrives in the global `query` variable
const narrationText = typeof query === 'string' ? query : '';

const words      = narrationText.trim().split(/\s+/).filter(Boolean);
const word_count = words.length;

// return only the count as a JSON string
return JSON.stringify({ word_count });
