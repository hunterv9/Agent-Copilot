# MODEL_IDS

## ID đang dùng
- `claude-opus-5`: Architect, PM, UX/UI, Dev, Test, Security, QC
- `claude-fable-5-1`: Team Lead, DevOps, OpenCode Dev

## Quy tắc
- Frontmatter `model` chỉ dùng 2 ID trên.
- Handoff `model` khớp frontmatter agent đích.
- ID tuỳ biến, phụ thuộc proxy/model picker. Không tồn tại = fallback không kiểm soát.
- Security, QC, production: thiếu bằng chứng runtime về model đã resolve = fail closed, dừng gate.

## Đổi model thật
- Sửa ID theo model picker môi trường, ví dụ `GPT-5.2`.
- Cập nhật file này + `CHANGELOG.md`.
