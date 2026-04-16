# RDS Setup Skill - Validation Report

**Date:** 2026-04-16  
**Module:** RDS (R Data Science)  
**Setup Skill:** rds-setup  
**Validator:** Claude (BMad Module Builder)  
**Status:** 🔴 **INCOMPLETE - MISSING CRITICAL INFRASTRUCTURE**

---

## Executive Summary

The **rds-setup** skill is currently incomplete and cannot properly install/register the RDS module. While the module content in `_bmad/rds/` is production-ready (as confirmed by VALIDATION-FINAL.md), the setup skill itself is missing all required infrastructure files.

**Overall Status:** 🔴 **FAIL - NOT FUNCTIONAL**  
**Compliance Score:** 25/100 (Grade F)

---

## Critical Issues Found

### 🔴 CRITICAL: Missing Required Files

The rds-setup skill is missing **ALL** required infrastructure:

| Required File | Status | Severity |
|--------------|--------|----------|
| `assets/module.yaml` | ❌ MISSING | CRITICAL |
| `assets/module-help.csv` | ❌ MISSING | CRITICAL |
| `scripts/merge-config.py` | ❌ MISSING | CRITICAL |
| `scripts/merge-help-csv.py` | ❌ MISSING | CRITICAL |
| `SKILL.md` | ✅ EXISTS | OK |

**Impact:** Without these files, the rds-setup skill cannot:
- Register the module in the BMad help system
- Merge module config into user's _bmad/config.yaml
- Provide discoverable menu commands
- Properly install the module

---

## Current Structure

### What Exists ✅

```
.claude/skills/rds-setup/
└── SKILL.md                    ✅ Present (3,756 bytes)
```

### What's Missing ❌

```
.claude/skills/rds-setup/
├── SKILL.md                    ✅ (exists)
├── assets/                     ❌ MISSING DIRECTORY
│   ├── module.yaml            ❌ CRITICAL
│   └── module-help.csv        ❌ CRITICAL
└── scripts/                    ❌ MISSING DIRECTORY
    ├── merge-config.py        ❌ CRITICAL
    └── merge-help-csv.py      ❌ CRITICAL
```

---

## Required Files Specification

### 1. `assets/module.yaml`

**Purpose:** Module metadata and configuration variables

**Required Fields:**
- `code: rds` - Module identifier
- `name: "RDS: R Data Science"` - Display name
- `description: "..."` - Brief description
- `module_version: 1.0.0` - Version tracking
- `default_selected: false` - Auto-install preference
- `module_greeting: "..."` - Post-install message

**Example Structure:**
```yaml
code: rds
name: "RDS: R Data Science"
description: "10-Phase Framework for R Data Science Excellence"
module_version: 1.0.0
default_selected: false
module_greeting: >
  🎉 RDS Module Installed Successfully!
  
  The R Data Science module is now available with 4 specialized agents.
  Start with /ada for project setup, /grace for EDA, /alan for modeling, 
  or /marie for reporting and deployment.
  
  See _bmad/rds/README.md for full documentation.

# Optional: Module-specific config variables
rds_workflows_path:
  prompt: "Path for RDS workflows?"
  default: "{project-root}/_bmad/rds/workflows"
  result: "{project-root}/_bmad/rds/workflows"
```

---

### 2. `assets/module-help.csv`

**Purpose:** Register the setup skill in BMad's help system

**Required Columns:**
- `module` - "RDS: R Data Science"
- `skill` - "rds-setup"
- `display-name` - "Setup RDS Module"
- `menu-code` - "SR" (suggested)
- `description` - What the skill does
- `action` - "configure" or "install"
- `args` - Arguments accepted
- `phase` - "anytime"
- `after` - Dependencies (if any)
- `before` - What should come after
- `required` - true/false
- `output-location` - Where files are created
- `outputs` - What gets created

**Example Entry:**
```csv
module,skill,display-name,menu-code,description,action,args,phase,after,before,required,output-location,outputs
RDS: R Data Science,rds-setup,Setup RDS Module,SR,"Install and configure the RDS module with 4 specialized agents for R data science.",configure,"{inline: skip prompts with provided values}",anytime,,,false,{project-root}/_bmad/rds,config and agents
```

---

### 3. `scripts/merge-config.py`

**Purpose:** Merge module.yaml config into user's _bmad/config.yaml

**Behavior:**
- Reads `assets/module.yaml`
- Prompts user for each config variable (unless headless/inline mode)
- Merges results into `{project-root}/_bmad/config.yaml`
- Creates backup before modifying
- Handles conflicts (module.yaml vs existing config)

**Must support:**
- `--headless` flag - No prompts, use defaults
- `--inline` flag - Accept values from command line
- Variable interpolation ({project-root}, {user_name}, etc.)

---

### 4. `scripts/merge-help-csv.py`

**Purpose:** Merge module-help.csv into global help system

**Behavior:**
- Reads `assets/module-help.csv`
- Merges into `{project-root}/_bmad/help.csv` (or creates if missing)
- Prevents duplicates
- Validates CSV integrity
- Updates menu code mappings

**Must support:**
- `--headless` flag - Silent operation
- Duplicate detection
- CSV validation

---

## SKILL.md Quality Assessment

### ✅ Strengths

1. **Clear overview** - Explains what RDS module provides
2. **Agent descriptions** - Lists all 4 agents with roles
3. **Workflow coverage** - Documents all 7 core workflows
4. **Installation steps** - Outlines what happens on invocation
5. **Success message** - Well-formatted post-install message
6. **Quick start guide** - Clear usage examples

### 🟡 Issues

