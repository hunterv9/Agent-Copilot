# Agent Permissions

## Nhóm quyền

| Nhóm | Tools | Mục đích |
|---|---|---|
| Read-only | `read`, `search`, `web` | Đọc và phân tích |
| Code modification | thêm `edit` | Sửa file |
| Execution | thêm `execute` | Chạy test/build/lệnh |
| Orchestration | thêm `agent` | Gọi agent khác |
| High-risk | `execute`, deployment hoặc security scan | Chỉ dùng khi cần và phải review |

## Chính sách hiện tại

| Agent | Quyền chính | Ghi chú |
|---|---|---|
| PM | Read, edit, search, web, todo | Không cần execute |
| Architect | Read, edit, search, execute, web, todo | Execute chỉ để khảo sát/kiểm chứng |
| UX/UI | Read, edit, search, web, todo | Không dùng artifact tool |
| Dev | Read, edit, search, execute, web, todo | Phải tự verify thay đổi |
| Test | Read, edit, search, execute, web, todo | Chạy test trong phạm vi |
| Security | Read, edit, search, execute, web, todo | Không test production nếu chưa được cấp phép |
| QC | Read, search, web | Chỉ review evidence, không execute |
| DevOps | Read, edit, search, execute, web, todo | Không tự deploy production |
| Team Lead | Có `agent` | Điều phối, không bỏ qua human gate |

## Nguyên tắc

- Chỉ cấp tool cần thiết cho nhiệm vụ.
- Prompt không thay thế permission boundary.
- Không in hoặc commit secret.
- Production deployment luôn cần human approval.
