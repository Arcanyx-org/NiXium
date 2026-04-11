# /nix - Nix Code Writing and Implementation

**Invokes:** `nix-specialist` agent (Gemma 2 27B IT)

**Purpose:** Write idiomatic Nix code, implement features, refactor configurations

## Usage

```bash
/nix <implementation task>
```

## When to Use

Use `/nix` for:
- Writing new NixOS configurations
- Creating systemd services
- Implementing features
- Refactoring existing code
- Building flake-parts modules
- Setting up VM testing configs

## Examples

```bash
# Service creation
/nix Create a systemd service for Prometheus monitoring with proper hardening
/nix Implement a health check service that runs every 5 minutes

# Configuration
/nix Set up WireGuard VPN configuration for the router machine
/nix Configure nginx with TLS 1.3 and strong cipher suites

# Refactoring
/nix Refactor src/nixos/machines/router/config/networking.nix for clarity
/nix Convert this shell script to use writeShellApplication

# Module development
/nix Create a shared module for monitoring that can be imported by all machines
/nix Build a flake-parts module for common security settings

# VM testing
/nix Set up VM variant configuration for testing disko
/nix Add VM testing check to verify service starts correctly
```

## Expected Output

Nix-specialist provides:

### 1. Implementation Code
Clean, well-commented Nix code following Nx standards:
```nix
{ config, pkgs, lib, ... }:
let
	inherit (lib) concatStringsSep;
	
	# Helper script with proper shellcheck validation
	myScript = pkgs.writeShellApplication {
		name = "my-script";
		runtimeInputs = [ pkgs.curl ];
		bashOptions = [ "errexit" "nounset" "pipefail" ];
		text = concatStringsSep "\n" [
			''echo "Starting task..."''
			''curl -s https://example.com''
		];
	};
in {
	# Service with hardening
	systemd.services.myservice = {
		description = "My Service";
		wantedBy = [ "multi-user.target" ];
		
		serviceConfig = {
			ExecStart = "${myScript}/bin/my-script";
			
			# Security hardening
			ProtectSystem = "strict";
			ProtectHome = true;
			PrivateTmp = true;
			NoNewPrivileges = true;
			DynamicUser = true;
		};
	};
}
```

### 2. VM Test Results
Evidence that code was tested:
```
✅ VM Test Results

Build:
  nix build .#nixosConfigurations.nixos-router-stable.config.system.build.vm --no-link
  Status: Success

Runtime:
  - Service starts: ✅ systemctl status myservice
  - No errors in logs: ✅ journalctl -u myservice
  - Functionality verified: ✅ Curl succeeded
  - Hardening active: ✅ ProtectSystem=strict confirmed

All changes reverted, ready for review.
```

### 3. Integration Instructions
How to use the new code:
```
To integrate:
1. Add to src/nixos/machines/router/default.nix:
   imports = [ ./config/myservice.nix ];

2. Rebuild:
   nixos-rebuild switch

3. Verify:
   systemctl status myservice
```

### 4. Documentation
Explanation of decisions:
```
Implementation notes:
- Used DynamicUser for automatic user/group creation
- ProtectSystem=strict prevents writes outside /var/lib/myservice
- PrivateTmp isolates /tmp to prevent interference
- Script uses writeShellApplication for automatic shellcheck validation
```

## Nx Standards Compliance

All code from `/nix` follows:

### ✅ Indentation
- Uses tabs (not spaces)
- Tab width = 4
- Consistent throughout

### ✅ Shell Scripts
- `pkgs.writeShellApplication` (NOT writeShellScriptBin)
- `bashOptions = [ "errexit" "nounset" "pipefail" ];`
- `concatStringsSep "\n"` for multi-line
- All variables quoted: `"$VAR"`

### ✅ Systemd Services
- Hardening options (ProtectSystem, PrivateTmp, etc.)
- Explicit User/Group or DynamicUser
- No plaintext secrets (use age.secrets)
- Absolute paths or writeShellApplication for ExecStart

### ✅ Comments
- Explain "why", not just "what"
- Document non-obvious decisions
- Reference issues/docs if relevant

### ✅ State Version
- Dynamic: `lib.versions.majorMinor lib.version`
- Never hardcoded: ~~`"24.11"`~~

## VM Testing Requirement

**MANDATORY:** All code from `/nix` must be VM tested before presentation.

### Testing Process

1. **Write code** in actual files (not just chat)
2. **Build VM:**
   ```bash
   nix build .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm --no-link
   ```
