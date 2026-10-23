import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ShareDocumentDialog extends StatefulWidget {
  final String documentId;
  final String documentTitle;
  final String ownerEmail;

  const ShareDocumentDialog({
    super.key,
    required this.documentId,
    required this.documentTitle,
    required this.ownerEmail,
  });

  @override
  State<ShareDocumentDialog> createState() => _ShareDocumentDialogState();
}

class _ShareDocumentDialogState extends State<ShareDocumentDialog> {
  final TextEditingController _emailController = TextEditingController();
  String _selectedPermission = 'VIEW'; // 'VIEW' hoặc 'EDIT'
  bool _isLoading = false;
  List<Map<String, dynamic>> _permissions = [];

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    final list = await SupabaseService.getDocumentPermissions(widget.documentId);
    setState(() {
      _permissions = list;
      _isLoading = false;
    });
  }

  Future<void> _handleShare() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email hợp lệ!')),
      );
      return;
    }

    if (email.toLowerCase() == widget.ownerEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn là chủ sở hữu, không cần chia sẻ cho chính mình!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await SupabaseService.shareDocument(
      documentId: widget.documentId,
      targetEmail: email,
      permissionType: _selectedPermission,
    );

    setState(() => _isLoading = false);

    if (success) {
      _emailController.clear();
      _loadPermissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chia sẻ thành công cho $email với quyền $_selectedPermission!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chia sẻ thất bại. Vui lòng thử lại!')),
        );
      }
    }
  }

  Future<void> _handleRevoke(String permissionId, String email) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận thu hồi quyền?'),
        content: Text('Bạn có chắc muốn thu hồi quyền truy cập của $email?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Thu hồi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.revokePermission(permissionId);
      _loadPermissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thu hồi quyền của $email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.share, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chia sẻ tài liệu',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.documentTitle,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Form nhập Email và Quyền
            const Text(
              'Thêm người dùng được cấp quyền:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Nhập email sinh viên (vd: user@gmail.com)',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedPermission,
                  items: const [
                    DropdownMenuItem(value: 'VIEW', child: Text('Chỉ xem')),
                    DropdownMenuItem(value: 'EDIT', child: Text('Được sửa')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPermission = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleShare,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Cấp quyền chia sẻ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Danh sách người có quyền truy cập:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Danh sách Permissions
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                  : _permissions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Chưa có tài khoản nào được chia sẻ.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _permissions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final p = _permissions[idx];
                            final email = p['shared_with_email'] ?? '';
                            final type = p['permission_type'] ?? 'VIEW';
                            final permId = p['id'].toString();

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: type == 'EDIT' ? Colors.orange : Colors.green,
                                child: Icon(
                                  type == 'EDIT' ? Icons.edit : Icons.visibility,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(email, style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Text(
                                type == 'EDIT' ? 'Quyền chỉnh sửa (Editor)' : 'Quyền chỉ xem (Viewer)',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                                tooltip: 'Thu hồi quyền',
                                onPressed: () => _handleRevoke(permId, email),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
