# Comprehensive Cursor Rules for Python

## Introduction
This document provides detailed cursor rules and best practices for writing Python code. Following these guidelines will ensure your code is readable, maintainable, secure, and follows established Python conventions. These rules are designed for general Python development and aim to improve code quality and consistency across projects.

## Core Principles
- **Readability**: Write code that is easy to understand (following the Zen of Python)
- **Simplicity**: Simple is better than complex
- **Explicitness**: Explicit is better than implicit
- **Consistency**: Follow established Python conventions (PEP 8)
- **Error Handling**: Errors should never pass silently
- **Documentation**: Document your code for future developers (including yourself)
- **Testability**: Write code that can be easily tested
- **Modularity**: Keep functions and classes focused on single responsibilities
- **Security** (Optional): Apply appropriate safeguards against common vulnerabilities when requested

## Code Structure & Organization

### Project Structure
```
project_name/
│
├── README.md                 # Project documentation
├── LICENSE                   # License information
├── pyproject.toml            # Project configuration (modern approach)
├── .gitignore                # Git ignored files and directories  
├── requirements.txt          # Dependencies (if not using pyproject.toml)
├── Makefile                  # Common commands (optional)
│
├── src/                      # Source directory (recommended over project_name/)
│   └── project_name/         # Main package directory
│       ├── __init__.py       # Package initialization
│       ├── __main__.py       # Entry point for running as module
│       ├── module1.py        # Core functionality
│       ├── module2.py        # Core functionality
│       └── subpackage/       # Nested package
│           ├── __init__.py
│           └── module3.py
│
├── tests/                    # Test directory
│   ├── __init__.py
│   ├── conftest.py           # Pytest fixtures and configuration
│   ├── test_module1.py
│   └── test_module2.py
│
├── docs/                     # Documentation
│   ├── index.md
│   └── api.md
│
└── scripts/                  # Utility scripts
    └── dev_setup.sh
```

### Modern Package Configuration (pyproject.toml)
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "project_name"
version = "0.1.0"
description = "A short description of the project"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
]
dependencies = [
    "requests>=2.28.0",
    "numpy>=1.22.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=22.3.0",
    "mypy>=0.960",
    "flake8>=4.0.0",
]
docs = [
    "sphinx>=4.5.0",
    "sphinx-rtd-theme>=1.0.0",
]

[project.urls]
"Homepage" = "https://github.com/username/project_name"
"Bug Tracker" = "https://github.com/username/project_name/issues"

[project.scripts]
project-cli = "project_name.__main__:main"

[tool.black]
line-length = 88
target-version = ["py38", "py39", "py310", "py311"]
include = '\.pyi?$'

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
```

### Module Structure
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Module description and purpose.

This module provides functionality for...
"""

# Standard library imports
import os
import sys
from datetime import datetime

# Third-party imports
import numpy as np
import pandas as pd

# Local application imports
from . import module1
from .subpackage import module3

# Constants
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30  # seconds

# Global variables (use sparingly)
_CACHE = {}


# Classes
class MyClass:
    """Class docstring with description."""
    
    def __init__(self, param1, param2=None):
        """Initialize the class instance."""
        self.param1 = param1
        self.param2 = param2
    
    def method1(self):
        """Method docstring."""
        pass


# Functions
def function1(arg1, arg2=None):
    """Function docstring with description.
    
    Args:
        arg1: Description of arg1
        arg2: Description of arg2, defaults to None
        
    Returns:
        Description of return value
        
    Raises:
        ValueError: When arg1 is invalid
    """
    # Function implementation
    return result


# Main execution
if __name__ == "__main__":
    # Code to run when file is executed directly
    pass
```

## Naming Conventions

### General Rules
- Use meaningful and descriptive names
- Avoid single letter names (except for counters or in mathematical expressions)
- Be consistent in your naming scheme

### Specific Conventions
- **Packages & Modules**: Short, lowercase names with underscores: `my_package`, `my_module`
- **Classes**: CapWords/PascalCase: `MyClass`, `DataProcessor`
- **Functions & Methods**: Lowercase with underscores (snake_case): `calculate_total`, `get_user_data`
- **Variables**: Lowercase with underscores: `user_name`, `total_count`
- **Constants**: Uppercase with underscores: `MAX_RETRIES`, `PI_VALUE`
- **Private Members**: Prefix with single underscore: `_private_method`, `_internal_value`
- **"Magic" Methods**: Double underscores: `__init__`, `__str__`
- **Throwaway Variables**: Double underscore: `for __, value in enumerate(items):`

## Whitespace and Formatting