1. **No actual installation logic** - SKILL.md describes what *should* happen but has no mechanism to execute it
2. **Missing script calls** - No references to merge-config.py or merge-help-csv.py
3. **No validation checks** - Describes verification steps but no implementation
4. **Outdated module path reference** - Says "requires existing R skills in BMAD" but doesn't verify this

---

## Impact Assessment

### What Works ✅

- User can invoke `/rds-setup`
- Skill description loads
- User sees what the module should provide

### What Doesn't Work ❌

- ❌ Module config NOT merged into _bmad/config.yaml
- ❌ Skill NOT registered in help system
- ❌ No menu codes available
- ❌ Module NOT discoverable via /help
- ❌ No validation that _bmad/rds/ exists
- ❌ No confirmation that agents are available
- ❌ User has no programmatic way to "install" the module

**Result:** The skill is essentially **documentation-only**. It tells users what RDS provides but doesn't actually install or configure anything.

---

## Recommendations

### Priority 1: Create Missing Infrastructure (CRITICAL)

**Required Actions:**
1. Create `assets/module.yaml` with RDS config
2. Create `assets/module-help.csv` with setup skill entry
3. Copy `merge-config.py` from bmad-bmb-setup (adapt for RDS)
4. Copy `merge-help-csv.py` from bmad-bmb-setup (adapt for RDS)

**Estimated Effort:** 30-45 minutes

---

### Priority 2: Update SKILL.md Logic (HIGH)

**Required Changes:**
1. Add `<activation>` block that calls merge scripts
2. Add validation checks for _bmad/rds/ directory
3. Add agent availability verification
4. Add error handling for missing dependencies

**Example Activation Block:**
```markdown
## On Activation

1. **Validate module exists:**
   - Check `_bmad/rds/` directory exists
   - Check `_bmad/rds/config.yaml` exists
   - Check `_bmad/rds/agents/` contains 4 agent files

2. **Merge configuration:**
   ```bash
   python3 .claude/skills/rds-setup/scripts/merge-config.py
   ```

3. **Register in help system:**
   ```bash
   python3 .claude/skills/rds-setup/scripts/merge-help-csv.py
   ```

4. **Display success message**

5. **Verify installation:**
   - Config merged? ✅
   - Help entries added? ✅
   - Agents callable? ✅
```

**Estimated Effort:** 15-20 minutes

---

### Priority 3: Add Agent Registration (MEDIUM)

**Required:**
- Mechanism to make agents callable as `/ada`, `/grace`, `/alan`, `/marie`
- Could use symlinks in .claude/skills/ pointing to _bmad/rds/agents/
- Or extend BMad's skill discovery to recognize _bmad/*/agents/ directories

**Estimated Effort:** 20-30 minutes

---

## Comparison with Working Setup Skills

### bmad-bmb-setup (Reference Implementation) ✅

```
.claude/skills/bmad-bmb-setup/
├── SKILL.md                    ✅
├── assets/
│   ├── module.yaml            ✅
│   └── module-help.csv        ✅
└── scripts/
    ├── merge-config.py        ✅
    ├── merge-help-csv.py      ✅
    └── cleanup-legacy.py      ✅
```

**Status:** Complete, functional, production-ready

### rds-setup (Current) ❌

```
.claude/skills/rds-setup/
└── SKILL.md                    ✅ (but incomplete logic)
```

**Status:** Incomplete, non-functional, not usable

---

## Validation Checklist

### ❌ Critical Requirements (0/5 Met)

- [ ] Module.yaml exists and is valid
- [ ] Module-help.csv exists with complete entries
- [ ] merge-config.py script exists and works
- [ ] merge-help-csv.py script exists and works
- [ ] SKILL.md has activation logic that calls scripts

### ⚠️ Quality Standards (2/5 Met)

- [x] SKILL.md clearly describes module purpose
- [ ] Installation process is automated
- [ ] Validation checks verify successful installation
- [ ] Error messages guide user to fix issues
- [x] Success message confirms what was installed

### ⚠️ Integration Points (1/4 Met)

- [x] Module content exists in _bmad/rds/
- [ ] Setup skill can discover and validate module content
- [ ] Agents are made callable after installation
- [ ] Help system updated with module entries

**Overall:** 3/14 checks passing (21%)

---

## Next Steps

### Immediate Action Required

To make rds-setup functional, execute in this order:

1. **Create assets/module.yaml** (5 min)
   - Copy structure from bmad-bmb-setup
   - Adapt for RDS module
   - Include module greeting message

2. **Create assets/module-help.csv** (5 min)
   - Single row entry for rds-setup skill
   - Menu code: "SR" (Setup RDS)
   - Action: "configure"

3. **Copy and adapt merge scripts** (15 min)
   - Copy merge-config.py from bmad-bmb-setup
   - Copy merge-help-csv.py from bmad-bmb-setup
   - Update paths for rds-setup
   - Test both scripts

4. **Update SKILL.md** (10 min)
   - Add activation block with script calls
   - Add validation checks
   - Add error handling

5. **Test installation** (5 min)
   - Run `/rds-setup`
   - Verify config merged
   - Verify help entries added
   - Verify agents callable

**Total Time:** ~40 minutes

---

## Conclusion

The RDS module content is excellent (Grade A+), but the setup skill is incomplete (Grade F). Without the required infrastructure files, users cannot properly install or use the module.

**Status:** 🔴 **NOT FUNCTIONAL**  
**Compliance Score:** 25/100  
**Recommendation:** **COMPLETE INFRASTRUCTURE BEFORE RELEASE**

The gap between a production-ready module and a functional setup skill is small (~40 minutes of work) but critical. Once infrastructure is added, the module will be fully usable.

---

**Validation Completed:** 2026-04-16  
**Validator:** Claude (BMad Module Builder)  
**Next Action:** Create missing infrastructure files  
**Estimated Time to Production:** 40 minutes
