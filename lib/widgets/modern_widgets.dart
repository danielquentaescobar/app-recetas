import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../utils/navigation_helper.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? fallbackRoute;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.fallbackRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      decoration: AppTheme.headerDecoration(),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Leading widget o botón de regreso
              if (showBackButton || leading != null)
                leading ?? 
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: onBackPressed ?? () {
                    if (fallbackRoute != null) {
                      NavigationHelper.goBack(context, fallbackRoute: fallbackRoute!);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              
              // Título
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: Colors.white,
                    fontSize: AppTheme.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: showBackButton || leading != null 
                    ? TextAlign.left 
                    : TextAlign.center,
                ),
              ),
              
              // Actions
              if (actions != null) ...actions!,
              
              // Botón de cambio de tema
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: themeProvider.toggleTheme,
                tooltip: themeProvider.isDarkMode 
                  ? 'Cambiar a modo claro'
                  : 'Cambiar a modo oscuro',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const GradientBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.backgroundDecoration(isDark: isDark),
      child: child,
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isSelected;

  const CategoryButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: AppTheme.categoryButtonStyle(
          color,
          isDark: themeProvider.isDarkMode,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(
            isSelected ? color : color.withOpacity(0.8),
          ),
          elevation: WidgetStateProperty.all(isSelected ? 8 : 4),
          shadowColor: WidgetStateProperty.all(
            color.withOpacity(0.5),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context, 12),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? color;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      decoration: AppTheme.recipeCardDecoration(isDark: themeProvider.isDarkMode),
      child: Material(
        color: color ?? themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double basePadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.basePadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final padding = AppTheme.getResponsivePadding(context, basePadding);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: themeProvider.isDarkMode
                ? [
                    const Color(0xFF2D2D2D),
                    const Color(0xFF404040),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFFE0E0E0),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFE0E0E0),
                  ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
          ),
        );
      },
    );
  }
}
