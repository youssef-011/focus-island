import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../../app_state/providers/app_state_provider.dart';
import '../profile_avatar_circle.dart';
import '../profile_avatar_options.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late String _selectedAvatarId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppStateProvider>().profile;
    _displayNameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _countryController = TextEditingController(text: profile.country);
    _selectedAvatarId = profile.avatarId;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }

    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name is required.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await context.read<AppStateProvider>().updateProfile(
          displayName: displayName,
          bio: _bioController.text,
          avatarId: _selectedAvatarId,
          phone: _phoneController.text,
          country: _countryController.text,
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ProfileAvatarCircle(
                    avatarId: _selectedAvatarId,
                    radius: 34,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your island identity',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ProfileAvatarOptions.all.map((option) {
                final isSelected = option.id == _selectedAvatarId;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAvatarId = option.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 92,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option.backgroundColor.withValues(alpha: 0.24)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? option.backgroundColor : Colors.white24,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: option.backgroundColor,
                          child: Icon(option.icon, color: option.iconColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomGlassCard(
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    style: const TextStyle(color: Colors.white70),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _displayNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Short Bio',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      hintText: 'What helps you stay focused?',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      hintText: 'Add a phone only if you need premium checkout later',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 2,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      hintText: 'EG',
                      hintStyle: TextStyle(color: Colors.white38),
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.background,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
