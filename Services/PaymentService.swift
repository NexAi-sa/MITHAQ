import Foundation
import PassKit
import StoreKit

// MARK: - Payment Service
class PaymentService: NSObject, ObservableObject {
    static let shared = PaymentService()
    
    @Published var availableProducts: [SKProduct] = []
    @Published var purchasedProducts: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let productIdentifiers = Set([
        "com.mithaq.premium.monthly",
        "com.mithaq.premium.yearly",
        "com.mithaq.premium.lifetime",
        "com.mithaq.credits.100",
        "com.mithaq.credits.500",
        "com.mithaq.credits.1000"
    ])
    
    private var productsRequest: SKProductsRequest?
    private var completionHandlers: [String: (Result<Bool, PaymentError>) -> Void] = [:]
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        loadProducts()
        restorePurchases()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Product Management
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    func purchaseProduct(_ product: SKProduct, completion: @escaping (Result<Bool, PaymentError>) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(.paymentsNotAllowed))
            return
        }
        
        let payment = SKPayment(product: product)
        completionHandlers[product.productIdentifier] = completion
        
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        isLoading = true
        SKPaymentQueue.default().restoreTransactions(with: self)
    }
    
    // MARK: - Apple Pay Integration
    func canMakeApplePayPayments() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }
    
    func createApplePayRequest(amount: NSDecimalNumber, currencyCode: String = "SAR") -> PKPaymentRequest? {
        let request = PKPaymentRequest()
        
        request.merchantIdentifier = "merchant.com.mithaq.app"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.supportedCountries = ["SA"]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "SA"
        request.currencyCode = currencyCode
        
        let paymentAmount = PKPaymentSummaryItem(
            label: "مثاق - اشتراك مميز",
            amount: amount
        )
        
        request.paymentSummaryItems = [paymentAmount]
        
        return request
    }
    
    func processApplePayment(payment: PKPayment, completion: @escaping (Result<Bool, PaymentError>) -> Void) {
        // Process Apple Pay payment with backend
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // Simulate payment processing
            completion(.success(true))
        }
    }
    
    // MARK: - Subscription Management
    func checkSubscriptionStatus(completion: @escaping (Result<SubscriptionStatus, PaymentError>) -> Void) {
        // Check subscription status with backend
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let status = SubscriptionStatus(
                isActive: true,
                tier: .premium,
                expiresAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                autoRenews: true,
                features: SubscriptionFeatures.all
            )
            completion(.success(status))
        }
    }
    
    func cancelSubscription(completion: @escaping (Result<Bool, PaymentError>) -> Void) {
        // Redirect to App Store subscription management
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
            completion(.failure(.invalidURL))
            return
        }
        
        UIApplication.shared.open(url) { success in
            if success {
                completion(.success(true))
            } else {
                completion(.failure(.failedToOpenURL))
            }
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension PaymentService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.availableProducts = response.products
            self.isLoading = false
            
            if !response.invalidProductIdentifiers.isEmpty {
                print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension PaymentService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            case .purchasing:
                break
            case .deferred:
                handleDeferred(transaction)
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        deliverProduct(for: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            errorMessage = error.localizedDescription
        }
        
        if let completion = completionHandlers[transaction.payment.productIdentifier] {
            completion(.failure(.paymentFailed))
            completionHandlers.removeValue(forKey: transaction.payment.productIdentifier)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        deliverProduct(for: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleDeferred(_ transaction: SKPaymentTransaction) {
        // Handle deferred payment (e.g., family sharing approval)
        errorMessage = "المدفوعات مؤجلة، في انتظار الموافقة"
    }
    
    private func deliverProduct(for transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier ?? transaction.payment.productIdentifier as String? else {
            return
        }
        
        purchasedProducts.append(productIdentifier)
        
        if let completion = completionHandlers[productIdentifier] {
            completion(.success(true))
            completionHandlers.removeValue(forKey: productIdentifier)
        }
        
        // Notify backend of purchase
        verifyPurchaseWithBackend(transaction: transaction)
    }
    
    private func verifyPurchaseWithBackend(transaction: SKPaymentTransaction) {
        // Send receipt to backend for verification
        guard let receiptData = getReceiptData() else { return }
        
        // Send receiptData to your server for verification
        // This is crucial for security
    }
    
    private func getReceiptData() -> Data? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return nil
        }
        return receiptData
    }
}

// MARK: - Payment Models
struct SubscriptionStatus: Codable {
    let isActive: Bool
    let tier: SubscriptionTier
    let expiresAt: Date?
    let autoRenews: Bool
    let features: [SubscriptionFeature]
}

enum SubscriptionTier: String, Codable, CaseIterable {
    case basic = "أساسي"
    case premium = "مميز"
    case platinum = "بلاتيني"
    
    var displayName: String {
        return rawValue
    }
    
    var features: [SubscriptionFeature] {
        switch self {
        case .basic:
            return [.basicMatching, .limitedMessages]
        case .premium:
            return [.unlimitedMatching, .unlimitedMessages, .advancedFilters, .personalityAnalysis]
        case .platinum:
            return SubscriptionFeature.all
        }
    }
}

enum SubscriptionFeature: String, Codable, CaseIterable {
    case basicMatching = "مطابقة أساسية"
    case unlimitedMatching = "مطابقة غير محدودة"
    case limitedMessages = "رسائل محدودة"
    case unlimitedMessages = "رسائل غير محدودة"
    case advancedFilters = "مرشحات متقدمة"
    case personalityAnalysis = "تحليل الشخصية"
    case compatibilityReports = "تقارير التوافق"
    case prioritySupport = "دعم أولوي"
    case incognitoMode = "وضع التخفي"
    case guardianFeatures = "ميزات الوصي"
    case videoCalls = "مكالمات فيديو"
    case translationServices = "خدمات الترجمة"
    
    var description: String {
        return rawValue
    }
}

struct PaymentPlan: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let currency: String
    let duration: PlanDuration
    let features: [SubscriptionFeature]
    let isPopular: Bool
    let savings: String?
    
    enum PlanDuration: String, Codable, CaseIterable {
        case monthly = "شهري"
        case yearly = "سنوي"
        case lifetime = "مدى الحياة"
    }
}

