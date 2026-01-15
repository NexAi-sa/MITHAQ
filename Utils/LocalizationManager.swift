import Foundation
import SwiftUI

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .arabic
    @Published var isRTL: Bool = true
    
    private init() {
        setLanguage(.arabic)
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        isRTL = language == .arabic
        
        // Update app locale
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force UI refresh
        objectWillChange.send()
    }
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// MARK: - Language Enum
enum Language: String, CaseIterable {
    case arabic = "ar"
    case english = "en"
    
    var code: String {
        return rawValue
    }
    
    var displayName: String {
        switch self {
        case .arabic:
            return "العربية"
        case .english:
            return "English"
        }
    }
    
    var nativeName: String {
        switch self {
        case .arabic:
            return "العربية"
        case .english:
            return "English"
        }
    }
}

// MARK: - Localized String Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = self.localized
        return String(format: localizedString, arguments: arguments)
    }
}

// MARK: - View Extension for RTL Support
extension View {
    func rtlSupport() -> some View {
        self.environment(\.layoutDirection, LocalizationManager.shared.isRTL ? .rightToLeft : .leftToRight)
    }
    
    func localizedText(_ key: String) -> some View {
        Text(key.localized)
            .rtlSupport()
    }
}

// MARK: - Localization Keys
struct LocalizationKeys {
    // General
    static let ok = "ok"
    static let cancel = "cancel"
    static let save = "save"
    static let delete = "delete"
    static let edit = "edit"
    static let done = "done"
    static let next = "next"
    static let previous = "previous"
    static let loading = "loading"
    static let error = "error"
    static let success = "success"
    static let warning = "warning"
    
    // Authentication
    static let login = "login"
    static let signup = "signup"
    static let logout = "logout"
    static let email = "email"
    static let password = "password"
    static let confirmPassword = "confirm_password"
    static let fullName = "full_name"
    static let phoneNumber = "phone_number"
    static let dateOfBirth = "date_of_birth"
    static let gender = "gender"
    static let male = "male"
    static let female = "female"
    static let forgotPassword = "forgot_password"
    static let agreeToTerms = "agree_to_terms"
    static let termsAndConditions = "terms_and_conditions"
    static let privacyPolicy = "privacy_policy"
    
    // App Sections
    static let home = "home"
    static let search = "search"
    static let matches = "matches"
    static let messages = "messages"
    static let profile = "profile"
    static let settings = "settings"
    
    // Matching
    static let like = "like"
    static let pass = "pass"
    static let superLike = "super_like"
    static let compatibility = "compatibility"
    static let personality = "personality"
    static let interests = "interests"
    static let education = "education"
    static let occupation = "occupation"
    static let location = "location"
    
    // Payment
    static let subscription = "subscription"
    static let premium = "premium"
    static let upgrade = "upgrade"
    static let payment = "payment"
    static let applePay = "apple_pay"
    static let creditCard = "credit_card"
    
    // Guardian
    static let guardian = "guardian"
    static let approval = "approval"
    static let permission = "permission"
    static let father = "father"
    static let mother = "mother"
    static let brother = "brother"
    
    // Messages
    static let sendMessage = "send_message"
    static let typing = "typing"
    static let online = "online"
    static let offline = "offline"
    static let lastSeen = "last_seen"
    
    // Profile
    static let aboutMe = "about_me"
    static let photos = "photos"
    static let preferences = "preferences"
    static let notifications = "notifications"
    static let privacy = "privacy"
    static let security = "security"
    
    // Errors
    static let networkError = "network_error"
    static let invalidEmail = "invalid_email"
    static let invalidPassword = "invalid_password"
    static let passwordsNotMatch = "passwords_not_match"
    static let emailAlreadyExists = "email_already_exists"
    static let userNotFound = "user_not_found"
    static let invalidCredentials = "invalid_credentials"
    static let accountDisabled = "account_disabled"
    static let weakPassword = "weak_password"
    static let ageRequirement = "age_requirement"
    static let termsRequired = "terms_required"
    static let phoneInvalid = "phone_invalid"
    static let nameRequired = "name_required"
}

// MARK: - Arabic Localized Strings
extension LocalizationKeys {
    static let arabicStrings: [String: String] = [
        // General
        "ok": "موافق",
        "cancel": "إلغاء",
        "save": "حفظ",
        "delete": "حذف",
        "edit": "تعديل",
        "done": "تم",
        "next": "التالي",
        "previous": "السابق",
        "loading": "جاري التحميل",
        "error": "خطأ",
        "success": "نجح",
        "warning": "تحذير",
        
        // Authentication
        "login": "تسجيل الدخول",
        "signup": "إنشاء حساب",
        "logout": "تسجيل الخروج",
        "email": "البريد الإلكتروني",
        "password": "كلمة المرور",
        "confirm_password": "تأكيد كلمة المرور",
        "full_name": "الاسم الكامل",
        "phone_number": "رقم الهاتف",
        "date_of_birth": "تاريخ الميلاد",
        "gender": "الجنس",
        "male": "ذكر",
        "female": "أنثى",
        "forgot_password": "نسيت كلمة المرور",
        "agree_to_terms": "أوافق على الشروط والأحكام",
        "terms_and_conditions": "الشروط والأحكام",
        "privacy_policy": "سياسة الخصوصية",
        
        // App Sections
        "home": "الرئيسية",
        "search": "البحث",
        "matches": "المطابقات",
        "messages": "الرسائل",
        "profile": "الملف الشخصي",
        "settings": "الإعدادات",
        
        // Matching
        "like": "إعجاب",
        "pass": "تجاهل",
        "super_like": "إعجاب خارق",
        "compatibility": "التوافق",
        "personality": "الشخصية",
        "interests": "الاهتمامات",
        "education": "التعليم",
        "occupation": "المهنة",
        "location": "الموقع",
        
        // Payment
        "subscription": "الاشتراك",
        "premium": "مميز",
        "upgrade": "ترقية",
        "payment": "الدفع",
        "apple_pay": "Apple Pay",
        "credit_card": "البطاقة الائتمانية",
        
        // Guardian
        "guardian": "الوصي",
        "approval": "الموافقة",
        "permission": "الإذن",
        "father": "الأب",
        "mother": "الأم",
        "brother": "الأخ",
        
        // Messages
        "send_message": "إرسال رسالة",
        "typing": "يكتب",
        "online": "متصل",
        "offline": "غير متصل",
        "last_seen": "آخر ظهور",
        
        // Profile
        "about_me": "عني",
        "photos": "الصور",
        "preferences": "التفضيلات",
        "notifications": "الإشعارات",
        "privacy": "الخصوصية",
        "security": "الأمان",
        
        // Errors
        "network_error": "خطأ في الشبكة",
        "invalid_email": "البريد الإلكتروني غير صالح",
        "invalid_password": "كلمة المرور غير صالحة",
        "passwords_not_match": "كلمات المرور غير متطابقة",
        "email_already_exists": "البريد الإلكتروني مسجل بالفعل",
        "user_not_found": "المستخدم غير موجود",
        "invalid_credentials": "البيانات غير صحيحة",
        "account_disabled": "الحساب معطل",
        "weak_password": "كلمة المرور ضعيفة جداً",
        "age_requirement": "يجب أن تكون 18 عاماً على الأقل",
        "terms_required": "يجب الموافقة على الشروط والأحكام",
        "phone_invalid": "رقم الهاتف غير صالح",
        "name_required": "الاسم مطلوب"
    ]
}
