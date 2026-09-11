# REPO MAP — Agent-Copilot (updated: 2026-09-11)

## Phạm vi và mức độ tin cậy

Đây là **Discovery review**, không phải greenfield design. Báo cáo dựa trên các file hiện có, Git metadata và việc đọc read-only các archive member trong VSIX. Không source/config/agent hiện có nào bị sửa; artifact duy nhất được tạo là file này.

- **High confidence:** inventory file, nội dung README/settings/frontmatter, Git branch/status, VSIX manifest/package metadata, archive entries và SHA-256.
- **Medium confidence:** hành vi runtime suy ra từ bundled `extension/out/extension.js` và extension README.
- **Low confidence / chưa xác minh:** VS Code thực tế load agent theo precedence nào, router/model ID có hoạt động trong máy đích không, identity/signature của binary, toàn bộ network/error-handling behavior của extension.

## What this system does

Repo chứa 9 custom agents Markdown cho GitHub Copilot trong VS Code, được tổ chức thành workflow từ triage/architecture, product requirements, UX/UI, development, testing, security, QC đến DevOps. README quy định gọi `Team Lead` làm entry point để điều phối các agent chuyên môn; agent files chứa YAML frontmatter và instruction prompt tương ứng (`README.md:1-3, 19-78`; `.github/agents/team-lead.agent.md:1-10, 66-103`).

Repo không chứa application backend/frontend hay source của VSIX. `extensions/9router-for-github-copilot-2.0.0.vsix` là binary VS Code extension đóng vai trò language-model provider/proxy cho OpenAI-compatible server. VSIX metadata xác nhận extension `9router-for-github-copilot` v2.0.0, publisher `hotrungnhan`, VS Code engine `^1.125.0`, activation `onStartupFinished`, `main: ./out/extension.js`, và provider `9router-github-copilot` (archive member `extension/package.json`, `extension.vsixmanifest`).

## Detected stack / tooling

| Layer | Technology | Evidence | Confidence |
|---|---|---|---|
| Agent definition | GitHub Copilot custom-agent Markdown + YAML frontmatter | `.github/agents/*.agent.md`; mỗi file có `name`, `description`, `tools`, `user-invocable`, `model` | High |
| Workspace config | VS Code JSON settings | `.vscode/settings.json:1-3` | High |
| Orchestration | Team Lead prompt + Copilot `agent` tool + named agents/handoffs | `.github/agents/team-lead.agent.md:4-16, 66-76`; `README.md:19-29` | High as intended design; runtime execution unverified |
| Extension runtime | VS Code extension, bundled JavaScript/Node runtime entry | VSIX `extension/package.json` (`main`, `activationEvents`), `extension/out/extension.js` | High for package metadata |
| Inference protocol | OpenAI-compatible HTTP endpoint; default `http://localhost:20128/v1` | VSIX `extension/package.json` settings; bundled JS contains `/chat/completions`; `extension/readme.md` | High/Medium |
| Extension package manager/build hints | Bun lockfile; npm/esbuild/TypeScript/vsce scripts embedded in artifact | VSIX `extension/bun.lock`, `extension/package.json` | High for artifact metadata; not repo tooling |
| Test runner/linter for this repo | **UNKNOWN / none detected** | No repo `package.json`, `pyproject.toml`, test tree, workflow, or CI manifest in tracked files | High that none is present in tracked inventory |
| Build/deploy command for this repo | **UNKNOWN** | Only the VSIX's embedded package metadata advertises build/test/package scripts; source is not included | High |
| Runtime services | VS Code/Copilot host plus optional user-selected inference server/router | README and VSIX metadata; no DB/queue/container/IaC found | High |

### Git metadata observed

- Branch: `copilot/team-lead-guardrails`; working tree clean at review time (`git status --short --branch`).
- HEAD: `e1d6219 Add Team Lead execution guardrails`; remote-tracking branch points to same commit.
- Remote: `https://github.com/hunterv9/Agent-Copilot.git`.
- Recent history shows changes around Team Lead delegation/live work logs/guardrails.
- Tracked inventory is exactly the 9 agent files, `.vscode/settings.json`, `README.md`, and the VSIX; no tracked CI, test, source, lockfile, or docs directory was found.