### Line Length
- Maximum 79 characters for code (88 for modern projects using Black)
- Maximum 72 characters for docstrings/comments

### Indentation
- Use 4 spaces per indentation level
- Never mix tabs and spaces

### Blank Lines
- 2 blank lines before top-level class and function definitions
- 1 blank line before method definitions inside a class
- Use blank lines to separate logical sections

### Imports
- Separate imports into groups:
  1. Standard library imports
  2. Third-party library imports
  3. Local application imports
- Within each group, use alphabetical order
- One import per line

```python
# Standard library
import os
import sys

# Third-party
import numpy as np
import pandas as pd

# Local
from . import local_module
from .subpackage import module
```

### Line Breaks
- Break before binary operators:

```python
# Good
income = (gross_wages
          + taxable_interest
          + dividend_income
          - ira_deduction)

# Avoid
income = gross_wages + \
         taxable_interest + \
         dividend_income - \
         ira_deduction
```

## Type Hints

### Modern Type Hinting (Python 3.9+)
- Use type hints for function parameters and return values
- Use built-in collection types directly (Python 3.9+)
- Apply appropriate typing concepts for more complex scenarios

```python
# Basic type hints
def greet(name: str, age: int | None = None) -> str:
    """Generate a greeting message."""
    if age is not None:
        return f"Hello {name}, you are {age} years old!"
    return f"Hello {name}!"

# Collection type hints (Python 3.9+)
def process_items(items: list[int]) -> dict[str, int]:
    result = {}
    for i, item in enumerate(items):
        result[f"item_{i}"] = item * 2
    return result

# Union types (Python 3.10+ uses pipe syntax)
def handle_input(value: int | float | str) -> str:
    return f"Processed: {value}"

# Optional is equivalent to Union[Type, None]
from typing import Optional
def may_return_none(arg: bool) -> Optional[str]:
    if arg:
        return "Value"
    return None
```

### Advanced Type Hints

```python
# Type aliases
from typing import TypeAlias

Vector: TypeAlias = list[float]

def scale(vector: Vector, factor: float) -> Vector:
    return [x * factor for x in vector]

# Self type for methods (Python 3.11+)
from typing import Self

class ChainableObject:
    def set_value(self, value: int) -> Self:
        self.value = value
        return self
    
    def process(self) -> Self:
        self.value *= 2
        return self

# TypedDict for dictionary structures
from typing import TypedDict

class MovieData(TypedDict):
    title: str
    year: int
    rating: float
    director: str

def format_movie(movie: MovieData) -> str:
    return f"{movie['title']} ({movie['year']}) - {movie['rating']}/10"

# Using protocols for structural subtyping
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

def render(drawable: Drawable) -> None:
    drawable.draw()

# Function type hints
from typing import Callable

def apply_operation(x: int, y: int, 
                   operation: Callable[[int, int], int]) -> int:
    return operation(x, y)

# Literal types for specific values
from typing import Literal

def set_alignment(align: Literal["left", "center", "right"]) -> None:
    print(f"Setting alignment to {align}")

# TypeVar for generic functions
from typing import TypeVar, Sequence

T = TypeVar('T')

def first_element(sequence: Sequence[T]) -> T:
    if not sequence:
        raise ValueError("Sequence cannot be empty")
    return sequence[0]
```

## String Formatting
- Prefer f-strings (Python 3.6+) over other string formatting methods

```python
# Good
name = "Alice"
greeting = f"Hello, {name}!"

# Avoid
greeting = "Hello, %s!" % name
greeting = "Hello, {}!".format(name)
```

## Context Managers
- Use context managers for resource management

```python
# Good
with open('file.txt', 'r') as file:
    content = file.read()

# Avoid
file = open('file.txt', 'r')
content = file.read()
file.close()
```

## List/Dict Comprehensions
- Use comprehensions for simple transformations, but prioritize readability

```python
# Good
squares = [x**2 for x in range(10)]

# Good - filter with comprehension 
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Avoid for complex operations
result = [complicated_transform(x) for x in data if complex_condition(x)]
```

## Error Handling

### Exception Patterns
- Be specific about which exceptions to catch
- Provide meaningful error messages
- Use the context manager pattern for cleanup

```python
try:
    value = int(user_input)
except ValueError as e:
    print(f"Invalid input. Please enter a number: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
    raise  # Re-raise unexpected exceptions
else:
    # Code to execute if no exception occurs
    process_value(value)
finally:
    # Cleanup code that always runs
    cleanup_resources()
```

### Custom Exceptions
- Create custom exceptions for domain-specific errors

