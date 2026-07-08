<!-- SUMMARY: Infrastructure navigation with nix/ subdirectory reference. LOAD WHEN: You need to find which infrastructure area to load. SKIP WHEN: You already know which specific infrastructure topic you need. -->

# Infrastructure Navigation

**Purpose**: DevOps and deployment patterns

## Structure

```
infrastructure/
├── navigation.md
├── docker/
│   ├── dockerfile-patterns.md
│   ├── compose-patterns.md
│   └── optimization.md
├── ci-cd/
│   ├── github-actions.md
│   ├── deployment-patterns.md
│   └── testing-pipelines.md
└── nix/
    ├── navigation.md
    ├── overview.md
    └── (future nix-specific files)
```

## Quick Routes

- **Nix/NixOS development** → `nix/`
- **Docker containerization** → `docker/`
- **CI/CD pipelines** → `ci-cd/`

## Related Context

- **Core Standards** → `../../core/standards/code-quality.md`
- **Testing** → `../../core/standards/test-coverage.md`
- **Nix Coding Standard** → `nix/overview.md` (links to core standard)