## Module map

| Directory/file | Owns | Depends on | Depended by | Risk/notes |
|---|---|---|---|---|
| `.github/agents/` | 9 prompt modules and their frontmatter contracts | VS Code/Copilot agent runtime, declared tools, configured model IDs | User invocation; Team Lead dispatch | No machine-readable schema or automated validation |
| `.github/agents/team-lead.agent.md` | Orchestration, triage, budgets, debate, human gates, handoff/report format | All named agents, `agent` tool, Copilot runtime | Primary workflow entry point | Largest coordination contract; rules are prose, not enforced policy |
| `.github/agents/architect.agent.md` | Discovery/greenfield mapping rules and `REPO_MAP.md`/`ARCHITECTURE.md` formats | Read/search/edit/execute/web/todo tools | Team Lead and direct user | Correctly separates Discovery from Greenfield in prompt |
| `.github/agents/pm.agent.md` | Requirements, PRD, stories, acceptance criteria | Read/search/edit/web/todo | Team Lead / Dev / Test / UX | Output is chat/template-based; no artifact path convention |
| `.github/agents/ux-ui.agent.md` | Visual design prompt, HTML mockup, Mermaid flow, tokens | Read/search/edit/web/todo; claims an `artifact` tool | Team Lead / Dev / Test | Declares no `artifact` tool despite making it mandatory |
| `.github/agents/dev.agent.md` | Implementation and self-review guidance | Read/search/edit/execute/web/todo | Team Lead / Test / Security / DevOps | Broad edit/execute permissions are prompt-governed |
| `.github/agents/test.agent.md` | Test strategy, execution, reports, bug reports | Read/search/edit/execute/web/todo | Team Lead / Dev / QC | No actual test harness in this repo |
| `.github/agents/security.agent.md` | Threat model, SAST/DAST/SCA and pentest guidance | Read/search/edit/execute/web/todo | Team Lead / DevOps / QC | Authorization/destructive-test safeguards are prose only |
| `.github/agents/qc.agent.md` | Final quality gate and verdict | Read/search/web only | Team Lead / DevOps | Cannot execute tests or dependency scans itself despite requiring verified results |
| `.github/agents/devops.agent.md` | CI/CD, IaC, deployment, rollback, monitoring | Read/search/edit/execute/web/todo | Team Lead | No CI/CD/IaC implementation exists in repo |
| `.vscode/settings.json` | Workspace request ceiling | VS Code settings runtime | Agent execution | Contains only `chat.agent.maxRequests: 50`; no agent location or Settings Sync ignore setting |
| `extensions/` | Prebuilt 9Router VSIX | VS Code extension host; external inference endpoint | Copilot model picker and chat/tool calls | Opaque binary; no source, release signature, SBOM, or build provenance in repo |
| `README.md` | Setup, workflow and router/model guidance | Actual agent names and VSIX filename | Human operator | Contains a demonstrable settings/configuration mismatch |

Dependency direction is conceptually one-way: user → Team Lead → specialist prompts/tools; Copilot host → VSIX → inference server. There is no application core, persistence layer, API service, queue or database to map. The main structural risk is not a code dependency cycle but a large, implicit prompt contract with no validator.

## Entry points

| Entry | Type | Handler/location | Evidence/status |
|---|---|---|---|
| Direct invocation of any custom agent | Interactive Copilot agent | `.github/agents/*.agent.md`, `user-invocable: true` | Declared in all 9 files; actual discovery/precedence not executed |
| `Team Lead` | Primary interactive orchestrator | `.github/agents/team-lead.agent.md:1-10, 66-103` | `agents` lists all 8 specialists; `agent` tool enabled |
| Team Lead handoff buttons | Interactive fallback handoffs | `.github/agents/team-lead.agent.md:8-55` | 9 handoffs, each with `send: true`; fallback semantics are prompt-documented |
| VSIX activation | VS Code extension lifecycle | VSIX `extension/package.json`: `activationEvents: ["onStartupFinished"]`, `main: ./out/extension.js` | Metadata verified; install/activation not run |
| 9Router model provider | Copilot language model provider | VSIX `extension/package.json`: `languageModelChatProviders`, vendor `9router-github-copilot` | Metadata verified |
| 9Router commands | Command palette/status UI | VSIX `extension/package.json`: 7 commands including Manage Providers, Test Server Connection, Refresh Models, Edit Custom Headers, Show Output | Metadata verified |
| Inference server | HTTP egress from extension | VSIX bundled JS/readme: default `/v1`, chat request to `/chat/completions`; readme documents `/v1/models` | Runtime inferred/read-only inspected; endpoint owner and transport policy unknown |

