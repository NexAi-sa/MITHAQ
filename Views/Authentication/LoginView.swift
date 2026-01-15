import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Logo and Title
                    VStack(spacing: 15) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(ColorPalette.primary)
                        
                        Text("مرحباً بعودتك")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.textPrimary)
                        
                        Text("سجل دخولك لمتابعة رحلتك في إيجاد الشريك المناسب")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("البريد الإلكتروني")
                                .font(.headline)
                                .foregroundColor(ColorPalette.textPrimary)
                            
                            TextField("أدخل بريدك الإلكتروني", text: $viewModel.email)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textDirection(.leftToRight)
                        }
                        
                        // Password Field
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("كلمة المرور")
                                .font(.headline)
                                .foregroundColor(ColorPalette.textPrimary)
                            
                            SecureField("أدخل كلمة المرور", text: $viewModel.password)
                                .textFieldStyle(RoundedTextFieldStyle())
                                .textDirection(.leftToRight)
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("نسيت كلمة المرور؟") {
                                // Handle forgot password
                            }
                            .font(.caption)
                            .foregroundColor(ColorPalette.primary)
                        }
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(ColorPalette.error)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Login Button
                        Button(action: {
                            viewModel.login()
                        }) {
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("جاري تسجيل الدخول...")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(ColorPalette.primary)
                                .cornerRadius(25)
                            } else {
                                Text("تسجيل الدخول")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(ColorPalette.primary)
                                    .cornerRadius(25)
                            }
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Social Login Options
                        VStack(spacing: 15) {
                            Text("أو سجل الدخول باستخدام")
                                .font(.caption)
                                .foregroundColor(ColorPalette.textSecondary)
                            
                            HStack(spacing: 20) {
                                SocialLoginButton(icon: "globe", text: "جوجل", color: .blue) {
                                    // Handle Google login
                                }
                                
                                SocialLoginButton(icon: "applelogo", text: "آبل", color: .black) {
                                    // Handle Apple login
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack {
                        Text("ليس لديك حساب؟")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                        
                        Button("إنشاء حساب جديد") {
                            // Navigate to signup
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorPalette.primary)
                    }
                    .padding(.bottom, 30)
                }
            }
            .background(ColorPalette.background)
            .navigationBarHidden(true)
        }
        .environmentObject(viewModel)
    }
}

struct SocialLoginButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(22)
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
    }
}

#Preview {
    LoginView()
}
