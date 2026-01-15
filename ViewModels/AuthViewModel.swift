import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showVerification = false
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var phone = ""
    @Published var dateOfBirth = Date()
    @Published var gender: User.Gender = .male
    @Published var agreeToTerms = false
    
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check for existing session
        checkExistingSession()
    }
    
    // MARK: - Authentication Methods
    func login() {
        guard validateLoginForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = AuthRequest(email: email, password: password)
        
        authService.login(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.handleAuthSuccess(response)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func register() {
        guard validateRegistrationForm() else { return }
        
        isLoading = true
        errorMessage = nil
        
        let request = RegisterRequest(
            name: name,
            email: email,
            phone: phone,
            password: password,
            dateOfBirth: dateOfBirth,
            gender: gender
        )
        
        authService.register(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.handleAuthSuccess(response)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        authService.logout()
        isAuthenticated = false
        currentUser = nil
        clearFormFields()
    }
    
    private func checkExistingSession() {
        if let token = KeychainManager.shared.getToken(),
           let userData = KeychainManager.shared.getUserData() {
            
            // Validate token with backend
            authService.validateToken(token: token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self?.isAuthenticated = true
                        self?.currentUser = user
                    case .failure:
                        // Token invalid, clear stored data
                        KeychainManager.shared.clearAll()
                    }
                }
            }
        }
    }
    
    private func handleAuthSuccess(_ response: AuthResponse) {
        // Store token securely
        KeychainManager.shared.saveToken(response.token)
        KeychainManager.shared.saveUserData(response.user)
        
        isAuthenticated = true
        currentUser = response.user
        clearFormFields()
        
        // Show verification if not verified
        if !response.user.isVerified {
            showVerification = true
        }
    }
    
    // MARK: - Validation
    private func validateLoginForm() -> Bool {
        if email.isEmpty {
            errorMessage = "الرجاء إدخال البريد الإلكتروني"
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "البريد الإلكتروني غير صالح"
            return false
        }
        
        if password.isEmpty {
            errorMessage = "الرجاء إدخال كلمة المرور"
            return false
        }
        
        if password.count < 8 {
            errorMessage = "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
            return false
        }
        
        return true
    }
    
    private func validateRegistrationForm() -> Bool {
        if !validateLoginForm() { return false }
        
        if name.isEmpty {
            errorMessage = "الرجاء إدخال الاسم الكامل"
            return false
        }
        
        if phone.isEmpty {
            errorMessage = "الرجاء إدخال رقم الهاتف"
            return false
        }
        
        if !isValidPhone(phone) {
            errorMessage = "رقم الهاتف غير صالح"
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "كلمات المرور غير متطابقة"
            return false
        }
        
        if !agreeToTerms {
            errorMessage = "يجب الموافقة على الشروط والأحكام"
            return false
        }
        
        // Check age requirement (minimum 18 years)
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        if age < 18 {
            errorMessage = "يجب أن تكون 18 عاماً على الأقل"
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^\\+?[0-9]{10,15}$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
    
    private func clearFormFields() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        phone = ""
        dateOfBirth = Date()
        gender = .male
        agreeToTerms = false
        errorMessage = nil
    }
}

// MARK: - Authentication Service
class AuthService {
    static let shared = AuthService()
    
    private let aiAgentSystem = AIAgentSystem.shared
    
    private init() {}
    
    func login(request: AuthRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        // Use AI agent for authentication
        aiAgentSystem.executeAgent(agentType: .authentication, input: request) { result in
            switch result {
            case .success(let response):
                if let authResponse = response as? AuthResponse {
                    completion(.success(authResponse))
                } else {
                    completion(.failure(AuthError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func register(request: RegisterRequest, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        // Use AI agent for registration
        aiAgentSystem.executeAgent(agentType: .authentication, input: request) { result in
            switch result {
            case .success(let response):
                if let authResponse = response as? AuthResponse {
                    completion(.success(authResponse))
                } else {
                    completion(.failure(AuthError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validateToken(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Validate token with backend
        // For now, simulate validation
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockUser = User(
                id: "user123",
                name: "مستخدم تجريبي",
                email: "test@example.com",
                phone: "+966500000000",
                dateOfBirth: Date(),
                gender: .male,
                isVerified: true,
                profileCompleted: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            completion(.success(mockUser))
        }
    }
    
    func logout() {
        KeychainManager.shared.clearAll()
        // Notify backend to invalidate token
    }
}

// MARK: - Authentication Errors
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case accountNotFound
    case accountDisabled
    case emailAlreadyExists
    case weakPassword
    case invalidResponse
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "البريد الإلكتروني أو كلمة المرور غير صحيحة"
        case .accountNotFound:
            return "الحساب غير موجود"
        case .accountDisabled:
            return "الحساب معطل"
        case .emailAlreadyExists:
            return "البريد الإلكتروني مسجل بالفعل"
        case .weakPassword:
            return "كلمة المرور ضعيفة جداً"
        case .invalidResponse:
            return "استجابة غير صالحة من الخادم"
        case .networkError:
            return "خطأ في الاتصال بالشبكة"
        }
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    static let shared = KeychainManager()
    
    private let serviceName = "com.mithaq.app"
    private let tokenKey = "auth_token"
    private let userDataKey = "user_data"
    
    private init() {}
    
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        KeychainHelper.save(key: tokenKey, data: data, service: serviceName)
    }
    
    func getToken() -> String? {
        guard let data = KeychainHelper.load(key: tokenKey, service: serviceName) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func saveUserData(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            KeychainHelper.save(key: userDataKey, data: data, service: serviceName)
        } catch {
            print("Failed to save user data: \(error)")
        }
    }
    
    func getUserData() -> User? {
        guard let data = KeychainHelper.load(key: userDataKey, service: serviceName) else { return nil }
        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            print("Failed to decode user data: \(error)")
            return nil
        }
    }
    
    func clearAll() {
        KeychainHelper.delete(key: tokenKey, service: serviceName)
        KeychainHelper.delete(key: userDataKey, service: serviceName)
    }
}

// MARK: - Keychain Helper
class KeychainHelper {
    static func save(key: String, data: Data, service: String) {
        let query = [
            kSecValueData: data,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
        SecItemAdd(query, nil)
    }
    
    static func load(key: String, service: String) -> Data? {
        let query = [
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        
        return nil
    }
    
    static func delete(key: String, service: String) {
        let query = [
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
