import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import '../struct/borrow_request.dart';

class BorrowManagementDialog extends StatelessWidget {
  const BorrowManagementDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialProvider>(context);
    final incoming = provider.incomingRequestsToApprove;
    final outgoing = provider.myOutgoingRequests;

    return DefaultTabController(
      length: 2,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 600,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sync_alt, color: Color(0xFF1E88E5), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quản lý Mượn & Trả Tài liệu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Theo dõi yêu cầu mượn và phê duyệt luồng tài liệu',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
              const SizedBox(height: 16),

              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF475569),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(
                      text: 'Yêu cầu cần duyệt (${incoming.where((r) => r.status == "PENDING").length})',
                    ),
                    Tab(
                      text: 'Tài liệu tôi mượn (${outgoing.length})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TabBarView Content
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Incoming requests to approve
                    incoming.isEmpty
                        ? _buildEmptyState('Không có yêu cầu mượn nào gửi đến bạn.')
                        : ListView.separated(
                            itemCount: incoming.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final req = incoming[index];
                              return _buildIncomingRequestCard(context, provider, req);
                            },
                          ),

                    // Tab 2: Outgoing requests (My borrows)
                    outgoing.isEmpty
                        ? _buildEmptyState('Bạn chưa gửi yêu cầu mượn tài liệu nào.')
                        : ListView.separated(
                            itemCount: outgoing.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final req = outgoing[index];
                              return _buildOutgoingRequestCard(context, provider, req);
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingRequestCard(BuildContext context, MaterialProvider provider, BorrowRequest req) {
    final isPending = req.status == 'PENDING';
    final isApproved = req.status == 'APPROVED';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  req.documentTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(req.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Người yêu cầu: ${req.borrowerName} (${req.borrowerEmail})',
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                'Hạn trả: ${req.returnDate} • Gửi ngày: ${req.requestDate}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          if (req.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lý do: "${req.notes}"',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPending) ...[
                OutlinedButton(
                  onPressed: () => provider.rejectBorrowRequest(req),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Từ chối', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => provider.approveBorrowRequest(req),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Duyệt cho mượn', style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
              if (isApproved) ...[
                ElevatedButton.icon(
                  onPressed: () => provider.returnBorrowedDocument(req),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Xác nhận đã nhận lại sách', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingRequestCard(BuildContext context, MaterialProvider provider, BorrowRequest req) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  req.documentTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(req.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Chủ tài liệu: ${req.ownerEmail}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.alarm, size: 13, color: Color(0xFFE11D48)),
              const SizedBox(width: 4),
              Text(
                'Hạn trả sách: ${req.returnDate}',
                style: const TextStyle(fontSize: 11, color: Color(0xFFE11D48), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (req.locationName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place, size: 13, color: Color(0xFF10B981)),
                const SizedBox(width: 4),
                Text(
                  'Vị trí nhận: ${req.locationName} (${req.shelfCode ?? ""})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ],
          if (req.status == 'APPROVED') ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => provider.returnBorrowedDocument(req),
                icon: const Icon(Icons.assignment_return, size: 15),
                label: const Text('Báo đã trả sách', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'APPROVED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Đã duyệt';
        break;
      case 'REJECTED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Từ chối';
        break;
      case 'RETURNED':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Đã hoàn trả';
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Chờ duyệt';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }
}