## Operational flow — how agents are intended to load and run

1. **Discovery/load:** VS Code/Copilot is expected to discover `.github/agents/*.agent.md` and parse their frontmatter. This convention is documented by README and the files' frontmatter; there is no explicit `chat.agentFilesLocations` in `.vscode/settings.json`, so the exact path precedence and whether any global agents override these files remain unverified.
2. **Selection:** Each agent is marked `user-invocable: true`. A user can invoke a specialist directly or call `Team Lead`; README recommends the latter (`README.md:19-29, 75-80`).
3. **Routing:** The selected prompt requests a model ID such as `Free_Model` or `Team_Lead`. README says `Free_Model` requires a proxy/model-picker ID and otherwise Copilot may fall back (`README.md:82`). The artifact is intended to expose the proxy provider and local default endpoint.
4. **Dispatch:** Team Lead uses the `agent` tool and names in frontmatter (`Architect`, `PM`, `UX/UI`, `Dev`, `Test`, `Security`, `QC`, `DevOps`) to delegate. It is instructed to pass context/reports and to use handoffs as fallback (`team-lead.agent.md:4-16, 66-76`).
5. **Gates and outputs:** Team Lead triages a minimum pipeline, emits status labels, applies phase budgets, requires human gates for plans/production, and expects reports/artifacts. These are behavioral instructions, not host-enforced controls (`team-lead.agent.md:77-123, 140-189, 213-249`).
6. **Extension data path:** VSIX activates in the VS Code host, registers the language-model provider, sends chat-completion requests to the configured OpenAI-compatible endpoint, and supports tool calling by default according to package settings. API keys/custom headers have SecretStorage migration paths; `verboseLogging` can write full chat request bodies/tool args to the output channel (VSIX `extension/package.json`, bundled JS; read-only).

### Core flow

`User → Copilot agent picker → Team Lead prompt → triage → agent tool/handoff → specialist prompt + declared tools → report/edit/artifact → Team Lead gate/status → user`

### Model/proxy flow

`Copilot/VS Code → 9Router language-model provider (VSIX) → configured serverUrl (default localhost:20128/v1) → OpenAI-compatible /chat/completions and model discovery → streamed result/tool calls → Copilot agent runtime`.

The flow is **intended**, not end-to-end validated in this review: no VSIX installation, model-picker test, server call, or agent dispatch was executed.

## Conventions observed

- Agent files use quoted names/descriptions/models, inline YAML arrays for tools/agents, and a long Markdown prompt after `---` (`.github/agents/*.agent.md:1-8`).
- All 9 agents are user-invocable; model routing is split between custom IDs `Free_Model` and `Team_Lead`.
- Prompts use explicit phases, checklists, output templates, P0–P3/severity vocabulary, and `ALWAYS`/`NEVER`/`DO NOT` rules.
- README is Vietnamese with English technical identifiers; agent prompts are English. This is workable but increases terminology drift.
- Workflow reports are prose templates, not JSON/schema-backed contracts. Artifact names such as `REPO_MAP.md`, `ARCHITECTURE.md`, `PROGRESS.md`, HTML artifacts and PRD are prescribed in prompts but not validated.
- Security-positive conventions exist in prompts: no production testing without authorization, no destructive payloads, human approval before production, SecretStorage for extension API keys/custom headers, and verbose logging disabled by default.

## Consistency and quality findings

### Confirmed issues

