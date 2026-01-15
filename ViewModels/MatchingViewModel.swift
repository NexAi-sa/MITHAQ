import Foundation
import Combine

class MatchingViewModel: ObservableObject {
    @Published var potentialMatches: [User] = []
    @Published var currentMatch: User?
    @Published var compatibilityScores: [String: CompatibilityScore] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Matching preferences
    @Published var preferences: UserPreferences?
    @Published var ageRange: ClosedRange<Int> = 18...50
    @Published var maxDistance: Int = 100
    @Published var selectedMaritalStatuses: Set<UserProfile.MaritalStatus> = []
    @Published var selectedReligiousPractices: Set<UserProfile.ReligiousPractice> = []
    
    private let matchingService = MatchingService.shared
    private let aiAgentSystem = AIAgentSystem.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMatchingPreferences()
    }
    
    // MARK: - Matching Methods
    func loadPotentialMatches() {
        isLoading = true
        errorMessage = nil
        
        matchingService.getPotentialMatches(preferences: preferences) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let matches):
                    self?.potentialMatches = matches
                    self?.analyzeCompatibility(for: matches)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func swipeRight(on user: User) {
        // Like user
        processMatchAction(user: user, action: .like)
    }
    
    func swipeLeft(on user: User) {
        // Pass user
        processMatchAction(user: user, action: .pass)
    }
    
    func superLike(on user: User) {
        // Super like user
        processMatchAction(user: user, action: .superLike)
    }
    
    private func processMatchAction(user: User, action: MatchAction) {
        matchingService.processMatchAction(userId: user.id, action: action) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let match):
                    if match.status == .accepted {
                        // Show match success
                        self?.showMatchSuccess(with: user)
                    }
                    // Remove from potential matches
                    self?.potentialMatches.removeAll { $0.id == user.id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func showMatchSuccess(with user: User) {
        // Navigate to match success screen
        // This would typically trigger navigation or show a modal
    }
    
    // MARK: - Compatibility Analysis
    private func analyzeCompatibility(for users: [User]) {
        guard let currentUser = getCurrentUser() else { return }
        
        for user in users {
            aiAgentSystem.assessCompatibility(user1: currentUser, user2: user) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let score):
                        self?.compatibilityScores[user.id] = score
                    case .failure(let error):
                        print("Compatibility analysis failed for user \(user.id): \(error)")
                    }
                }
            }
        }
    }
    
    func getCompatibilityScore(for userId: String) -> CompatibilityScore? {
        return compatibilityScores[userId]
    }
    
    func getCompatibilityColor(for score: Double) -> Color {
        switch score {
        case 80...100:
            return ColorPalette.compatibilityExcellent
        case 60..<80:
            return ColorPalette.compatibilityGood
        case 40..<60:
            return ColorPalette.compatibilityAverage
        default:
            return ColorPalette.compatibilityPoor
        }
    }
    
    // MARK: - Preferences Management
    func loadMatchingPreferences() {
        matchingService.getMatchingPreferences { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let preferences):
                    self?.preferences = preferences
                    self?.updateLocalPreferences()
                case .failure(let error):
                    print("Failed to load preferences: \(error)")
                }
            }
        }
    }
    
    func saveMatchingPreferences() {
        guard var updatedPreferences = preferences else { return }
        
        updatedPreferences.ageRange = ageRange
        updatedPreferences.maxDistance = maxDistance
        updatedPreferences.maritalStatusPreferences = Array(selectedMaritalStatuses)
        updatedPreferences.religiousPracticePreferences = Array(selectedReligiousPractices)
        
        matchingService.saveMatchingPreferences(preferences: updatedPreferences) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.preferences = updatedPreferences
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateLocalPreferences() {
        guard let preferences = preferences else { return }
        
        ageRange = preferences.ageRange
        maxDistance = preferences.maxDistance ?? 100
        selectedMaritalStatuses = Set(preferences.maritalStatusPreferences)
        selectedReligiousPractices = Set(preferences.religiousPracticePreferences)
    }
    
    private func getCurrentUser() -> User? {
        // Get current user from auth service or app state
        return nil // Implement based on your app architecture
    }
}

// MARK: - Matching Service
class MatchingService {
    static let shared = MatchingService()
    
    private init() {}
    
    func getPotentialMatches(preferences: UserPreferences?, completion: @escaping (Result<[User], Error>) -> Void) {
        // Fetch potential matches from backend based on preferences
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Mock data for demonstration
            let mockMatches = [
                createMockUser(id: "1", name: "فاطمة أحمد", age: 28),
                createMockUser(id: "2", name: "مريم محمد", age: 32),
                createMockUser(id: "3", name: "عائشة عبدالله", age: 26)
            ]
            completion(.success(mockMatches))
        }
    }
    
    func processMatchAction(userId: String, action: MatchAction, completion: @escaping (Result<Match, Error>) -> Void) {
        // Process match action (like, pass, super like) with backend
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Mock match response
            let match = Match(
                id: UUID().uuidString,
                user1Id: "current_user_id",
                user2Id: userId,
                compatibilityScore: CompatibilityScore(
                    overall: 85.0,
                    personality: 80.0,
                    values: 90.0,
                    lifestyle: 75.0,
                    religious: 88.0,
                    family: 85.0,
                    goals: 82.0,
                    riskIndex: 15.0,
                    growthFit: 85.0,
                    insights: [],
                    recommendations: []
                ),
                status: action == .like ? .accepted : .pending,
                createdAt: Date(),
                updatedAt: Date(),
                initiatedBy: "current_user_id",
                guardianApprovalRequired: false,
                guardianApprovals: nil
            )
            completion(.success(match))
        }
    }
    
    func getMatchingPreferences(completion: @escaping (Result<UserPreferences, Error>) -> Void) {
        // Fetch user's matching preferences from backend
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockPreferences = UserPreferences(
                userId: "current_user_id",
                ageRange: 25...35,
                maxDistance: 100,
                maritalStatusPreferences: [.neverMarried],
                religiousPracticePreferences: [.practicing, .moderatelyPracticing],
                educationPreferences: [.bachelor, .master],
                locationPreferences: [],
                lifestylePreferences: LifestylePreferences(
                    smokingAcceptable: [.never, .occasionally],
                    drinkingAcceptable: [.never],
                    dietAcceptable: [.halal]
                )
            )
            completion(.success(mockPreferences))
        }
    }
    
    func saveMatchingPreferences(preferences: UserPreferences, completion: @escaping (Result<Void, Error>) -> Void) {
        // Save preferences to backend
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }
    
    private func createMockUser(id: String, name: String, age: Int) -> User {
        let calendar = Calendar.current
        let dateOfBirth = calendar.date(byAdding: .year, value: -age, to: Date()) ?? Date()
        
        return User(
            id: id,
            name: name,
            email: "\(name.lowercased().replacingOccurrences(of: " ", with: ""))@example.com",
            phone: "+96650000000\(id)",
            dateOfBirth: dateOfBirth,
            gender: .female,
            isVerified: true,
            profileCompleted: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Match Action
enum MatchAction: String, CaseIterable {
    case pass = "pass"
    case like = "like"
    case superLike = "super_like"
    
    var displayName: String {
        switch self {
        case .pass:
            return "تجاهل"
        case .like:
            return "إعجاب"
        case .superLike:
            return "إعجاب خارق"
        }
    }
}
