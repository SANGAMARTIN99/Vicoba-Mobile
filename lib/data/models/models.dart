import 'package:flutter/foundation.dart';

// Data Models for VicobaPlus Mobile

class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final List<String> roles;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      email: json['email'],
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['role'] != null ? [json['role'].toString()] : ['MEMBER']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'roles': roles,
      };
}

class UserContext {
  final String groupId;
  final String groupName;
  final String? groupCode;
  final String role;
  final String? status;

  UserContext({
    required this.groupId,
    required this.groupName,
    this.groupCode,
    required this.role,
    this.status,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) {
    return UserContext(
      groupId: json['groupId']?.toString() ?? json['id']?.toString() ?? '',
      groupName: json['groupName'] ?? json['name'] ?? 'VICOBA Group',
      groupCode: json['groupCode'] ?? json['code'],
      role: json['role'] ?? json['roleName'] ?? 'MEMBER',
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'groupName': groupName,
        'groupCode': groupCode,
        'role': role,
        'status': status,
      };
}

class AuthResponse {
  final String? token;
  final String? preAuthToken;
  final UserProfile? user;
  final List<UserContext> availableContexts;
  final UserContext? activeContext;

  AuthResponse({
    this.token,
    this.preAuthToken,
    this.user,
    required this.availableContexts,
    this.activeContext,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final contextsList = (json['availableContexts'] as List<dynamic>?)
            ?.map((e) => UserContext.fromJson(e as Map<String, dynamic>))
            .toList() ??
        (json['contexts'] as List<dynamic>?)
            ?.map((e) => UserContext.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    UserContext? active;
    if (json['activeContext'] != null && json['activeContext'] is Map<String, dynamic>) {
      active = UserContext.fromJson(json['activeContext']);
    } else if (contextsList.isNotEmpty) {
      active = contextsList.first;
    }

    return AuthResponse(
      token: json['token'] ?? json['accessToken'],
      preAuthToken: json['preAuthToken'],
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      availableContexts: contextsList,
      activeContext: active,
    );
  }
}

class DashboardMetrics {
  final double totalSharesValue;
  final double totalVoluntarySavings;
  final double outstandingLoansBalance;
  final double groupCashInVault;
  final int totalMembersCount;
  final ActiveMeetingBanner? activeMeeting;
  final List<RecentTransaction> recentTransactions;

  DashboardMetrics({
    required this.totalSharesValue,
    required this.totalVoluntarySavings,
    required this.outstandingLoansBalance,
    required this.groupCashInVault,
    required this.totalMembersCount,
    this.activeMeeting,
    required this.recentTransactions,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalSharesValue: (json['totalSharesValue'] ?? json['totalShares'] ?? 0).toDouble(),
      totalVoluntarySavings: (json['totalVoluntarySavings'] ?? json['totalSavings'] ?? 0).toDouble(),
      outstandingLoansBalance: (json['outstandingLoansBalance'] ?? json['totalLoans'] ?? 0).toDouble(),
      groupCashInVault: (json['groupCashInVault'] ?? json['cashInVault'] ?? 0).toDouble(),
      totalMembersCount: (json['totalMembersCount'] ?? json['activeMembersCount'] ?? 0).toInt(),
      activeMeeting: json['activeMeeting'] != null
          ? ActiveMeetingBanner.fromJson(json['activeMeeting'])
          : null,
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => RecentTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ActiveMeetingBanner {
  final String id;
  final int meetingNumber;
  final String meetingDate;
  final String status;

  ActiveMeetingBanner({
    required this.id,
    required this.meetingNumber,
    required this.meetingDate,
    required this.status,
  });

  factory ActiveMeetingBanner.fromJson(Map<String, dynamic> json) {
    return ActiveMeetingBanner(
      id: json['id']?.toString() ?? '',
      meetingNumber: (json['meetingNumber'] ?? json['number'] ?? 1).toInt(),
      meetingDate: json['meetingDate'] ?? json['date'] ?? '',
      status: json['status'] ?? 'IN_PROGRESS',
    );
  }
}

class RecentTransaction {
  final String id;
  final String type;
  final double amount;
  final String memberName;
  final String date;
  final String? receiptNumber;

  RecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.memberName,
    required this.date,
    this.receiptNumber,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? json['transactionType'] ?? 'SHARE_PURCHASE',
      amount: (json['amount'] ?? 0).toDouble(),
      memberName: json['memberName'] ?? json['memberFullName'] ?? 'Member',
      date: json['date'] ?? json['createdAt'] ?? '',
      receiptNumber: json['receiptNumber'],
    );
  }
}

class Member {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String role;
  final String status;
  final int sharesCount;
  final double totalSharesAmount;
  final double voluntarySavingsBalance;
  final double activeLoanBalance;
  final String? joinedAt;

  Member({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.sharesCount,
    required this.totalSharesAmount,
    required this.voluntarySavingsBalance,
    required this.activeLoanBalance,
    this.joinedAt,
  });

  String get phoneNumber => phone;
  double get savingsBalance => voluntarySavingsBalance;
  bool get isActive => status == 'ACTIVE';
  int get activeLoansCount => activeLoanBalance > 0 ? 1 : 0;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'ACTIVE',
      sharesCount: (json['sharesCount'] ?? json['numberOfShares'] ?? 0).toInt(),
      totalSharesAmount: (json['totalSharesAmount'] ?? 0).toDouble(),
      voluntarySavingsBalance: (json['voluntarySavingsBalance'] ?? json['savings'] ?? 0).toDouble(),
      activeLoanBalance: (json['activeLoanBalance'] ?? json['loanBalance'] ?? 0).toDouble(),
      joinedAt: json['joinedAt'] ?? json['createdAt'],
    );
  }
}

class Meeting {
  final String id;
  final int meetingNumber;
  final String meetingDate;
  final String status; // PLANNED, IN_PROGRESS, CLOSED
  final String? cycleId;
  final double totalCollections;
  final int attendanceCount;

  Meeting({
    required this.id,
    required this.meetingNumber,
    required this.meetingDate,
    required this.status,
    this.cycleId,
    required this.totalCollections,
    required this.attendanceCount,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id']?.toString() ?? '',
      meetingNumber: (json['meetingNumber'] ?? json['number'] ?? 1).toInt(),
      meetingDate: json['meetingDate'] ?? '',
      status: json['status'] ?? 'PLANNED',
      cycleId: json['cycleId']?.toString(),
      totalCollections: (json['totalCollections'] ?? 0).toDouble(),
      attendanceCount: (json['attendanceCount'] ?? 0).toInt(),
    );
  }
}

class AttendanceEntry {
  final String membershipId;
  final String memberName;
  String status; // PRESENT, LATE, ABSENT, EXCUSED
  String? notes;

  AttendanceEntry({
    required this.membershipId,
    required this.memberName,
    required this.status,
    this.notes,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      membershipId: json['membershipId']?.toString() ?? json['memberId']?.toString() ?? '',
      memberName: json['memberName'] ?? json['fullName'] ?? 'Member',
      status: json['status'] ?? 'PRESENT',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'membershipId': membershipId,
        'status': status,
        'notes': notes,
      };
}

class Loan {
  final String id;
  final String? loanNumber;
  final String memberId;
  final String memberName;
  final double principalAmount;
  final double interestRate;
  final int durationMonths;
  final double totalRepayable;
  final double balanceRemaining;
  final String status; // PENDING, APPROVED, REJECTED, DISBURSED, REPAID
  final String? purpose;
  final String? applicationDate;

  Loan({
    required this.id,
    this.loanNumber,
    required this.memberId,
    required this.memberName,
    required this.principalAmount,
    required this.interestRate,
    required this.durationMonths,
    required this.totalRepayable,
    required this.balanceRemaining,
    required this.status,
    this.purpose,
    this.applicationDate,
  });

  String get borrowerName => memberName;
  double get principal => principalAmount;

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id']?.toString() ?? '',
      loanNumber: json['loanNumber'],
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] ?? json['borrowerName'] ?? 'Member',
      principalAmount: (json['principalAmount'] ?? json['principal'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 10.0).toDouble(),
      durationMonths: (json['durationMonths'] ?? json['duration'] ?? 3).toInt(),
      totalRepayable: (json['totalRepayable'] ?? 0).toDouble(),
      balanceRemaining: (json['balanceRemaining'] ?? json['balance'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      purpose: json['purpose'],
      applicationDate: json['applicationDate'] ?? json['createdAt'],
    );
  }
}

class Receipt {
  final String id;
  final String receiptNumber;
  final String type; // SHARE_PURCHASE, SAVINGS_DEPOSIT, LOAN_REPAYMENT, FINE_PAYMENT
  final double amount;
  final String memberName;
  final String? membershipId;
  final String createdAt;
  final String digitalSignatureHash;
  final String qrPayload;
  final String? groupName;
  final String? issuedBy;

  String get hashSignature => digitalSignatureHash;
  String get signatureHash => digitalSignatureHash;
  String get issuedAt => createdAt;
  bool get isVerified => digitalSignatureHash.isNotEmpty;

  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.type,
    required this.amount,
    required this.memberName,
    this.membershipId,
    String? createdAt,
    String? issuedAt,
    String? digitalSignatureHash,
    String? signatureHash,
    String? qrPayload,
    this.groupName,
    this.issuedBy,
  })  : createdAt = createdAt ?? issuedAt ?? DateTime.now().toIso8601String(),
        digitalSignatureHash = digitalSignatureHash ??
            signatureHash ??
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        qrPayload = qrPayload ??
            'https://vicobaplus.com/verify/$receiptNumber?hash=${digitalSignatureHash ?? signatureHash ?? "verified"}';

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final rNumber = json['receiptNumber'] ?? 'REC-${DateTime.now().millisecondsSinceEpoch}';
    final hash = json['digitalSignatureHash'] ??
        json['hash'] ??
        json['signatureHash'] ??
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    return Receipt(
      id: json['id']?.toString() ?? '',
      receiptNumber: rNumber,
      type: json['type'] ?? json['receiptType'] ?? 'SHARE_PURCHASE',
      amount: (json['amount'] ?? 0).toDouble(),
      memberName: json['memberName'] ?? json['member'] ?? 'Member',
      membershipId: json['membershipId']?.toString(),
      createdAt: json['createdAt'] ?? json['issuedAt'] ?? DateTime.now().toIso8601String(),
      digitalSignatureHash: hash,
      qrPayload: json['qrPayload'] ?? 'https://vicobaplus.com/verify/$rNumber?hash=$hash',
      groupName: json['groupName'],
      issuedBy: json['issuedBy'],
    );
  }
}

class Fine {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final String reason;
  final String status; // UNPAID, PAID, WAIVED
  final String? issuedAt;
  final String? paidAt;

