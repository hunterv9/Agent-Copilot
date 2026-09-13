# Agent Prompt Conventions

Mỗi agent nên tuân theo cấu trúc sau:

## 1. Frontmatter

Phải có:

```yaml
name: "Agent Name"
description: "When to use this agent"
tools: [read, search]
user-invocable: true
model: "claude-opus-5"
```

Chỉ sử dụng model:

```
claude-fable-5-1
claude-opus-5
```

## 2. Quy tắc prompt

Nên có các phần:

- Mục tiêu chính.
- Phạm vi được phép.
- Công cụ được sử dụng.
- Quy tắc bảo mật.
- Cách tự kiểm chứng.
- Format báo cáo ngắn.

## 3. Quy tắc chung

- Hành động trực tiếp thay vì giải thích dài.
- Chỉ đọc/sửa file liên quan.
- Không tự mở rộng phạm vi.
- Không giả vờ đã chạy test hoặc tool.
- Báo rõ lỗi, blocker và evidence.
- Không in secret hoặc credential.
- Không deploy production nếu thiếu human approval.

## 4. Báo cáo

Báo cáo nên gồm:

1. File đã đọc hoặc sửa.
2. Thay đổi chính.
3. Lệnh/test đã chạy.
4. Kết quả.
5. Blocker hoặc bước tiếp theo.
