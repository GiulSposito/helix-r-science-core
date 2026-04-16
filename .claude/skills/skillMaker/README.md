# SkillMaker - Claude Code Skill Generator

A comprehensive Claude Code skill for creating production-ready skills following best practices and established patterns.

## Overview

SkillMaker guides you through the entire skill creation process:
- Requirements gathering
- Structure decision
- Content generation
- Optimization
- Testing and validation

## Quick Start

Invoke the skill:

```bash
/skillMaker
```

Or just mention creating a skill in conversation:
- "Create a skill for..."
- "I want to make a new skill that..."
- "Help me build a skill to..."

## What This Skill Does

1. **Asks targeted questions** to understand your skill requirements
2. **Determines optimal structure** based on complexity
3. **Generates skill content** following patterns and conventions
4. **Creates supporting files** (templates, examples, references) as needed
5. **Applies optimizations** for performance and maintainability
6. **Validates** the generated skill

## Features

- **Template Library**: Pre-built templates for common skill types
- **Pattern Reference**: Comprehensive pattern catalog
- **Best Practices**: Built-in knowledge of skill conventions
- **Example Gallery**: Real-world skill examples
- **Interactive Guidance**: Step-by-step skill creation process

## Skill Types Supported

### 1. Reference/Conventions Skills
Background knowledge Claude applies automatically
- Coding standards
- API conventions
- Design patterns
- Style guides

### 2. Task Workflow Skills
Multi-step processes users invoke manually
- Feature creation
- Deployment workflows
- Code generation
- Documentation updates

### 3. Dynamic Context Skills
Skills that leverage live data
- PR reviews
- Git analysis
- Project scanning
- Build information

### 4. Bundled Skills
Complex skills with supporting files
- Code generators with templates
- Analyzers with reference docs
- Workflows with helper scripts

### 5. Research Skills
Deep exploration in isolated context
- Architecture analysis
- Codebase documentation
- Dependency mapping

## File Structure

```
.claude/skills/skillMaker/
├── SKILL.md                           # Main skill definition
├── README.md                          # This file
├── templates/
│   └── basic-skill-template.md       # Starting templates
├── examples/
│   └── skill-structures.md           # Complete examples
└── references/
    └── skill-patterns.md             # Pattern catalog
```

## Usage Examples

### Create a Simple Reference Skill

```
User: Create a skill for our API naming conventions

SkillMaker will:
1. Ask about trigger conditions
2. Determine it's a reference skill
3. Generate SKILL.md with conventions
4. Set user-invocable: false (Claude-only)
```

### Create a Task Workflow Skill

```
User: Make a skill to generate test files

SkillMaker will:
1. Ask about arguments needed
2. Identify it needs templates
3. Create bundled structure
4. Generate templates for different test types
5. Add validation scripts
```

### Create a Dynamic Context Skill

```
User: Build a skill for PR reviews

SkillMaker will:
1. Identify need for GitHub CLI commands
2. Add dynamic context injection
3. Generate review checklist
4. Set appropriate tool restrictions
```

## Configuration Generated

SkillMaker generates skills with optimal configuration:

```yaml
---
name: generated-skill-name
description: Specific triggers based on your requirements
version: 1.0.0
# Appropriate invocation flags
# Correct tool restrictions
# Optional: context, agent, model overrides
---
```

## Best Practices Applied

SkillMaker automatically applies:

- ✅ Specific, trigger-rich descriptions
- ✅ Appropriate file structure for complexity
- ✅ Tool restrictions matching actual needs
- ✅ Error handling in shell commands
- ✅ Supporting file organization
- ✅ Concrete examples
- ✅ Optimization patterns
- ✅ Validation checklist

## Supporting Files

### Templates

[templates/basic-skill-template.md](templates/basic-skill-template.md)
- Simple reference skill template
- Task workflow skill template
- Dynamic context skill template
- Bundled skill template
- Research skill template

### Examples

[examples/skill-structures.md](examples/skill-structures.md)
- Complete example skills
- Real-world implementations
- Different skill categories
- Pattern demonstrations

### References

[references/skill-patterns.md](references/skill-patterns.md)
- Description patterns
- Argument handling
- Dynamic context injection
- Tool restrictions
- Invocation control
- File organization
- Error handling
- Performance optimization

## Common Questions

**Q: How do I know what skill type to create?**
A: SkillMaker will ask questions to determine the best type. Generally:
- Reference: Background knowledge/conventions
- Task: User-invoked workflows
- Context: Needs live data from git/files
- Bundled: Complex with templates/scripts
- Research: Deep exploration

**Q: Should my skill be user-invocable, Claude-only, or both?**
A: SkillMaker will guide you:
- User-only: Side-effect tasks (deploy, commit, delete)
- Claude-only: Background knowledge (conventions, patterns)
- Both: Research, analysis, generation

**Q: How big should SKILL.md be?**
A: Keep under 500 lines. SkillMaker will create supporting files for larger content.

**Q: What tools should I allow?**
A: SkillMaker determines this based on your skill's needs:
- Read-only: Read, Grep, Glob
- Modification: Add Write, Edit
- Automation: Add Bash with restrictions

**Q: When should I use dynamic context (!`command`)?**
A: For live data that changes:
- Git status/branches/commits
- File contents
- Project detection
- PR information
- Build status

**Q: How do I test the generated skill?**
A: SkillMaker provides:
- Validation checklist
- Test invocation examples
- Trigger phrase testing guide

## Troubleshooting

**Skill doesn't auto-trigger:**
- Check description has specific trigger phrases
- Verify no `disable-model-invocation: true`
- Test with exact phrases from description

**Skill not in autocomplete:**
- Verify SKILL.md in correct location
- Check YAML frontmatter is valid
- Ensure no `user-invocable: false`

**Shell commands fail:**
- Add error handling: `2>/dev/null || echo "fallback"`
- Check commands available in environment
- Test commands independently first

## Tips for Success

1. **Be specific in requirements** - The more detail you provide, the better the generated skill
2. **Review generated content** - Customize for your specific needs
3. **Test thoroughly** - Try different invocation methods
4. **Iterate** - Refine description and content based on testing
5. **Start simple** - Can always add complexity later

## Related Documentation

- [Claude Code Skills Documentation](https://docs.anthropic.com/claude-code/skills)
- [Skill Best Practices Guide](https://docs.anthropic.com/claude-code/best-practices)
- [Example Plugin Skills](~/.claude/plugins/)

## Version History

- **1.0.0** (2026-03-08): Initial release
  - Complete skill generation workflow
  - Template library
  - Pattern reference
  - Example gallery

## Contributing

To improve SkillMaker:
1. Test with different skill types
2. Add new patterns to references/
3. Contribute templates for common use cases
4. Share example skills you've created

## License

Part of Claude Code extensibility system.

---

**Ready to create your first skill?** Just type `/skillMaker` or ask Claude to help you build a skill!