```python
class ValidationError(Exception):
    """Raised when data validation fails."""
    pass

def validate_username(username):
    if len(username) < 3:
        raise ValidationError("Username must be at least 3 characters")
    # More validation logic...
```

## Documentation

### Docstrings
- Use docstrings for all modules, classes, and functions
- Follow a consistent docstring style (Google, NumPy, or reStructuredText)

```python
def calculate_area(length: float, width: float) -> float:
    """Calculate the area of a rectangle.
    
    Args:
        length: The length of the rectangle.
        width: The width of the rectangle.
        
    Returns:
        The area of the rectangle.
        
    Raises:
        ValueError: If length or width is negative.
    """
    if length < 0 or width < 0:
        raise ValueError("Dimensions cannot be negative")
    return length * width
```

### Comments
- Use comments sparingly to explain "why", not "what"
- Keep comments up-to-date with code changes
- Use inline comments only for complex logic

```python
# Good: Explains why, not what
# Skip weekends to avoid processing non-business days
if day.weekday() < 5:  # Monday = 0, Sunday = 6
    process_business_data()
```

## Testing

### Test Structure
- Write unit tests for functions and classes
- Use pytest for testing
- Keep tests in a separate directory

```python
# test_calculator.py
import pytest
from my_package import calculator

def test_add():
    """Test the add function with positive numbers."""
    assert calculator.add(2, 3) == 5
    
def test_add_negative():
    """Test the add function with negative numbers."""
    assert calculator.add(-1, -2) == -3
    
def test_divide():
    """Test the divide function."""
    assert calculator.divide(6, 3) == 2
    
def test_divide_by_zero():
    """Test that divide raises an exception when dividing by zero."""
    with pytest.raises(ValueError):
        calculator.divide(5, 0)
```

### Mocking
- Use mocking to isolate units of code

```python
from unittest.mock import Mock, patch

@patch('my_module.requests.get')
def test_api_call(mock_get):
    # Configure the mock
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.json.return_value = {'key': 'value'}
    mock_get.return_value = mock_response
    
    # Test function that makes API call
    result = my_module.fetch_data()
    
    # Assertions
    assert result == {'key': 'value'}
    mock_get.assert_called_once_with('https://api.example.com/data')
```

## Performance Optimization

### Efficient Operations
- Use appropriate data structures for performance
- Minimize operations inside loops
- Use built-in functions and standard library solutions

```python
# Good: Single pass through data
counter = collections.Counter(words)

# Avoid: Multiple passes through data
counter = {}
for word in words:
    if word not in counter:
        counter[word] = 0
    counter[word] += 1
```

### Profiling
- Profile code before optimizing
- Focus optimization on bottlenecks

```python
import cProfile
import pstats

# Profile a function
cProfile.run('my_function()', 'profile_stats')

# Analyze results
p = pstats.Stats('profile_stats')
p.sort_stats('cumulative').print_stats(10)  # Show top 10 by cumulative time
```

## Modern Python Development Tools

### Code Formatting and Linting
- Use **Black** for automatic code formatting
- Use **Ruff** as a fast, comprehensive linter (replacing Flake8, isort, pydocstyle, etc.)
- Configure with pyproject.toml for consistent settings

```toml
# In pyproject.toml
[tool.black]
line-length = 88
target-version = ["py310", "py311"]

[tool.ruff]
line-length = 88
target-version = "py310"
select = ["E", "F", "I", "N", "B", "A", "C4", "SIM", "TID"]
ignore = ["E203"]  # For Black compatibility

[tool.ruff.isort]
known-first-party = ["mypackage"]
```

```bash
# Install tools
pip install black ruff

# Format code
black src/ tests/

# Run linter
ruff check src/ tests/

# Fix auto-fixable issues
ruff check --fix src/ tests/
```

### Type Checking
- Use **mypy** for static type checking

```toml
# In pyproject.toml
[tool.mypy]
python_version = "3.10"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
strict_optional = true
```

```bash
# Install mypy
pip install mypy

# Run type checking
mypy src/
```

### Dependency Management
- Use **Poetry** for modern, comprehensive dependency management
- Alternative: **Hatch** for simpler projects

```bash
# Initialize a new project
poetry new myproject

# Add dependencies
poetry add requests numpy

# Add dev dependencies
poetry add --group dev pytest black mypy

# Install dependencies
poetry install

# Update dependencies
poetry update
```

### Testing
- Use **pytest** for testing
- Use **pytest-cov** for coverage reports

```toml
# In pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
addopts = "--cov=src --cov-report=term --cov-report=html"
```

```bash
# Install pytest with coverage
pip install pytest pytest-cov

# Run tests
pytest

# Run specific test
pytest tests/test_module.py::test_function
```

