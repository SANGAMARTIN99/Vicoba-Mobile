import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../data/models/models.dart';
import '../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ApiClient _client = ApiClient();

  UserProfile? _user;
  UserContext? _activeContext;
  List<UserContext> _availableContexts = [];
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  UserProfile? get user => _user;
  UserContext? get activeContext => _activeContext;
  List<UserContext> get availableContexts => _availableContexts;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  String get currentRole => _activeContext?.role.toUpperCase() ?? 'MEMBER';

  // Role helpers
  bool get isLeader {
    final role = currentRole;
    return role == 'CHAIRPERSON' ||
        role == 'SECRETARY' ||
        role == 'TREASURER' ||
        role == 'PLATFORM_ADMIN';
  }

  bool get isTreasurer => currentRole == 'TREASURER';
  bool get isChairperson => currentRole == 'CHAIRPERSON';
  bool get isSecretary => currentRole == 'SECRETARY';
  bool get isAuditor => currentRole == 'AUDITOR';
  bool get isLoanOfficer => currentRole == 'LOAN_OFFICER';
  bool get isMember => currentRole == 'MEMBER';
  bool get isPlatformAdmin => currentRole == 'PLATFORM_ADMIN';

  bool hasRole(List<String> allowedRoles) {
    if (allowedRoles.isEmpty || allowedRoles.contains('ALL') || isPlatformAdmin) {
      return true;
    }
    return allowedRoles.map((r) => r.toUpperCase()).contains(currentRole);
  }

  AuthProvider() {
    _client.onUnauthorized = () {
      logout();
    };
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('vicoba_token');
      final activeGroupId = prefs.getString('vicoba_active_context_id');
      final groupName = prefs.getString('vicoba_active_group_name') ?? 'VICOBA Group';
      final role = prefs.getString('vicoba_active_role') ?? 'MEMBER';

      if (_token != null && _token!.isNotEmpty) {
        _client.setAuth(_token, activeGroupId);
        if (activeGroupId != null) {
          _activeContext = UserContext(
            groupId: activeGroupId,
            groupName: groupName,
            role: role,
          );
        }

        try {
          final profile = await _apiService.getProfile();
          _user = profile;
          final contexts = await _apiService.getContexts();
          _availableContexts = contexts;
          if (_activeContext == null && contexts.isNotEmpty) {
            _activeContext = contexts.first;
            await _saveActiveContextToPrefs(_activeContext!);
          }
        } catch (_) {
          // Keep offline/cached credentials if server unreachable
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String phoneOrEmail, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        phoneOrEmail: phoneOrEmail,
        password: password,
      );

      _token = response.token;
      _user = response.user;
      _availableContexts = response.availableContexts;
      _activeContext = response.activeContext ??
          (_availableContexts.isNotEmpty ? _availableContexts.first : null);

      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vicoba_token', _token!);
        if (_activeContext != null) {
          await _saveActiveContextToPrefs(_activeContext!);
        }
        _client.setAuth(_token, _activeContext?.groupId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Could not sign in: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerTenant({
    required String groupName,
    required String groupCode,
    required String chairpersonFullName,
    required String chairpersonPhone,
    String? chairpersonEmail,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.registerTenant(
        groupName: groupName,
        groupCode: groupCode,
        chairpersonFullName: chairpersonFullName,
        chairpersonPhone: chairpersonPhone,
        chairpersonEmail: chairpersonEmail,
        password: password,
      );

      _token = response.token;
      _user = response.user;
      _availableContexts = response.availableContexts;
      _activeContext = response.activeContext ??
          (_availableContexts.isNotEmpty ? _availableContexts.first : null);

      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vicoba_token', _token!);
        if (_activeContext != null) {
          await _saveActiveContextToPrefs(_activeContext!);
        }
        _client.setAuth(_token, _activeContext?.groupId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> switchContext(String targetGroupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.switchContext(targetGroupId);
      if (response.token != null) {
        _token = response.token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vicoba_token', _token!);
      }
      if (response.activeContext != null) {
        _activeContext = response.activeContext;
      } else {
        final match = _availableContexts.firstWhere(
          (c) => c.groupId == targetGroupId,
          orElse: () => _activeContext!,
        );
        _activeContext = match;
      }
      await _saveActiveContextToPrefs(_activeContext!);
      _client.setAuth(_token, _activeContext?.groupId);
    } catch (e) {
      _errorMessage = 'Failed to switch context: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _activeContext = null;
    _availableContexts = [];
    _client.setAuth(null, null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vicoba_token');
    await prefs.remove('vicoba_active_context_id');
    await prefs.remove('vicoba_active_group_name');
    await prefs.remove('vicoba_active_role');

    notifyListeners();
  }

  Future<void> _saveActiveContextToPrefs(UserContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vicoba_active_context_id', ctx.groupId);
    await prefs.setString('vicoba_active_group_name', ctx.groupName);
    await prefs.setString('vicoba_active_role', ctx.role);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