// MARK: - Payment Errors
enum PaymentError: Error, LocalizedError {
    case paymentsNotAllowed
    case productNotFound
    case paymentFailed
    case purchaseCancelled
    case verificationFailed
    case networkError
    case invalidURL
    case failedToOpenURL
    
    var errorDescription: String? {
        switch self {
        case .paymentsNotAllowed:
            return "المدفوعات غير مسموح بها على هذا الجهاز"
        case .productNotFound:
            return "المنتج غير متاح"
        case .paymentFailed:
            return "فشلت عملية الدفع"
        case .purchaseCancelled:
            return "تم إلغاء عملية الشراء"
        case .verificationFailed:
            return "فشل التحقق من الشراء"
        case .networkError:
            return "خطأ في الاتصال بالشبكة"
        case .invalidURL:
            return "رابط غير صالح"
        case .failedToOpenURL:
            return "فشل فتح الرابط"
        }
    }
}

// MARK: - Payment Plans Data
extension PaymentService {
    static func getPaymentPlans() -> [PaymentPlan] {
        return [
            PaymentPlan(
                id: "premium_monthly",
                name: "مميز شهري",
                description: "وصول كامل لجميع الميزات المميزة",
                price: 99.99,
                currency: "SAR",
                duration: .monthly,
                features: SubscriptionTier.premium.features,
                isPopular: false,
                savings: nil
            ),
            PaymentPlan(
                id: "premium_yearly",
                name: "مميز سنوي",
                description: "وفر 20% مع الاشتراك السنوي",
                price: 959.99,
                currency: "SAR",
                duration: .yearly,
                features: SubscriptionTier.premium.features,
                isPopular: true,
                savings: "20%"
            ),
            PaymentPlan(
                id: "platinum_lifetime",
                name: "بلاتيني مدى الحياة",
                description: "وصول مدى الحياة لجميع الميزات",
                price: 4999.99,
                currency: "SAR",
                duration: .lifetime,
                features: SubscriptionTier.platinum.features,
                isPopular: false,
                savings: "50%"
            )
        ]
    }
}
