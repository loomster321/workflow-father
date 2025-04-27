# Comprehensive Cursor Rules for n8n JavaScript Code Nodes

## Introduction
This document provides detailed cursor rules and best practices for writing JavaScript code in n8n Code Nodes. Following these guidelines will ensure your code is optimized, maintainable, secure, and follows established n8n conventions. Consistent coding practices are especially important in n8n workflows where they enable collaboration, troubleshooting, and long-term maintainability of your automation ecosystem.

## Core Principles
- **Clarity**: Write code that is easy to understand and maintain
- **Immutability**: Never mutate input data directly
- **Performance**: Optimize for execution speed and resource usage
- **Error Handling**: Implement comprehensive error prevention strategies
- **Maintainability**: Structure your code for easy updates and modifications
- **Testability**: Write code that can be easily tested and validated
- **Documentation**: Add appropriate comments for complex logic
- **Security** (Optional): Implement security measures when explicitly requested

---

## Code Structure & Organization

### File Structure
```javascript
// 1. Imports and Constants
const moment = require('moment');
const BATCH_SIZE = 100;
const CODE_VERSION = '1.0.0';

// 2. Configuration
const CONFIG = {
  retryAttempts: 3,
  timeoutMs: 5000,
  debug: false
};

// 3. Helper Functions
function validateInput(item) {
  // Input validation logic
}

// 4. Main Execution Logic
const processedItems = $input.all().map(item => {
  // Processing logic
});

// 5. Error Handling
try {
  // Validate final output
} catch (error) {
  console.error('Error in processing:', error.message);
  // Handle error appropriately
}

// 6. Return Statement
return { json: processedItems };
```

### Code Documentation
- Add a brief description at the top explaining what the code does
- Document complex logic with inline comments
- Use JSDoc-style comments for functions:

```javascript
/**
 * Transforms raw customer data into standardized format
 * @param {Object} customer - Raw customer data
 * @param {string} customer.id - Unique customer identifier
 * @param {Object} [options] - Optional configuration
 * @returns {Object} Standardized customer object
 */
function transformCustomer(customer, options = {}) {
  // Function implementation
}
```

### Naming Conventions
- Use **camelCase** for variables, functions, and methods
- Use **PascalCase** for classes and constructors
- Use **UPPER_SNAKE_CASE** for constants
- Use **descriptive prefixes** for boolean variables:
  - `is` for state (e.g., `isProcessed`)
  - `has` for presence (e.g., `hasError`)
  - `should` for conditions (e.g., `shouldRetry`)

### Function Structure
- **Single Responsibility**: Each function should do one thing well
- **Pure Functions**: Avoid side effects where possible
- **Early Returns**: Handle edge cases early to reduce nesting
- **Parameter Limits**: Keep function parameters to a maximum of 3

```javascript
// ✅ Good: Pure function with early returns
function formatAmount(value, currency = 'USD') {
  if (value === null || value === undefined) return '0.00';
  if (typeof value !== 'number') return value.toString();
  
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency
  }).format(value);
}
```

---

## Input Handling

### Execution Modes
- **Run Once for All Items**:
  ```javascript
  const allItems = $input.all(); // Returns array of all input items
  // Process all items at once
  return { json: processedItems };
  ```

- **Run Once for Each Item**:
  ```javascript
  const currentItem = $input.item; // Current item being processed
  // Process single item
  return { json: processedItem };
  ```

### Immutable Data Handling
**NEVER** mutate original input data directly. Always create copies:

```javascript
// ❌ Dangerous: Direct modification
$input.item.json.price *= 1.1;

// ✅ Safe: Cloning approach
const modifiedItem = JSON.parse(JSON.stringify($input.item.json));
modifiedItem.price *= 1.1;
return { json: modifiedItem };
```

```javascript
// ✅ Better: Using spread operator
const modifiedItem = {
  ...$input.item.json,
  price: $input.item.json.price * 1.1,
  updatedAt: new Date().toISOString()
};
return { json: modifiedItem };
```

### Efficient Data Access Patterns