1. **README/config mismatch — medium/high operational risk.** README states Settings Sync is blocked via `settingsSync.ignoredExtensions` (`README.md:92-93`), but `.vscode/settings.json:1-3` contains only `chat.agent.maxRequests`. There is no repository evidence that the extension is actually excluded from Settings Sync.
2. **UX/UI tool contract is impossible as declared.** UX/UI says the primary deliverable must use an `artifact` tool (`.github/agents/ux-ui.agent.md:197-200, 304`), but its frontmatter tools are only `[read, edit, search, web, todo]` (`:4`). This can cause failed handoffs or text-only output.
3. **QC verification capability is underspecified.** QC declares `[read, search, web]` (`.github/agents/qc.agent.md:4`) but says it must not approve without passing test results and must review dependency scans (`:45, 136-141`). It can review supplied evidence, but cannot itself execute tests/scans; the prompt does not clearly distinguish “verify report” from “run verification.”
4. **Model IDs are environment-specific and incompletely documented.** `Free_Model` is explained in README (`README.md:82`), but `Team_Lead` is not explained as a provider/model contract. The repository does not validate that either ID exists in the target model picker. Fallback behavior can silently change model selection.
5. **Budget semantics are not proven equivalent.** Team Lead describes budgets in “tool calls” (`README.md:58-64`, `.github/agents/team-lead.agent.md:104-123`), while workspace config is named `chat.agent.maxRequests` (`.vscode/settings.json:2`). No evidence shows this setting enforces the same unit or per-pipeline limits.
6. **UX prompt contains internal drift.** It requires dark/light support and says “skip dark mode” is an anti-pattern (`.github/agents/ux-ui.agent.md:196-205, 264-279`), but also says not to invent a dark theme when the project has none (`:12, 261`). The latter is safer, but the contract is contradictory. The output numbering also repeats item `3` (`:226-255`).
7. **Prompt policy is not a technical permission boundary.** Several agents have `edit`/`execute`/`web`, while important safety constraints exist only as prose. A compromised/misrouted model could ignore “NEVER” rules; no host-level allowlist or approval policy is present in this repo.

### Maintainability risks

- The Team Lead prompt is a large, cross-cutting policy document with duplicated workflow, gate, escalation and output requirements (`.github/agents/team-lead.agent.md:58-410`). Small policy changes require editing one large prompt and can conflict with specialist prompts.
- No frontmatter schema, lint, duplicate-name check, handoff target check, model-ID check, or Markdown link check is present.
- Agent-to-agent contracts are free-form Markdown. Required fields such as status, confidence, evidence, blockers and test results are not machine-validated.
- The binary extension is not reproducible from this repo: source is absent, only bundled `out/extension.js` is distributed. The embedded lockfile provides package checksums, but not a build attestation or source-to-binary mapping.
- No changelog/version matrix documents compatibility among VS Code, Copilot agent runtime, custom model IDs and VSIX v2.0.0.
- Mixed Vietnamese/English and aliases such as `Team Lead` / `Team_Lead`, `Free_Model`, `QC`, and `quality gate` need a glossary to prevent routing and report drift.

## Security and supply-chain review

### Findings

