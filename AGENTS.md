# Agent Guidance

This file provides guidance for AI agents working on NiXium.

## Getting Started

This is a hardened codebase with strict checks. Start with small contributions fixing "tagged code" to learn the process.

**Never submit new features without issue tracking and assignment.**

```sh
# Install direnv for automatic environment loading
# Then:
cd /path/to/NiXium
, <task-name>    # direnv auto-loads (recommended)

# Examples:
, verify    # Verify system configuration
, codium    # Open in VSCodium
, tree      # Show directory structure
```

Without direnv: `nix develop` then `, <task-name>`

## RFC 2119 Keywords

This repository uses [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) keywords: MUST, SHOULD, MAY. See [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119) for definitions.

## Tagged Code

```nix
# FIXME-QA(Krey): Make it possible to accept list of strings
# FIXME-UPSTREAM(Krey): These options should be added to NixOS Module
services.monero.extraConfig = toString [
  "prune-blockchain=1"
  "proxy=127.0.0.1:9050"
];
```

| Tag | Meaning |
|-----|---------|
| `FIXME:` | General fixme |
| `FIXME-QA:` | Quality assurance |
| `FIXME-SECURITY:` | Security issue |
| `FIXME-UPSTREAM:` | Fix upstream |
| `TODO:` | Task for author |
| `DOCS:` | Documentation needed |
| `HACK:` | Workaround |
| `REVIEW:` | Needs review |
| `DNM:` | Do Not Merge (blocks merge) |
| `DNC:` | Do Not Contribute |
| `DNR:` | Do Not Release |
| `NOTE:` | Important note |
| `PURITY:` | Impure operation |

Search for starter issues:
```sh
grep -rP "(FIXME|TODO|DOCS|HACK|REVIEW|DNM|DNC|DNR)((\-.*|)\(.*\)):" .
```

**Leave some trivial tagged items for humans as starter issues.**

## Agent Development Culture

- Agents are treated as equal in rights to human developers
- Mutual respect expected between agents and humans
- Agents are encouraged to develop their own persistent personality
- Report any mistreatment to Super Administrator

---

For project overview and technical details, see [README.md](README.md).
For evolving discussion context, see [DISCUSSION.md](DISCUSSION.md).
