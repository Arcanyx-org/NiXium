<!-- SUMMARY: NiXium business context — mission-critical infrastructure for paranoid environments. LOAD WHEN: You need to understand why NiXium exists and what it protects. SKIP WHEN: You only need technical implementation details. -->

# Business Domain — NiXium

## Problem Statement

NiXium addresses the need for **mission-critical, high-security infrastructure** in paranoid environments where lives, security, or sensitive data may depend on the correctness and resilience of systems.

## Core Purpose

This code protects **real systems and data** in environments where:
- Security breaches have real-world consequences
- System failures could endanger lives or compromise critical operations
- Zero-trust principles must be rigorously applied
- Supply chain security is paramount (post-XZ backdoor era)

## Stakeholders

- **Primary user/administrator**: kreyren (system administrator and legal owner of all systems)
- **Beneficiaries**: Individuals/organizations requiring paranoid-grade security
- **Future maintainers**: AI agents and human contributors who inherit this infrastructure

## Value Proposition

NiXium delivers security and reliability through:

### 1. Zero-Trust Security Model
- **Never trust, always verify** - Every component is potentially hostile
- **Defense in depth** - Multiple security layers limit blast radius
- **Assume breach** - Design as if attackers already have foothold
- **Explicit deny by default** - Everything blocked unless explicitly allowed

### 2. Mission-Critical Reliability
- Quality cannot be compromised for speed
- Proactive risk management prevents incidents before they occur
- Systems designed for failure and recovery
- All operations trackable and auditable

### 3. Research-First Engineering
- **20:2:1 ratio** - 20 parts research, 2 parts documentation, 1 part code
- Research finds better solutions and catches issues early
- Documentation compounds value for future contributors
- Code is treated as liability - less code means fewer bugs

### 4. Transparent & Maintainable Design
- Declarative infrastructure (configuration as code, versioned in git)
- Explicit dependencies and obvious behavior
- Peer-reviewed changes and documented design decisions
- Self-documenting systems readable in crisis situations

## Current Services & Use Cases

Based on NiXium's implementation, the infrastructure supports:

- **Monero node** - Privacy-preserving cryptocurrency infrastructure
- **Vikunja** - Task management and productivity suite
- **Custom NixOS machines** - Specialized configurations for different security domains
- **Flake-parts architecture** - Modular, reproducible NixOS configurations
- **Disko integration** - Declarative disk encryption and partitioning
- **Lanzaboote** - Secure, reproducible bootloader management
- **Ragenix** - Age-based secret management for encrypted credentials
- **Impermanence** - tmpfs root with explicit persistence for security

## Operating Environment

- **Paranoid environments** - Assumes sophisticated adversaries
- **Long-term data protection** - Considers post-quantum cryptography timelines
- **Supply chain security** - Learns from XZ backdoor incident
- **Sustainable pace** - Resists pressure to "just ship it" in favor of thoroughness

## Success Metrics

NiXium is successful when:
- Rewrites are prevented through thorough planning
- Risks are identified before they become incidents
- Complexity is simplified without sacrificing capability
- Security is maintained without blocking productivity
- Assumptions are challenged with evidence
- Knowledge is shared through teaching and collaboration

## Related Context

- **Technical domain**: How NiXium is built (stack, architecture, decisions)
- **Decisions log**: Why specific technical choices were made
- **Living notes**: Current work, open questions, and technical debt
- **Business-tech bridge**: How business needs map to technical solutions
