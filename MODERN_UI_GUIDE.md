# 🎨 Modern UI Design Guide

## Tổng quan

Ứng dụng Gara Management đã được thiết kế lại với phong cách hiện đại, đẹp mắt và các hiệu ứng animation mượt mà. Tài liệu này hướng dẫn cách sử dụng các widget và animation mới.

## 🎯 Màu sắc chính

### Gradient Colors
```dart
// Primary Gradient
const Color(0xFF667EEA), // Modern Purple
const Color(0xFF764BA2), // Dark Purple  
const Color(0xFFF093FB), // Pink
const Color(0xFFF5576C), // Red
```

### Status Colors
```dart
const Color(0xFF10B981), // Success Green
const Color(0xFFF59E0B), // Warning Orange
const Color(0xFFEF4444), // Error Red
const Color(0xFF3B82F6), // Info Blue
```

## 🎭 Animation Utils

### Cách sử dụng AnimationUtils

```dart
import '../utils/animation_utils.dart';

// Fade In Animation
AnimationUtils.fadeInAnimation(
  child: YourWidget(),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOut,
)

// Slide In Animation
AnimationUtils.slideInAnimation(
  child: YourWidget(),
  duration: Duration(milliseconds: 800),
  curve: Curves.easeOutCubic,
  begin: Offset(0, 0.3),
)

// Scale Animation
AnimationUtils.scaleAnimation(
  child: YourWidget(),
  duration: Duration(milliseconds: 600),
  curve: Curves.elasticOut,
)

// Bounce Animation
AnimationUtils.bounceAnimation(
  child: YourWidget(),
  duration: Duration(milliseconds: 1000),
)

// Floating Animation
AnimationUtils.floatingAnimation(
  child: YourWidget(),
  duration: Duration(milliseconds: 2000),
)

// Gradient Text Animation
AnimationUtils.gradientTextAnimation(
  text: 'Your Text',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  duration: Duration(milliseconds: 3000),
)
```

## 🎨 Modern UI Widgets

### ModernCard
```dart
import '../widgets/modern_ui_widgets.dart';

ModernCard(
  child: YourContent(),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  borderRadius: 16.0,
  backgroundColor: Colors.white,
  onTap: () => print('Card tapped'),
  enableAnimation: true,
)
```

### ModernButton
```dart
ModernButton(
  text: 'Click Me',
  onPressed: () => print('Button pressed'),
  backgroundColor: Color(0xFF667EEA),
  textColor: Colors.white,
  height: 56.0,
  borderRadius: 16.0,
  icon: Icons.add,
  isLoading: false,
  isOutlined: false,
)
```

### ModernTextField
```dart
ModernTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  prefixIcon: Icons.email_outlined,
  suffixIcon: Icons.visibility_outlined,
  onSuffixIconTap: () => print('Suffix tapped'),
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
  onChanged: (value) => print('Text changed: $value'),
)
```

### ModernChip
```dart
ModernChip(
  label: 'Active',
  icon: Icons.check_circle,
  backgroundColor: Color(0xFF10B981),
  textColor: Colors.white,
  onTap: () => print('Chip tapped'),
  isSelected: true,
)
```

### ModernAvatar
```dart
ModernAvatar(
  imageUrl: 'https://example.com/avatar.jpg',
  name: 'John Doe',
  size: 48.0,
  backgroundColor: Color(0xFF667EEA),
  fallbackIcon: Icons.person,
)
```

### ModernBadge
```dart
ModernBadge(
  text: 'New',
  backgroundColor: Color(0xFFEF4444),
  textColor: Colors.white,
  fontSize: 12,
)
```

### ModernIconButton
```dart
ModernIconButton(
  icon: Icons.favorite,
  onPressed: () => print('Icon button pressed'),
  backgroundColor: Colors.grey.withOpacity(0.1),
  iconColor: Color(0xFF667EEA),
  size: 48.0,
  iconSize: 24.0,
)
```

## 🔄 Loading Widgets

### ModernLoadingSpinner
```dart
import '../widgets/loading_widgets.dart';

ModernLoadingSpinner(
  size: 40.0,
  color: Color(0xFF667EEA),
  duration: Duration(milliseconds: 1500),
)
```

