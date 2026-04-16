# Skill Patterns Reference

Comprehensive patterns and techniques for building effective Claude Code skills.

## Table of Contents

1. [Description Patterns](#description-patterns)
2. [Argument Handling](#argument-handling)
3. [Dynamic Context Injection](#dynamic-context-injection)
4. [Tool Restriction Patterns](#tool-restriction-patterns)
5. [Invocation Control Patterns](#invocation-control-patterns)
6. [File Organization Patterns](#file-organization-patterns)
7. [Error Handling](#error-handling)
8. [Performance Optimization](#performance-optimization)

---

## Description Patterns

### Pattern: Multi-Trigger Description

**Use when:** Skill can be invoked in multiple ways

```yaml
description: |
  Generate API documentation from code.
  Use when user asks to "document the API", "create API docs",
  "generate OpenAPI spec", mentions "Swagger" or "API documentation",
  or discusses documenting endpoints.
```

**Key elements:**
- Action verb first ("Generate", "Analyze", "Create")
- 3-5 specific trigger phrases in quotes
- 2-3 relevant keywords without quotes
- Topic area description

### Pattern: Contextual Trigger

**Use when:** Skill applies in specific situations

```yaml
description: |
  Apply security best practices when working with authentication,
  authorization, or sensitive data. Use when user mentions "auth",
  "security", "password", "token", or works on files in auth/ directory.
```

### Pattern: Task-Specific Trigger

**Use when:** Skill is for specific user-invoked tasks

```yaml
description: |
  Deploy application to staging environment.
  Use when user asks to "deploy to staging", "push to staging",
  or says "deploy staging".
```

### Pattern: Always-Active Background Knowledge

**Use when:** Skill provides conventions Claude should always follow

```yaml
description: |
  Code style and formatting conventions for this project.
  Apply these standards when writing or modifying code.
user-invocable: false  # Claude-only
```

---

## Argument Handling

### Pattern: Positional Arguments

```yaml
# In frontmatter
argument-hint: [component-name] [source-framework] [target-framework]
```

```markdown
# In skill content
Migrate the $0 component from $1 to $2 framework.

**Arguments:**
- $0 or $ARGUMENTS[0]: Component name
- $1 or $ARGUMENTS[1]: Source framework
- $2 or $ARGUMENTS[2]: Target framework
```

**Usage:** `/migrate SearchBar React Vue`

### Pattern: All Arguments as String

```markdown
Process the following request: $ARGUMENTS

This approach works when you want Claude to interpret
the entire argument string flexibly.
```

**Usage:** `/custom-command do something complex with multiple words`

### Pattern: Optional Arguments with Defaults

```markdown
Generate tests for ${1:-all components} using ${2:-jest}.

- ${1:-default}: Uses argument 1, or "default" if not provided
- $1: Uses argument 1, empty string if not provided
```

### Pattern: Argument Validation

```markdown
## Arguments

$0 - Feature name (required, must be kebab-case)
$1 - Feature type (required, one of: component|service|api|page)

## Validation

Before proceeding:
1. Verify $0 is in kebab-case format
2. Verify $1 is one of the allowed types
3. If validation fails, explain requirements and ask user to retry
```

### Pattern: Flexible Argument Parsing

```markdown
## Argument Parsing

Arguments can be provided as:
- Individual words: `/command arg1 arg2 arg3`
- Quoted phrases: `/command "some phrase" arg2`
- All interpreted: $ARGUMENTS

Parse based on context and user intent.
```

---

## Dynamic Context Injection

### Pattern: Git Context

```markdown
## Current Repository Context

- **Repository**: !`git remote get-url origin 2>/dev/null || echo "No remote configured"`
- **Branch**: !`git branch --show-current 2>/dev/null || echo "Not a git repository"`
- **Status**: !`git status --short 2>/dev/null | head -10 || echo "No changes"`
- **Recent commits**:
!`git log --oneline -5 2>/dev/null || echo "No commits"`
```

### Pattern: Project Detection

```markdown
## Project Type Detection

- **Package manager**: !`[ -f "package-lock.json" ] && echo "npm" || [ -f "yarn.lock" ] && echo "yarn" || [ -f "pnpm-lock.yaml" ] && echo "pnpm" || [ -f "bun.lockb" ] && echo "bun" || echo "unknown"`
- **Language**: !`[ -f "package.json" ] && echo "JavaScript/TypeScript" || [ -f "pyproject.toml" ] && echo "Python" || [ -f "go.mod" ] && echo "Go" || [ -f "Cargo.toml" ] && echo "Rust" || echo "Unknown"`
- **Framework**: !`cat package.json 2>/dev/null | grep -E '"(next|react|vue|angular|express|fastapi)"' | head -1 | sed 's/.*"\(.*\)".*/\1/' || echo "Not detected"`
```

### Pattern: GitHub PR Context

```markdown
## Pull Request Context

!`if ! gh pr view &>/dev/null; then echo "Error: Not in a PR context. Run this from a branch with an open PR, or specify PR number."; exit 1; fi`

- **PR Number**: !`gh pr view --json number -q .number`
- **Title**: !`gh pr view --json title -q .title`
- **Author**: !`gh pr view --json author -q .author.login`
- **Status**: !`gh pr view --json state,isDraft -q 'if .isDraft then "Draft" else .state end'`
- **Base**: !`gh pr view --json baseRefName -q .baseRefName`
- **Head**: !`gh pr view --json headRefName -q .headRefName`
- **Changed files**:
!`gh pr diff --name-only`
```

### Pattern: Environment Detection

```markdown
## Environment Context

- **OS**: !`uname -s`
- **Shell**: !`echo $SHELL | sed 's/.*\///'`
- **Node version**: !`node --version 2>/dev/null || echo "Not installed"`
- **Python version**: !`python3 --version 2>/dev/null || echo "Not installed"`
- **Git version**: !`git --version 2>/dev/null | sed 's/git version //' || echo "Not installed"`
```

### Pattern: File-Based Context

```markdown
## Configuration Context

### Package.json
!`cat package.json 2>/dev/null | head -20 || echo "No package.json found"`

### Dependencies of Interest
- **Testing**: !`cat package.json 2>/dev/null | grep -E '"(jest|vitest|mocha|jasmine)"' || echo "None"`
- **Linting**: !`cat package.json 2>/dev/null | grep -E '"(eslint|prettier)"' || echo "None"`
- **Framework**: !`cat package.json 2>/dev/null | grep -E '"(react|vue|angular|next)"' || echo "None"`
```

### Pattern: Conditional Context

```markdown
## Build System

!`if [ -f "package.json" ]; then
  echo "### NPM Scripts"
  cat package.json | grep -A 20 '"scripts"' | head -15
elif [ -f "Makefile" ]; then
  echo "### Make Targets"
  grep "^[a-zA-Z].*:" Makefile | head -10
elif [ -f "justfile" ]; then
  echo "### Just Recipes"
  grep "^[a-zA-Z].*:" justfile | head -10
else
  echo "No build system detected"
fi`
```

### Pattern: Batch Data Collection

```markdown
## Comprehensive Project Context

!`echo "=== Project Type ==="
ls -1 package.json pyproject.toml go.mod Cargo.toml 2>/dev/null | head -1

echo -e "\n=== Git Status ==="
git status --short 2>/dev/null | head -5 || echo "Not a git repo"

echo -e "\n=== Directory Structure ==="
ls -d */ 2>/dev/null | head -10 || echo "No subdirectories"

echo -e "\n=== Entry Points ==="
ls -1 main.* index.* app.* server.* 2>/dev/null || echo "No obvious entry point"`
```

---

## Tool Restriction Patterns

### Pattern: Read-Only Research

```yaml
allowed-tools: Read, Grep, Glob, Bash(git log:*), Bash(git diff:*)
```

**Use for:** Analysis, research, documentation generation

### Pattern: Safe Modification

```yaml
allowed-tools: Read, Write, Edit, Grep, Glob
```

**Use for:** Code generation, file updates (no shell execution)

### Pattern: Test Execution

```yaml
allowed-tools: Read, Bash(npm test:*), Bash(npm run test:*)
```

**Use for:** Running tests without modification permissions

### Pattern: Git Operations

```yaml
allowed-tools: Read, Bash(git status:*), Bash(git diff:*), Bash(git log:*)
```

**Use for:** Git information gathering without commits/pushes

### Pattern: Build Operations

```yaml
allowed-tools: Read, Bash(npm run build:*), Bash(npm run dev:*)
```

**Use for:** Build and development server management

### Pattern: PR Operations

```yaml
allowed-tools: Bash(gh pr:*), Bash(gh issue:*), Read
```

**Use for:** GitHub PR and issue management

### Pattern: Full Automation

```yaml
allowed-tools: Read, Write, Edit, Bash
```

**Use for:** Complete workflows with validation that need full access

### Pattern: Specific Commands Only

```yaml
allowed-tools: |
  Read, Write, Edit,
  Bash(npm test:*),
  Bash(git status:*),
  Bash(git diff:*),
  Bash(git add:*),
  Bash(git commit:*)
```

**Use for:** Precise control over allowed operations

---

## Invocation Control Patterns

### Pattern: User-Only Task (Side Effects)

```yaml
name: deploy-production
description: Deploy application to production environment.
disable-model-invocation: true  # Only user can invoke
```

**Use for:** Deployments, deletions, commits, publishes

### Pattern: Claude-Only Knowledge

```yaml
name: coding-conventions
description: Project coding standards and conventions.
user-invocable: false  # Only Claude can use
```

**Use for:** Background knowledge, conventions, patterns

### Pattern: Both Can Invoke (Default)

```yaml
name: analyze-code
description: Analyze code quality and suggest improvements.
# No invocation flags - both can invoke
```

**Use for:** Research, analysis, information gathering

### Pattern: Conditional User Access

```yaml
name: review-pr
description: Review pull request with detailed checklist.
# User can invoke manually OR Claude when user discusses PR
```

**Use for:** Workflows that should be available both ways

---

## File Organization Patterns

### Pattern: Minimal Skill (< 200 lines)

```
skill-name/
└── SKILL.md
```

**Use when:** Simple reference or straightforward workflow

### Pattern: Standard Skill (200-500 lines)

```
skill-name/
├── SKILL.md           # Main instructions
└── examples/
    └── example.md     # 1-2 examples
```

**Use when:** Skill benefits from examples but no templates needed

### Pattern: Bundled Skill (> 500 lines total)

```
skill-name/
├── SKILL.md                    # Core instructions (< 500 lines)
├── README.md                   # User documentation
├── templates/
│   ├── template1.md
│   └── template2.md
├── examples/
│   ├── example1.md
│   └── example2.md
├── references/
│   ├── detailed-patterns.md   # Detailed reference material
│   └── api-reference.md
└── scripts/
    ├── preprocess.sh
    └── validate.sh
```

**Use when:** Complex skill with templates, multiple patterns, scripts

### Pattern: Template Organization

```
templates/
├── base-template.md           # Common base
├── variant-1.md               # Specific variant
├── variant-2.md               # Another variant
└── README.md                  # Template usage guide
```

### Pattern: Examples Organization

```
examples/
├── simple/
│   └── basic-usage.md
├── advanced/
│   └── complex-scenario.md
└── README.md                  # Examples overview
```

### Pattern: Scripts Organization

```
scripts/
├── analyze.sh                 # Data collection
├── validate.sh                # Output validation
├── format.sh                  # Output formatting
└── README.md                  # Scripts documentation
```

---

## Error Handling

### Pattern: Command Error Handling

```markdown
## Context Gathering

- **Git remote**: !`git remote get-url origin 2>/dev/null || echo "No remote configured"`
- **Current branch**: !`git branch --show-current 2>/dev/null || echo "Not in git repository"`
```

**Key:** Use `2>/dev/null || echo "fallback"` for graceful failures

### Pattern: Prerequisite Checking

```markdown
## Prerequisites Check

!`if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub."
    echo "Run: gh auth login"
    exit 1
fi

echo "✓ Prerequisites met"`
```

### Pattern: Validation Before Execution

```markdown
## Validation

Before proceeding:

1. **Verify arguments**
   - Check $0 is not empty
   - Validate $1 is expected format
   - Confirm $2 is valid option

2. **Check environment**
   - Verify required tools installed
   - Confirm necessary files exist
   - Check permissions

If validation fails:
- Explain what's wrong
- Show expected format
- Ask user to correct and retry
```

### Pattern: Graceful Degradation

```markdown
## Optional Context

Try to gather enhanced context, fall back if unavailable:

- **PR info**: !`gh pr view --json title -q .title 2>/dev/null || echo "(Not in PR context - proceeding without PR info)"`
- **CI status**: !`gh pr checks 2>/dev/null || echo "(CI info unavailable)"`
```

### Pattern: User Feedback on Errors

```markdown
## Error Handling

If any step fails:

1. **Identify the error**
   - Show the specific failure
   - Explain what was attempted

2. **Suggest remediation**
   - Provide specific fix steps
   - Offer alternative approaches

3. **Ask before retrying**
   - Don't auto-retry without user input
   - Propose next steps
```

---

## Performance Optimization

### Pattern: Batch Command Execution

```markdown
## Context Collection

!`{
  echo "=== Project Type ==="
  ls package.json pyproject.toml 2>/dev/null | head -1

  echo -e "\n=== Git Info ==="
  git branch --show-current 2>/dev/null
  git status --short 2>/dev/null | head -5

  echo -e "\n=== Dependencies ==="
  cat package.json 2>/dev/null | grep -E '"(react|vue|next)"'
}`
```

**Benefits:** Single shell invocation vs. multiple commands

### Pattern: Lazy Context Loading

```markdown
# Main SKILL.md - Keep minimal

For detailed patterns, see [references/patterns.md](references/patterns.md)
For API reference, see [references/api-reference.md](references/api-reference.md)
```

**Benefits:** Supporting files loaded only when Claude needs them

### Pattern: Cached Results

```markdown
## Build Information

!`if [ -f ".skill-cache/build-info.txt" ] && [ $(find ".skill-cache/build-info.txt" -mmin -5) ]; then
    cat ".skill-cache/build-info.txt"
else
    mkdir -p ".skill-cache"
    npm run build -- --dry-run 2>&1 | tee ".skill-cache/build-info.txt"
fi`
```

**Benefits:** Cache expensive operations (5 minute TTL in this example)

### Pattern: Conditional Detail Level

```markdown
## Analysis Depth

Determine appropriate depth based on codebase size:

!`file_count=$(find . -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l | tr -d ' ')
if [ $file_count -lt 50 ]; then
    echo "FULL - Analyze all files"
elif [ $file_count -lt 200 ]; then
    echo "SAMPLE - Analyze representative files"
else
    echo "LIGHT - Focus on entry points only"
fi`
```

### Pattern: Efficient File Filtering

```markdown
## Target Files

!`# More efficient than separate finds
find . -type f \( -name "*.ts" -o -name "*.tsx" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/dist/*" \
  -not -path "*/.next/*" \
  | head -20`
```

### Pattern: Subagent Delegation

```yaml
name: deep-analysis
description: Perform comprehensive codebase analysis.
context: fork          # Run in isolated subagent
agent: Explore        # Use specialized agent
```

**Benefits:** Keeps main context clean, parallel execution possible

---

## Advanced Patterns

### Pattern: Multi-Stage Workflow

```markdown
## Workflow Stages

### Stage 1: Discovery (Quick)
[Fast operations to gather basic info]

**Checkpoint:** Confirm approach before proceeding

### Stage 2: Analysis (Moderate)
[More detailed analysis based on Stage 1]

**Checkpoint:** Review findings

### Stage 3: Generation (Slow)
[Generate output based on previous stages]
```

### Pattern: Interactive Decision Points

```markdown
## Decision Point

Based on analysis, I can proceed with:

**Option A:** [Quick approach]
- Pros: [...]
- Cons: [...]

**Option B:** [Thorough approach]
- Pros: [...]
- Cons: [...]

**Which approach would you prefer?**
```

**Note:** Use AskUserQuestion tool for this, not manual questions

### Pattern: Template Selection Logic

```markdown
## Template Selection

Choose template based on context:

!`if grep -q "react" package.json 2>/dev/null; then
    echo "templates/react-component.md"
elif grep -q "vue" package.json 2>/dev/null; then
    echo "templates/vue-component.md"
else
    echo "templates/generic-component.md"
fi`

Selected template will be used for generation.
```

### Pattern: Incremental Generation

```markdown
## Generation Strategy

For large output:

1. **Generate structure first**
   - Create file skeleton
   - Add TODOs for sections

2. **Fill in sections incrementally**
   - Complete one section at a time
   - Validate each section

3. **Final polish**
   - Remove TODOs
   - Validate complete file
```

---

## Anti-Patterns to Avoid

### ❌ Anti-Pattern: Vague Description

```yaml
# Bad
description: Helpful skill for coding tasks

# Good
description: |
  Generate React components with TypeScript.
  Use when user asks to "create component", "new component",
  mentions "React component", or discusses component creation.
```

### ❌ Anti-Pattern: Monolithic SKILL.md

```markdown
# Bad: 2000 lines in SKILL.md
[Huge amount of content...]

# Good: Split into files
# Main SKILL.md (400 lines)
For patterns, see [references/patterns.md](references/patterns.md)
For API docs, see [references/api.md](references/api.md)
```

### ❌ Anti-Pattern: Unrestricted Tools for Limited Tasks

```yaml
# Bad
name: analyze-code
allowed-tools: Read, Write, Edit, Bash  # Too broad

# Good
name: analyze-code
allowed-tools: Read, Grep, Glob  # Appropriate for read-only analysis
```

### ❌ Anti-Pattern: Missing Error Handling

```markdown
# Bad
Current branch: !`git branch --show-current`

# Good
Current branch: !`git branch --show-current 2>/dev/null || echo "Not a git repository"`
```

### ❌ Anti-Pattern: No Supporting File References

```markdown
# Bad: Supporting files exist but not mentioned
[Main content...]

# Good: Explicit references
For detailed patterns, see [references/patterns.md](references/patterns.md)
```

---

## Testing Patterns

### Pattern: Manual Test Cases

After creating skill, test with:

```bash
# Test manual invocation
/skill-name arg1 arg2

# Test description triggers
# Use phrases from description in conversation
```

### Pattern: Validation Checklist

```markdown
- [ ] Frontmatter YAML is valid
- [ ] Description has 3+ trigger phrases
- [ ] All !`commands` use error handling
- [ ] Referenced files exist
- [ ] Tool restrictions match needs
- [ ] Invocation flags align with behavior
- [ ] Examples are concrete and clear
- [ ] SKILL.md is under 500 lines
```

---

## Summary

Key principles for effective skills:

1. **Specific descriptions** - Include trigger phrases users would actually say
2. **Appropriate scope** - Split large skills across files
3. **Error handling** - Always provide fallbacks for shell commands
4. **Tool restrictions** - Grant minimum necessary permissions
5. **Clear structure** - Organize with phases/sections
6. **Concrete examples** - Include 2-3 real examples
7. **Referenced files** - Explicitly link supporting files
8. **Performance** - Batch commands, lazy load details
