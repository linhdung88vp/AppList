import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gara_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gara_list_item.dart';
import 'add_gara_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedArea = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Gara Ô tô'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          // Hiển thị thông tin user
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user != null) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (authProvider.user!.displayName?.isNotEmpty == true 
                          ? authProvider.user!.displayName!.substring(0, 1).toUpperCase()
                          : authProvider.user!.email!.substring(0, 1).toUpperCase()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog();
                    } else if (value == 'statistics') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'info',
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.user!.displayName ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            authProvider.user!.email!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (authProvider.isAdmin)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                                            const PopupMenuItem(
                          value: 'statistics',
                          child: Row(
                            children: [
                              Icon(Icons.analytics, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Thống kê'),
                            ],
                          ),
                        ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Đăng xuất'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GaraProvider>().refreshData();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search và Filter
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm gara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter theo khu vực
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bộ lọc khu vực:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedArea.isEmpty ? null : _selectedArea,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              labelText: 'Quận/Huyện',
                            ),
                            hint: const Text('Tất cả quận/huyện'),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Tất cả quận/huyện'),
                              ),
                              const DropdownMenuItem(
                                value: 'Hai Bà Trưng',
                                child: Text('Hai Bà Trưng'),
                              ),
                              const DropdownMenuItem(
                                value: 'Cầu Giấy',
                                child: Text('Cầu Giấy'),
                              ),
                              const DropdownMenuItem(
                                value: 'Đống Đa',
                                child: Text('Đống Đa'),
                              ),
                              const DropdownMenuItem(
                                value: 'Ba Đình',
                                child: Text('Ba Đình'),
                              ),
                              const DropdownMenuItem(
                                value: 'Hoàn Kiếm',
                                child: Text('Hoàn Kiếm'),
                              ),
                              const DropdownMenuItem(
                                value: 'Tây Hồ',
                                child: Text('Tây Hồ'),
                              ),
                              const DropdownMenuItem(
                                value: 'Long Biên',
                                child: Text('Long Biên'),
                              ),
                              const DropdownMenuItem(
                                value: 'Thanh Xuân',
                                child: Text('Thanh Xuân'),
                              ),
                              const DropdownMenuItem(
                                value: 'Hoàng Mai',
                                child: Text('Hoàng Mai'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedArea = value ?? '';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách gara
          Expanded(
            child: Consumer<GaraProvider>(
              builder: (context, garaProvider, child) {
                if (garaProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (garaProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          garaProvider.error!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            garaProvider.clearError();
                            garaProvider.refreshData();
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                List<dynamic> filteredGaras = garaProvider.garas;

                // Áp dụng search
                if (_searchQuery.isNotEmpty) {
                  filteredGaras = garaProvider.searchGaras(_searchQuery);
                }

                // Áp dụng filter theo khu vực
                if (_selectedArea.isNotEmpty) {
                  filteredGaras = garaProvider.filterGarasByArea(_selectedArea);
                }

                if (filteredGaras.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.car_repair_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedArea.isNotEmpty
                              ? 'Không tìm thấy gara nào'
                              : 'Chưa có gara nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty && _selectedArea.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Bấm nút + để thêm gara đầu tiên',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await garaProvider.refreshData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredGaras.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GaraListItem(gara: filteredGaras[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGaraScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Gara'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}
