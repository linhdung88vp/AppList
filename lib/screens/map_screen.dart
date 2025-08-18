import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isAdmin = false;
  bool _isLoading = true;
  Position? _currentPosition;
  String _currentAddress = 'Đang lấy vị trí...';
  List<Marker> _userMarkers = [];
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _getCurrentLocation();
    _loadUserLocations();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _isAdmin = userData['role'] == 'admin';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isAdmin = false;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isAdmin = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Dịch vụ vị trí bị tắt';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Quyền vị trí bị từ chối';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Quyền vị trí bị từ chối vĩnh viễn';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}';
          });
        }
      } catch (e) {
        setState(() {
          _currentAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Không thể lấy vị trí: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bản đồ'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Truy cập bị từ chối',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chỉ admin mới có thể xem bản đồ',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bản đồ vị trí',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Làm mới vị trí',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Location Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Vị trí hiện tại:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (_currentPosition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Real Map with OpenStreetMap
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null 
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(21.0285, 105.8542), // Hà Nội
                    initialZoom: 13.0,
                    onMapReady: () {
                      _loadUserLocations();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.gara_management_app',
                    ),
                    // Current location marker
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // User location markers
                    MarkerLayer(
                      markers: _userMarkers,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // User Locations List
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Vị trí người dùng:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Lỗi: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final users = snapshot.data?.docs ?? [];

                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            'Chưa có người dùng nào',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index].data() as Map<String, dynamic>;
                          final hasLocation = user['latitude'] != null && user['longitude'] != null;
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: hasLocation ? Colors.green[100] : Colors.grey[100],
                              child: Icon(
                                hasLocation ? Icons.location_on : Icons.location_off,
                                color: hasLocation ? Colors.green[600] : Colors.grey[600],
                                size: 20,
                              ),
                            ),
                            title: Text(
                              user['displayName'] ?? user['email'] ?? 'Unknown User',
                              style: TextStyle(
                                fontWeight: hasLocation ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            subtitle: hasLocation
                                ? Text(
                                    '${user['latitude'].toStringAsFixed(4)}, ${user['longitude'].toStringAsFixed(4)}',
                                    style: TextStyle(
                                      color: Colors.green[600],
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    'Chưa có vị trí',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                            trailing: hasLocation
                                ? Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey[400],
                                  )
                                : null,
                            onTap: hasLocation ? () {
                              // Navigate to user location on map
                              _showUserLocationDialog(user);
                            } : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadUserLocations() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final List<Marker> markers = [];
      
      for (var doc in usersSnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        if (userData['latitude'] != null && userData['longitude'] != null) {
          final lat = userData['latitude'] as double;
          final lng = userData['longitude'] as double;
          final userName = userData['displayName'] ?? userData['email'] ?? 'Unknown User';
          final isOnline = userData['lastSeen'] != null;
          
          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 30,
              height: 30,
              child: GestureDetector(
                onTap: () => _showUserLocationDialog(userData),
                child: Container(
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isOnline ? Icons.person : Icons.person_off,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          );
        }
      }
      
      setState(() {
        _userMarkers = markers;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải vị trí user: $e');
    }
  }

  void _showUserLocationDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vị trí ${user['displayName'] ?? 'User'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email'] ?? 'N/A'}'),
            Text('Vĩ độ: ${user['latitude']}'),
            Text('Kinh độ: ${user['longitude']}'),
            if (user['lastSeen'] != null)
              Text('Lần cuối: ${user['lastSeen']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Di chuyển bản đồ đến vị trí user
              if (user['latitude'] != null && user['longitude'] != null) {
                _mapController.move(
                  LatLng(user['latitude'], user['longitude']),
                  15.0,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã di chuyển bản đồ đến vị trí user'),
                  ),
                );
              }
            },
            child: const Text('Xem trên bản đồ'),
          ),
        ],
      ),
    );
  }
}