3. **Run VM:**
   ```bash
   nix run .#nixosConfigurations.nixos-<machine>-stable.config.system.build.vm -- -nographic
   ```
4. **Verify behavior:**
   - Service starts correctly
   - Logs show no errors
   - Functionality works as intended
   - Hardening options active
5. **Revert changes:**
   ```bash
   git restore <modified-files>
   ```
6. **Present results** with test evidence

## Integration Workflow

Typical workflow:
1. `/research` to understand requirements
2. **`/nix`** to implement solution
3. `/quick` to validate syntax
4. `/security` to review security
5. Maintainer approves, code merged

## Flake-Parts Patterns

### Machine Configuration Structure
```
src/nixos/machines/<machine>/
├── default.nix          # Main config, imports others
├── config/              # Machine-specific configs
│   ├── networking.nix
│   ├── firewall.nix
│   └── services.nix
├── secrets/             # Age-encrypted secrets
└── releases/            # Release-specific overrides
```

### Machine default.nix Template
```nix
{ inputs, ... }: {
	flake.nixosModules.<machine> = { config, pkgs, lib, ... }: {
		imports = [
			./config/networking.nix
			./config/firewall.nix
			# Add new configs here
		];
		
		networking.hostName = "<machine>";
		system.stateVersion = lib.versions.majorMinor lib.version;
	};
}
```

### Shared Module Export
```nix
# In src/nixos/default.nix
{
	flake.nixosModules = {
		monitoring = import ./modules/monitoring;
		security = import ./modules/security;
	};
}

# In machine's default.nix
{
	imports = [
		inputs.self.nixosModules.monitoring
		inputs.self.nixosModules.security
	];
}
```

## Common Implementation Patterns

### Systemd Service with Script
```nix
let
	serviceScript = pkgs.writeShellApplication {
		name = "myservice";
		runtimeInputs = [ pkgs.curl pkgs.jq ];
		text = ''
			curl -s https://api.example.com | jq -r '.data'
		'';
	};
in {
	systemd.services.myservice = {
		description = "My Service";
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			ExecStart = "${serviceScript}/bin/myservice";
			ProtectSystem = "strict";
			DynamicUser = true;
		};
	};
}
```

### Timer-Based Service
```nix
{
	systemd.services.backup = {
		description = "Backup service";
		serviceConfig = {
			Type = "oneshot";
			ExecStart = "${pkgs.rsync}/bin/rsync -av /src /dest";
		};
	};
	
	systemd.timers.backup = {
		wantedBy = [ "timers.target" ];
		timerConfig = {
			OnCalendar = "daily";
			Persistent = true;
		};
	};
}
```

### Secret Integration
```nix
{
	age.secrets.myapp-token = {
		file = ./secrets/myapp-token.age;
		owner = "myapp";
		mode = "0400";
	};
	
	systemd.services.myapp = {
		script = ''
			TOKEN=$(cat ${config.age.secrets.myapp-token.path})
			# Use $TOKEN
		'';
	};
}
```

## Performance

- **Speed:** Moderate (includes VM testing)
- **Token usage:** Moderate
- **Cost:** Low (Gemma is efficient)

## Tips for Better Results

**Be specific about requirements:**
- ✅ "Create systemd service for Prometheus, must scrape localhost:9100 every 30s, use DynamicUser"
- ❌ "Set up monitoring" (too vague)

**Provide context:**
- ✅ "This service handles external traffic, ensure proper hardening"
- ❌ No context about security requirements

**Specify integration point:**
- ✅ "Add to router machine in config/monitoring.nix"
- ❌ Don't specify where code should live

## Known Strengths

Per maintainer feedback:
> "Gemma 14B writes good Nix"

- Clean, idiomatic code
- Good flake-parts understanding
- Follows Nx standards naturally
- Practical, not over-engineered
- Strong VM testing discipline

## Success Criteria

Good `/nix` output:
- ✅ Code follows Nx standards
- ✅ VM tested with documented results
- ✅ Includes systemd hardening
- ✅ Well-commented
- ✅ Integration instructions clear

Poor `/nix` output:
- ❌ Untested code
- ❌ Uses spaces instead of tabs
- ❌ writeShellScriptBin instead of writeShellApplication
- ❌ Missing hardening
- ❌ Hardcoded stateVersion
- ❌ No comments

## Post-Implementation

After `/nix` creates code:

1. **Review output** - Does it match requirements?
2. **Check test results** - Did VM testing pass?
3. **Run `/quick`** - Validate syntax/linting
4. **Run `/security`** - Security review
5. **Approve or request changes**
6. **Merge** when all checks pass