### PulseLoadingDots
```dart
PulseLoadingDots(
  color: Color(0xFF667EEA),
  size: 8.0,
  duration: Duration(milliseconds: 1200),
)
```

### ShimmerLoadingCard
```dart
ShimmerLoadingCard(
  height: 120.0,
  borderRadius: 16.0,
  margin: EdgeInsets.all(8),
)
```

### LoadingOverlay
```dart
LoadingOverlay(
  child: YourMainContent(),
  isLoading: true,
  message: 'Loading...',
  backgroundColor: Colors.black54,
)
```

### SkeletonLoadingList
```dart
SkeletonLoadingList(
  itemCount: 5,
  itemHeight: 80.0,
  itemMargin: EdgeInsets.only(bottom: 12),
)
```

### AnimatedSuccessCheck
```dart
AnimatedSuccessCheck(
  size: 60.0,
  color: Color(0xFF10B981),
  onComplete: () => print('Animation completed'),
)
```

### ProgressLoadingBar
```dart
ProgressLoadingBar(
  progress: 0.75, // 75%
  height: 8.0,
  backgroundColor: Colors.grey[300],
  progressColor: Color(0xFF667EEA),
  animationDuration: Duration(milliseconds: 500),
)
```

## 🎨 Custom Painters

### ParticlesPainter
```dart
CustomPaint(
  painter: ParticlesPainter(animationValue),
  size: Size.infinite,
)
```

## 📱 Responsive Design

### Breakpoints
```dart
// Mobile: < 600px
// Tablet: 600px - 900px  
// Desktop: > 900px

double screenWidth = MediaQuery.of(context).size.width;
bool isMobile = screenWidth < 600;
bool isTablet = screenWidth >= 600 && screenWidth < 900;
bool isDesktop = screenWidth >= 900;
```

### Adaptive Layout
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 900) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## 🎯 Best Practices

### 1. Animation Performance
- Sử dụng `AnimationController` với `vsync: this`
- Dispose controllers trong `dispose()` method
- Tránh tạo animation không cần thiết

### 2. Loading States
- Luôn hiển thị loading state khi fetch data
- Sử dụng skeleton loading cho UX tốt hơn
- Có fallback cho error states

### 3. Accessibility
- Thêm `semanticsLabel` cho các widget quan trọng
- Sử dụng `ExcludeSemantics` cho decorative elements
- Đảm bảo contrast ratio đủ cao

### 4. Theme Consistency
- Sử dụng colors từ theme thay vì hardcode
- Tạo custom theme extensions khi cần
- Maintain consistent spacing và typography

## 🚀 Migration Guide

### Từ Old UI sang Modern UI

1. **Thay thế Card cũ:**
```dart
// Old
Card(
  child: YourContent(),
  elevation: 4,
)

// New  
ModernCard(
  child: YourContent(),
  enableAnimation: true,
)
```

2. **Thay thế Button cũ:**
```dart
// Old
ElevatedButton(
  onPressed: onPressed,
  child: Text('Button'),
)

// New
ModernButton(
  text: 'Button',
  onPressed: onPressed,
)
```

3. **Thay thế TextField cũ:**
```dart
// Old
TextField(
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(),
  ),
)

// New
ModernTextField(
  label: 'Label',
)
```

## 🎨 Customization

### Tạo Custom Theme
```dart
class CustomTheme {
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      // Custom theme properties
    );
  }
}
```

### Tạo Custom Animation
```dart
class CustomAnimation extends StatefulWidget {
  final Widget child;
  
  const CustomAnimation({required this.child});
  
  @override
  State<CustomAnimation> createState() => _CustomAnimationState();
}

class _CustomAnimationState extends State<CustomAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
```

## 📚 Resources

- [Flutter Animation Documentation](https://docs.flutter.dev/development/ui/animations)
- [Material Design Guidelines](https://material.io/design)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

---

**Lưu ý:** Đảm bảo import đúng các file và sử dụng các widget một cách nhất quán trong toàn bộ ứng dụng để maintain design system.