| Method | Use Case | Complexity | Notes |
|--------|----------|------------|-------|
| `$input.first()` | First item | O(1) | Prefer over `$input.all()[0]` |
| `$input.last()` | Last item | O(n) | Use cautiously with large datasets |
| `$input.item` | Current item | O(1) | In "Run once for each" mode |
| `$input.all()` | All items | O(n) | In "Run once for all" mode |
| `$input.itemIndex` | Current index | O(1) | In "Run once for each" mode |

```javascript
// ✅ Good: Clear intent for first item
const firstItem = $input.first();

// ❌ Poor: Less readable and redundant processing
const firstItem = $input.all()[0];
```

### Context-Aware Processing

```javascript
// Check workflow context 
if ($input.context.noItemsLeft) {
  // Finalize batch processing
  return { json: { status: 'completed', totalProcessed: $input.context.totalProcessed } };
}

// Access workflow variables
const apiKey = $workflow.variables.apiKey;
```

---

## Error Prevention and Handling

### Standardized Error Classification

Define clear error categories to improve error handling consistency:

```javascript
// Define error types
const ErrorTypes = {
  VALIDATION: 'VALIDATION_ERROR',
  PROCESSING: 'PROCESSING_ERROR',
  EXTERNAL: 'EXTERNAL_SERVICE_ERROR',
  CONFIGURATION: 'CONFIGURATION_ERROR'
};

// Create custom error class
class WorkflowError extends Error {
  constructor(message, type, details = {}) {
    super(message);
    this.name = 'WorkflowError';
    this.type = type;
    this.details = details;
    this.timestamp = new Date().toISOString();
  }
}

// Example usage
if (!item.json?.orderId) {
  throw new WorkflowError(
    'Missing order ID', 
    ErrorTypes.VALIDATION, 
    { item: item.json }
  );
}
```

### Type Safety and Validation

```javascript
// Validate input structure before processing
function validateOrderItem(item) {
  if (!item.json) {
    throw new WorkflowError(
      'Invalid item: missing json property',
      ErrorTypes.VALIDATION
    );
  }
  
  if (typeof item.json.orderId !== 'string') {
    throw new WorkflowError(
      `Invalid order ID format: ${typeof item.json.orderId}`,
      ErrorTypes.VALIDATION,
      { expectedType: 'string', receivedType: typeof item.json.orderId }
    );
  }
  
  if (typeof item.json.quantity !== 'number' || item.json.quantity <= 0) {
    throw new WorkflowError(
      `Invalid quantity: ${item.json.quantity}`,
      ErrorTypes.VALIDATION,
      { value: item.json.quantity }
    );
  }
  
  return true;
}

// Apply validation to all items
const allItems = $input.all();
allItems.forEach(validateOrderItem);
```

### Null Safety

```javascript
// Use optional chaining and nullish coalescing
const orderValue = $input.item.json?.orderDetails?.total ?? 0;
const customerName = $input.item.json?.customer?.name || 'Anonymous';

// Safely access nested properties
function getNestedProperty(obj, path, defaultValue = null) {
  return path.split('.').reduce((prev, curr) => 
    prev ? prev[curr] : defaultValue, obj);
}

const zipCode = getNestedProperty($input.item.json, 'address.zipCode', '00000');
```

### Try-Catch Blocks

Always wrap risky operations in try-catch blocks with appropriate error handling:

```javascript
try {
  // Risky operation (e.g., JSON parsing)
  const config = JSON.parse($input.item.json.configString);
  return { json: { success: true, config } };
} catch (error) {
  console.error('Failed to parse config:', error.message);
  return { 
    json: { 
      success: false, 
      error: error.message,
      originalData: $input.item.json.configString
    } 
  };
}
```

### Graceful Degradation

Design your code to handle partial failures gracefully:

```javascript
// Process multiple items, continuing even if some fail
function processWithFallbacks(items) {
  return items.map(item => {
    try {
      return processItem(item);
    } catch (error) {
      console.error(`Failed to process item ${item.json?.id}:`, error.message);
      // Return a fallback or partial result instead of failing completely
      return {
        json: {
          id: item.json?.id,
          processingError: error.message,
          status: 'FAILED',
          partialData: extractSafeData(item)
        }
      };
    }
  });
}

// Extract whatever data is safe to use even when processing fails
function extractSafeData(item) {
  const safe = {};
  // Copy only the fields we know are safe
  if (item.json?.id) safe.id = item.json.id;
  if (item.json?.name) safe.name = item.json.name;
  return safe;
}
```

---

## Performance Optimization

### Batch Processing

```javascript
// Process items in batches of 100
const batchSize = 100;
const allItems = $input.all();
const batches = [];

// Create batches
for (let i = 0; i < allItems.length; i += batchSize) {
  batches.push(allItems.slice(i, i + batchSize));
}

// Process each batch
const results = batches.map(batch => {
  return batch.map(processSingleItem);
});

// Flatten results
return { json: results.flat() };
```

### Task Runners for Improved Performance

In n8n version 1.0 and later, you can take advantage of Task Runners for JavaScript Code Nodes to achieve up to 6x performance improvement:

```javascript
// Use the Task Runner API if available
if ($taskRunner) {
  // Define a task that can be run in parallel
  const processItemTask = $taskRunner.define(item => {
    // Complex processing logic
    return transformItem(item);
  });
  
  // Process all items in parallel
  const results = await $taskRunner.runAll(
    $input.all(),
    processItemTask,
    { concurrency: 5 } // Process 5 items at a time
  );
  
  return { json: results };
} else {
  // Fallback for older n8n versions
  return { json: $input.all().map(transformItem) };
}
```

### Benchmarking Critical Code

Measure performance of critical code sections to identify bottlenecks:

```javascript
function timeExecution(fn, label) {
  const start = performance.now();
  const result = fn();
  const duration = performance.now() - start;
  console.log(`${label} took ${duration.toFixed(2)}ms to execute`);
  return result;
}

// Usage
const transformedData = timeExecution(() => {
  return $input.all().map(complexTransformation);
}, 'Data transformation');
```

### Memory Management

```javascript
// For very large datasets, use generators
function* processLargeDataset(items) {
  for (const item of items) {
    // Process one item at a time to avoid memory spikes
    yield transformItem(item);
  }
}

// Convert generator results to array
const results = [...processLargeDataset($input.all())];
return { json: results };
```

### Reduce Object Creation

```javascript
// ❌ Inefficient: Creates many temporary objects
const processedItems = $input.all().map(item => {
  const temp1 = doSomething(item);
  const temp2 = doSomethingElse(temp1);
  const temp3 = yetAnotherOperation(temp2);
  return finalTransform(temp3);
});

// ✅ Better: Chains operations to reduce temporary objects
const processedItems = $input.all().map(item => 
  finalTransform(
    yetAnotherOperation(
      doSomethingElse(
        doSomething(item)
      )
    )
  )
);

// ✅ Also good: Use reduce for complex transformations
const processedItems = $input.all().reduce((result, item) => {
  // Complex transformation logic that builds up the result
  result.push(transformItem(item));
  return result;
}, []);
```

---

## Cross-Node Integration

### Referencing External Node Data

```javascript
// Access data from previous nodes
const userData = $("User Lookup").item.json;
const allProducts = $("Product API").all();

// Get data from specific item by index
const specificItem = $("Item Generator").item($input.itemIndex).json;
```

### Parameter Forwarding

```javascript
// Preserve configuration from previous nodes
const queryParams = $input.params;
const apiEndpoint = $("API Config").first().json.endpoint;

// Forward metadata
return {
  json: {
    ...processedData,
    _meta: {
      source: $input.item.json._meta,
      processedAt: new Date().toISOString()
    }
  }
};
```

---

## Debugging & Logging

### Structured Logging Levels

Use different logging methods for different severity levels:

