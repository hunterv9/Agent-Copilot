# Compatibility Matrix

| Thành phần | Phiên bản/cấu hình | Trạng thái |
|---|---|---|
| VS Code | Môi trường người dùng | Chưa xác minh tự động |
| GitHub Copilot Chat/Agent | Môi trường người dùng | Chưa xác minh tự động |
| Custom agents | `.github/agents/*.agent.md` | Đã kiểm tra bằng CI |
| Team Lead model | `claude-fable-5-1` | Phụ thuộc provider/router |
| Specialist model | `claude-opus-5` | Phụ thuộc provider/router |
| 9Router VSIX | `extensions/9router-for-github-copilot-2.0.0.vsix` | Chưa kiểm chứng provenance |
| Inference server | OpenAI-compatible endpoint | Phụ thuộc cấu hình local |
| OpenCode CLI | Tùy môi trường | Không bắt buộc |

## Trạng thái xác minh

- **Verified:** Được kiểm tra bằng repository hoặc CI.
- **Configured:** Đã khai báo nhưng chưa kiểm tra runtime đầy đủ.
- **Unknown:** Chưa xác minh.

## Giới hạn

- Model ID phải tồn tại trong model picker/provider.
- Custom agent không tự cài model hoặc router.
- CI chỉ kiểm tra cấu hình file, không kiểm tra VS Code runtime.
- Không xem workflow là production-ready nếu chưa kiểm tra router, endpoint và quyền tool.