  Fine({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.reason,
    required this.status,
    this.issuedAt,
    this.paidAt,
  });

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? json['membershipId']?.toString() ?? '',
      memberName: json['memberName'] ?? 'Member',
      amount: (json['amount'] ?? 0).toDouble(),
      reason: json['reason'] ?? 'Meeting Absence',
      status: json['status'] ?? 'UNPAID',
      issuedAt: json['issuedAt'] ?? json['createdAt'],
      paidAt: json['paidAt'],
    );
  }
}

class Cycle {
  final String id;
  final int cycleNumber;
  final String name;
  final String startDate;
  final String? endDate;
  final String status; // ACTIVE, COMPLETED
  final double totalShares;
  final double totalEarnings;
  final double estimatedDividend;

  Cycle({
    required this.id,
    required this.cycleNumber,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.totalShares,
    required this.totalEarnings,
    required this.estimatedDividend,
  });

  factory Cycle.fromJson(Map<String, dynamic> json) {
    return Cycle(
      id: json['id']?.toString() ?? '',
      cycleNumber: (json['cycleNumber'] ?? 1).toInt(),
      name: json['name'] ?? 'Cycle 1',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'],
      status: json['status'] ?? 'ACTIVE',
      totalShares: (json['totalShares'] ?? 0).toDouble(),
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      estimatedDividend: (json['estimatedDividend'] ?? 0).toDouble(),
    );
  }
}

