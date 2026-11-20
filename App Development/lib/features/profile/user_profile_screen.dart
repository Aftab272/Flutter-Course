import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_card.dart';
import '../../services/research_service.dart';
import '../../services/shop_service.dart';
import '../../services/product_service.dart';
import '../../services/supabase_service.dart';
import '../../services/theme_service.dart';
import '../../shared/widgets/app_avatar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ResearchService _researchService = ResearchService();
  final ShopService _shopService = ShopService();
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _researchService.addListener(_refresh);
  }

  @override
  void dispose() {
    _researchService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showEditProfileDialog() {
    final user = _researchService.user;
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            'Edit Profile Information',
            style: TextStyle(color: AppColors.adaptiveText, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: AppColors.adaptiveText),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: TextStyle(color: AppColors.adaptiveText),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newEmail = emailCtrl.text.trim();
                if (newName.isNotEmpty) {
                  _researchService.updateUser(user.copyWith(
                    name: newName,
                    email: newEmail.isNotEmpty ? newEmail : user.email,
                  ));
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Color(0xFF2563EB),
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(StateSetter setDlgState, TextEditingController urlController) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';
        setDlgState(() {
          urlController.text = dataUri;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery photo selection error: $e')),
        );
      }
    }
  }

  void _showChangeProfilePictureDialog() {
    final theme = Theme.of(context);
    final urlController = TextEditingController(text: _researchService.user.avatarUrl);
    final sampleAvatars = [
      'assets/avatars/rana_user_avatar.png',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_researchService.user.name)}&background=9333EA&color=fff&size=200&bold=true',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final currentUrl = urlController.text.trim();
            return AlertDialog(
              backgroundColor: theme.cardTheme.color ?? AppColors.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              title: const Row(
                children: [
                  Icon(Icons.account_circle_outlined, color: AppColors.primaryGreen),
                  SizedBox(width: 10),
                  Text('Update Profile Picture', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AppAvatar(
                            avatarUrl: currentUrl,
                            name: _researchService.user.name,
                            radius: 46,
                            border: Border.all(color: theme.colorScheme.primary, width: 2),
                          ),
                          if (currentUrl.isNotEmpty)
                            InkWell(
                              onTap: () {
                                setDlgState(() => urlController.clear());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Mobile Gallery Picker Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.photo_library_rounded, size: 20),
                        label: const Text(
                          'Choose from Mobile Gallery / Files',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        onPressed: () => _pickImageFromGallery(setDlgState, urlController),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR PASTE URL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'https://example.com/my-photo.jpg',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          tooltip: 'Preview',
                          onPressed: () => setDlgState(() {}),
                        ),
                      ),
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Or Select from Quick Presets (Includes Your Real Photo):',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sampleAvatars.map((av) {
                          final isSel = currentUrl == av;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setDlgState(() => urlController.text = av);
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? const Color(0xFF2563EB) : Colors.transparent,
                                    width: 2.2,
                                  ),
                                ),
                                child: AppAvatar(
                                  avatarUrl: av,
                                  name: 'Avatar',
                                  radius: 19,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Remove profile picture
                    final u = _researchService.user;
                    _researchService.updateUser(u.copyWith(avatarUrl: ''));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile picture removed.')),
                    );
                  },
                  child: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final u = _researchService.user;
                    final newUrl = urlController.text.trim();
                    _researchService.updateUser(u.copyWith(avatarUrl: newUrl));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile picture saved successfully!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  child: const Text('Save Picture'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final user = _researchService.user;

    final shopsCount = _shopService.totalAnalyzedShopsCount;
    final productsCount = _productService.totalResearchedProductsCount;
    final savedCount = _productService.totalSavedProductsCount + _shopService.savedShops.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32.0 : 16.0,
          vertical: 20.0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Profile & Account',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your profile credentials, avatar photo, and workspace scraping quotas.',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.65), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Profile Card with Photo Upload & Email Display
              CustomCard(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        InkWell(
                          onTap: _showChangeProfilePictureDialog,
                          borderRadius: BorderRadius.circular(42),
                          child: AppAvatar(
                            avatarUrl: user.avatarUrl,
                            name: user.name,
                            radius: 40,
                            border: Border.all(color: theme.colorScheme.secondary, width: 2),
                          ),
                        ),
                        InkWell(
                          onTap: _showChangeProfilePictureDialog,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.email_outlined, size: 14, color: AppColors.adaptiveText),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      user.email.isNotEmpty
                                          ? user.email
                                          : (SupabaseService().currentUser?.email ?? 'Not signed in'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.adaptiveText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
                                ),
                                child: const Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.adaptiveText,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              side: BorderSide(color: Colors.black.withOpacity(0.22)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.upload_rounded, size: 15),
                            label: const Text('Change Profile Picture', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            onPressed: _showChangeProfilePictureDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // App & Profile Settings Card (Mobile + Desktop Quick Access)
              CustomCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_rounded, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'App & Profile Settings',
                            style: TextStyle(
                              color: AppColors.adaptiveText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF2563EB)),
                      ),
                      title: Text(
                        'App Settings & Preferences',
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Theme, notifications, scraping speed, API & account controls',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.adaptiveText),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      ),
                      title: Text(
                        'Edit Profile Details',
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Update your display name and account email',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.adaptiveText),
                      onTap: _showEditProfileDialog,
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ThemeService().isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 18,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      title: Text(
                        ThemeService().isLight ? 'Switch to Dark Blue Theme' : 'Switch to White Theme',
                        style: TextStyle(color: AppColors.adaptiveText, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        'Currently active: ${ThemeService().isLight ? "Clean White Theme" : "Dark Blue Theme"}',
                        style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12),
                      ),
                      trailing: Switch(
                        value: !ThemeService().isLight,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (_) {
                          setState(() {
                            ThemeService().togglePrimaryTheme();
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          ThemeService().togglePrimaryTheme();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Scraping & Research Quota
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Monthly Usage & Quotas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.adaptiveText, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Renews in 18 days', style: TextStyle(color: AppColors.adaptiveSubtext, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _quotaProgress(
                      label: 'Shops & Storefronts Analyzed',
                      current: shopsCount,
                      max: user.maxShopsQuota,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 16),
                    _quotaProgress(
                      label: 'Product Intelligence Items Processed',
                      current: productsCount,
                      max: user.maxProductsQuota,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 16),
                    _quotaProgress(
                      label: 'Saved Research Bookmarks',
                      current: savedCount,
                      max: 100,
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quotaProgress({
    required String label,
    required int current,
    required int max,
    required Color color,
  }) {
    final ratio = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.adaptiveText, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Text('$current / $max', style: TextStyle(color: AppColors.adaptiveText, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}

