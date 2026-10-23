import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../providers/material_provider.dart';
import '../database/database.dart';
import '../struct/material_meta.dart';
import 'add_edit_material_page.dart';
import '../widgets/share_document_dialog.dart';
import '../widgets/borrow_request_dialog.dart';
import '../widgets/borrow_management_dialog.dart';
import '../widgets/interactive_location_map_widget.dart';
import '../widgets/recommendations_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0; // 0: Documents, 1: Map/Location, 2: Recommendations, 3: Borrow/Lend
  bool _isSigningIn = false;

  final List<String> _filters = [
    'Tất cả',
    'Bài giảng',
    'Bài tập',
    'Tài liệu tham khảo',
    'Tài liệu vật lý',
    'Đang mượn',
    'Yêu thích',
    'Đã xong',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMaterialPage()),
    );
  }

  void _openEditPage(StudyMaterial material) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditMaterialPage(material: material)),
    );
  }

  void _openShareDialog(BuildContext context, StudyMaterial item) {
    showDialog(
      context: context,
      builder: (ctx) => ShareDocumentDialog(
        documentId: item.id.toString(),
        documentTitle: item.title,
        ownerEmail: AuthService.currentUser?.email ?? 'phamanhh25@gmail.com',
      ),
    );
  }

  void _openBorrowDialog(BuildContext context, StudyMaterial item) {
    showDialog(
      context: context,
      builder: (ctx) => BorrowRequestDialog(material: item),
    );
  }

  void _openBorrowManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const BorrowManagementDialog(),
    );
  }

  void _confirmDelete(BuildContext context, StudyMaterial material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa tài liệu?'),
        content: Text('Bạn có chắc chắn muốn xóa "${material.title}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MaterialProvider>(context, listen: false).deleteMaterial(material);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa tài liệu thành công!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MaterialProvider>(context);
    final pendingBorrowCount = provider.incomingRequestsToApprove
        .where((r) => r.status == 'PENDING')
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopOrWeb = constraints.maxWidth >= 850;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: _buildAppBar(context, pendingBorrowCount),
          body: isDesktopOrWeb
              ? Row(
                  children: [
                    // Desktop / Web Sidebar Navigation Rail
                    _buildNavigationRail(pendingBorrowCount),
                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    // Main Content
                    Expanded(child: _buildCurrentTabContent(provider, isDesktop: true)),
                  ],
                )
              : _buildCurrentTabContent(provider, isDesktop: false),
          bottomNavigationBar: isDesktopOrWeb ? null : _buildBottomNavBar(pendingBorrowCount),
          floatingActionButton: _currentTabIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: _openAddPage,
                  backgroundColor: const Color(0xFF1E88E5),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Thêm tài liệu',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int pendingBorrowCount) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, color: Color(0xFF1E88E5), size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản lý Tài liệu Đa nền tảng',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Phạm Quang Anh - 2351170573 - 65KTPM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Nút mở nhanh Quản lý mượn trả
        IconButton(
          tooltip: 'Quản lý mượn trả',
          icon: Badge(
            isLabelVisible: pendingBorrowCount > 0,
            label: Text('$pendingBorrowCount'),
            child: const Icon(Icons.handshake_outlined, color: Color(0xFF1E88E5)),
          ),
          onPressed: () => _openBorrowManagement(context),
        ),

        // Auth Google profile
        StreamBuilder<User?>(
          stream: AuthService.authStateChanges,
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user != null) {
              return PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == 'logout') {
                    await AuthService.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã đăng xuất Google')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      user.displayName ?? user.email ?? 'Google User',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFF1E88E5),
                    backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                    child: user.photoURL == null
                        ? Text(
                            (user.displayName ?? user.email ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              );
            }
            if (_isSigningIn) {
              return const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E88E5)),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _isSigningIn = true);
                    final cred = await AuthService.signInWithGoogle();
                    setState(() => _isSigningIn = false);
                    if (cred != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Chào mừng ${cred.user?.displayName ?? cred.user?.email}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Đăng nhập Google', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationRail(int pendingBorrowCount) {
    return NavigationRail(
      selectedIndex: _currentTabIndex,
      onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      selectedIconTheme: const IconThemeData(color: Color(0xFF1E88E5)),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF1E88E5),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: Text('Tài liệu'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: Text('Bản đồ'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome),
          label: Text('Gợi ý AI'),
        ),
        NavigationRailDestination(
          icon: Badge(
            isLabelVisible: pendingBorrowCount > 0,
            label: Text('$pendingBorrowCount'),
            child: const Icon(Icons.sync_alt_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: pendingBorrowCount > 0,
            label: Text('$pendingBorrowCount'),
            child: const Icon(Icons.sync_alt),
          ),
          label: const Text('Mượn / Trả'),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(int pendingBorrowCount) {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) => setState(() => _currentTabIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E88E5),
      unselectedItemColor: const Color(0xFF64748B),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          activeIcon: Icon(Icons.folder),
          label: 'Tài liệu',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Bản đồ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: 'Gợi ý AI',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: pendingBorrowCount > 0,
            label: Text('$pendingBorrowCount'),
            child: const Icon(Icons.sync_alt_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: pendingBorrowCount > 0,
            label: Text('$pendingBorrowCount'),
            child: const Icon(Icons.sync_alt),
          ),
          label: 'Mượn / Trả',
        ),
      ],
    );
  }

  Widget _buildCurrentTabContent(MaterialProvider provider, {required bool isDesktop}) {
    switch (_currentTabIndex) {
      case 1:
        return _buildMapTab(provider);
      case 2:
        return RecommendationsView(
          onOpenMaterial: (mat) => _openEditPage(mat),
        );
      case 3:
        return const BorrowManagementDialog();
      case 0:
      default:
        return _buildDocumentsTab(provider, isDesktop: isDesktop);
    }
  }

  Widget _buildMapTab(MaterialProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Định vị & Quản lý Vị trí Tài liệu Vật lý',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text(
                  'Bản đồ khuôn viên trường, Thư viện và Phòng Lab. Tìm kiếm tài liệu theo kệ sách thực tế.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          InteractiveLocationMapWidget(
            materials: provider.allRawMaterials,
            userLat: provider.userProfile.latitude ?? 21.028511,
            userLng: provider.userProfile.longitude ?? 105.854167,
            onSelectMaterial: (mat) => _openEditPage(mat),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(MaterialProvider provider, {required bool isDesktop}) {
    final materials = provider.materials;
    final totalCount = provider.allRawMaterials.length;
    final completedCount = provider.allRawMaterials
        .where((m) => MaterialMeta.fromRaw(m.description).isCompleted)
        .length;
    final allTags = provider.allUniqueTags;

    return Column(
      children: [
        // Search & Stats Container
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Search input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.search(val),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tiêu đề, môn học, tag (#Flutter), vị trí...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              provider.search('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Thống kê nhanh
              Row(
                children: [
                  _buildStatPill('Tổng số', '$totalCount', const Color(0xFF1E88E5)),
                  const SizedBox(width: 8),
                  _buildStatPill('Đã xong', '$completedCount', const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildStatPill('Chưa xong', '${totalCount - completedCount}', const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildStatPill(
                    'Đang mượn',
                    '${provider.allRawMaterials.where((m) => MaterialMeta.fromRaw(m.description).borrowStatus == "BORROWED").length}',
                    const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tag cloud filter bar
        if (allTags.isNotEmpty) ...[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.tag, size: 16, color: Color(0xFF1E88E5)),
                const SizedBox(width: 6),
                const Text('Thẻ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allTags.map((tag) {
                        final isSelected = provider.selectedTags.contains(tag);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E88E5),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (_) => provider.toggleTagFilter(tag),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (provider.selectedTags.isNotEmpty)
                  TextButton(
                    onPressed: provider.clearTagFilters,
                    child: const Text('Bỏ lọc', style: TextStyle(fontSize: 11, color: Colors.red)),
                  ),
              ],
            ),
          ),
        ],

        // Type filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = provider.selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: isSelected,
                  label: Text(filter),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF1E88E5),
                  onSelected: (_) => provider.setFilter(filter),
                ),
              );
            }).toList(),
          ),
        ),

        // Materials List / Grid
        Expanded(
          child: materials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'Không tìm thấy tài liệu nào phù hợp'
                            : 'Chưa có tài liệu học tập nào',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bấm "+ Thêm tài liệu" để bắt đầu lưu trữ',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : isDesktop
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 460,
                        mainAxisExtent: 250,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final item = materials[index];
                        final meta = MaterialMeta.fromRaw(item.description);
                        return _buildMaterialCard(item, meta);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final item = materials[index];
                        final meta = MaterialMeta.fromRaw(item.description);
                        return _buildMaterialCard(item, meta);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatPill(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(StudyMaterial item, MaterialMeta meta) {
    Color badgeColor;
    String badgeEmoji;
    if (item.type == 'Bài tập') {
      badgeColor = const Color(0xFFE65100);
      badgeEmoji = '📑';
    } else if (item.type == 'Tài liệu tham khảo') {
      badgeColor = const Color(0xFF2E7D32);
      badgeEmoji = '📗';
    } else {
      badgeColor = const Color(0xFF1E88E5);
      badgeEmoji = '📖';
    }

    final isBorrowed = meta.borrowStatus == 'BORROWED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: meta.isCompleted ? const Color(0xFF10B981).withOpacity(0.4) : const Color(0xFFE2E8F0),
          width: meta.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openEditPage(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type badge & Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$badgeEmoji ${item.type}',
                        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Badge Vật lý vs Kỹ thuật số
                    if (meta.isPhysical)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.inventory_2, size: 12, color: Color(0xFF92400E)),
                            SizedBox(width: 4),
                            Text('Bản in', style: TextStyle(color: Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Mượn tài liệu button
                    if (meta.isAvailableForBorrow) ...[
                      InkWell(
                        onTap: () => _openBorrowDialog(context, item),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBorrowed ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isBorrowed ? Icons.person_pin : Icons.handshake,
                                size: 13,
                                color: isBorrowed ? const Color(0xFF991B1B) : const Color(0xFF166534),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isBorrowed ? 'Đang mượn' : 'Mượn',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isBorrowed ? const Color(0xFF991B1B) : const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Nút chia sẻ
                    IconButton(
                      icon: const Icon(Icons.share, size: 18, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Chia sẻ tài liệu',
                      onPressed: () => _openShareDialog(context, item),
                    ),
                    const SizedBox(width: 8),

                    // Nút xóa
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Xóa tài liệu',
                      onPressed: () => _confirmDelete(context, item),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tiêu đề
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Môn học
                Text(
                  meta.subject,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),

                // Tags chips
                if (meta.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: meta.tags.take(4).map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                ],

                // Vị trí vật lý nếu có
                if (meta.isPhysical && meta.locationName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.place, size: 13, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${meta.locationName} (${meta.shelfCode ?? "Kệ"})',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                // Trạng thái mượn chi tiết & hoàn thành
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isBorrowed && meta.borrowerName != null) ...[
                      Text(
                        'Người mượn: ${meta.borrowerName} (Hạn: ${meta.borrowDueDate ?? "Chưa rõ"})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFE11D48), fontWeight: FontWeight.w600),
                      ),
                    ] else ...[
                      Text(
                        meta.deadline != null ? 'Hạn: ${meta.deadline}' : 'Không hạn',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],

                    if (meta.isCompleted)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text('Đã xong', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
