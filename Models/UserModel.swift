import Foundation

// MARK: - User Models
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let dateOfBirth: Date
    let gender: Gender
    let isVerified: Bool
    let profileCompleted: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Profile information
    var profile: UserProfile?
    var preferences: UserPreferences?
    var guardian: Guardian?
    
    enum Gender: String, Codable, CaseIterable {
        case male = "ذكر"
        case female = "أنثى"
    }
}

struct UserProfile: Codable {
    let userId: String
    var bio: String?
    var education: Education?
    var occupation: String?
    var location: Location?
    var height: Double?
    var weight: Double?
    var maritalStatus: MaritalStatus?
    var hasChildren: Bool?
    var wantsChildren: Bool?
    var religiousPractice: ReligiousPractice?
    var lifestyle: Lifestyle?
    var photos: [String]?
    var interests: [String]?
    
    enum MaritalStatus: String, Codable, CaseIterable {
        case neverMarried = "لم يتزوج من قبل"
        case divorced = "مطلق"
        case widowed = "أرمل"
    }
    
    enum ReligiousPractice: String, Codable, CaseIterable {
        case practicing = "ممارس"
        case moderatelyPracticing = "ممارس بشكل معتدل"
        case notPracticing = "غير ممارس"
    }
}

struct Education: Codable {
    let level: EducationLevel
    let field: String?
    let institution: String?
    
    enum EducationLevel: String, Codable, CaseIterable {
        case highSchool = "ثانوي"
        case bachelor = "بكالوريوس"
        case master = "ماجستير"
        case phd = "دكتوراه"
        case other = "أخرى"
    }
}

struct Location: Codable {
    let country: String
    let city: String
    let willingToRelocate: Bool
}

struct Lifestyle: Codable {
    let diet: Diet
    let smoking: SmokingStatus
    let drinking: DrinkingStatus
    
    enum Diet: String, Codable, CaseIterable {
        case halal = "حلال"
        case vegetarian = "نباتي"
        case vegan = "نباتي صارم"
        case noRestriction = "بدون قيود"
    }
    
    enum SmokingStatus: String, Codable, CaseIterable {
        case never = "أبداً"
        case occasionally = "أحياناً"
        case regularly = "بشكل منتظم"
        case tryingToQuit = "أحاول الإقلاع"
    }
    
    enum DrinkingStatus: String, Codable, CaseIterable {
        case never = "أبداً"
        case socially = "اجتماعياً"
        case rarely = "نادراً"
    }
}

struct UserPreferences: Codable {
    let userId: String
    var ageRange: ClosedRange<Int>
    var maxDistance: Int?
    var maritalStatusPreferences: [UserProfile.MaritalStatus]
    var religiousPracticePreferences: [UserProfile.ReligiousPractice]
    var educationPreferences: [Education.EducationLevel]
    var locationPreferences: [LocationPreference]
    var lifestylePreferences: LifestylePreferences
}

struct LocationPreference: Codable {
    let country: String
    let cities: [String]
}

struct LifestylePreferences: Codable {
    let smokingAcceptable: [UserProfile.Lifestyle.SmokingStatus]
    let drinkingAcceptable: [UserProfile.Lifestyle.DrinkingStatus]
    let dietAcceptable: [UserProfile.Lifestyle.Diet]
}

// MARK: - Guardian Model
struct Guardian: Codable {
    let id: String
    let userId: String
    let name: String
    let relationship: GuardianRelationship
    let email: String
    let phone: String
    let isVerified: Bool
    let permissions: GuardianPermissions
    
    enum GuardianRelationship: String, Codable, CaseIterable {
        case father = "الأب"
        case mother = "الأم"
        case brother = "الأخ"
        case uncle = "العم"
        case other = "أخرى"
    }
}

struct GuardianPermissions: Codable {
    let canApproveMatches: Bool
    let canViewConversations: Bool
    let canManageProfile: Bool
    let requireApprovalForContact: Bool
}

// MARK: - Authentication Models
struct AuthRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let user: User
    let token: String
    let refreshToken: String
    let expiresIn: Int
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let phone: String
    let password: String
    let dateOfBirth: Date
    let gender: User.Gender
}

struct VerificationRequest: Codable {
    let userId: String
    let documentType: DocumentType
    let documentData: Data
    let additionalInfo: [String: String]?
    
    enum DocumentType: String, Codable, CaseIterable {
        case nationalId = "بطاقة الهوية الوطنية"
        case passport = "جواز السفر"
        case driversLicense = "رخصة القيادة"
    }
}

struct VerificationResponse: Codable {
    let isVerified: Bool
    let verificationId: String
    let status: VerificationStatus
    let message: String?
    
    enum VerificationStatus: String, Codable, CaseIterable {
        case pending = "قيد الانتظار"
        case approved = "موافق عليه"
        case rejected = "مرفوض"
        case requiresMoreInfo = "يتطلب معلومات إضافية"
    }
}
