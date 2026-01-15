import SwiftUI
import PassKit

struct PaymentView: View {
    @StateObject private var paymentService = PaymentService.shared
    @State private var selectedPlan: PaymentPlan?
    @State private var showingApplePay = false
    @State private var applePayRequest: PKPaymentRequest?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(ColorPalette.accent)
                        
                        Text("ارتقِ تجربتك")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.textPrimary)
                        
                        Text("احصل على إمكانية الوصول إلى جميع الميزات المميزة")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Payment Plans
                    VStack(spacing: 20) {
                        ForEach(PaymentService.getPaymentPlans()) { plan in
                            PaymentPlanCard(
                                plan: plan,
                                isSelected: selectedPlan?.id == plan.id,
                                onSelect: {
                                    selectedPlan = plan
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Features Comparison
                    FeaturesComparisonView()
                        .padding(.horizontal, 20)
                    
                    // Payment Buttons
                    VStack(spacing: 15) {
                        if let plan = selectedPlan {
                            // Apple Pay Button
                            if paymentService.canMakeApplePayPayments() {
                                ApplePayButton {
                                    initiateApplePayment(for: plan)
                                }
                            }
                            
                            // Credit Card Button
                            Button(action: {
                                initiateStoreKitPayment(for: plan)
                            }) {
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .font(.title3)
                                    Text("الدفع بالبطاقة")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(ColorPalette.primary)
                                .cornerRadius(25)
                            }
                        } else {
                            Text("اختر خطة للمتابعة")
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.textSecondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Security Badge
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(ColorPalette.success)
                        Text("مدفوعات آمنة ومشفرة")
                            .font(.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .background(ColorPalette.background)
            .navigationTitle("الاشتراك")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                Group {
                    if paymentService.isLoading {
                        ProgressView("جاري المعالجة...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
        }
        .alert("خطأ في الدفع", isPresented: .constant(paymentService.errorMessage != nil)) {
            Button("موافق") {
                paymentService.errorMessage = nil
            }
        } message: {
            if let errorMessage = paymentService.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showingApplePay) {
            if let request = applePayRequest {
                ApplePayView(request: request) { success in
                    showingApplePay = false
                    if success {
                        // Handle successful payment
                    }
                }
            }
        }
    }
    
    private func initiateApplePayment(for plan: PaymentPlan) {
        let amount = NSDecimalNumber(value: Double(truncating: plan.price as NSNumber))
        if let request = paymentService.createApplePayRequest(amount: amount) {
            applePayRequest = request
            showingApplePay = true
        }
    }
    
    private func initiateStoreKitPayment(for plan: PaymentPlan) {
        guard let product = paymentService.availableProducts.first(where: { $0.productIdentifier == plan.id }) else {
            paymentService.errorMessage = "المنتج غير متاح"
            return
        }
        
        paymentService.purchaseProduct(product) { result in
            switch result {
            case .success:
                // Handle successful purchase
                print("Purchase successful")
            case .failure(let error):
                paymentService.errorMessage = error.localizedDescription
            }
        }
    }
}

struct PaymentPlanCard: View {
    let plan: PaymentPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 15) {
                // Plan Header
                HStack {
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(plan.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : ColorPalette.textPrimary)
                        
                        Text(plan.description)
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : ColorPalette.textSecondary)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Spacer()
                    
                    if plan.isPopular {
                        Text("الأكثر شعبية")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(ColorPalette.secondary)
                            .cornerRadius(12)
                    }
                }
                
                // Price
                VStack(spacing: 5) {
                    HStack {
                        Text("\(plan.price, specifier: "%.2f")")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isSelected ? .white : ColorPalette.primary)
                        
                        Text(plan.currency)
                            .font(.title3)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : ColorPalette.textSecondary)
                        
                        if let savings = plan.savings {
                            Text("وفر \(savings)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorPalette.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(ColorPalette.success.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                    
                    Text("/\(plan.duration.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : ColorPalette.textSecondary)
                }
                
                // Features
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(Array(plan.features.prefix(4).enumerated()), id: \.offset) { index, feature in
                        HStack {
                            Text(feature.description)
                                .font(.caption)
                                .foregroundColor(isSelected ? .white.opacity(0.9) : ColorPalette.textPrimary)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(isSelected ? .white : ColorPalette.success)
                        }
                    }
                    
                    if plan.features.count > 4 {
                        Text("+\(plan.features.count - 4) ميزات أخرى")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.7) : ColorPalette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? ColorPalette.primary : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? ColorPalette.primary : Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            )
            .shadow(color: isSelected ? ColorPalette.primary.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturesComparisonView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("مقارنة الميزات")
                .font(.headline)
                .foregroundColor(ColorPalette.textPrimary)
            
            VStack(spacing: 15) {
                FeatureRow(
                    feature: "المطابقات اليومية",
                    basic: "5",
                    premium: "غير محدود",
                    platinum: "غير محدود"
                )
                
                FeatureRow(
                    feature: "الرسائل",
                    basic: "10/يوم",
                    premium: "غير محدود",
                    platinum: "غير محدود"
                )
                
                FeatureRow(
                    feature: "تحليل الشخصية",
                    basic: "أساسي",
                    premium: "متقدم",
                    platinum: "شامل"
                )
                
                FeatureRow(
                    feature: "تقارير التوافق",
                    basic: "❌",
                    premium: "✓",
                    platinum: "✓"
                )
                
                FeatureRow(
                    feature: "مكالمات فيديو",
                    basic: "❌",
                    premium: "❌",
                    platinum: "✓"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FeatureRow: View {
    let feature: String
    let basic: String
    let premium: String
    let platinum: String
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .foregroundColor(ColorPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text(basic)
                .font(.caption)
                .foregroundColor(ColorPalette.textSecondary)
                .frame(width: 60)
            
            Text(premium)
                .font(.caption)
                .foregroundColor(ColorPalette.primary)
                .fontWeight(.semibold)
                .frame(width: 60)
            
            Text(platinum)
                .font(.caption)
                .foregroundColor(ColorPalette.accent)
                .fontWeight(.bold)
                .frame(width: 60)
        }
        .padding(.vertical, 8)
    }
}

struct ApplePayButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "applelogo")
                    .font(.title3)
                Text("Apple Pay")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(25)
        }
    }
}

struct ApplePayView: UIViewControllerRepresentable {
    let request: PKPaymentRequest
    let completion: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
        let controller = PKPaymentAuthorizationViewController(paymentRequest: request)
        controller?.delegate = context.coordinator
        return controller!
    }
    
    func updateUIViewController(_ uiViewController: PKPaymentAuthorizationViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
        let completion: (Bool) -> Void
        
        init(completion: @escaping (Bool) -> Void) {
            self.completion = completion
        }
        
        func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
            // Process payment
            PaymentService.shared.processApplePayment(payment: payment) { result in
                switch result {
                case .success:
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.completion(true)
                case .failure:
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self.completion(false)
                }
            }
        }
        
        func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
            controller.dismiss(animated: true) {
                self.completion(false)
            }
        }
    }
}

#Preview {
    PaymentView()
}
