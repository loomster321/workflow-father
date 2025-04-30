// n8n Code Node to parse Visual Narrative Output for every item.

return items.map(item => {
  try {
    return { json: JSON.parse(item.json.output) };
  } catch (e) {
    // Optionally, you can log or handle the error differently
    return { json: { error: 'Invalid JSON in output field', details: e.message, raw: item.json.output } };
  }
});

