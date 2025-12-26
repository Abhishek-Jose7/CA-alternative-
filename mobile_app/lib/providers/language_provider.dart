import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale _chatLocale = const Locale('hi'); 
  String _userId = "user_${DateTime.now().millisecondsSinceEpoch}";
  bool _hasAskedLanguage = false;

  Locale get locale => _locale;
  Locale get chatLocale => _chatLocale;
  String get userId => _userId;
  bool get hasAskedLanguage => _hasAskedLanguage;

  void markAsked() {
    _hasAskedLanguage = true;
    notifyListeners();
  }

  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
  }

  void setChatLanguage(String code) {
    _chatLocale = Locale(code);
    notifyListeners();
  }

  // Simple Translation Dictionary
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Kirana Guard',
      'hello': 'Namaste,',
      'ready_help': 'Your Pocket CA is ready to help',
      'health_score': 'GST Health Score',
      'health_good': 'Excellent! No critical notices.',
      'quick_actions': 'Quick Actions',
      'scan_invoice': 'Scan Invoice',
      'check_notice': 'Check Notice',
      'supplier_check': 'Supplier Check',
      'expense_manager': 'Kaccha-Pakka',
      'ask_ai': 'Ask AI',
      'deadlines': 'Tithi Calendar',
      'recent_activity': 'Recent Activity',
      'view_all': 'View All',
      'language': 'English',
      'change_lang_title': 'Select Bhasha',
      'supplier_check_title': 'Supplier Deshbhakti Check',
      'enter_gstin': 'Enter Supplier GSTIN',
      'check_niyat': 'Check Niyat',
      'safe': 'Safe',
      'risky': 'Risky',
      'safe_msg': 'He files returns on time. Safe for ITC.',
      'risky_msg': 'He hasn\'t filed for 2 months. Don\'t pay tax!',
      'expense_title': 'Add Expense',
      'pakka': 'Pakka (Bill)',
      'kaccha': 'Kaccha (Cash)',
      'save_entry': 'Save Entry',
      'amount': 'Amount',
      'desc': 'Description',
      'chat_settings': 'Chat Language',
      'save_changes': 'Save Changes',
      'edit_profile': 'Edit Profile',
      'business_details': 'Business Details',
      'add_deadline': 'Add Deadline',
    },
    'hi': {
      'app_title': 'किराना गार्ड',
      'hello': 'नमस्ते,',
      'ready_help': 'आपका पर्सनल CA मदद के लिए तैयार है',
      'health_score': 'GST हेल्थ स्कोर',
      'health_good': 'बहुत बढ़िया! कोई नोटिस नहीं है।',
      'quick_actions': 'त्वरित कार्य',
      'scan_invoice': 'बिल स्कैन करें',
      'check_notice': 'नोटिस चेक करें',
      'supplier_check': 'सप्लायर नियत',
      'expense_manager': 'कच्चा-पक्का',
      'ask_ai': 'AI से पूछें',
      'deadlines': 'तिथि कैलेंडर',
      'recent_activity': 'हाल की गतिविधि',
      'view_all': 'सभी देखें',
      'language': 'हिंदी',
      'change_lang_title': 'भाषा चुनें',
      'supplier_check_title': 'सप्लायर देशभक्ति चेक',
      'enter_gstin': 'सप्लायर GSTIN डालें',
      'check_niyat': 'नियत चेक करें',
      'safe': 'सुरक्षित',
      'risky': 'खतरनाक',
      'safe_msg': 'यह समय पर रिटर्न भरता है। ITC के लिए सुरक्षित।',
      'risky_msg': 'इसने 2 महीने से रिटर्न नहीं भरा। टैक्स मत देना!',
      'expense_title': 'खर्चा जोड़ें',
      'pakka': 'पक्का (बिल)',
      'kaccha': 'कच्चा (कैश)',
      'save_entry': 'सेव करें',
      'amount': 'रकम',
      'desc': 'विवरण',
      'chat_settings': 'चैट भाषा',
      'save_changes': 'बदलाव सेव करें',
      'edit_profile': 'प्रोफाइल बदलें',
      'business_details': 'बिज़नेस विवरण',
      'add_deadline': 'डेडलाइन जोड़ें',
    },
    'mr': {
      'app_title': 'किराणा गार्ड',
      'hello': 'नमस्कार,',
      'ready_help': 'तुमचा पॉकेट CA मदतीसाठी तयार आहे',
      'health_score': 'GST हेल्थ स्कोर',
      'health_good': 'उत्तम! कोणतीही नोटीस नाही.',
      'quick_actions': 'जलद क्रिया',
      'scan_invoice': 'बिल स्कॅन करा',
      'check_notice': 'नोटीस तपासा',
      'supplier_check': 'सप्लायर तपासणी',
      'expense_manager': 'कच्चा-पक्का',
      'ask_ai': 'AI ला विचारा',
      'deadlines': 'तिथी कॅलेंडर',
      'recent_activity': 'अलीकडील क्रियाकलाप',
      'view_all': 'सर्व पहा',
      'language': 'मराठी',
      'change_lang_title': 'भाषा निवडा',
      'supplier_check_title': 'सप्लायर देशभक्ती तपासणी',
      'enter_gstin': 'सप्लायर GSTIN टाका',
      'check_niyat': 'नियत तपासा',
      'safe': 'सुरक्षित',
      'risky': 'धोकादायक',
      'safe_msg': 'हा वेळेवर रिटर्न भरतो. सुरक्षित आहे.',
      'risky_msg': 'याने 2 महिने रिटर्न भरले नाही. टॅक्स देऊ नका!',
      'expense_title': 'खर्च जोडा',
      'pakka': 'पक्का (बिल)',
      'kaccha': 'कच्चा (कॅश)',
      'save_entry': 'सेव्ह करा',
      'amount': 'रक्कम',
      'desc': 'वर्णन',
      'chat_settings': 'चैट भाषा',
      'save_changes': 'बदल जतन करा',
      'edit_profile': 'प्रोफाइल संपादित करा',
      'business_details': 'व्यवसाय तपशील',
      'add_deadline': 'डेडलाइन जोडा',
    }
  };

  String t(String key) {
    return _localizedValues[_locale.languageCode]?[key] ?? _localizedValues['en']![key]!;
  }
}
