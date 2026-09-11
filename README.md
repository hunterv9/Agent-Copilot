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
### Chống chạy vô hạn

Team Lead có ngân sách cố định để tránh chạy hàng chục phút hoặc cả ngày:

- Exploration: tối đa 8 tool calls.
- Quick Fix: tối đa 12 tool calls.
- Bug Fix: tối đa 24 tool calls.
- Standard Feature: tối đa 36 tool calls.
- Full Release/Dev Swarm: tối đa 50 tool calls.

Đây là ngân sách do prompt yêu cầu Team Lead tự đếm để chống chạy vô hạn, không phải cam kết giới hạn cứng của host. `chat.agent.maxRequests` trong workspace là trần runtime riêng (hiện là `50` request theo tên setting); repo chưa xác minh request của host có cùng đơn vị/phạm vi với “tool calls” của pipeline. Không được coi hai con số là tương đương hoặc cộng dồn; khi một trần không rõ hiệu lực, Team Lead phải dừng và báo giới hạn runtime.

Team Lead phải dừng nếu hai lần gọi liên tiếp không tạo thêm bằng chứng/kết quả, không retry lỗi quá một lần, và không tự retry toàn bộ context khi router báo `aborted`, `timeout`, `context length` hoặc lỗi transport. Thay đổi trên 3 file, nhiều module hoặc archive/delete thư mục phải quay lại human plan gate.

### Cơ chế tranh luận

- Task nhỏ, rủi ro thấp: một agent phù hợp xử lý trực tiếp.
- Task vừa/lớn: 2–3 agent độc lập đưa ra phương án với trade-off, rủi ro, khả năng kiểm thử và mức tự tin.
- Security tham gia khi có auth, PII, payment, crypto, input parsing, dependency hoặc infrastructure; Test đánh giá acceptance criteria và regression risk.
- QC chấm điểm correctness, security, data integrity, maintainability, operability, performance, testability và delivery risk; Team Lead chọn phương án dựa trên bằng chứng, không chỉ theo đa số.
- Nếu không thể giải quyết bất đồng bằng bằng chứng, Team Lead phải dừng ở human gate thay vì tự đoán.

## Cài đặt

**Option A — theo repo (khuyên dùng):** copy thư mục `.github/agents/` vào repo của bạn, cả team dùng chung, version theo git.

**Option B — global:** trỏ setting `chat.agentFilesLocations` tới thư mục `.github/agents/` này.

## Lưu ý về model và fallback

Frontmatter đang dùng hai model ID tuỳ biến:

- `Free_Model`: dùng cho các agent chi phí thấp và proxy nhiều model.
- `Team_Lead`: dùng cho Team Lead và một số agent cần điều phối/thiết kế.

Proxy/host phải expose đúng các ID này trong model picker. Nếu ID không tồn tại, bị đổi tên hoặc provider không resolve được, runtime **có thể** fallback về model đang chọn hoặc một model mặc định; repo không kiểm soát và chưa xác minh chính sách fallback đó. Vì vậy tên trong frontmatter không phải bằng chứng model thực tế hay model family. Với Security, QC và mọi công việc production, nếu không có bằng chứng runtime về model đã resolve thì phải fail closed, dừng gate/dispatch và yêu cầu người dùng xác minh. Muốn cố định model thật thì sửa ID theo model picker của môi trường, ví dụ `GPT-5.2` hoặc `Claude Sonnet 4.5 (copilot)`.

## Extension phụ trợ — 9Router (proxy model)

Team này dùng các model ID tuỳ biến qua proxy. VSIX là binary executable của bên thứ ba; source, build provenance, chữ ký và quan hệ publisher chưa được xác minh độc lập. Không coi việc file nằm trong repo hoặc có checksum là bằng chứng authenticity. Chỉ cài sau khi quy trình bảo mật của môi trường đã phê duyệt artifact và endpoint.

Nếu đã phê duyệt, cài đúng 1 router duy nhất từ file đính kèm trong repo, **không dùng `--force` mặc định**:

```powershell
code --install-extension .\extensions\9router-for-github-copilot-2.0.0.vsix
```

- KHÔNG cài thêm router khác (`xiaomimimo-for-copilot`...): 2 router cùng hook Copilot sẽ đánh nhau và vỡ auth.
- `.vscode/settings.json` của repo **không** cấu hình `settingsSync.ignoredExtensions`; README không thể khẳng định extension bị chặn khỏi Settings Sync. Chính sách Settings Sync là user/server-level và phụ thuộc VS Code, vì vậy hãy kiểm tra policy thực tế trên từng máy; cài tay không tự tạo ra cơ chế chặn sync.
- SHA-256 quan sát được của file hiện tại là `97314D7C3B0DB6FAE0188C76E3E2D55316C20672A30CF64E4B420C00253C5DE1`. Hash này chỉ dùng để phát hiện file đã thay đổi sau khi được cung cấp/duyệt; một hash tự công bố **không chứng minh** nguồn gốc, publisher, chữ ký hay an toàn của VSIX.

## Ranh giới dữ liệu và rủi ro runtime

- Prompt, đoạn code và context có thể được gửi tới server inference được cấu hình trong router (mặc định được quan sát là localhost, nhưng server URL có thể đổi). Không hứa rằng dữ liệu chỉ ở local: Copilot/VS Code host vẫn có thể có các luồng title, auth, telemetry hoặc dịch vụ riêng; chính sách TLS, retention và endpoint remote cần được xác minh theo môi trường.
- Tool-calling làm model/router có thể đề xuất thao tác qua các tool agent đã khai báo. Prompt safety không phải permission boundary; endpoint hoặc prompt injection bị compromise có thể tạo đề xuất đọc/sửa file, chạy lệnh hoặc truy cập web. Chỉ bật với endpoint/model tin cậy và xem xét confirmation của host trước thao tác nhạy cảm.
- `verboseLogging` nếu bật có thể ghi request chat đầy đủ, messages và tool arguments vào Output channel. Tắt mặc định không thay thế policy retention/redaction; không bật trong workspace có secret hoặc dữ liệu nhạy cảm nếu chưa có kiểm soát phù hợp.

## Kiểm tra cấu hình agent

Validator chỉ đọc file, không gọi network, không chạy VSIX và không cài extension. Chạy từ root repo:

```powershell
powershell -NoProfile -File .\scripts\validate-agents.ps1
```

Script sẽ kiểm tra 9 agent bắt buộc, frontmatter, tool/model allowlist, Team Lead agents và handoffs, JSON settings, VSIX được README tham chiếu, và các yêu cầu tool trong prompt nhưng không được khai báo. Exit code khác `0` nghĩa là có lỗi cần xử lý.

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
scripts/
  validate-agents.ps1
```