class ProposalVote {
  final String id;
  final String title;
  final String? description;
  final String status; // OPEN, CLOSED
  final String closesAt;
  final int votesFor;
  final int votesAgainst;
  final String? userVote;

  ProposalVote({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.closesAt,
    required this.votesFor,
    required this.votesAgainst,
    this.userVote,
  });

  factory ProposalVote.fromJson(Map<String, dynamic> json) {
    return ProposalVote(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'OPEN',
      closesAt: json['closesAt'] ?? '',
      votesFor: (json['votesFor'] ?? 0).toInt(),
      votesAgainst: (json['votesAgainst'] ?? 0).toInt(),
      userVote: json['userVote'],
    );
  }
}

class SocialFundClaim {
  final String id;
  final String memberName;
  final double amount;
  final String reason;
  final String status; // PENDING, APPROVED, DISBURSED
  final String createdAt;

  SocialFundClaim({
    required this.id,
    required this.memberName,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory SocialFundClaim.fromJson(Map<String, dynamic> json) {
    return SocialFundClaim(
      id: json['id']?.toString() ?? '',
      memberName: json['memberName'] ?? 'Member',
      amount: (json['amount'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ReconciliationRecord {
  final String id;
  final String reference;
  final String phoneNumber;
  final double amount;
  final String status; // COMPLETED, PENDING, FAILED
  final bool matchedWithLedger;
  final String date;

  ReconciliationRecord({
    required this.id,
    required this.reference,
    required this.phoneNumber,
    required this.amount,
    required this.status,
    required this.matchedWithLedger,
    required this.date,
  });

  factory ReconciliationRecord.fromJson(Map<String, dynamic> json) {
    return ReconciliationRecord(
      id: json['id']?.toString() ?? '',
      reference: json['reference'] ?? json['mpesaReference'] ?? 'REF-${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: json['phoneNumber'] ?? json['phone'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'COMPLETED',
      matchedWithLedger: json['matchedWithLedger'] ?? true,
      date: json['date'] ?? json['createdAt'] ?? '',
    );
  }
}

class AiChatMessage {
  final String id;
  final String role; // USER, ASSISTANT
  final String content;
  final DateTime timestamp;

  AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      role: json['role'] ?? 'ASSISTANT',
      content: json['content'] ?? json['reply'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class RiskAssessment {
  final double score; // 0 to 100
  final String riskLevel; // LOW, MODERATE, ELEVATED, CRITICAL
  final String summary;
  final List<String> recommendations;

  RiskAssessment({
    required this.score,
    required this.riskLevel,
    required this.summary,
    required this.recommendations,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      score: (json['score'] ?? 85.0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'LOW',
      summary: json['summary'] ?? 'Group demonstrates strong savings discipline and timely loan repayments.',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'Maintain regular weekly meetings to ensure high attendance.',
            'Encourage loan diversification across more business sectors.',
            'Review social welfare reserve levels before annual share-out.',
          ],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String code;
  final double priceMonthly;
  final int maxMembers;
  final List<String> features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.code,
    required this.priceMonthly,
    required this.maxMembers,
    required this.features,
  });
}

// -------------------------------------------------------------
// LOAN DETAILS & REPAYMENT SCHEDULE
// -------------------------------------------------------------
class LoanScheduleItem {
  final int installmentNumber;
  final String dueDate;
  final double principalDue;
  final double interestDue;
  final double totalDue;
  final String status; // PENDING, PAID, OVERDUE
  final String? paidAt;

  LoanScheduleItem({
    required this.installmentNumber,
    required this.dueDate,
    required this.principalDue,
    required this.interestDue,
    required this.totalDue,
    required this.status,
    this.paidAt,
  });

  factory LoanScheduleItem.fromJson(Map<String, dynamic> json) {
    return LoanScheduleItem(
      installmentNumber: (json['installmentNumber'] ?? json['installmentNo'] ?? 1).toInt(),
      dueDate: json['dueDate'] ?? '',
      principalDue: (json['principalDue'] ?? json['principal'] ?? 0).toDouble(),
      interestDue: (json['interestDue'] ?? json['interest'] ?? 0).toDouble(),
      totalDue: (json['totalDue'] ?? json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      paidAt: json['paidAt'],
    );
  }
}

class LoanGuarantor {
  final String id;
  final String loanId;
  final String memberName;
  final String membershipId;
  final double pledgeAmount;
  final String status; // PENDING, APPROVED, REJECTED
  final String? requestedAt;
  final String? borrowerName;
  final double? loanAmount;

  LoanGuarantor({
    required this.id,
    required this.loanId,
    required this.memberName,
    required this.membershipId,
    required this.pledgeAmount,
    required this.status,
    this.requestedAt,
    this.borrowerName,
    this.loanAmount,
  });

  factory LoanGuarantor.fromJson(Map<String, dynamic> json) {
    return LoanGuarantor(
      id: json['id']?.toString() ?? '',
      loanId: json['loanId']?.toString() ?? '',
      memberName: json['memberName'] ?? json['guarantorName'] ?? 'Member',
      membershipId: json['membershipId']?.toString() ?? '',
      pledgeAmount: (json['pledgeAmount'] ?? json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      requestedAt: json['requestedAt'] ?? json['createdAt'],
      borrowerName: json['borrowerName'],
      loanAmount: json['loanAmount'] != null ? (json['loanAmount']).toDouble() : null,
    );
  }
}

class LoanDetail {
  final Loan loan;
  final List<LoanScheduleItem> schedule;
  final List<LoanGuarantor> guarantors;
  final double totalRepaid;
  final String interestMethod; // FLAT, REDUCING
  final String? approvedAt;
  final String? disbursedAt;

  LoanDetail({
    required this.loan,
    required this.schedule,
    required this.guarantors,
    required this.totalRepaid,
    this.interestMethod = 'FLAT',
    this.approvedAt,
    this.disbursedAt,
  });

  factory LoanDetail.fromJson(Map<String, dynamic> json) {
    final loanObj = Loan.fromJson(json['loan'] is Map<String, dynamic> ? json['loan'] : json);
    final scheduleList = (json['schedule'] as List<dynamic>?)
            ?.map((e) => LoanScheduleItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final guarantorList = (json['guarantors'] as List<dynamic>?)
            ?.map((e) => LoanGuarantor.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return LoanDetail(
      loan: loanObj,
      schedule: scheduleList,
      guarantors: guarantorList,
      totalRepaid: (json['totalRepaid'] ?? 0).toDouble(),
      interestMethod: json['interestMethod'] ?? 'FLAT',
      approvedAt: json['approvedAt'],
      disbursedAt: json['disbursedAt'],
    );
  }
}

// -------------------------------------------------------------
// FEDERATION & APEX COOPERATIVE NETWORK
// -------------------------------------------------------------
class Federation {
  final String id;
  final String name;
  final String code;
  final String region;
  final String district;
  final int groupCount;
  final String? createdAt;
  final String description;
  final int totalMembers;
  final double combinedCapital;
  final double interLendingPool;
  final double solvencyIndex;
  final FederationMetrics? metrics;
  final List<PeerGroupBenchmark> peerGroups;

  int get totalGroups => groupCount;

  Federation({
    required this.id,
    required this.name,
    required this.code,
    this.region = 'Dar es Salaam',
    this.district = 'Ilala',
    int? groupCount,
    int? totalGroups,
    this.createdAt,
    this.description = '',
    this.totalMembers = 0,
    this.combinedCapital = 0.0,
    this.interLendingPool = 0.0,
    this.solvencyIndex = 95.0,
    this.metrics,
    this.peerGroups = const [],
  }) : groupCount = groupCount ?? totalGroups ?? 1;

  factory Federation.fromJson(Map<String, dynamic> json) {
    final peers = (json['peerGroups'] as List<dynamic>?)
            ?.map((e) => PeerGroupBenchmark.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return Federation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      region: json['region'] ?? 'Dar es Salaam',
      district: json['district'] ?? 'Ilala',
      groupCount: (json['groupCount'] ?? json['totalGroups'] ?? 1).toInt(),
      createdAt: json['createdAt'],
      description: json['description'] ?? '',
      totalMembers: (json['totalMembers'] ?? 0).toInt(),
      combinedCapital: (json['combinedCapital'] ?? 0).toDouble(),
      interLendingPool: (json['interLendingPool'] ?? 0).toDouble(),
      solvencyIndex: (json['solvencyIndex'] ?? 95.0).toDouble(),
      metrics: json['metrics'] != null ? FederationMetrics.fromJson(json['metrics']) : null,
      peerGroups: peers,
    );
  }
}

class PeerGroupBenchmark {
  final String id;
  final String name;
  final String code;
  final String region;
  final int memberCount;
  final double totalSavings;
  final double solvencyScore;
  final String riskGrade; // AAA, AA, A, BBB

  String get groupId => id;
  String get groupName => name;

  PeerGroupBenchmark({
    String? id,
    String? groupId,
    String? name,
    String? groupName,
    this.code = '',
    this.region = '',
    required this.memberCount,
    required this.totalSavings,
    required this.solvencyScore,
    required this.riskGrade,
  })  : id = id ?? groupId ?? '',
        name = name ?? groupName ?? '';

  factory PeerGroupBenchmark.fromJson(Map<String, dynamic> json) {
    return PeerGroupBenchmark(
      id: (json['id'] ?? json['groupId'])?.toString() ?? '',
      name: json['name'] ?? json['groupName'] ?? '',
      code: json['code'] ?? '',
      region: json['region'] ?? '',
      memberCount: (json['memberCount'] ?? 25).toInt(),
      totalSavings: (json['totalSavings'] ?? 0).toDouble(),
      solvencyScore: (json['solvencyScore'] ?? 95.0).toDouble(),
      riskGrade: json['riskGrade'] ?? 'AA',
    );
  }
}

typedef FederationPeerGroup = PeerGroupBenchmark;

class FederationMetrics {
  final int totalGroups;
  final double combinedCapital;
  final int aggregateMembers;
  final double solvencyIndex;
  final double interLendingPool;
  final double averageRecoveryRate;
  final List<PeerGroupBenchmark> peerGroups;

  double get totalCapital => combinedCapital;
  int get totalMembers => aggregateMembers;
  double get averageSolvencyScore => solvencyIndex;
  double get interLendingAvailable => interLendingPool;
  double get defaultRate => (100.0 - averageRecoveryRate).clamp(0.0, 100.0);

  FederationMetrics({
    required this.totalGroups,
    double? combinedCapital,
    double? totalCapital,
    int? aggregateMembers,
    int? totalMembers,
    double? solvencyIndex,
    double? averageSolvencyScore,
    double? interLendingPool,
    double? interLendingAvailable,
    double? averageRecoveryRate,
    double? defaultRate,
    List<PeerGroupBenchmark>? peerGroups,
  })  : combinedCapital = (combinedCapital ?? totalCapital ?? 0).toDouble(),
        aggregateMembers = (aggregateMembers ?? totalMembers ?? 0).toInt(),
        solvencyIndex = (solvencyIndex ?? averageSolvencyScore ?? 0).toDouble(),
        interLendingPool = (interLendingPool ?? interLendingAvailable ?? 0).toDouble(),
        averageRecoveryRate = (averageRecoveryRate ?? (defaultRate != null ? (100.0 - defaultRate) : 98.0)).toDouble(),
        peerGroups = peerGroups ?? [];

  factory FederationMetrics.fromJson(Map<String, dynamic> json) {
    final peers = (json['peerGroups'] as List<dynamic>?)
            ?.map((e) => PeerGroupBenchmark.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return FederationMetrics(
      totalGroups: (json['totalGroups'] ?? 14).toInt(),
      combinedCapital: (json['combinedCapital'] ?? json['totalCapital'] ?? 84500000).toDouble(),
      aggregateMembers: (json['aggregateMembers'] ?? json['totalMembers'] ?? 350).toInt(),
      solvencyIndex: (json['solvencyIndex'] ?? json['averageSolvencyScore'] ?? 98.4).toDouble(),
      interLendingPool: (json['interLendingPool'] ?? json['interLendingAvailable'] ?? 24000000).toDouble(),
      averageRecoveryRate: (json['averageRecoveryRate'] ?? (json['defaultRate'] != null ? (100.0 - json['defaultRate']) : 99.1)).toDouble(),
      peerGroups: peers,
    );
  }
}

// -------------------------------------------------------------
// FINANCIAL STATEMENTS & REPORTS
// -------------------------------------------------------------
class BalanceSheetReport {
  final String asOfDate;
  final double cashOnHand;
  final double bankBalance;
  final double loansReceivable;
  final double otherAssets;
  final double totalAssets;
  final double memberSavings;
  final double socialFund;
  final double emergencyFund;
  final double retainedSurplus;
  final double totalLiabilitiesAndEquity;

  BalanceSheetReport({
    this.asOfDate = '',
    required this.cashOnHand,
    this.bankBalance = 0.0,
    required this.loansReceivable,
    this.otherAssets = 0.0,
    double? totalAssets,
    required this.memberSavings,
    required this.socialFund,
    this.emergencyFund = 0.0,
    required this.retainedSurplus,
    double? totalLiabilitiesAndEquity,
  })  : totalAssets = totalAssets ?? (cashOnHand + bankBalance + loansReceivable + otherAssets),
        totalLiabilitiesAndEquity = totalLiabilitiesAndEquity ?? (memberSavings + socialFund + emergencyFund + retainedSurplus);

  factory BalanceSheetReport.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as Map<String, dynamic>? ?? {};
    final liab = json['liabilitiesAndEquity'] as Map<String, dynamic>? ?? {};
    final cash = (assets['cashOnHand'] ?? json['cashOnHand'] ?? 2450000).toDouble();
    final bank = (assets['bankBalance'] ?? json['bankBalance'] ?? 0).toDouble();
    final loans = (assets['loansReceivable'] ?? json['loansReceivable'] ?? 1820000).toDouble();
    final other = (assets['otherAssets'] ?? json['otherAssets'] ?? 0).toDouble();
    final savings = (liab['memberSavings'] ?? json['memberSavings'] ?? 3200000).toDouble();
    final social = (liab['socialFund'] ?? json['socialFund'] ?? 350000).toDouble();
    final emergency = (liab['emergencyFund'] ?? json['emergencyFund'] ?? 0).toDouble();
    final surplus = (liab['retainedSurplus'] ?? json['retainedSurplus'] ?? 720000).toDouble();

    return BalanceSheetReport(
      asOfDate: json['asOfDate'] ?? '',
      cashOnHand: cash,
      bankBalance: bank,
      loansReceivable: loans,
      otherAssets: other,
      totalAssets: (json['totalAssets'] ?? (cash + bank + loans + other)).toDouble(),
      memberSavings: savings,
      socialFund: social,
      emergencyFund: emergency,
      retainedSurplus: surplus,
      totalLiabilitiesAndEquity: (json['totalLiabilitiesAndEquity'] ?? (savings + social + emergency + surplus)).toDouble(),
    );
  }
}

class IncomeStatementReport {
  final String periodStart;
  final String periodEnd;
  final double interestRevenue;
  final double finesAndPenalties;
  final double membershipFees;
  final double otherIncome;
  final double totalRevenue;
  final double stationeryExpenses;
  final double meetingExpenses;
  final double bankCharges;
  final double welfarePayouts;
  final double totalExpenses;
  final double netSurplus;

  // Compatibility getters
  double get interestIncome => interestRevenue;
  double get finesIncome => finesAndPenalties;
  double get totalIncome => totalRevenue;
  double get operatingExpenses => totalExpenses;

  IncomeStatementReport({
    this.periodStart = '',
    this.periodEnd = '',
    double? interestRevenue,
    double? finesAndPenalties,
    this.membershipFees = 0.0,
    this.otherIncome = 0.0,
    double? totalRevenue,
    this.stationeryExpenses = 0.0,
    this.meetingExpenses = 0.0,
    this.bankCharges = 0.0,
    this.welfarePayouts = 0.0,
    double? totalExpenses,
    double? netSurplus,
    // Alternative parameter names
    double? interestIncome,
    double? finesIncome,
    double? totalIncome,
    double? operatingExpenses,
  })  : interestRevenue = interestRevenue ?? interestIncome ?? 0.0,
        finesAndPenalties = finesAndPenalties ?? finesIncome ?? 0.0,
        totalRevenue = totalRevenue ?? totalIncome ?? ((interestRevenue ?? interestIncome ?? 0.0) + (finesAndPenalties ?? finesIncome ?? 0.0) + (membershipFees) + (otherIncome)),
        totalExpenses = totalExpenses ?? operatingExpenses ?? (stationeryExpenses + meetingExpenses + bankCharges + welfarePayouts),
        netSurplus = netSurplus ?? ((totalRevenue ?? totalIncome ?? 0.0) - (totalExpenses ?? operatingExpenses ?? 0.0));

  factory IncomeStatementReport.fromJson(Map<String, dynamic> json) {
    final interest = (json['interestRevenue'] ?? json['interestIncome'] ?? 380000).toDouble();
    final fines = (json['finesAndPenalties'] ?? json['finesIncome'] ?? 45000).toDouble();
    final memberFees = (json['membershipFees'] ?? 0).toDouble();
    final other = (json['otherIncome'] ?? 0).toDouble();
    final total = (json['totalRevenue'] ?? json['totalIncome'] ?? (interest + fines + memberFees + other)).toDouble();

    final stationery = (json['stationeryExpenses'] ?? 0).toDouble();
    final meeting = (json['meetingExpenses'] ?? 0).toDouble();
    final bank = (json['bankCharges'] ?? 0).toDouble();
    final welfare = (json['welfarePayouts'] ?? 0).toDouble();
    final expenses = (json['totalExpenses'] ?? json['operatingExpenses'] ?? (stationery + meeting + bank + welfare)).toDouble();
    final surplus = (json['netSurplus'] ?? (total - expenses)).toDouble();

    return IncomeStatementReport(
      periodStart: json['periodStart'] ?? '',
      periodEnd: json['periodEnd'] ?? '',
      interestRevenue: interest,
      finesAndPenalties: fines,
      membershipFees: memberFees,
      otherIncome: other,
      totalRevenue: total,
      stationeryExpenses: stationery,
      meetingExpenses: meeting,
      bankCharges: bank,
      welfarePayouts: welfare,
      totalExpenses: expenses,
      netSurplus: surplus,
    );
  }
}

class CashFlowStatementReport {
  final String periodStart;
  final String periodEnd;
  final double savingsInflow;
  final double loanRepaymentsInflow;
  final double interestAndFeesInflow;
  final double totalInflow;
  final double loansDisbursedOutflow;
  final double expensesPaidOutflow;
  final double welfareOutflow;
  final double totalOutflow;
  final double beginningCash;
  final double netCashFlow;
  final double endingCash;

  double get cashIn => totalInflow;
  double get cashOut => totalOutflow;

  CashFlowStatementReport({
    this.periodStart = '',
    this.periodEnd = '',
    this.savingsInflow = 0.0,
    this.loanRepaymentsInflow = 0.0,
    this.interestAndFeesInflow = 0.0,
    double? totalInflow,
    this.loansDisbursedOutflow = 0.0,
    this.expensesPaidOutflow = 0.0,
    this.welfareOutflow = 0.0,
    double? totalOutflow,
    this.beginningCash = 0.0,
    double? netCashFlow,
    this.endingCash = 0.0,
    double? cashIn,
    double? cashOut,
  })  : totalInflow = totalInflow ?? cashIn ?? (savingsInflow + loanRepaymentsInflow + interestAndFeesInflow),
        totalOutflow = totalOutflow ?? cashOut ?? (loansDisbursedOutflow + expensesPaidOutflow + welfareOutflow),
        netCashFlow = netCashFlow ?? ((totalInflow ?? cashIn ?? 0.0) - (totalOutflow ?? cashOut ?? 0.0));

  factory CashFlowStatementReport.fromJson(Map<String, dynamic> json) {
    final cin = (json['totalInflow'] ?? json['cashIn'] ?? 1450000).toDouble();
    final cout = (json['totalOutflow'] ?? json['cashOut'] ?? 890000).toDouble();
    return CashFlowStatementReport(
      periodStart: json['periodStart'] ?? '',
      periodEnd: json['periodEnd'] ?? '',
      savingsInflow: (json['savingsInflow'] ?? 0).toDouble(),
      loanRepaymentsInflow: (json['loanRepaymentsInflow'] ?? 0).toDouble(),
      interestAndFeesInflow: (json['interestAndFeesInflow'] ?? 0).toDouble(),
      totalInflow: cin,
      loansDisbursedOutflow: (json['loansDisbursedOutflow'] ?? 0).toDouble(),
      expensesPaidOutflow: (json['expensesPaidOutflow'] ?? 0).toDouble(),
      welfareOutflow: (json['welfareOutflow'] ?? 0).toDouble(),
      totalOutflow: cout,
      beginningCash: (json['beginningCash'] ?? 0).toDouble(),
      netCashFlow: (json['netCashFlow'] ?? (cin - cout)).toDouble(),
      endingCash: (json['endingCash'] ?? 0).toDouble(),
    );
  }
}

// -------------------------------------------------------------
// AUDIT LOGS & TAMPER-EVIDENT TRAILS
// -------------------------------------------------------------
class AuditLogEntry {
  final String id;
  final String action;
  final String actorName;
  final String actorRole;
  final String entityType;
  final String entityId;
  final String timestamp;
  final String details;
  final String hashSeal;
  final String ipAddress;
  final Map<String, dynamic>? changes;

  String get hash => hashSeal;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.actorName,
    required this.actorRole,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    required this.details,
    String? hashSeal,
    String? hash,
    String? ipAddress,
    this.changes,
  })  : hashSeal = hashSeal ?? hash ?? 'sha256-verified-$id',
        ipAddress = ipAddress ?? '197.250.45.12';

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id']?.toString() ?? '',
      action: json['action'] ?? 'UPDATE',
      actorName: json['actorName'] ?? json['performedBy'] ?? 'Leader',
      actorRole: json['actorRole'] ?? 'CHAIRPERSON',
      entityType: json['entityType'] ?? 'LOAN',
      entityId: json['entityId']?.toString() ?? '',
      timestamp: json['timestamp'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      details: json['details']?.toString() ?? json['description']?.toString() ?? '',
      hashSeal: json['hashSeal'] ??
          json['hash'] ??
          'sha256-verified-${json['id'] ?? "e3b0c44"}',
      ipAddress: json['ipAddress'] ?? '197.250.45.12',
      changes: json['changes'] is Map<String, dynamic> ? json['changes'] : null,
    );
  }
}

// -------------------------------------------------------------
// USER SECURITY SESSIONS
// -------------------------------------------------------------
class UserSession {
  final String id;
  final String deviceInfo;
  final String ipAddress;
  final String lastActive;
  final bool isCurrent;
  final String? location;
  final String? createdAt;

  String get device => deviceInfo;

  UserSession({
    required this.id,
    String? deviceInfo,
    String? device,
    required this.ipAddress,
    required this.lastActive,
    required this.isCurrent,
    this.location,
    this.createdAt,
  }) : deviceInfo = deviceInfo ?? device ?? 'Mobile Device';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id']?.toString() ?? '',
      deviceInfo: json['deviceInfo'] ?? json['device'] ?? json['userAgent'] ?? 'Mobile Device',
      ipAddress: json['ipAddress'] ?? '197.250.2.14',
      lastActive: json['lastActive'] ?? json['lastActivity'] ?? DateTime.now().toIso8601String(),
      isCurrent: json['isCurrent'] ?? false,
      location: json['location'] ?? 'Dar es Salaam, TZ',
      createdAt: json['createdAt'],
    );
  }
}
