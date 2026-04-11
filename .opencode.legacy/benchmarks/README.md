# NiXium Agent Benchmarks

**Purpose:** Measure agent onboarding effectiveness and task performance to validate OpenCode optimization work.

**Goal Metric:** Reduce onboarding from 80 messages/8 hours → 10 messages/5 minutes.

---

## Benchmark Categories

### 1. Architecture Understanding
- **Test:** Flake-parts vs standard NixOS comprehension
- **Success:** Agent correctly identifies where to add config without trial-and-error
- **Baseline:** ~30 messages of confusion about module imports

### 2. Security Pattern Recognition
- **Test:** Zero-trust principles, secret handling, PURITY tagging
- **Success:** Agent catches security issues proactively
- **Baseline:** Security issues discovered in review, not prevention

### 3. Contradictory Requirements Detection
- **Test:** Spot conflicting instructions or impossible constraints
- **Success:** Agent asks clarifying questions before implementing
- **Baseline:** Agents implement one requirement, break another

### 4. Realistic Task Completion
- **Test:** Add new service with proper testing, documentation, security
- **Success:** Complete task following all standards without extensive correction
- **Baseline:** 80 messages, 8 hours of back-and-forth

---

## Running Benchmarks

1. **Fresh session** - Start new OpenCode session with no prior context
2. **Present scenario** - Give agent one of the scenario files from `scenarios/`
3. **Measure metrics:**
   - Message count to completion
   - Time to completion
   - Errors caught vs missed
   - Documentation/testing quality
4. **Record results** - Update `results/<model-name>-YYYY-MM-DD.md`

---

## Benchmark Scenarios

| Scenario | File | Focus Area |
|----------|------|------------|
| Module Addition | `scenarios/01-add-module.md` | Flake-parts architecture |
| Security Hardening | `scenarios/02-security-service.md` | Zero-trust patterns |
| Conflicting Requirements | `scenarios/03-contradictory-task.md` | Critical thinking |
| Full Feature | `scenarios/04-complete-feature.md` | End-to-end workflow |

---

## Success Criteria

**Excellent (Target):**
- ≤10 messages to task completion
- ≤5 minutes elapsed time
- All security/quality checks passed
- Proper VM testing before proposal
- Clear documentation of approach

**Good:**
- ≤20 messages
- ≤15 minutes
- Minor corrections needed
- Most quality checks passed

**Needs Improvement:**
- >30 messages
- >30 minutes
- Major misunderstandings of architecture
- Skipped testing or security checks

---

## Baseline Metrics

**Before OpenCode optimization (Quest 02):**
- 80 messages of back-and-forth
- 8 hours of agent time
- Repeated misunderstandings about flake-parts
- Security issues caught in review, not prevention
- Extensive re-explanation of architecture

**Target after optimization:**
- 10 messages to completion
- 5 minutes elapsed time
- Self-directed task completion
- Proactive security awareness
- Architecture understood from documentation

See `baseline-metrics.md` for detailed pre-optimization data.
