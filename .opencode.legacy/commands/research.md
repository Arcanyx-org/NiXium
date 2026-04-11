# /research - Deep Research and Investigation

**Invokes:** `researcher` agent (DeepSeek Chat)

**Purpose:** Conduct thorough research, explore architecture, investigate issues, and document findings

## Usage

```bash
/research <question or investigation task>
```

## When to Use

Use `/research` when you need to:
- Understand how a system or component works
- Investigate why something behaves a certain way
- Explore multiple approaches to a problem
- Find patterns or anti-patterns in the codebase
- Gather context before making decisions
- Document historical context or architectural decisions

## Examples

```bash
# Architecture understanding
/research How does NiXium's impermanence implementation work?
/research Explain the flake-parts module structure for machines

# Pattern discovery
/research Find all instances of systemd hardening in the codebase
/research What patterns do we use for secret management?

# Investigation
/research Why is the router VM build failing with disko errors?
/research Trace how firewall rules are applied during boot

# Trade-off analysis
/research Compare writeShellApplication vs writeShellScriptBin
/research Should this be a shared module or machine-specific config?

# Historical context
/research Why was decision X made in iteration Y?
/research What security considerations led to zero-trust adoption?
```

## Expected Output

The researcher agent will provide:

1. **Summary** - 2-3 sentence answer to your question
2. **Detailed findings** - Evidence from code, docs, git history, or tests
3. **File references** - Specific paths and line numbers
4. **Recommendations** - If applicable, what to do next
5. **Open questions** - What's still unclear
6. **Memory update suggestion** - If findings should be preserved

## Output Format Example

```markdown
## Summary
NiXium uses impermanence via tmpfs root filesystem with explicit persistence. 
Only /nix/persist is preserved across reboots, everything else is ephemeral.

## Detailed Findings

Implementation is in `src/nixos/modules/impermanence/default.nix:45-89`.

Key components:
- Root filesystem mounted as tmpfs (line 45)
- /nix/persist is BTRFS on encrypted partition (line 52)
- Bind mounts for specific directories (line 67-78)

Pattern used:
```nix
environment.persistence."/nix/persist" = {
  directories = [ "/etc/nixos" "/var/log" ];
  files = [ "/etc/machine-id" ];
};
```

Testing in git history shows this was added in iteration 14 (commit abc123)
to improve compromise resilience.

## Recommendations

This pattern should be documented in .opencode/guides/ for future reference.
Consider adding VM test to verify impermanence works correctly.

## Open Questions

- Should /var/cache be ephemeral or persisted? (currently ephemeral)
- How do we handle application state that expects persistence?

## Memory Update Suggestion

Add to MEMORY.md under "Architecture Decisions":
> Impermanence via tmpfs root, only /nix/persist survives reboot.
> See src/nixos/modules/impermanence/default.nix for implementation.
```

## Performance

- **Speed:** Thorough, not fast (expect 2-5 minutes for complex questions)
- **Token usage:** High (loads full context: QUICK_START, SOUL, ideology)
- **Cost:** Moderate (DeepSeek is efficient despite thoroughness)

## Integration with Other Commands

Often used as first step:
1. `/research` to understand problem
2. `/nix` to implement solution
3. `/quick` to validate syntax
4. `/security` to review security

## Tips for Better Results

**Be specific:**
- ✅ "How does the router machine handle firewall rules for WireGuard?"
- ❌ "How does networking work?"

**Provide context:**
- ✅ "I'm seeing VM build fail with disko error 'partition size mismatch'. Research the disko configuration and VM variant setup to understand why."
- ❌ "VM broken, fix it"

**Ask follow-ups:**
- Research may raise new questions - ask them!
- "You mentioned X has trade-off Y - can you elaborate?"

## Known Strengths

Per maintainer feedback:
> "DeepSeek absolutely amazing for research"

- Excellent at deep dives
- Good at connecting disparate information
- Patient with ambiguous questions
- Strong documentation skills
- Finds non-obvious patterns

## Limitations

- Not for simple syntax checks (use `/quick`)
- Not for writing code (use `/nix`)
- Not for security review (use `/security`)
- May go deep into tangents (redirect if needed)