1. **Opaque executable VSIX / high trust boundary.** The archive contains `extension/out/extension.js` and manifest metadata marks executable code; activation is `onStartupFinished`. Installing it grants third-party code execution inside VS Code. The repo does not include source, signature/provenance, SBOM, release commit, or a verified publisher relationship. The artifact publisher/repository is `hotrungnhan/9router-for-github-copilot`, while this repo/remote is `hunterv9/Agent-Copilot` (VSIX `extension/package.json`, `extension.vsixmanifest`).
2. **No integrity pin in operator instructions.** README recommends `code --install-extension ... --force` (`README.md:84-93`) but does not publish/verify the observed SHA-256: `97314D7C3B0DB6FAE0188C76E3E2D55316C20672A30CF64E4B420C00253C5DE1`. `--force` also overwrites an existing installation, increasing rollback/recovery risk.
3. **Prompt/code egress depends on a configurable server.** VSIX defaults to localhost but accepts a server URL and API key/custom headers. The extension README says inference stays on the user's server, but also acknowledges Copilot host telemetry/title/auth traffic may go to GitHub. The stronger README statement “Prompts and code go to your server only” (`extension/readme.md`) should not be treated as a universal data-residency guarantee. TLS/remote-endpoint policy was not verified.
4. **Tool-calling amplifies model/router compromise.** VSIX package settings default `enableToolCalling: true`; README describes agent tools such as file operations and terminal (`extension/package.json`, `extension/readme.md`). A malicious/compromised remote endpoint or prompt injection could produce dangerous tool calls. Human confirmation behavior is delegated to the host and is not documented/tested here.
5. **Verbose logging can expose sensitive content.** VSIX metadata explicitly says enabling `verboseLogging` writes the full chat request, messages and tool args to the output channel. It is false by default, which is positive, but there is no retention/redaction policy or automated guard.
6. **Dependency/provenance visibility is partial.** `extension/bun.lock` contains many pinned/checksummed packages and lists `@vscode/vsce-sign` as trusted, which is positive. However, the repo cannot reproduce or audit the build because source and CI are absent; the lockfile is inside the opaque artifact.

### Positive controls observed

- API key/custom headers are documented as migrated to VS Code SecretStorage rather than persistent plain settings (`extension/package.json`, bundled JS).
- Verbose request logging defaults to false (`extension/package.json`).
- Security prompt explicitly forbids unauthorized production testing and destructive payloads (`.github/agents/security.agent.md:299-322`).
- Team Lead/DevOps prompts require human approval before production deployment (`.github/agents/team-lead.agent.md:213-230`, `.github/agents/devops.agent.md` deployment rules).

## Missing validation, tests and CI

- No test files, test runner, coverage config, package manifest, lockfile, CI workflow, SAST/SCA/DAST config, release workflow or VSIX verification script exists in the tracked repo.
- The VSIX's embedded `package.json` advertises `lint`, TypeScript compile and Node test scripts, but the archive has no `src/` or test source tree; those scripts cannot be meaningfully reproduced from this repo.
- No test was run during this review. No VSIX was installed or activated, no model picker was exercised, no inference server was contacted, and no agent handoff was executed.
- Missing minimum validation includes: frontmatter parse/schema validation, unique-name/handoff target validation, supported model-ID smoke test, agent discovery smoke test, Team Lead dispatch/gate regression tests, VSIX hash/provenance check, extension install/activation smoke test, request-log redaction test, TLS/remote endpoint policy test, and tool-call approval/prompt-injection tests.

## Prioritized recommendations

### P0 — before trusting this setup with sensitive code or production

1. **Quarantine and provenance-check the VSIX.** Obtain source/release from the upstream publisher, verify the release commit and signature/checksum, compare/rebuild the binary where possible, and record an approved hash. Do not install an unverified executable extension into a privileged workspace.
2. **Define the model/router trust boundary.** Treat the inference server and model as able to see prompts/code and influence tool calls. Disable tool calling for untrusted endpoints/models, require explicit human confirmation for terminal/file actions, and document approved hosts/TLS requirements.
3. **Correct the data-flow/privacy claim.** Document exactly what goes to the configured server vs GitHub/VS Code host, including utility/title/telemetry paths, logs, retention and remote HTTP/TLS behavior.

### P1 — next hardening iteration

1. Resolve the Settings Sync claim: add the actual supported ignore configuration through an approved workspace/user policy, or remove the claim and provide an operational check (`README.md:92-93` vs `.vscode/settings.json:1-3`).
2. Add source/provenance for the VSIX (or a separate audited upstream release process), SBOM, signed release metadata, reproducible build instructions and CI that publishes the hash.
3. Add CI validation for agent frontmatter: YAML parse, required keys, unique `name`, valid `agents`/handoff targets, allowed tool names, model-ID allowlist, Markdown links, and README structure consistency.
4. Make contracts executable: define a small JSON/schema or required Markdown fields for dispatch, evidence, confidence, blockers, test result and gate verdict.
5. Fix the UX/UI capability contract (`artifact` tool) and clarify the dark-mode rule; clarify QC as “review supplied evidence” or grant a controlled verification capability. Correct duplicate output numbering.
6. Add a minimal integration suite using a fake inference server and a fake Copilot/agent harness where available: discovery, direct invocation, Team Lead dispatch, fallback handoff, budget stop, human gate, tool-call rejection, verbose-log redaction and remote URL policy.
7. Replace `--force` as the default install guidance with explicit version/hash verification and a rollback/uninstall procedure.

