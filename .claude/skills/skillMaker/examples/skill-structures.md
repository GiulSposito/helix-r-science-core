# Skill Structure Examples

Complete examples of well-structured skills across different categories.

## Example 1: Simple Reference Skill

**Use case**: Code conventions that Claude should always apply

```yaml
---
name: api-conventions
description: Apply API design patterns and conventions. Use when creating or modifying API endpoints, discussing API design, or when user mentions "API standards" or "REST conventions".
user-invocable: false  # Claude-only background knowledge
---

# API Conventions

Apply these patterns when working with APIs:

## Naming Conventions

### Endpoints
- Use plural nouns: `/users`, `/posts`, `/comments`
- Resource hierarchy: `/users/:id/posts`
- Actions as sub-resources: `/posts/:id/publish`

### HTTP Methods
- GET: Retrieve resource(s)
- POST: Create new resource
- PUT: Replace entire resource
- PATCH: Partially update resource
- DELETE: Remove resource

## Response Format

All endpoints return consistent JSON structure:

\`\`\`json
{
  "data": { /* resource data */ },
  "meta": {
    "timestamp": "2026-03-08T12:00:00Z",
    "version": "1.0"
  }
}
\`\`\`

Errors follow RFC 7807:

\`\`\`json
{
  "type": "https://api.example.com/errors/not-found",
  "title": "Resource Not Found",
  "status": 404,
  "detail": "User with ID 123 not found"
}
\`\`\`

## Status Codes

- 200: Success with body
- 201: Created (include Location header)
- 204: Success no body
- 400: Bad request (validation errors)
- 401: Unauthorized
- 403: Forbidden
- 404: Not found
- 500: Server error

## Validation

- Validate all inputs at endpoint entry
- Return 400 with detailed error messages
- Include field-level error information

\`\`\`json
{
  "type": "validation-error",
  "title": "Validation Failed",
  "status": 400,
  "errors": {
    "email": ["Must be valid email format"],
    "age": ["Must be 18 or older"]
  }
}
\`\`\`
```

---

## Example 2: Task Workflow Skill

**Use case**: Multi-step feature creation process

