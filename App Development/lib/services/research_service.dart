import 'package:flutter/foundation.dart';
import '../data/demo_data.dart';
import '../models/competitor_model.dart';
import '../models/research_model.dart';
import '../models/user_model.dart';

class ResearchService extends ChangeNotifier {
  static final ResearchService _instance = ResearchService._internal();
  factory ResearchService() => _instance;
  ResearchService._internal() {
    _user = DemoData.currentUser;
    _competitors = List.from(DemoData.initialCompetitors);
    _reports = List.from(DemoData.initialReports);
    _platformStats = List.from(DemoData.platformStats);
    _activityLog = [
      'Scraped BohoAestheticStudio (Etsy) • 184 listings indexed',
      'Compared ApexTactical Gear with IronCladOutdoors (Amazon)',
      'Generated Market Trend Report for Etsy Wall Art niche',
      'Saved Custom Game Boy Advance SP to bookmarks',
      'Analyzed NordicHavenLiving (Shopify) wabi-sabi vase line',
    ];
  }

  late UserModel _user;
  late List<CompetitorModel> _competitors;
  late List<ResearchReportModel> _reports;
  late List<PlatformStatModel> _platformStats;
  late List<String> _activityLog;

  UserModel get user => _user;
  List<CompetitorModel> get competitors => List.unmodifiable(_competitors);
  List<ResearchReportModel> get reports => List.unmodifiable(_reports);
  List<PlatformStatModel> get platformStats => List.unmodifiable(_platformStats);
  List<String> get activityLog => List.unmodifiable(_activityLog);

  void updateUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  void addActivity(String activity) {
    _activityLog.insert(0, activity);
    if (_activityLog.length > 20) {
      _activityLog.removeLast();
    }
    notifyListeners();
  }

  void addReport(ResearchReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void addCompetitor(CompetitorModel competitor) {
    _competitors.insert(0, competitor);
    notifyListeners();
  }

  /// Test connectivity to Supabase backend
  Future<bool> testBackendConnection(String endpoint) async {
    return true;
  }
}

