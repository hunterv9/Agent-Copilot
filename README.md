# Agent Copilot

Bộ custom agents (`.agent.md`) cho GitHub Copilot trong VS Code: một team ảo 9 agent phối hợp theo pipeline, từ ý tưởng tới production.

## Danh sách agent

| Agent | Vai trò | Gọi trực tiếp |
|-------|---------|---------------|
| `team-lead` | Điều phối toàn bộ workflow, triage task → chọn pipeline tối thiểu | ✅ |
| `architect` | Discovery: vẽ bản đồ repo (`REPO_MAP.md`) · Greenfield: thiết kế kiến trúc mới (`ARCHITECTURE.md`, ADR, C4) | ✅ |
| `pm` | Yêu cầu, user story, acceptance criteria, PRD | subagent |
| `ux-ui` | Mockup HTML tương tác + user flow Mermaid + design tokens | subagent |
| `dev` | Implement, fix bug, refactor | subagent |
| `test` | Chiến lược test, test case, bug report | subagent |
| `security` | Threat modeling, OWASP Top 10, pentest, SAST/DAST/SCA | ✅ |
| `qc` | Quality gate: chấm điểm, verdict APPROVED / CONDITIONAL / REJECTED | subagent |
| `devops` | CI/CD, IaC, deployment, rollback, monitoring | subagent |

## Cách hoạt động

Chỉ cần gọi **Team Lead**, mô tả task. Nó sẽ:

1. **Triage** — phân loại task, chọn pipeline nhỏ nhất an toàn (không full pipeline mặc định):

| Pipeline | Khi nào |
|----------|---------|
| Exploration | Chỉ hỏi, không sửa code → Architect only |
| Quick Fix | Typo, config 1 file → Dev (+ Test smoke) |
| Bug Fix | Bug có repro → Dev → Test → QC light |
| Standard Feature | Yêu cầu rõ, vùng ít rủi ro → Dev → Test → QC → DevOps (nếu release) |
| Full Release | API public, auth/payment/PII, migration, infra → full 0–7 |
| Hotfix | Sự cố production → Dev → Test → QC nhanh → DevOps |
| Solution Design | Hệ thống mới / tái kiến trúc → Architect → PM → Dev |

2. **Công bố pipeline + phase bị skip kèm lý do** trước khi chạy (bạn có thể override).
3. Thực thi từng phase, verify gate, trả **Team Status Report**.

## Cài đặt

**Option A — theo repo (khuyên dùng):** copy thư mục `.github/agents/` vào repo của bạn, cả team dùng chung, version theo git.

**Option B — global:** trỏ setting `chat.agentFilesLocations` tới thư mục `.github/agents/` này.

## Lưu ý về model

Frontmatter đang dùng `model: "Free_Model"` — dành cho setup proxy nhiều model. Proxy của bạn phải expose đúng model ID `Free_Model` trong model picker của VS Code, nếu không Copilot sẽ fallback về model đang chọn. Muốn cố định model thật thì sửa thành tên chuẩn, ví dụ `model: 'GPT-5.2'` hoặc `model: 'Claude Sonnet 4.5 (copilot)'`.

## Cấu trúc

```
.github/
  agents/
    team-lead.agent.md
    architect.agent.md
    pm.agent.md
    ux-ui.agent.md
    dev.agent.md
    test.agent.md
    security.agent.md
    qc.agent.md
    devops.agent.md
```