```yaml
---
name: add-feature
description: Create a complete feature with tests and documentation. Use when user asks to "add a feature", "create feature", "build feature", or discusses implementing new functionality.
disable-model-invocation: true  # User-only invocation
allowed-tools: Read, Write, Edit, Bash
---

# Feature Creator

Create production-ready features following project patterns.

## Usage

\`/add-feature feature-name feature-type\`

**Arguments:**
- $0: Feature name (kebab-case, e.g., "user-authentication")
- $1: Feature type (component|service|api|page)

**Example:**
\`/add-feature user-profile component\`

## Workflow

### Phase 1: Analysis

1. **Understand project structure**
   - Locate similar features
   - Identify naming conventions
   - Find test patterns
   - Review documentation structure

2. **Confirm approach**
   - Present planned files to create/modify
   - Show structure overview
   - Get user approval

### Phase 2: Implementation

#### For Component Type

1. **Create component file**
   - Location: `src/components/$0/`
   - Follow naming convention from similar components
   - Include TypeScript types
   - Add JSDoc comments

2. **Create tests**
   - Location: `src/components/$0/__tests__/`
   - Cover main functionality
   - Follow existing test patterns
   - Aim for >80% coverage

3. **Create Storybook story** (if project uses Storybook)
   - Location: `src/components/$0/$0.stories.tsx`
   - Include common variants
   - Add interactive controls

4. **Export from index**
   - Update `src/components/index.ts`
   - Maintain alphabetical order

#### For Service Type

1. **Create service file**
   - Location: `src/services/$0.service.ts`
   - Define clear interface
   - Include error handling
   - Add logging

2. **Create tests**
   - Mock external dependencies
   - Test error scenarios
   - Verify logging

3. **Update service registry**
   - Add to `src/services/index.ts`

#### For API Type

1. **Create route handler**
   - Location: `src/api/routes/$0.ts`
   - Follow REST conventions
   - Add validation middleware
   - Include error handling

2. **Create tests**
   - Test all HTTP methods
   - Verify validation
   - Check error responses
   - Test authentication/authorization

3. **Update API docs**
   - Add to OpenAPI spec
   - Include example requests/responses

#### For Page Type

1. **Create page component**
   - Location: `src/pages/$0/`
   - Include layout
   - Add SEO metadata
   - Handle loading states

2. **Add route**
   - Update router configuration
   - Add navigation link if needed

3. **Create tests**
   - Test rendering
   - Verify data fetching
   - Check error states

### Phase 3: Quality Checks

1. **Run tests**
   \`\`\`bash
   npm test -- $0
   \`\`\`

2. **Type check**
   \`\`\`bash
   npm run type-check
   \`\`\`

3. **Lint**
   \`\`\`bash
   npm run lint -- --fix
   \`\`\`

4. **Format**
   \`\`\`bash
   npm run format
   \`\`\`

### Phase 4: Documentation

1. **Update README**
   - Add feature to main README if user-facing
   - Include usage examples

2. **Add inline documentation**
   - JSDoc for public APIs
   - Complex logic comments

3. **Update CHANGELOG**
   - Add to "Unreleased" section
   - Note breaking changes

### Phase 5: Summary

Present to user:
- Files created
- Tests written
- Documentation updated
- Next steps (PR creation, deployment, etc.)

## Common Patterns

### Error Boundary (for components)

\`\`\`tsx
export class FeatureNameErrorBoundary extends React.Component {
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logError(error, errorInfo);
  }

  render() {
    return this.state.hasError ? <ErrorFallback /> : this.props.children;
  }
}
\`\`\`

### Service Pattern

\`\`\`typescript
export class FeatureNameService {
  constructor(
    private http: HttpClient,
    private logger: Logger
  ) {}

  async fetchData(): Promise<Data> {
    try {
      const response = await this.http.get('/endpoint');
      this.logger.info('Data fetched successfully');
      return response.data;
    } catch (error) {
      this.logger.error('Failed to fetch data', error);
      throw new ServiceError('Data fetch failed', error);
    }
  }
}
\`\`\`

### API Handler Pattern

\`\`\`typescript
export const handler = async (req: Request, res: Response) => {
  try {
    // Validate input
    const validated = schema.parse(req.body);

    // Business logic
    const result = await service.process(validated);

    // Success response
    res.status(200).json({
      data: result,
      meta: { timestamp: new Date().toISOString() }
    });
  } catch (error) {
    if (error instanceof ValidationError) {
      res.status(400).json({ error: error.message });
    } else {
      logger.error('Handler error', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};
\`\`\`

## Troubleshooting

**Tests fail after creation:**
- Check for missing test dependencies
- Verify mocks are properly configured
- Ensure test files match project patterns

**Type errors:**
- Add necessary type definitions
- Check import paths
- Verify exported types

**Integration issues:**
- Verify exports in index files
- Check route registration
- Confirm service initialization
```

---

## Example 3: Dynamic Context Skill

**Use case**: Work with current PR context

```yaml
---
name: pr-review
description: Perform thorough PR review with checklist. Use when user asks to "review PR", "check pull request", mentions "PR review", or discusses code review.
allowed-tools: Bash(gh *), Read, Grep
---

# Pull Request Reviewer

## Current PR Context

!`if ! gh pr view &>/dev/null; then echo "Not in PR context. Please navigate to PR or specify PR number."; exit 1; fi`

### PR Details
- **Title**: !`gh pr view --json title -q .title`
- **Author**: !`gh pr view --json author -q .author.login`
- **Status**: !`gh pr view --json state,isDraft -q 'if .isDraft then "Draft" else .state end'`
- **Branch**: !`gh pr view --json headRefName -q .headRefName` → !`gh pr view --json baseRefName -q .baseRefName`
- **Reviewers**: !`gh pr view --json reviewRequests -q '.reviewRequests | map(.login) | join(", ")'`

### Changed Files
!`gh pr diff --name-only`

### Statistics
- **Files changed**: !`gh pr diff --name-only | wc -l | tr -d ' '`
- **Additions**: !`gh pr diff --stat | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+'` lines
- **Deletions**: !`gh pr diff --stat | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+'` lines

## Review Process

### 1. High-Level Assessment

Review PR title and description:
- Is the purpose clear?
- Are breaking changes noted?
- Is the scope appropriate (not too large)?

### 2. Code Quality Review

For each changed file, check:

#### Architecture & Design
- [ ] Changes follow project architecture
- [ ] Proper separation of concerns
- [ ] No unnecessary coupling
- [ ] Appropriate abstractions

