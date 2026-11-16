class TeamMemberContribution {
  final String name;
  final String studentId;
  final String role;
  final double assignedHours;
  final double completedHours;
  final double hourlyRate;
  final double totalBudget;
  final double actualSpent;
  final double contributionPercent;

  TeamMemberContribution({
    required this.name,
    required this.studentId,
    required this.role,
    required this.assignedHours,
    required this.completedHours,
    required this.hourlyRate,
    required this.totalBudget,
    required this.actualSpent,
    required this.contributionPercent,
  });

  double get progressPercent => (completedHours / assignedHours) * 100;
}

class EvmMetricsModel {
  final double bac; // Budget at Completion ($4,126.00)
  final double pv;  // Planned Value ($2,650.00)
  final double ev;  // Earned Value ($2,307.20)
  final double ac;  // Actual Cost ($2,307.20)
  final double eac; // Estimate at Completion ($4,126.00)
  final double cv;  // Cost Variance ($0.00)
  final double sv;  // Schedule Variance (-$342.80)
  final double cpi; // Cost Performance Index (1.00)
  final double spi; // Schedule Performance Index (0.87 -> 1.00)
  final double totalWorkHours;    // 1,104.0 hrs
  final double actualWorkHours;   // 613.6 hrs
  final double remainingWorkHours;// 490.4 hrs
  final double percentComplete;   // 56%
  final List<TeamMemberContribution> teamMembers;

  EvmMetricsModel({
    required this.bac,
    required this.pv,
    required this.ev,
    required this.ac,
    required this.eac,
    required this.cv,
    required this.sv,
    required this.cpi,
    required this.spi,
    required this.totalWorkHours,
    required this.actualWorkHours,
    required this.remainingWorkHours,
    required this.percentComplete,
    required this.teamMembers,
  });

  static EvmMetricsModel getDefaultMetrics() {
    return EvmMetricsModel(
      bac: 4126.00,
      pv: 2650.00,
      ev: 2307.20,
      ac: 2307.20,
      eac: 4126.00,
      cv: 0.00,
      sv: -342.80,
      cpi: 1.00,
      spi: 0.87, // Recovers to 1.00 after Flutter switch
      totalWorkHours: 1104.0,
      actualWorkHours: 613.6,
      remainingWorkHours: 490.4,
      percentComplete: 56.0,
      teamMembers: [
        TeamMemberContribution(
          name: 'Trần Dương Thái',
          studentId: '23IT249',
          role: 'Trưởng nhóm / PM, Mobile Lead',
          assignedHours: 282.0,
          completedHours: 70.0,
          hourlyRate: 4.0,
          totalBudget: 1128.00,
          actualSpent: 280.00,
          contributionPercent: 25.0,
        ),
        TeamMemberContribution(
          name: 'Bùi Nguyễn Toàn',
          studentId: '23IT277',
          role: 'Backend Lead, Database Architect',
          assignedHours: 242.0,
          completedHours: 182.0,
          hourlyRate: 4.0,
          totalBudget: 968.00,
          actualSpent: 728.00,
          contributionPercent: 25.0,
        ),
        TeamMemberContribution(
          name: 'Nguyễn Thành Thịnh',
          studentId: '23IT262',
          role: 'Backend & Database Developer',
          assignedHours: 294.0,
          completedHours: 206.0,
          hourlyRate: 3.5,
          totalBudget: 1029.00,
          actualSpent: 721.00,
          contributionPercent: 25.0,
        ),
        TeamMemberContribution(
          name: 'Lê Thị Diệu Tâm',
          studentId: '23IT244',
          role: 'Frontend Lead, Tester & BA',
          assignedHours: 286.0,
          completedHours: 155.6,
          hourlyRate: 3.5,
          totalBudget: 1001.00,
          actualSpent: 544.60,
          contributionPercent: 25.0,
        ),
      ],
    );
  }
}

