import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusmate/core/constants/app_constants.dart';

/// Provides the current user ID from SharedPreferences.
/// Returns null when no user is signed in.
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// Whether the user has completed onboarding.
final onboardingCompleteProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;
});

/// Theme mode preference: 0=system, 1=light, 2=dark.
final themeModeProvider = StateProvider<int>((ref) => 0);