#### Code Quality
- [ ] Clear, descriptive naming
- [ ] Functions have single responsibility
- [ ] Appropriate error handling
- [ ] No code duplication
- [ ] Comments explain "why", not "what"

#### Performance
- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] Appropriate caching if needed
- [ ] No memory leaks

#### Security
- [ ] Input validation present
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Secrets not committed
- [ ] Authorization checks in place

#### Testing
- [ ] New functionality has tests
- [ ] Tests are meaningful
- [ ] Edge cases covered
- [ ] Tests are maintainable

### 3. Specific File Analysis

Review key files in detail:

!`for file in $(gh pr diff --name-only | head -5); do echo "---"; echo "File: $file"; echo "Changes:"; gh pr diff -- "$file" | head -50; done`

### 4. Review Comments

Check existing review comments:

!`gh pr view --json reviews -q '.reviews[] | "[\(.state)] \(.author.login): \(.body)"' | head -10`

### 5. CI/CD Status

!`gh pr checks`

## Review Output Format

Provide review in this structure:

### Summary
[2-3 sentences on overall assessment]

### Strengths
- [What's done well]
- [Good patterns used]

### Issues Found

#### Critical (Must Fix)
- [ ] [Issue description] - `file.ts:123`

#### Major (Should Fix)
- [ ] [Issue description] - `file.ts:45`

#### Minor (Consider)
- [ ] [Issue description] - `file.ts:67`

### Recommendations
1. [Specific actionable recommendation]
2. [Another recommendation]

### Questions
- [Question about approach or design]
- [Another question]

### Approval Status
[Approve | Request Changes | Comment]

## Review Guidelines

**Critical Issues** (block approval):
- Security vulnerabilities
- Data loss risks
- Breaking changes without migration
- Missing critical tests

**Major Issues** (strong request for changes):
- Poor error handling
- Performance problems
- Significant code quality issues
- Missing important tests

**Minor Issues** (suggestions):
- Naming improvements
- Refactoring opportunities
- Additional test coverage
- Documentation enhancements

## Commands for Reviewer

After completing review, suggest next steps:

\`\`\`bash
# Approve PR
gh pr review --approve

# Request changes
gh pr review --request-changes --body "Review comments above"

# Add comment without approval
gh pr review --comment --body "Looks good, minor suggestions above"

# Check out PR locally for testing
gh pr checkout

# View PR in browser
gh pr view --web
\`\`\`
```

---

## Example 4: Bundled Skill with Templates

**Use case**: Generate test files from templates

```yaml
---
name: generate-tests
description: Generate comprehensive test files. Use when user asks to "write tests", "create tests", "add test coverage", mentions "unit tests", or discusses testing.
disable-model-invocation: true
allowed-tools: Read, Write, Bash
---

# Test Generator

Generate comprehensive test files following project patterns.

## Usage

\`/generate-tests path/to/file.ts\`

## Process

### 1. Analyze Source File

Read the target file and identify:
- Exported functions/classes
- Function signatures and parameters
- Edge cases and error conditions
- External dependencies to mock

### 2. Detect Test Framework

Check project configuration:

!`if [ -f "jest.config.js" ] || grep -q "jest" package.json 2>/dev/null; then echo "jest"; elif [ -f "vitest.config.ts" ] || grep -q "vitest" package.json 2>/dev/null; then echo "vitest"; else echo "unknown"; fi`

### 3. Select Template

Based on source file type and test framework:

- **React Component**: [templates/react-component-test.template](templates/react-component-test.template)
- **Service/Class**: [templates/service-test.template](templates/service-test.template)
- **Utility Functions**: [templates/utils-test.template](templates/utils-test.template)
- **API Handler**: [templates/api-handler-test.template](templates/api-handler-test.template)

### 4. Generate Test File

1. Apply template
2. Generate test cases for each function
3. Add mock setup for dependencies
4. Include edge case tests
5. Add integration tests if applicable

### 5. Validate

Run generated tests:

\`\`\`bash
npm test -- path/to/file.test.ts
\`\`\`

## Template Variables

Templates use these substitutions:

- \`{{FILE_NAME}}\`: Source file name
- \`{{IMPORT_PATH}}\`: Relative import path
- \`{{COMPONENT_NAME}}\`: Component/class name
- \`{{FUNCTIONS}}\`: List of functions to test
- \`{{MOCKS}}\`: Generated mock setup

## Example Output

See [examples/generated-tests/](examples/generated-tests/) for sample outputs.

## Coverage Goals

Aim for:
- 80%+ line coverage
- All public functions tested
- Edge cases covered
- Error conditions tested
- Integration scenarios included

## Common Test Patterns

See [references/test-patterns.md](references/test-patterns.md) for comprehensive patterns.
```

---

## Example 5: Research/Exploration Skill

**Use case**: Deep codebase analysis

```yaml
---
name: analyze-architecture
description: Analyze and document codebase architecture. Use when user asks to "analyze architecture", "document structure", "explain codebase", mentions "architectural overview", or discusses code organization.
context: fork  # Run in isolated subagent
agent: Explore
allowed-tools: Read, Grep, Glob, Bash
---

# Architecture Analyzer

Perform deep analysis of codebase architecture and generate documentation.

## Exploration Process

### Phase 1: Project Structure Discovery

1. **Identify project type**
   - Check for package.json, pyproject.toml, go.mod, etc.
   - Detect frameworks and main dependencies
   - Understand build system

2. **Map directory structure**
   - Locate source code directories
   - Identify configuration files
   - Find test directories
   - Map public/static assets

3. **Analyze entry points**
   - Main application files
   - API routes/endpoints
   - CLI commands
   - Background workers

### Phase 2: Code Organization Analysis

1. **Module boundaries**
   - Identify logical modules/packages
   - Map dependencies between modules
   - Detect circular dependencies

2. **Design patterns**
   - Identify architectural patterns (MVC, MVVM, Clean Architecture, etc.)
   - Find factory, singleton, observer patterns
   - Document state management approach

3. **Data flow**
   - Trace data from input to storage
   - Identify API boundaries
   - Map external service integrations

### Phase 3: Component Analysis

1. **Core components**
   - Authentication/authorization
   - Database layer
   - API layer
   - Business logic
   - UI components (if applicable)

2. **Infrastructure**
   - Configuration management
   - Logging and monitoring
   - Error handling
   - Caching strategies

### Phase 4: Documentation Generation

Generate comprehensive architecture document including:

1. **Overview Diagram** (textual representation)
2. **Module Map** with responsibilities
3. **Data Flow** diagrams
4. **Key Design Decisions**
5. **Technology Stack**
6. **Patterns and Conventions**
7. **Integration Points**
8. **Areas for Improvement**

## Output Format

\`\`\`markdown
# Architecture Documentation

## Executive Summary
[High-level overview]

## Technology Stack
- Language: [detected]
- Framework: [detected]
- Database: [detected]
- Key Libraries: [list]

## Project Structure

\`\`\`
src/
├── components/     # [purpose]
├── services/       # [purpose]
├── utils/          # [purpose]
└── ...
\`\`\`

## Architectural Patterns

### Primary Pattern: [Name]
[Description and rationale]

### Supporting Patterns
- [Pattern name]: [Usage]

## Core Components

### Component: [Name]
- **Purpose**: [What it does]
- **Location**: [File paths]
- **Dependencies**: [What it depends on]
- **Dependents**: [What depends on it]

## Data Flow

\`\`\`
User Request
    ↓
[Component 1]
    ↓
[Component 2]
    ↓
Database
\`\`\`

## Integration Points

### External Services
- [Service name]: [Purpose, how integrated]

### APIs Exposed
- [Endpoint]: [Purpose]

## Key Design Decisions

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]

## Code Quality Observations

### Strengths
- [Observation]

### Areas for Improvement
- [Observation]

## Recommendations

1. [Actionable recommendation]
2. [Actionable recommendation]
\`\`\`

## Analysis Depth

Adjust thoroughness based on codebase size:
- Small (<100 files): Analyze all files
- Medium (100-500 files): Sample representative files
- Large (500+ files): Focus on entry points and key modules
```

---

## Summary

These examples demonstrate the five main skill categories:

1. **Reference Skills**: Background knowledge Claude applies automatically
2. **Task Workflow Skills**: Multi-step processes with clear execution
3. **Dynamic Context Skills**: Leverage live data via shell commands
4. **Bundled Skills**: Include templates, examples, scripts
5. **Research Skills**: Deep exploration in isolated context

Key patterns across all examples:
- Clear, specific descriptions with trigger phrases
- Appropriate invocation control flags
- Tool restrictions matching actual needs
- Structured, organized content
- Supporting file references
- Concrete examples and patterns
