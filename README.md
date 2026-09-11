# Agent Copilot

Bộ custom agents (`.agent.md`) cho GitHub Copilot trong VS Code: một team ảo 9 agent phối hợp theo pipeline, từ ý tưởng tới production.

## Danh sách agent

| Agent | Vai trò | Gọi trực tiếp |
|-------|---------|---------------|
| `team-lead` | Điều phối toàn bộ workflow, triage task → chọn pipeline tối thiểu | ✅ |
| `architect` | Discovery: vẽ bản đồ repo (`REPO_MAP.md`) · Greenfield: thiết kế kiến trúc mới (`ARCHITECTURE.md`, ADR, C4) | ✅ |
| `pm` | Yêu cầu, user story, acceptance criteria, PRD | ✅ |
| `ux-ui` | Mockup HTML tương tác + user flow Mermaid + design tokens | ✅ |
| `dev` | Implement, fix bug, refactor | ✅ |
| `test` | Chiến lược test, test case, bug report | ✅ |
| `security` | Threat modeling, OWASP Top 10, pentest, SAST/DAST/SCA | ✅ |
| `qc` | Quality gate: chấm điểm, verdict APPROVED / CONDITIONAL / REJECTED | ✅ |
| `devops` | CI/CD, IaC, deployment, rollback, monitoring | ✅ |

## Cách hoạt động

Chỉ cần gọi **Team Lead**, mô tả mục tiêu/task. Team Lead sẽ tự gọi các agent chuyên môn bằng agent tool; bạn không cần bấm handoff trong workflow bình thường. Handoff trên giao diện chỉ là phương án dự phòng nếu runtime không cho phép gọi subagent tự động.

Team Lead sẽ:

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
3. Tự giao việc, truyền đầy đủ report giữa các phase, chạy các phase độc lập song song khi runtime hỗ trợ, verify gate và trả **Team Status Report**.
4. Với task vừa/lớn hoặc có rủi ro, cho 2–3 agent đề xuất độc lập, phản biện chéo, sau đó để QC lập decision matrix trước khi chọn phương án. Báo cáo phải ghi rõ phương án bị loại, bằng chứng quyết định và bất đồng còn lại.
5. Chỉ dừng để bạn quyết định ở human gate cho thay đổi lớn hoặc triển khai production; Team Lead không tự triển khai production.

### Log tiến độ trực tiếp

Team Lead phải cập nhật trong chat trong lúc workflow chạy, không chỉ trả kết quả cuối:

- `🚦 [WORKFLOW]`: pipeline và phase bị bỏ qua.
- `📤 [DISPATCH]`: agent nào nhận việc, phạm vi, đầu ra cần có, chạy song song hay không.
- `⏳ [WAITING]`: đang chờ agent nào và chờ điều gì.
- `✅ [DONE]`: agent đã xong, report/artifact nhận được và kết quả gate.
- `⚠️ [BLOCKED]`: blocker, ảnh hưởng và người xử lý tiếp theo.
- `🧠 [DECISION]`: các phương án, bằng chứng, lựa chọn cuối, phương án bị loại và bất đồng.

Mỗi cập nhật quan trọng phải kèm work board ngắn gồm `Agent`, `Task`, `Status`, `Output / blocker`. Nếu VS Code thu gọn log nội bộ của subagent, các status message của Team Lead là audit trail hiển thị chính thức.

### Cơ chế tranh luận

- Task nhỏ, rủi ro thấp: một agent phù hợp xử lý trực tiếp.
- Task vừa/lớn: 2–3 agent độc lập đưa ra phương án với trade-off, rủi ro, khả năng kiểm thử và mức tự tin.
- Security tham gia khi có auth, PII, payment, crypto, input parsing, dependency hoặc infrastructure; Test đánh giá acceptance criteria và regression risk.
- QC chấm điểm correctness, security, data integrity, maintainability, operability, performance, testability và delivery risk; Team Lead chọn phương án dựa trên bằng chứng, không chỉ theo đa số.
- Nếu không thể giải quyết bất đồng bằng bằng chứng, Team Lead phải dừng ở human gate thay vì tự đoán.

## Cài đặt

**Option A — theo repo (khuyên dùng):** copy thư mục `.github/agents/` vào repo của bạn, cả team dùng chung, version theo git.

**Option B — global:** trỏ setting `chat.agentFilesLocations` tới thư mục `.github/agents/` này.

## Lưu ý về model

Frontmatter đang dùng `model: "Free_Model"` — dành cho setup proxy nhiều model. Proxy của bạn phải expose đúng model ID `Free_Model` trong model picker của VS Code, nếu không Copilot sẽ fallback về model đang chọn. Muốn cố định model thật thì sửa thành tên chuẩn, ví dụ `model: 'GPT-5.2'` hoặc `model: 'Claude Sonnet 4.5 (copilot)'`.

## Extension phụ trợ — 9Router (proxy model)

Team này dùng `model: "Free_Model"` qua proxy. Cài đúng 1 router duy nhất từ file đính kèm trong repo:

```powershell
code --install-extension .\extensions\9router-for-github-copilot-2.0.0.vsix --force
```

- KHÔNG cài thêm router khác (`xiaomimimo-for-copilot`...): 2 router cùng hook Copilot sẽ đánh nhau và vỡ auth.
- KHÔNG để router roam theo Settings Sync (đã chặn bằng `settingsSync.ignoredExtensions`) — máy/server nào cần thì cài tay từ file vsix này.

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
extensions/
  9router-for-github-copilot-2.0.0.vsix
```