### Pre-commit Hooks
- Use **pre-commit** to automate checks before commits

```yaml
# .pre-commit-config.yaml
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files

-   repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
    -   id: black

-   repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.0.262
    hooks:
    -   id: ruff
        args: [--fix, --exit-non-zero-on-fix]

-   repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.3.0
    hooks:
    -   id: mypy
        additional_dependencies: [types-requests]
```

## Common Pitfalls to Avoid

1. **Ignoring PEP 8**: Inconsistent coding style makes code harder to read and maintain
   ```python
   # Bad: Inconsistent spacing and naming
   def CalculateTotal( x,y ):
       return x+y
   
   # Good: Follows PEP 8
   def calculate_total(x, y):
       return x + y
   ```

2. **Mutable Default Arguments**: Can lead to unexpected behavior
   ```python
   # Bad: Mutable default argument
   def append_to_list(item, my_list=[]):
       my_list.append(item)
       return my_list
   
   # Good: Use None as default
   def append_to_list(item, my_list=None):
       if my_list is None:
           my_list = []
       my_list.append(item)
       return my_list
   ```

3. **Not Using Context Managers**: Resource leaks
   ```python
   # Bad: No context manager
   f = open('file.txt', 'w')
   f.write('Hello')
   f.close()  # What if an exception occurs before this line?
   
   # Good: Uses context manager
   with open('file.txt', 'w') as f:
       f.write('Hello')  # File closed automatically, even if exception occurs
   ```

4. **Overly Complex Comprehensions**: Reduces readability
   ```python
   # Bad: Hard to read
   result = [[x for x in row if x > 0] for row in matrix if sum(row) > 0]
   
   # Good: More readable
   filtered_matrix = [row for row in matrix if sum(row) > 0]
   result = []
   for row in filtered_matrix:
       filtered_row = [x for x in row if x > 0]
       result.append(filtered_row)
   ```

5. **Catching All Exceptions**: Hides bugs
   ```python
   # Bad: Catches everything
   try:
       process_data()
   except:  # Catches all exceptions, including KeyboardInterrupt, SystemExit
       pass
   
   # Good: Specific exception handling
   try:
       process_data()
   except ValueError as e:
       print(f"Invalid data: {e}")
   ```

## Security Considerations (Optional)

> **Note**: The security features in this section are optional and should only be implemented when explicitly requested by the end user.

Implementing security measures is essential for developing robust Python applications. Below are key security practices to follow when security is a priority:

### Input Validation and Sanitization

Always validate and sanitize all input, especially from external sources:

```python
# Bad: Vulnerable to SQL injection
def get_user(username):
    cursor.execute(f"SELECT * FROM users WHERE username = '{username}'")
    return cursor.fetchone()

# Good: Use parameterized queries
def get_user(username):
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    return cursor.fetchone()

# Good: Input validation
def process_age(age_str):
    try:
        age = int(age_str)
        if age < 0 or age > 150:
            raise ValueError("Age must be between 0 and 150")
        return age
    except ValueError as e:
        raise ValueError(f"Invalid age input: {e}")
```

### Avoiding Dangerous Functions

Some Python functions can execute arbitrary code and should be avoided or used with extreme caution:

```python
# Dangerous - never use with untrusted input
eval(user_input)  # Executes arbitrary Python code
exec(user_input)  # Executes arbitrary Python code
__import__(user_input)  # Dynamically imports modules
pickle.loads(user_data)  # Can execute arbitrary code during deserialization

# Safer alternatives
import ast
# Safe evaluation of expressions (still be cautious)
parsed = ast.literal_eval('{"name": "John", "age": 30}')

# For deserialization, prefer JSON over pickle
import json
data = json.loads(user_data)
```

### Secure Password Handling

Never store passwords in plaintext. Use proper hashing algorithms with salting:

```python
# Secure password handling using passlib
from passlib.hash import argon2
from passlib.hash import pbkdf2_sha256

# Recommended: Argon2 (winner of the Password Hashing Competition)
def hash_password(password):
    return argon2.hash(password)

def verify_password(password, hash):
    return argon2.verify(password, hash)

# Alternative: PBKDF2
def hash_password_pbkdf2(password):
    return pbkdf2_sha256.hash(password)
```

### Safe File Operations

Handle file operations securely:

