import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/api_service.dart';

class GroupDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardMetrics? _metrics;
  List<Member> _members = [];
  List<Meeting> _meetings = [];
  List<Loan> _loans = [];
  List<Fine> _fines = [];
  List<Receipt> _receipts = [];
  List<Cycle> _cycles = [];
  RiskAssessment? _healthAssessment;
  List<LoanGuarantor> _guarantees = [];
  List<Federation> _federations = [];
  FederationMetrics? _federationMetrics;
  BalanceSheetReport? _balanceSheet;
  IncomeStatementReport? _incomeStatement;
  CashFlowStatementReport? _cashFlow;
  List<AuditLogEntry> _auditLogs = [];
  List<UserSession> _sessions = [];

  bool _isLoading = false;
  String? _error;

  DashboardMetrics? get metrics => _metrics;
  List<Member> get members => _members;
  List<Meeting> get meetings => _meetings;
  List<Loan> get loans => _loans;
  List<Fine> get fines => _fines;
  List<Receipt> get receipts => _receipts;
  List<Cycle> get cycles => _cycles;
  RiskAssessment? get healthAssessment => _healthAssessment;
  List<LoanGuarantor> get guarantees => _guarantees;
  List<Federation> get federations => _federations;
  FederationMetrics? get federationMetrics => _federationMetrics;
  BalanceSheetReport? get balanceSheet => _balanceSheet;
  IncomeStatementReport? get incomeStatement => _incomeStatement;
  CashFlowStatementReport? get cashFlow => _cashFlow;
  CashFlowStatementReport? get cashFlowStatement => _cashFlow;
  List<AuditLogEntry> get auditLogs => _auditLogs;
  List<UserSession> get sessions => _sessions;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Active meeting getter
  Meeting? get activeMeeting {
    try {
      return _meetings.firstWhere((m) => m.status == 'IN_PROGRESS');
    } catch (_) {
      return null;
    }
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadDashboard(),
        loadMembers(),
        loadMeetings(),
        loadLoans(),
        loadGuarantees(),
        loadFines(),
        loadReceipts(),
        loadCycles(),
        loadHealthAssessment(),
        loadFederations(),
        loadFinancialReports(),
        loadAuditLogs(),
        loadSessions(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    try {
      _metrics = await _apiService.getDashboardMetrics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard metrics: $e');
    }
  }

  Future<void> loadMembers() async {
    try {
      _members = await _apiService.getMembers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading members: $e');
    }
  }

  Future<void> loadMeetings() async {
    try {
      _meetings = await _apiService.getMeetings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading meetings: $e');
    }
  }

  Future<void> loadLoans() async {
    try {
      _loans = await _apiService.getLoans();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading loans: $e');
    }
  }

  Future<void> loadFines() async {
    try {
      _fines = await _apiService.getFines();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading fines: $e');
    }
  }

  Future<void> loadReceipts() async {
    try {
      _receipts = await _apiService.getReceipts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading receipts: $e');
    }
  }

  Future<void> loadCycles() async {
    try {
      _cycles = await _apiService.getCycles();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cycles: $e');
    }
  }

  Future<void> loadHealthAssessment() async {
    try {
      _healthAssessment = await _apiService.getHealthAssessment();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading AI health assessment: $e');
    }
  }

  Future<void> loadGuarantees() async {
    try {
      _guarantees = await _apiService.getMyGuarantees();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading guarantees: $e');
    }
  }

  Future<void> respondToGuarantee(String id, bool accept) async {
    try {
      await _apiService.respondToGuarantee(id, accept);
      await loadGuarantees();
      await loadLoans();
    } catch (e) {
      debugPrint('Error responding to guarantee: $e');
      rethrow;
    }
  }

  Future<void> loadFederations() async {
    try {
      _federations = await _apiService.getFederations();
      if (_federations.isNotEmpty) {
        await loadFederationMetrics(_federations.first.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading federations: $e');
    }
  }

  Future<void> loadFederationMetrics(String fedId) async {
    try {
      _federationMetrics = await _apiService.getFederationMetrics(fedId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading federation metrics: $e');
    }
  }

  Future<void> createFederation({
    required String name,
    required String code,
    required String region,
    required String district,
  }) async {
    try {
      await _apiService.createFederation(
        name: name,
        code: code,
        region: region,
        district: district,
      );
      await loadFederations();
    } catch (e) {
      debugPrint('Error creating federation: $e');
      rethrow;
    }
  }

  Future<void> affiliateGroup(String fedId, String groupId) async {
    try {
      await _apiService.affiliateGroup(fedId, groupId);
      await loadFederations();
    } catch (e) {
      debugPrint('Error affiliating group: $e');
      rethrow;
    }
  }

  Future<void> loadFinancialReports() async {
    try {
      final results = await Future.wait([
        _apiService.getBalanceSheet(),
        _apiService.getIncomeStatement(),
        _apiService.getCashFlow(),
      ]);
      _balanceSheet = results[0] as BalanceSheetReport;
      _incomeStatement = results[1] as IncomeStatementReport;
      _cashFlow = results[2] as CashFlowStatementReport;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading financial reports: $e');
    }
  }

  Future<void> loadAuditLogs() async {
    try {
      _auditLogs = await _apiService.getAuditLogs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    }
  }

  Future<void> loadSessions() async {
    try {
      _sessions = await _apiService.getSessions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading sessions: $e');
    }
  }

  Future<void> revokeSession(String id) async {
    try {
      await _apiService.revokeSession(id);
      await loadSessions();
    } catch (e) {
      debugPrint('Error revoking session: $e');
      rethrow;
    }
  }

  Future<void> revokeAllOtherSessions() async {
    try {
      await _apiService.revokeAllOtherSessions();
      await loadSessions();
    } catch (e) {
      debugPrint('Error revoking all other sessions: $e');
      rethrow;
    }
  }

  Future<Receipt> verifyReceipt(String number) async {
    try {
      final map = await _apiService.verifyReceipt(number);
      return Receipt.fromJson(map);
    } catch (e) {
      debugPrint('Error verifying receipt: $e');
      rethrow;
    }
  }

  void refresh() {
    loadAllData();
  }
}
