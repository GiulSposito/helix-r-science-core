# Basic Skill Template

Use this template as a starting point for creating new skills.

## Simple Reference Skill Template

```yaml
---
name: skill-name
description: [Action] when user [trigger conditions]. Use when user asks to "[phrase]", "[another phrase]", mentions "[keyword]", or discusses [topic].
user-invocable: false  # Optional: Claude-only background knowledge
---

# [Skill Name] - [One-line Purpose]

[2-3 sentence overview of what this skill does]

## Overview

[Detailed explanation of when and how to use this skill]

## Guidelines

### [Category 1]
- [Guideline]
- [Guideline]

### [Category 2]
- [Guideline]
- [Guideline]

## Examples

### Example 1: [Scenario]
\`\`\`
[Example code or pattern]
\`\`\`

### Example 2: [Scenario]
\`\`\`
[Example code or pattern]
\`\`\`

## Best Practices

- [Practice]
- [Practice]
```

---

## Task Workflow Skill Template

```yaml
---
name: task-name
description: [Action] when user asks to "[trigger phrase]". Use when [conditions].
disable-model-invocation: true  # User-only invocation
allowed-tools: Read, Write, Edit, Bash
---

# [Task Name] - [Purpose]

[Overview of what this task accomplishes]

## Usage

\`/task-name [arg1] [arg2]\`

**Arguments:**
- $0 or $ARGUMENTS[0]: [Description]
- $1 or $ARGUMENTS[1]: [Description]

**Example:**
\`/task-name example-arg another-arg\`

## Workflow

### Phase 1: [Phase Name]

1. **[Step name]**
   - [Sub-step]
   - [Sub-step]

2. **[Step name]**
   - [Sub-step]
   - [Sub-step]

### Phase 2: [Phase Name]

1. **[Step name]**
   - [Sub-step]
   - [Sub-step]

### Phase 3: [Phase Name]

1. **[Step name]**
   - [Sub-step]
   - [Sub-step]

## Validation

After completion:
- [ ] [Check item]
- [ ] [Check item]
- [ ] [Check item]

## Common Patterns

### Pattern 1: [Name]
\`\`\`
[Code or command example]
\`\`\`

### Pattern 2: [Name]
\`\`\`
[Code or command example]
\`\`\`
```

---

## Dynamic Context Skill Template

```yaml
---
name: context-skill
description: [Action using live data]. Use when [conditions].
allowed-tools: Bash(command *), Read, Grep
---

# [Skill Name] - [Purpose]

[Overview]

## Current Context

### [Context Category 1]
- **[Field]**: !`command to get value`
- **[Field]**: !`another command`

### [Context Category 2]
!`command that outputs multiple lines`

## Process

### 1. [Step name]
[Instructions using context above]

### 2. [Step name]
[More instructions]

## Output Format

Present results as:

### Summary
[High-level summary]

### Details
- [Detail item]
- [Detail item]

### Recommendations
1. [Recommendation]
2. [Recommendation]
```

---

## Bundled Skill Template

```yaml
---
name: bundled-skill
description: [Action] using templates and scripts. Use when [conditions].
allowed-tools: Read, Write, Bash
---

# [Skill Name] - [Purpose]

[Overview]

## Templates

This skill includes templates for:
- [Template name]: [templates/template-name.md](templates/template-name.md)
- [Template name]: [templates/another-template.md](templates/another-template.md)

## Process

### 1. [Step name]
[Instructions]

### 2. Generate from Template
Use the appropriate template based on [condition]:
- If [condition]: Use [template-name]
- If [condition]: Use [another-template]

### 3. [Step name]
Run validation script:
\`\`\`bash
${CLAUDE_SKILL_DIR}/scripts/validate.sh output-file
\`\`\`

## Examples

See [examples/](examples/) for sample outputs:
- [Example name]: [examples/example-1.md](examples/example-1.md)
- [Example name]: [examples/example-2.md](examples/example-2.md)

## Additional Resources

For detailed patterns, see [references/patterns.md](references/patterns.md)
```

---

## Research/Exploration Skill Template

```yaml
---
name: research-skill
description: Research and analyze [topic]. Use when user asks to [trigger conditions].
context: fork  # Run in isolated subagent
agent: Explore
allowed-tools: Read, Grep, Glob, Bash
---

# [Research Topic] Analyzer

Deep analysis and research of [topic].

## Research Process

### Phase 1: Discovery

1. **Identify [targets]**
   - Search for [pattern]
   - Locate [files/components]
   - Map [relationships]

2. **Gather context**
   - Read [files]
   - Extract [information]
   - Note [patterns]

### Phase 2: Analysis

1. **Analyze [aspect]**
   - [Analysis step]
   - [Analysis step]

2. **Identify [patterns]**
   - [Pattern detection]
   - [Pattern detection]

### Phase 3: Synthesis

1. **Compile findings**
   - [Synthesis step]
   - [Synthesis step]

2. **Generate report**
   - [Report section]
   - [Report section]

## Output Format

\`\`\`markdown
# [Research Topic] Analysis Report

## Summary
[High-level findings]

## Detailed Findings

### [Category 1]
[Findings]

### [Category 2]
[Findings]

## Patterns Identified
- [Pattern]: [Description]
- [Pattern]: [Description]

## Recommendations
1. [Recommendation with rationale]
2. [Recommendation with rationale]

## Next Steps
- [Action item]
- [Action item]
\`\`\`

## Research Scope

Adjust depth based on [criteria]:
- [Condition]: [Scope adjustment]
- [Condition]: [Scope adjustment]
```

---

## Template Selection Guide

Choose the appropriate template based on your skill type:

| Skill Type | Template | When to Use |
|------------|----------|-------------|
| **Reference** | Simple Reference | Conventions, patterns, standards Claude should always apply |
| **Task** | Task Workflow | Multi-step processes users invoke manually |
| **Context** | Dynamic Context | Skills that need live data from git, files, or commands |
| **Bundled** | Bundled Skill | Complex skills with templates, scripts, or examples |
| **Research** | Research/Exploration | Deep analysis that should run in isolation |

## Quick Start Checklist

When using a template:

1. [ ] Replace `skill-name` with your actual skill name (kebab-case)
2. [ ] Write specific, trigger-rich description
3. [ ] Choose appropriate invocation flags
4. [ ] List needed tools in `allowed-tools`
5. [ ] Fill in all `[placeholders]` with actual content
6. [ ] Add concrete examples
7. [ ] Include at least 2-3 specific patterns
8. [ ] Reference any supporting files
9. [ ] Test with trigger phrases

## Customization Tips

**For all templates:**
- Keep main SKILL.md under 500 lines
- Include 2-3 concrete examples
- Add specific trigger phrases to description
- Reference supporting files explicitly

**For reference skills:**
- Make them `user-invocable: false` (Claude-only)
- Focus on patterns and conventions
- Include decision trees or flowcharts

**For task skills:**
- Add `disable-model-invocation: true` (user-only)
- Break into clear phases
- Include validation steps
- Provide usage examples with arguments

**For context skills:**
- Test all shell commands work
- Add error handling with `|| echo "fallback"`
- Suppress errors with `2>/dev/null`
- Keep commands efficient

**For bundled skills:**
- Create supporting files in subdirectories
- Link to templates and examples explicitly
- Include script for validation/processing
- Show template variable usage

**For research skills:**
- Use `context: fork` and `agent: Explore`
- Limit tools to read-only
- Define clear output format
- Adjust scope based on project size