### P2 — maintainability and operator experience

1. Publish a compatibility matrix: VS Code version, Copilot agent runtime, supported model IDs, router version, server protocol and known limitations.
2. Add `CHANGELOG.md`/release notes for prompt-contract changes and version agent files independently from the VSIX.
3. Standardize terminology and language, especially `Team Lead` vs `Team_Lead`, `Free_Model`, report statuses and P0/P1/P2/P3 severity.
4. Reduce prompt duplication through a documented template/convention and keep specialist-specific rules focused; retain a single source of truth for gates and safety policy.
5. Add least-privilege profiles or documented safe defaults for agents with `execute`, `edit`, `web` and tool-calling access.

## Open unknowns / blockers

- **Runtime loading:** not verified whether the target VS Code/Copilot version automatically loads this repo's `.github/agents` without `chat.agentFilesLocations`, nor precedence against global/user agents.
- **Model routing:** `Free_Model` is documented but `Team_Lead` is not; availability, fallback semantics and picker names depend on external Copilot/router configuration.
- **VSIX authenticity:** archive identity and hash are observed, but publisher ownership, signing status, release provenance and source equivalence were not independently verified.
- **Runtime security:** the bundle confirms fetch/SecretStorage-related code and endpoint configuration, but a full behavioral audit, TLS review, server authentication review and tool approval test were not performed.
- **Local environment:** ignored/untracked files outside the tracked inventory, user-level VS Code settings, installed extensions and actual inference-server configuration were not audited.
- **No application behavior:** there is no backend/frontend/database flow to execute or test in this repository.

## Onboarding brief

### System in one paragraph

Start from `README.md` for intended workflow and install assumptions, then inspect `.github/agents/team-lead.agent.md` for orchestration policy and the specialist file relevant to the task. Treat the VSIX as a separate privileged executable dependency, not as source code. Before using it with sensitive code, resolve the P0 provenance and data/tool-call trust issues.

### Where to start reading

1. `README.md:1-110` — system purpose, workflow, model/router assumptions and installation guidance.
2. `.github/agents/team-lead.agent.md:1-410` — routing, budgets, gates and handoff contract.
3. `.github/agents/architect.agent.md:1-194` — expected Discovery/Greenfield artifact formats.
4. `.vscode/settings.json:1-3` — only workspace runtime setting currently present.
5. `extensions/9router-for-github-copilot-2.0.0.vsix` archive members `extension/package.json`, `extension.vsixmanifest`, `extension/readme.md`, `extension/out/extension.js` — provider, commands, endpoint and executable artifact boundary.

### If you need to extend this repo

- Add/update agent behavior only in the relevant `.github/agents/*.agent.md`, after schema/contract validation exists.
- Update orchestration/handoff policy in `team-lead.agent.md` and validate every target/name/model ID.
- Update operator/setup claims in `README.md` together with the actual `.vscode` policy.
- Treat VSIX changes as a separately reviewed supply-chain release; do not patch the binary blindly.

### Watch out for

- Missing Settings Sync exclusion despite README assertion.
- Unverified third-party executable VSIX from a different upstream repository.
- Custom model IDs and prompt-only safety rules that may silently fail or be ignored.
- Tool-calling and verbose logging crossing the code/privacy trust boundary.

## Review conclusion

**Overall: useful prompt-workflow prototype, not yet a verified production-safe distribution.** The agent organization and explicit human-gate intent are coherent, but operational correctness depends on external Copilot/router behavior. The highest-priority action is to establish VSIX provenance and constrain model/tool/data trust before installing or using it on sensitive repositories. Review completed with no source/config/agent modifications and no tests claimed or run.
