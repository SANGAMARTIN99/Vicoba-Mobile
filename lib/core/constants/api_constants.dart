/// API Constants and Endpoints for VicobaPlus
class ApiConstants {
  ApiConstants._();

  // Default base URL. Can be adjusted via settings or environment
  static const String defaultBaseUrl = 'http://127.0.0.1:8080/api';
  static const String localhostBaseUrl = 'http://127.0.0.1:8080/api';
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String registerTenant = '/auth/register-tenant';
  static const String switchContext = '/auth/switch';
  static const String userProfile = '/me';
  static const String userContexts = '/me/contexts';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Members
  static const String members = '/members';

  // Meetings
  static const String meetings = '/meetings';

  // Transactions
  static const String buyShares = '/transactions/shares';
  static const String depositSavings = '/transactions/savings';
  static const String contributeSocialFund = '/transactions/social-fund';

  // Loans
  static const String loans = '/loans';
  static const String loanEligibility = '/loans/eligibility';

  // Fines
  static const String fines = '/fines';

  // Receipts
  static const String receipts = '/receipts';
  static const String publicVerify = '/receipts/verify';

  // Cycles
  static const String cycles = '/cycles';

  // Governance
  static const String votes = '/votes';
  static const String socialFundRequests = '/social-fund/requests';
  static const String disputes = '/disputes';

  // Reconciliation
  static const String reconciliation = '/reconciliation';

  // AI Advisor
  static const String aiChat = '/ai/chat';
  static const String aiHealth = '/ai/assess-health';
  static const String aiLatestAssessment = '/ai/latest-assessment';

  // Subscriptions
  static const String subscriptionCurrent = '/subscriptions/current';
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionUpgrade = '/subscriptions/upgrade';

  // Settings & Sessions
  static const String settings = '/settings';
  static const String auditLogs = '/audit-logs';
  static const String federations = '/federations';
  static const String myGuarantees = '/loans/my-guarantees';
  static const String sessions = '/sessions';

  // Reports
  static const String reportsBalanceSheet = '/reports/balance-sheet';
  static const String reportsIncomeStatement = '/reports/income-statement';
  static const String reportsCashFlow = '/reports/cash-flow';
}
