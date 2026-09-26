import 'package:flutter/material.dart';

/// AppLocalizations handles bilingual support (English and Swahili)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'appName': 'VicobaPlus',
      'tagline': 'Modern VICOBA Microfinance Platform',
      'save': 'Save',
      'cancel': 'Cancel',
      'submit': 'Submit',
      'delete': 'Delete',
      'edit': 'Edit',
      'back': 'Back',
      'close': 'Close',
      'search': 'Search...',
      'filter': 'Filter',
      'status': 'Status',
      'date': 'Date',
      'amount': 'Amount',
      'currency': 'TZS',
      'loading': 'Loading...',
      'noData': 'No records found',
      'retry': 'Try Again',
      'confirm': 'Confirm',
      'success': 'Completed successfully',
      'error': 'An error occurred. Please try again.',
      'all': 'All',
      'actions': 'Actions',

      // Roles
      'role_CHAIRPERSON': 'Chairperson',
      'role_SECRETARY': 'Secretary',
      'role_TREASURER': 'Treasurer',
      'role_MEMBER': 'Member',
      'role_AUDITOR': 'Auditor',
      'role_PLATFORM_ADMIN': 'Platform Admin',

      // Onboarding
      'onboarding_title_1': 'Community Savings & Trust',
      'onboarding_desc_1': 'Manage your VICOBA shares, savings, and social welfare funds with tamper-evident cryptographic ledgers and real-time passbooks.',
      'onboarding_title_2': 'Seamless Mobile Money',
      'onboarding_desc_2': 'Instant automated reconciliation with M-Pesa, Airtel Money, and Tigo Pesa. No lost deposits or reconciliation disputes.',
      'onboarding_title_3': 'Empower Your Future',
      'onboarding_desc_3': 'Transparent micro-loans, peer guarantees, and fair automated dividend share-outs at the end of every cycle.',
      'getStarted': 'Get Started',
      'skip': 'Skip',
      'next': 'Next',

      // Auth
      'loginTitle': 'Sign In to VicobaPlus',
      'loginSubtitle': 'Enter your phone number and password to access your community group',
      'phoneLabel': 'Phone Number',
      'phoneHint': '07XXXXXXXX or 255XXXXXXXXX',
      'passwordLabel': 'Password',
      'passwordHint': '••••••••',
      'signInBtn': 'Sign In',
      'signingIn': 'Signing in...',
      'registerNewGroup': 'Register New VICOBA Group',
      'registerGroupDesc': 'Start a digital group and become its founding Chairperson',
      'groupName': 'Group Name',
      'groupCode': 'Group Code (e.g., KILIMA01)',
      'leaderName': 'Chairperson Full Name',
      'leaderPhone': 'Chairperson Phone',
      'leaderEmail': 'Email Address (Optional)',
      'registerBtn': 'Register Group',
      'registering': 'Registering...',
      'alreadyHaveAccount': 'Already registered? Sign in here',
      'switchGroup': 'Switch Group Context',
      'activeGroup': 'Active Group',
      'signOut': 'Sign Out',

      // Dashboard
      'dashboard': 'Dashboard',
      'welcomeBack': 'Welcome, {name}',
      'vaultCash': 'Cash in Vault',
      'totalShares': 'Total Shares',
      'voluntarySavings': 'Voluntary Savings',
      'outstandingLoans': 'Active Loans',
      'activeMembers': 'Active Members',
      'activeMeetingAlert': 'Meeting #{number} is currently active!',
      'enterMeeting': 'Enter Meeting Mode',
      'startMeeting': 'Start New Meeting',
      'quickActions': 'Quick Actions',
      'buyShares': 'Buy Shares',
      'depositSavings': 'Deposit Savings',
      'applyLoan': 'Apply Loan',
      'recentActivity': 'Recent Activity',

      // Members
      'members': 'Members',
      'membersDirectory': 'Members Directory',
      'addMember': 'Add New Member',
      'memberDetail': 'Member Profile & Statement',
      'sharesHeld': 'Shares Held',
      'savingsBalance': 'Savings Balance',
      'loanBalance': 'Loan Balance',
      'activeStatus': 'Active',
      'inactiveStatus': 'Inactive',

      // Meetings
      'meetings': 'Weekly Meetings',
      'meetingNumber': 'Meeting #{number}',
      'meetingDate': 'Meeting Date',
      'meetingMode': 'Meeting Orchestrator',
      'attendanceRollCall': 'Attendance Roll Call',
      'present': 'Present',
      'late': 'Late',
      'absent': 'Absent',
      'authorizedAbsent': 'Excused',
      'recordCollection': 'Record Collections',
      'socialFund': 'Social Welfare',
      'fineIssue': 'Issue Absence Fine',
      'closeMeeting': 'End & Close Meeting',
      'meetingClosedSummary': 'Meeting Summary & Balances',

      // Loans
      'loans': 'Loans & Credit',
      'activeLoans': 'Active Loans',
      'loanAmount': 'Principal',
      'durationMonths': 'Duration (Months)',
      'monthlyInterest': 'Interest Rate',
      'repayLoan': 'Make Repayment',
      'guarantors': 'Guarantors',
      'eligibilityScore': 'Borrowing Limit',
      'disburseLoan': 'Disburse Funds',

      // Receipts & QR
      'receipts': 'Cryptographic Receipts',
      'receiptNumber': 'Receipt No',
      'receiptHash': 'SHA-256 Ledger Hash',
      'scanVerify': 'Scan QR Code to Verify',
      'tamperEvident': 'Cryptographically Verified',

      // Fines
      'fines': 'Fines & Penalties',
      'unpaidFines': 'Unpaid Fines',
      'payFine': 'Pay Fine',
      'waiveFine': 'Waive Fine',
      'fineReason': 'Reason for Fine',

      // Cycles & Share-out
      'cycles': 'Cycle Share-Out',
      'cycleName': 'Cycle #{number}',
      'dividendShare': 'Estimated Dividend',
      'distributeDividends': 'Calculate Share-Out',

      // Governance
      'governance': 'Governance & Votes',
      'activeProposals': 'Proposals & Voting',
      'socialWelfareRequests': 'Social Fund Claims',
      'disputes': 'Member Grievances',
      'voteFor': 'Vote For',
      'voteAgainst': 'Vote Against',

      // M-Pesa & Reconciliation
      'reconciliation': 'M-Pesa Reconciliation',
      'stkPush': 'Initiate STK Push',
      'transactionStatus': 'Mobile Money Status',
      'matchLedger': 'Reconciled With Ledger',

      // AI Advisor
      'aiAdvisor': 'AI Financial Advisor',
      'healthScore': 'Financial Health Score',
      'askAdvisor': 'Ask your cooperative advisor anything...',
      'riskAppraisal': 'Group Risk Appraisal',

      // Subscription & Settings
      'subscription': 'Subscription & Plan',
      'currentPlan': 'Current Plan',
      'upgradePlan': 'Upgrade Tier',
      'settings': 'Settings',
      'language': 'Language / Lugha',
      'theme': 'Appearance',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'auditLogs': 'Audit Trail',

      // Loan Schedule & Guarantees
      'loanDetails': 'Loan Details & Schedule',
      'amortizationSchedule': 'Repayment Schedule',
      'myGuarantees': 'My Guarantees',
      'acceptGuarantee': 'Accept Guarantee',
      'declineGuarantee': 'Decline Guarantee',
      'pledgedAmount': 'Pledged Amount',
      'approveLoan': 'Approve Loan',
      'rejectLoan': 'Reject Loan',
      'installmentNumber': 'Installment #{num}',

      // Federation & Apex
      'federation': 'Apex Federation',
      'federations': 'Apex Federations',
      'cooperativeNetwork': 'Cooperative Network',
      'combinedCapital': 'Combined Capital',
      'solvencyIndex': 'Solvency Index',
      'interLendingPool': 'Inter-Lending Pool',
      'peerGroups': 'Peer Groups Benchmark',
      'affiliateGroup': 'Affiliate Group',
      'createFederation': 'Create Apex Federation',

      // Financial Reports
      'reports': 'Financial Reports',
      'balanceSheet': 'Balance Sheet',
      'incomeStatement': 'Income Statement',
      'cashFlow': 'Cash Flow Statement',
      'totalAssets': 'Total Assets',
      'totalLiabilities': 'Total Liabilities & Equity',
      'operatingExpenses': 'Operating Expenses',
      'netSurplus': 'Net Surplus',
      'exportPdf': 'Export Official PDF',

      // Receipt Verification
      'verifyReceipt': 'Verify Receipt',
      'receiptVerification': 'Digital Receipt Verification',
      'scanQrCode': 'Scan QR Code',
      'tamperProof': 'Cryptographically Secured',
      'receiptValid': 'Official Ledger Receipt - Verified Authentic',

      // Security & Sessions
      'securitySessions': 'Active Sessions & Devices',
      'currentDevice': 'Current Device',
      'revokeSession': 'Revoke Access',
      'revokeAllOthers': 'Log Out Other Devices',
    },
    'sw': {
      // Common
      'appName': 'VicobaPlus',
      'tagline': 'Mfumo wa Kisasa wa VICOBA na Vikundi vya Akiba',
      'save': 'Hifadhi',
      'cancel': 'Ghairi',
      'submit': 'Wasilisha',
      'delete': 'Futa',
      'edit': 'Hariri',
      'back': 'Rudi Nyuma',
      'close': 'Funga',
      'search': 'Tafuta...',
      'filter': 'Chuja',
      'status': 'Hali',
      'date': 'Tarehe',
      'amount': 'Kiasi',
      'currency': 'TZS',
      'loading': 'Inapakia...',
      'noData': 'Hakuna taarifa zilizopatikana',
      'retry': 'Jaribu Tena',
      'confirm': 'Thibitisha',
      'success': 'Imekamilika kikamilifu',
      'error': 'Hitilafu imetokea. Tafadhali jaribu tena.',
      'all': 'Zote',
      'actions': 'Vitendo',

      // Roles
      'role_CHAIRPERSON': 'Mwenyekiti',
      'role_SECRETARY': 'Katibu',
      'role_TREASURER': 'Mweka Hazina',
      'role_MEMBER': 'Mwanachama',
      'role_AUDITOR': 'Mkaguzi wa Hesabu',
      'role_PLATFORM_ADMIN': 'Msimamizi Mkuu',

      // Onboarding
      'onboarding_title_1': 'Akiba na Uaminifu wa Jamii',
      'onboarding_desc_1': 'Simamia hisa, akiba, na mifuko ya jamii ya kikundi chako kwa usalama wa kidijitali na vitabu vya kisasa visivyoghoshiwa.',
      'onboarding_title_2': 'Upatanisho wa M-Pesa Bila Shaka',
      'onboarding_desc_2': 'Malipo ya simu yanaingia moja kwa moja kwenye leja kupitia M-Pesa, Airtel Money, na Tigo Pesa bila mizozo ya hesabu.',
      'onboarding_title_3': 'Kukuza Uchumi na Mikopo Nafuu',
      'onboarding_desc_3': 'Mikopo ya uwazi, wadhamini wa kuaminika, na mgao wa faida (gawio) unaokokotolewa kiotomatiki mwisho wa mzunguko.',
      'getStarted': 'Anza Sasa',
      'skip': 'Ruka',
      'next': 'Endelea',

      // Auth
      'loginTitle': 'Ingia kwenye VicobaPlus',
      'loginSubtitle': 'Weka namba yako ya simu na nenosiri kuingia kwenye kikundi chako',
      'phoneLabel': 'Namba ya Simu',
      'phoneHint': '07XXXXXXXX au 255XXXXXXXXX',
      'passwordLabel': 'Nenosiri',
      'passwordHint': '••••••••',
      'signInBtn': 'Ingia',
      'signingIn': 'Inaingia...',
      'registerNewGroup': 'Sajili Kikundi Kipya cha VICOBA',
      'registerGroupDesc': 'Anzisha kikundi cha kidijitali na uwe mwenyekiti mwanzilishi',
      'groupName': 'Jina la Kikundi',
      'groupCode': 'Kifupi cha Kikundi (mfano KILIMA01)',
      'leaderName': 'Jina Kamili la Mwenyekiti',
      'leaderPhone': 'Namba ya Simu ya Mwenyekiti',
      'leaderEmail': 'Barua Pepe (Hiari)',
      'registerBtn': 'Sajili Kikundi',
      'registering': 'Kikundi kinasajiliwa...',
      'alreadyHaveAccount': 'Tayari una akaunti? Ingia hapa',
      'switchGroup': 'Badili Kikundi',
      'activeGroup': 'Kikundi cha Sasa',
      'signOut': 'Toka',

      // Dashboard
      'dashboard': 'Dashibodi',
      'welcomeBack': 'Karibu, {name}',
      'vaultCash': 'Pesa kwenye Sanduku',
      'totalShares': 'Jumla ya Hisa',
      'voluntarySavings': 'Akiba ya Hiari',
      'outstandingLoans': 'Mikopo Iliyoko Nje',
      'activeMembers': 'Wanachama Hai',
      'activeMeetingAlert': 'Mkutano #{number} wa leo unaendelea sasa!',
      'enterMeeting': 'Ingia Mkutano',
      'startMeeting': 'Anzisha Mkutano Mpya',
      'quickActions': 'Huduma za Haraka',
      'buyShares': 'Nunua Hisa',
      'depositSavings': 'Weka Akiba',
      'applyLoan': 'Omba Mkopo',
      'recentActivity': 'Miamala ya Hivi Karibuni',

      // Members
      'members': 'Wanachama',
      'membersDirectory': 'Orodha ya Wanachama',
      'addMember': 'Ongeza Mwanachama',
      'memberDetail': 'Taarifa na Leja ya Mwanachama',
      'sharesHeld': 'Hisa Alizonazo',
      'savingsBalance': 'Salio la Akiba',
      'loanBalance': 'Deni la Mkopo',
      'activeStatus': 'Yupo Hai',
      'inactiveStatus': 'Amesitishwa',

      // Meetings
      'meetings': 'Mikutano ya Wiki',
      'meetingNumber': 'Mkutano #{number}',
      'meetingDate': 'Tarehe ya Mkutano',
      'meetingMode': 'Usimamizi wa Mkutano',
      'attendanceRollCall': 'Kupiga Mahudhurio',
      'present': 'Amefika',
      'late': 'Amechelewa',
      'absent': 'Hajafika',
      'authorizedAbsent': 'Ameomba Ruhusa',
      'recordCollection': 'Kusanya Michango',
      'socialFund': 'Mfuko wa Jamii',
      'fineIssue': 'Toa Faini ya Utoro',
      'closeMeeting': 'Funga Mkutano',
      'meetingClosedSummary': 'Muhtasari wa Mkutano na Salio',

      // Loans
      'loans': 'Mikopo',
      'activeLoans': 'Mikopo Inayoendelea',
      'loanAmount': 'Kiasi cha Mkopo',
      'durationMonths': 'Muda (Miezi)',
      'monthlyInterest': 'Kiwango cha Riba',
      'repayLoan': 'Lipa Marejesho',
      'guarantors': 'Wadhamini',
      'eligibilityScore': 'Kiwango cha Kukopa',
      'disburseLoan': 'Toa Pesa ya Mkopo',

      // Receipts & QR
      'receipts': 'Risiti za Kidijitali',
      'receiptNumber': 'Namba ya Risiti',
      'receiptHash': 'Saini ya Kihesabu (SHA-256)',
      'scanVerify': 'Piga picha QR Code kuthibitisha',
      'tamperEvident': 'Imethibitishwa Kidijitali',

      // Fines
      'fines': 'Faini na Adhabu',
      'unpaidFines': 'Faini Zisizolipwa',
      'payFine': 'Lipa Faini',
      'waiveFine': 'Samehe Faini',
      'fineReason': 'Sababu ya Faini',

      // Cycles & Share-out
      'cycles': 'Mgao wa Mzunguko (Gawio)',
      'cycleName': 'Mzunguko #{number}',
      'dividendShare': 'Kadirio la Gawio',
      'distributeDividends': 'Kokotoa Mgao wa Faida',

      // Governance
      'governance': 'Utawala na Kura',
      'activeProposals': 'Hoja na Upigaji Kura',
      'socialWelfareRequests': 'Maombi ya Mfuko wa Jamii',
      'disputes': 'Malalamiko na Rufaa',
      'voteFor': 'Piga Kura ya Ndiyo',
      'voteAgainst': 'Piga Kura ya Hapana',

      // M-Pesa & Reconciliation
      'reconciliation': 'Upatanisho wa M-Pesa',
      'stkPush': 'Tuma Ombi la M-Pesa (STK)',
      'transactionStatus': 'Hali ya Muamala',
      'matchLedger': 'Imelinganishwa na Leja',

      // AI Advisor
      'aiAdvisor': 'Mshauri wa AI wa VICOBA',
      'healthScore': 'Kiwango cha Afya ya Fedha',
      'askAdvisor': 'Uliza swali lolote la kifedha la kikundi...',
      'riskAppraisal': 'Tathmini ya Hatari ya Kikundi',

      // Subscription & Settings
      'subscription': 'Mpango na Malipo',
      'currentPlan': 'Mpango wa Sasa',
      'upgradePlan': 'Boresha Mpango',
      'settings': 'Mipangilio',
      'language': 'Lugha / Language',
      'theme': 'Muonekano',
      'darkMode': 'Hali ya Usiku',
      'lightMode': 'Hali ya Mchana',
      'auditLogs': 'Kumbukumbu za Ukaguzi',

      // Loan Schedule & Guarantees
      'loanDetails': 'Taarifa za Mkopo na Ratiba',
      'amortizationSchedule': 'Ratiba ya Marejesho',
      'myGuarantees': 'Dhamana Zangu',
      'acceptGuarantee': 'Kubali Udhamini',
      'declineGuarantee': 'Kataa Udhamini',
      'pledgedAmount': 'Kiasi Kilichodhaminiwa',
      'approveLoan': 'Idhinisha Mkopo',
      'rejectLoan': 'Kataa Mkopo',
      'installmentNumber': 'Awamu ya {num}',

      // Federation & Apex
      'federation': 'Muungano wa VICOBA',
      'federations': 'Miungano ya VICOBA',
      'cooperativeNetwork': 'Mtandao wa Vikundi',
      'combinedCapital': 'Mtaji Mjumuisho',
      'solvencyIndex': 'Kiwango cha Ukwasi',
      'interLendingPool': 'Hazina ya Kukopeshana Vikundi',
      'peerGroups': 'Vikundi Shirikishi',
      'affiliateGroup': 'Jiunge na Muungano',
      'createFederation': 'Anzisha Muungano Mpya',

      // Financial Reports
      'reports': 'Ripoti za Kifedha',
      'balanceSheet': 'Mizania (Balance Sheet)',
      'incomeStatement': 'Taarifa ya Mapato na Matumizi',
      'cashFlow': 'Mtiririko wa Fedha Taslimu',
      'totalAssets': 'Jumla ya Mali',
      'totalLiabilities': 'Jumla ya Dhima na Mtaji',
      'operatingExpenses': 'Gharama za Uendeshaji',
      'netSurplus': 'Faida Halisi / Ziada',
      'exportPdf': 'Pakua Ripoti ya PDF',

      // Receipt Verification
      'verifyReceipt': 'Thibitisha Risiti',
      'receiptVerification': 'Uhakiki wa Risiti ya Kidijitali',
      'scanQrCode': 'Skani QR Kodi',
      'tamperProof': 'Imelindwa Kidijitali',
      'receiptValid': 'Risiti Halali - Imethibitishwa kwenye Leja',

      // Security & Sessions
      'securitySessions': 'Vifaa Vilivyoingia',
      'currentDevice': 'Kifaa Hiki cha Sasa',
      'revokeSession': 'Funga Kifaa Hiki',
      'revokeAllOthers': 'Ondoa Vifaa Vingine Vyote',
    },
  };

  String translate(String key, [Map<String, String>? params]) {
    String? value = _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value?.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sw'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
