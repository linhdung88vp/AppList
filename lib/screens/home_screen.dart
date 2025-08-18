import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'add_gara_screen.dart';
import 'gara_detail_screen.dart';
import '../widgets/gara_card.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/modern_ui_widgets.dart';
import '../utils/animation_utils.dart';
import '../models/gara.dart';
import '../providers/gara_provider.dart';
import '../config/firebase_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  FirebaseFirestore? _firestore; // null nếu Firebase chưa init (Web)
  String _searchQuery = '';
  String _selectedDistrict = 'Tất cả quận';
  bool _isSearchExpanded = false;

  // 30 quận/huyện ở Hà Nội
  final List<String> _hanoiDistricts = [
    'Tất cả quận',
    'Ba Đình',
    'Hoàn Kiếm',
    'Hai Bà Trưng',
    'Đống Đa',
    'Tây Hồ',
    'Cầu Giấy',
    'Thanh Xuân',
    'Hoàng Mai',
    'Long Biên',
    'Nam Từ Liêm',
    'Bắc Từ Liêm',
    'Hà Đông',
    'Sơn Tây',
    'Ba Vì',
    'Phúc Thọ',
    'Đan Phượng',
    'Hoài Đức',
    'Quốc Oai',
    'Thạch Thất',
    'Chương Mỹ',
    'Thanh Oai',
    'Thường Tín',
    'Phú Xuyên',
    'Ứng Hòa',
    'Mỹ Đức',
    'Gia Lâm',
    'Đông Anh',
    'Sóc Sơn',
    'Mê Linh',
    'Phú Thọ',
  ];

  late AnimationController _headerController;
  late AnimationController _searchController;
  late Animation<double> _headerAnimation;
  late Animation<Offset> _searchSlideAnimation;

  @override
  void initState() {
    super.initState();
    // Chỉ set Firestore khi đã init
    _firestore = FirebaseConfig.isInitialized ? FirebaseConfig.firestore : null;
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _searchSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _searchController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getUserName() {
    // TODO: Get actual user name from auth provider
    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Modern Header with Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFFF093FB),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // Header Content with Animation
                    FadeTransition(
                      opacity: _headerAnimation,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào, ${_getUserName()} 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'GARA MANAGEMENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ModernIconButton(
                            icon: Icons.notifications_outlined,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            iconColor: Colors.white,
                            size: 48,
                            iconSize: 24,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Modern Search Bar
                    SlideTransition(
                      position: _searchSlideAnimation,
                      child: FadeTransition(
                        opacity: _searchController,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF667EEA),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm theo tên, địa chỉ, số điện thoại...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F2937),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              
                              ModernIconButton(
                                icon: Icons.tune,
                                backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                                iconColor: const Color(0xFF667EEA),
                                size: 40,
                                iconSize: 20,
                                onPressed: () {
                                  setState(() {
                                    _isSearchExpanded = !_isSearchExpanded;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Expandable Filter Section
                    if (_isSearchExpanded) ...[
                      const SizedBox(height: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lọc theo quận/huyện:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: _hanoiDistricts.length,
                                itemBuilder: (context, index) {
                                  final district = _hanoiDistricts[index];
                                  final isSelected = _selectedDistrict == district;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ModernChip(
                                      label: district,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() {
                                          _selectedDistrict = district;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Gara List Section (Firestore nếu có, nếu không dùng local provider)
          Expanded(
            child: _firestore == null
                ? _buildLocalList(context)
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore!.collection('garas').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SkeletonLoadingList(itemCount: 6);
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Có lỗi xảy ra',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vui lòng thử lại sau',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final garas = snapshot.data?.docs ?? [];
                      final filteredGaras = garas.where((doc) {
                        final gara = Gara.fromFirestore(doc);
                        
                        // Tìm kiếm theo tên gara, địa chỉ, số điện thoại
                        final matchesSearch = _searchQuery.isEmpty || 
                          gara.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          gara.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          gara.phoneNumbers.any((phone) => phone.toLowerCase().contains(_searchQuery.toLowerCase()));
                        
                        // Lọc theo quận/huyện
                        final matchesDistrict = _selectedDistrict == 'Tất cả quận' || 
                          gara.address.toLowerCase().contains(_selectedDistrict.toLowerCase());
                        
                        return matchesSearch && matchesDistrict;
                      }).toList();

                      if (filteredGaras.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty ? Icons.search_off : Icons.business,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty ? 'Không tìm thấy gara' : 'Chưa có gara nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty 
                                  ? 'Thử tìm kiếm với từ khóa khác'
                                  : 'Thêm gara đầu tiên để bắt đầu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredGaras.length,
                        itemBuilder: (context, index) {
                          final gara = Gara.fromFirestore(filteredGaras[index]);
                          final garaData = filteredGaras[index].data() as Map<String, dynamic>;
                          final garaId = filteredGaras[index].id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GaraCard(
                              gara: garaData,
                              garaId: garaId,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GaraDetailScreen(gara: gara),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimationUtils.scaleAnimation(
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddGaraScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Thêm Gara',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalList(BuildContext context) {
    final provider = context.watch<GaraProvider>();
    // Áp dụng filter
    final filtered = provider.garas.where((g) {
      final matchesSearch = _searchQuery.isEmpty ||
          g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.phoneNumbers.any((p) => p.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesDistrict = _selectedDistrict == 'Tất cả quận' ||
          g.address.toLowerCase().contains(_selectedDistrict.toLowerCase());
      return matchesSearch && matchesDistrict;
    }).toList();

    if (provider.isLoading) {
      return const SkeletonLoadingList(itemCount: 6);
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.business,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'Không tìm thấy gara' : 'Chưa có gara nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty 
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Thêm gara đầu tiên để bắt đầu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final g = filtered[index];
        return ModernCard(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(g.address, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 6),
              Text('Liên hệ: ${g.phoneNumbers.join(', ')}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        );
      },
    );
  }
}