```javascript
// Define logging utility with severity levels
const logger = {
  debug: (message, data) => {
    if (CONFIG.debug) console.log(`[DEBUG] ${message}`, data);
  },
  info: (message, data) => {
    console.log(`[INFO] ${message}`, data);
  },
  warn: (message, data) => {
    console.warn(`[WARNING] ${message}`, data);
  },
  error: (message, data) => {
    console.error(`[ERROR] ${message}`, data);
  }
};

// Usage examples
logger.info('Processing started', {
  itemCount: $input.all().length,
  workflowId: $workflow.id,
  timestamp: new Date().toISOString()
});

logger.debug('Raw input data', $input.first().json);

try {
  // Risky operation
} catch (error) {
  logger.error('Operation failed', {
    error: error.message,
    itemId: $input.item.json.id,
    stack: error.stack
  });
}
```

### Conditional Debug Output

Toggle verbose output based on configuration:

```javascript
// Define debug configuration
const DEBUG = $workflow.variables.debugMode || false;

// Conditionally log detailed information
function debugLog(message, data) {
  if (DEBUG) {
    console.log(`[DEBUG] ${message}`, data);
  }
}

// Usage
debugLog('Processing item', {
  index: $input.itemIndex,
  raw: $input.item.json
});
```

### Progress Tracking

For long-running operations, track and log progress:

```javascript
function processWithProgress(items) {
  const total = items.length;
  
  return items.map((item, index) => {
    // Log every 10% of progress
    if (index % Math.max(1, Math.floor(total / 10)) === 0) {
      console.log(`Progress: ${Math.floor((index / total) * 100)}% (${index}/${total})`);
    }
    
    return processItem(item);
  });
}
```

### Code Versioning

```javascript
// Embed code version in output for traceability
const CODE_VERSION = '1.2.3';

return { 
  json: { 
    ...processedData,
    _metadata: {
      codeVersion: CODE_VERSION,
      processedAt: new Date().toISOString()
    }
  } 
};
```

---

## Modular Code Practices

### Helper Functions

```javascript
// Reusable validation functions
function isValidEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return typeof email === 'string' && regex.test(email);
}

// Data transformation helpers
function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency
  }).format(amount);
}

// Domain-specific utilities
function calculateTotalPrice(items, taxRate = 0.1) {
  const subtotal = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const tax = subtotal * taxRate;
  return subtotal + tax;
}
```

### Async Operations

```javascript
// Proper async handling
const axios = require('axios');

async function fetchExternalData(ids) {
  try {
    const responses = await Promise.all(
      ids.map(id => axios.get(`https://api.example.com/data/${id}`))
    );
    return responses.map(response => response.data);
  } catch (error) {
    console.error('API fetch failed:', error.message);
    return [];
  }
}

// Usage in n8n Code Node
const itemIds = $input.all().map(item => item.json.id);
const externalData = await fetchExternalData(itemIds);

return { json: externalData };
```

---

## Data Transformation Patterns

### Mapping and Filtering

```javascript
// Transform all items
const transformedItems = $input.all().map(item => ({
  id: item.json.id,
  name: item.json.name.toUpperCase(),
  createdAt: new Date(item.json.createdAt).toISOString()
}));

// Filter items
const activeItems = $input.all().filter(item => 
  item.json.status === 'active' && !item.json.isArchived
);

// Combine operations
const processedItems = $input.all()
  .filter(item => item.json.price > 0)
  .map(item => ({
    id: item.json.id,
    displayPrice: formatCurrency(item.json.price)
  }));
```

### Grouping and Aggregation

```javascript
// Group items by a property
function groupBy(items, key) {
  return items.reduce((result, item) => {
    const groupKey = item.json[key];
    if (!result[groupKey]) {
      result[groupKey] = [];
    }
    result[groupKey].push(item);
    return result;
  }, {});
}

// Usage
const itemsByCategory = groupBy($input.all(), 'category');

// Aggregate values
const salesByRegion = $input.all().reduce((result, item) => {
  const region = item.json.region;
  if (!result[region]) {
    result[region] = 0;
  }
  result[region] += item.json.saleAmount;
  return result;
}, {});
```

### Object Restructuring

```javascript
// Convert array to lookup object
const usersById = $input.all().reduce((result, user) => {
  result[user.json.id] = user.json;
  return result;
}, {});