```python
# Avoid path traversal vulnerabilities
import os
from pathlib import Path

def safe_open_file(filename):
    # Normalize path and check if it's within allowed directory
    base_dir = "/safe/directory"
    requested_path = os.path.normpath(os.path.join(base_dir, filename))
    
    if not requested_path.startswith(base_dir):
        raise ValueError("Access to file is forbidden")
        
    # Open file safely
    with open(requested_path, 'r') as f:
        return f.read()

# Using pathlib (preferred in modern Python)
def safe_open_file_pathlib(filename):
    base_dir = Path("/safe/directory")
    try:
        requested_path = (base_dir / filename).resolve()
        if base_dir not in requested_path.parents:
            raise ValueError("Access to file is forbidden")
        return requested_path.read_text()
    except (ValueError, IOError) as e:
        raise ValueError(f"Error accessing file: {e}")
```

### Secure Dependencies

Keep your dependencies updated and regularly check for security vulnerabilities:

```bash
# Check for vulnerable packages
pip install safety
safety check

# Alternative: using pip-audit
pip install pip-audit
pip-audit

# If using a pyproject.toml-based workflow:
pip install pip-audit
pip-audit -r pyproject.toml
```

### SAST (Static Application Security Testing)

Use SAST tools to scan your code for security vulnerabilities:

```bash
# Bandit - security-focused linter
pip install bandit
bandit -r ./src/

# Semgrep - pattern-based code analysis
pip install semgrep
semgrep --config=p/python ./src/
```

### Protecting Sensitive Data

Avoid hardcoding sensitive information:

```python
# Bad: Hardcoded credentials
API_KEY = "1234567890abcdef"
DATABASE_PASSWORD = "password123"

# Good: Use environment variables
import os
from dotenv import load_dotenv

load_dotenv()  # Load from .env file
API_KEY = os.environ.get("API_KEY")
DATABASE_PASSWORD = os.environ.get("DATABASE_PASSWORD")

# For production, consider a proper secrets management solution
# such as HashiCorp Vault, AWS Secrets Manager, etc.
```

## When to Apply Security Features

The security features outlined in this document should only be implemented when:

1. **Explicitly requested by the end user**: Only add security measures when the user specifically asks for them.

2. **Working with external data sources**: If your application processes data from external APIs, web requests, user inputs, or public-facing interfaces that are explicitly mentioned as requiring security measures.

3. **Processing sensitive information**: When the user indicates that the application handles sensitive data like PII, financial information, or credentials.

In standard internal applications or scripts where data comes from trusted sources and doesn't contain sensitive information, these security measures can often be omitted for simplicity unless specifically requested.

## Final Checklist

Before finalizing your Python code, ensure you've covered these points:

- [ ] **PEP 8 Compliance**: Code follows Python style guide
- [ ] **Documentation**: Modules, classes, and functions have docstrings
- [ ] **Type Hints**: Functions have appropriate type annotations
- [ ] **Error Handling**: Exceptions are properly caught and handled
- [ ] **Tests**: Code has unit tests with good coverage
- [ ] **Performance**: No obvious inefficiencies or bottlenecks
- [ ] **Dependencies**: All dependencies are properly specified in pyproject.toml
- [ ] **Logging**: Appropriate logging for troubleshooting
- [ ] **Configuration**: No hardcoded environment-specific values
- [ ] **Consistency**: Naming, formatting, and patterns are consistent
- [ ] **Static Analysis**: Code passed linting and type checking
- [ ] **Edge Cases**: Code handles boundary conditions and unexpected inputs
- [ ] **Clean Code**: No commented-out code or unnecessary TODOs
- [ ] **Resource Management**: Files, connections, and other resources properly closed
- [ ] **Compatibility**: Code works with target Python versions
- [ ] **Documentation**: README and other documentation is up-to-date
- [ ] **Security** (When requested): Input validation, secure coding practices, and dependency security checks implemented

## Additional Resources

### Official Python Guidelines
- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 257 - Docstring Conventions](https://peps.python.org/pep-0257/)
- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [PEP 621 - Storing project metadata in pyproject.toml](https://peps.python.org/pep-0621/)
- [The Zen of Python (PEP 20)](https://peps.python.org/pep-0020/)

### Testing and Quality Tools
- [pytest Documentation](https://docs.pytest.org/)
- [Black Documentation](https://black.readthedocs.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [mypy Documentation](https://mypy.readthedocs.io/)
- [pre-commit Documentation](https://pre-commit.com/)

### Package Management
- [Python Packaging User Guide](https://packaging.python.org/)
- [Poetry Documentation](https://python-poetry.org/docs/)
- [Hatch Documentation](https://hatch.pypa.io/)

### Security Resources
- [OWASP Python Security Project](https://owasp.org/www-project-python-security/)
- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Python Security Best Practices](https://snyk.io/blog/python-security-best-practices-cheat-sheet/)
