import Foundation

// MARK: - Matching Models
struct Match: Codable, Identifiable {
    let id: String
    let user1Id: String
    let user2Id: String
    let compatibilityScore: CompatibilityScore
    let status: MatchStatus
    let createdAt: Date
    let updatedAt: Date
    let initiatedBy: String
    let guardianApprovalRequired: Bool
    let guardianApprovals: [GuardianApproval]?
    
    enum MatchStatus: String, Codable, CaseIterable {
        case pending = "قيد الانتظار"
        case accepted = "مقبول"
        case rejected = "مرفوض"
        case expired = "منتهي الصلاحية"
    }
}

struct CompatibilityScore: Codable {
    let overall: Double // 0-100
    let personality: Double
    let values: Double
    let lifestyle: Double
    let religious: Double
    let family: Double
    let goals: Double
    let riskIndex: Double // 0-100, lower is better
    let growthFit: Double // 0-100
    let insights: [CompatibilityInsight]
    let recommendations: [String]
}

struct CompatibilityInsight: Codable {
    let category: InsightCategory
    let score: Double
    let description: String
    let importance: Importance
    
    enum InsightCategory: String, Codable, CaseIterable {
        case personality = "الشخصية"
        case values = "القيم"
        case communication = "التواصل"
        case conflictResolution = "حل النزاعات"
        case familyGoals = "الأهداف العائلية"
        case lifestyle = "نمط الحياة"
        case religious = "الديني"
        case financial = "المالي"
    }
    
    enum Importance: String, Codable, CaseIterable {
        case critical = "حرج"
        case important = "مهم"
        case moderate = "معتدل"
        case low = "منخفض"
    }
}

struct GuardianApproval: Codable {
    let guardianId: String
    let userId: String
    let matchId: String
    let status: ApprovalStatus
    let comment: String?
    let timestamp: Date
    
    enum ApprovalStatus: String, Codable, CaseIterable {
        case pending = "قيد الانتظار"
        case approved = "موافق عليه"
        case rejected = "مرفوض"
        case needsMoreInfo = "يحتاج معلومات إضافية"
    }
}

// MARK: - Conversation Models
struct Conversation: Codable, Identifiable {
    let id: String
    let participants: [String]
    let matchId: String
    let lastMessage: Message?
    let unreadCount: Int
    let isActive: Bool
    let guardianMonitored: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let type: MessageType
    let timestamp: Date
    let isRead: Bool
    let isEdited: Bool
    let editedAt: Date?
    let attachments: [MessageAttachment]?
    let moderatedContent: ModeratedContent?
    
    enum MessageType: String, Codable, CaseIterable {
        case text = "نص"
        case image = "صورة"
        case voice = "صوت"
        case document = "مستند"
        case system = "نظام"
    }
}

struct MessageAttachment: Codable {
    let id: String
    let type: Message.MessageType
    let url: String
    let fileName: String
    let fileSize: Int64
    let thumbnailUrl: String?
}

struct ModeratedContent: Codable {
    let originalContent: String
    let filteredContent: String
    let violations: [ContentViolation]
    let autoFiltered: Bool
    let requiresReview: Bool
    
    struct ContentViolation: Codable {
        let type: ViolationType
        let severity: Severity
        let position: Range<String.Index>
        
        enum ViolationType: String, Codable, CaseIterable {
            case inappropriateLanguage = "لغة غير لائقة"
            case harassment = "تحرش"
            case spam = "رسائل مزعجة"
            case personalInfo = "معلومات شخصية"
            case inappropriateContent = "محتوى غير لائق"
        }
        
        enum Severity: String, Codable, CaseIterable {
            case low = "منخفض"
            case medium = "متوسط"
            case high = "مرتفع"
            case critical = "حرج"
        }
    }
}

// MARK: - Personality Analysis Models
struct PersonalityAnalysis: Codable {
    let userId: String
    let analysisId: String
    let responses: [PersonalityResponse]
    let traits: PersonalityTraits
    let compatibilityFactors: CompatibilityFactors
    let completedAt: Date
    let confidence: Double
}

struct PersonalityResponse: Codable {
    let questionId: String
    let question: String
    let answer: String
    let responseTime: TimeInterval
    let confidence: Double
}

struct PersonalityTraits: Codable {
    let openness: Double
    let conscientiousness: Double
    let extraversion: Double
    let agreeableness: Double
    let neuroticism: Double
    let additionalTraits: [String: Double]
}

struct CompatibilityFactors: Codable {
    let communicationStyle: CommunicationStyle
    let conflictResolution: ConflictResolutionStyle
    let loveLanguage: LoveLanguage
    let attachmentStyle: AttachmentStyle
    let valuesAlignment: ValuesAlignment
    
    enum CommunicationStyle: String, Codable, CaseIterable {
        case direct = "مباشر"
        case indirect = "غير مباشر"
        case assertive = "جازم"
        case passive = "سلبي"
    }
    
    enum ConflictResolutionStyle: String, Codable, CaseIterable {
        case collaborative = "تعاوني"
        case competitive = "تنافسي"
        case accommodating = "مساوم"
        case avoiding = "تجنبي"
        case compromising = "مساومة"
    }
    
    enum LoveLanguage: String, Codable, CaseIterable {
        case wordsOfAffirmation = "كلمات التأكيد"
        case qualityTime = "وقت الجودة"
        case receivingGifts = "تلقي الهدايا"
        case actsOfService = "أفعال الخدمة"
        case physicalTouch = "اللمس الجسدي"
    }
    
    enum AttachmentStyle: String, Codable, CaseIterable {
        case secure = "آمن"
        case anxious = "قلق"
        case avoidant = "تجنبي"
        case disorganized = "غير منظم"
    }
}

struct ValuesAlignment: Codable {
    let family: Double
    let career: Double
    let religion: Double
    let education: Double
    let lifestyle: Double
    let finances: Double
    let personalGrowth: Double
}