// Flatten nested structures
const flattenedData = $input.all().map(item => ({
  id: item.json.id,
  name: item.json.name,
  street: item.json.address?.street,
  city: item.json.address?.city,
  country: item.json.address?.country
}));

// Restructure API responses
const processedResponse = {
  success: true,
  data: $input.all().map(item => ({
    id: item.json.id,
    displayName: `${item.json.firstName} ${item.json.lastName}`,
    email: item.json.email
  }))
};
```

---

## Security Considerations (Optional)

> **Note**: The security features in this section are optional and should only be implemented when explicitly requested by the user.

### Input Sanitization

When requested by the user, sanitize inputs, especially when handling data that might contain malicious content:

```javascript
// Basic HTML sanitization
function sanitizeHtml(text) {
  if (!text) return text;
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// SQL injection protection
function escapeSqlInput(input) {
  if (!input) return input;
  return String(input)
    .replace(/'/g, "''")
    .replace(/\\/g, '\\\\');
}
```

### Sensitive Data Handling

When requested by the user, implement careful handling of sensitive data in your code and logs:

```javascript
// Mask sensitive data in logs
function maskSensitiveData(data) {
  if (!data) return data;
  
  // Create a deep copy to avoid modifying original
  const sanitized = JSON.parse(JSON.stringify(data));
  
  // Mask credit card numbers
  if (sanitized.creditCard) {
    sanitized.creditCard = sanitized.creditCard.replace(/\d(?=\d{4})/g, '*');
  }
  
  // Mask API keys
  if (sanitized.apiKey) {
    sanitized.apiKey = '********';
  }
  
  // Mask email addresses
  if (sanitized.email) {
    const [name, domain] = sanitized.email.split('@');
    sanitized.email = `${name.charAt(0)}${'*'.repeat(name.length - 1)}@${domain}`;
  }
  
  return sanitized;
}

// Usage
console.log('Processing payment', maskSensitiveData(paymentData));
```

## Final Checklist

Before finalizing your Code Node, ensure you've covered these points:

- [ ] **Structure**: Code is logically organized with clear sections
- [ ] **Documentation**: Code includes appropriate comments and documentation
- [ ] **Names**: Variables, functions, and constants follow naming conventions
- [ ] **Input Handling**: Correct execution mode is selected and input data is accessed properly
- [ ] **Immutability**: No direct mutations of input data
- [ ] **Validation**: Input data is validated before processing
- [ ] **Error Handling**: Comprehensive error prevention with try-catch blocks
- [ ] **Performance**: Code is optimized for execution speed and memory usage
- [ ] **Testing**: Code is tested with various inputs, including edge cases
- [ ] **Logging**: Appropriate logging for troubleshooting
- [ ] **Return**: Data is returned in the correct format for n8n
- [ ] **Security** (When requested): Inputs are sanitized and sensitive data is handled appropriately

---

## When to Apply Security Features

The security features outlined in this document should only be implemented when:

1. **Explicitly requested by the user**: Only add security measures when the user specifically asks for them.

2. **Working with external data sources**: If your workflow processes data from external APIs, webhooks, or user inputs that are explicitly mentioned as requiring security measures.

3. **Processing sensitive information**: When the user indicates that the workflow handles sensitive data like PII, financial information, or credentials.

In standard internal automation workflows where data comes from trusted sources and doesn't contain sensitive information, these security measures can often be omitted for simplicity and performance unless specifically requested.

1. **Forgetting to Return**: Always include a return statement
   ```javascript
   // ❌ Bad: No return statement
   function processItems() {
     const result = $input.all().map(transformItem);
     // Missing return!
   }
   
   // ✅ Good: Explicit return
   function processItems() {
     const result = $input.all().map(transformItem);
     return { json: result };
   }
   ```

2. **Incorrect Structure**: Return data must follow n8n's expected format
   ```javascript
   // ❌ Bad: Incorrect return format
   return transformedItems;
   
   // ✅ Good: Correct n8n format
   return { json: transformedItems };
   ```

3. **Direct Mutations**: Never modify `$input` data directly
   ```javascript
   // ❌ Bad: Direct mutation
   $input.item.json.price *= 1.1;
   
   // ✅ Good: Create new object
   const modifiedItem = { ...$input.item.json, price: $input.item.json.price * 1.1 };
   ```

4. **Excessive Logging**: Log only necessary information to avoid clutter
   ```javascript
   // ❌ Bad: Logging everything
   $input.all().forEach(item => console.log('Processing item:', item));
   
   // ✅ Good: Selective logging
   console.log(`Processing ${$input.all().length} items`);
   ```

5. **Missing Validation**: Always validate input before processing
   ```javascript
   // ❌ Bad: No validation
   const total = items.reduce((sum, item) => sum + item.json.amount, 0);
   
   // ✅ Good: With validation
   const total = items.reduce((sum, item) => {
     if (typeof item.json.amount !== 'number') {
       throw new Error(`Invalid amount: ${item.json.amount}`);
     }
     return sum + item.json.amount;
   }, 0);
   ```

6. **Blocking Operations**: Avoid long-running synchronous operations
   ```javascript
   // ❌ Bad: Blocking operation
   let result = [];
   for (let i = 0; i < 1000000; i++) {
     result.push(complexCalculation(i));
   }
   
   // ✅ Good: Chunked processing
   const chunks = splitIntoChunks($input.all(), 100);
   const results = chunks.map(processChunk);
   ```

7. **Excessive Complexity**: Break down complex logic into helper functions
   ```javascript
   // ❌ Bad: Monolithic code
   const processedItems = $input.all().map(item => {
     // 50 lines of complex transformations
   });
   
   // ✅ Good: Modular approach
   const processedItems = $input.all().map(item => {
     const validated = validateItem(item);
     const enriched = enrichWithMetadata(validated);
     return transformFormat(enriched);
   });
   ```

8. **Hard-coded Values**: Use constants or configuration for changeable values
   ```javascript
   // ❌ Bad: Hard-coded values
   if (item.json.status === 'active' && item.json.region === 'us-east-1') {
     // Process
   }
   
   // ✅ Good: Configurable values
   const CONFIG = {
     activeStatus: 'active',
     supportedRegions: ['us-east-1', 'eu-west-1']
   };
   
   if (item.json.status === CONFIG.activeStatus && 
       CONFIG.supportedRegions.includes(item.json.region)) {
     // Process
   }
   ```

9. **Inadequate Error Handling**: Always implement try-catch for risky operations
   ```javascript
   // ❌ Bad: No error handling
   const data = JSON.parse(item.json.rawData);
   
   // ✅ Good: With error handling
   let data;
   try {
     data = JSON.parse(item.json.rawData);
   } catch (error) {
     console.error('Failed to parse raw data:', error.message);
     data = { error: 'Invalid format' };
   }
   ```

10. **Performance Bottlenecks**: Watch for inefficient loops or redundant processing
    ```javascript
    // ❌ Bad: Inefficient nested loops
    const result = [];
    for (const item of items) {
      for (const product of allProducts) {
        if (item.json.productId === product.id) {
          result.push({ ...item.json, productName: product.name });
        }
      }
    }
    
    // ✅ Good: Use lookup objects
    const productMap = allProducts.reduce((map, product) => {
      map[product.id] = product.name;
      return map;
    }, {});
    
    const result = items.map(item => ({
      ...item.json,
      productName: productMap[item.json.productId] || 'Unknown'
    }));
    ```

11. **Not Checking Execution Mode**: Always verify which execution mode you're in
    ```javascript
    // ❌ Bad: Assuming execution mode
    const items = $input.all();  // Fails in "Run once for each" mode
    
    // ✅ Good: Mode-aware code
    let items;
    if ($input.all) {
      // "Run once for all items" mode
      items = $input.all();
    } else {
      // "Run once for each item" mode
      items = [$input.item];
    }
    ```

12. **Not Handling Binary Data**: Properly handle any binary data in your workflows
    ```javascript
    // ❌ Bad: Ignoring binary data
    return { json: processedData };
    
    // ✅ Good: Preserving binary data
    return {
      json: processedData,
      binary: $input.item.binary  // Preserve binary data if it exists
    };
    ```
