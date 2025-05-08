// Create a Javascript n8n Node to parse the output string to JSON.

// Parse Script Architecture Output to JSON
// This code node transforms the output string from script architecture JSON into a structured object

// Main execution function - process all items at once
const items = $input.all();
const processedItems = [];

// Process each input item
for (const item of items) {
  try {
    // Create a copy of the item to avoid mutating the original
    const newItem = JSON.parse(JSON.stringify(item));
    
    // The input structure might vary - check different possible locations for the output string
    let outputString;
    
    // Case 1: item.json.output exists
    if (newItem.json?.output) {
      outputString = newItem.json.output;
    } 
    // Case 2: item.output exists
    else if (newItem.output) {
      outputString = newItem.output;
    }
    // Case a: item itself is a string
    else if (typeof newItem === 'string') {
      outputString = newItem;
    }
    // Case b: direct item access without json property
    else if (typeof item === 'object') {
      if (item.output) {
        outputString = item.output;
      } else {
        throw new Error('Input is missing the required "output" property');
      }
    } else {
      throw new Error('Input is missing the required "output" property');
    }
    
    // Parse the output string into a JSON object
    const parsedOutput = JSON.parse(outputString);
    
    // Create proper output structure
    // If we already have a json property, add parsedData to it
    if (newItem.json) {
      newItem.json.parsedData = parsedOutput;
      // Remove the original output so it doesn't prefix the result
      delete newItem.json.output;
      delete newItem.output;
    } 
    // Otherwise create a new json property with the parsed data
    else {
      newItem.json = {
        parsedData: parsedOutput
      };
    }
    
    // Log success
    console.log(`Successfully parsed script architecture data for item ${processedItems.length + 1}`);
    
    // Add to processed items
    processedItems.push(newItem);
  } catch (error) {
    // Handle errors gracefully
    console.error(`Error processing item: ${error.message}`);
    
    // Create a proper error structure regardless of input structure
    const errorItem = {
      json: {
        error: error.message,
        parsedData: null,
        originalInput: JSON.stringify(item).substring(0, 100) + '...' // Include truncated original for debugging
      }
    };
    
    processedItems.push(errorItem);
  }
}

// Return the processed items
// n8n expects an array of items in 'Run Once for All Items' mode
return processedItems;

