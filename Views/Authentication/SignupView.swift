import SwiftUI

struct SignupView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPasswordRequirements = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Text("إنشاء حساب جديد")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.primary)
                        
                        Text("انضم إلى مثاق وابدأ رحلتك في إيجاد الشريك المناسب")
                            .font(.subheadline)
                            .foregroundColor(ColorPalette.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Registration Form
                    VStack(spacing: 20) {
                        // Personal Information Section
                        VStack(alignment: .trailing, spacing: 15) {
                            SectionHeader(title: "المعلومات الشخصية", icon: "person.fill")
                            
                            // Full Name
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("الاسم الكامل")
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.textPrimary)
                                
                                TextField("أدخل اسمك الكامل", text: $viewModel.name)
                                    .textFieldStyle(RoundedTextFieldStyle())
                            }
                            
                            // Email
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
                            
                            // Phone
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("رقم الهاتف")
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.textPrimary)
                                
                                TextField("أدخل رقم هاتفك", text: $viewModel.phone)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .keyboardType(.phonePad)
                                    .textDirection(.leftToRight)
                            }
                            
                            // Date of Birth
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("تاريخ الميلاد")
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.textPrimary)
                                
                                DatePicker("", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                            }
                            
                            // Gender
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("الجنس")
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.textPrimary)
                                
                                HStack(spacing: 20) {
                                    ForEach(User.Gender.allCases, id: \.self) { gender in
                                        Button(action: {
                                            viewModel.gender = gender
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: viewModel.gender == gender ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(viewModel.gender == gender ? ColorPalette.primary : Color.gray)
                                                Text(gender.rawValue)
                                                    .font(.subheadline)
                                                    .foregroundColor(ColorPalette.textPrimary)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(viewModel.gender == gender ? ColorPalette.primary.opacity(0.1) : Color.clear)
                                            )
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        
                        // Security Section
                        VStack(alignment: .trailing, spacing: 15) {
                            SectionHeader(title: "المعلومات الأمنية", icon: "lock.fill")
                            
                            // Password
                            VStack(alignment: .trailing, spacing: 8) {
                                HStack {
                                    Text("كلمة المرور")
                                        .font(.headline)
                                        .foregroundColor(ColorPalette.textPrimary)
                                    
                                    Button(action: {
                                        showPasswordRequirements.toggle()
                                    }) {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(ColorPalette.primary)
                                    }
                                }
                                
                                SecureField("أدخل كلمة المرور", text: $viewModel.password)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .textDirection(.leftToRight)
                                
                                if showPasswordRequirements {
                                    PasswordRequirementsView(password: viewModel.password)
                                }
                            }
                            
                            // Confirm Password
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("تأكيد كلمة المرور")
                                    .font(.headline)
                                    .foregroundColor(ColorPalette.textPrimary)
                                
                                SecureField("أعد إدخال كلمة المرور", text: $viewModel.confirmPassword)
                                    .textFieldStyle(RoundedTextFieldStyle())
                                    .textDirection(.leftToRight)
                            }
                        }
                        
                        // Terms and Conditions
                        VStack(alignment: .trailing, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Button(action: {
                                    viewModel.agreeToTerms.toggle()
                                }) {
                                    Image(systemName: viewModel.agreeToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(viewModel.agreeToTerms ? ColorPalette.primary : Color.gray)
                                        .font(.title3)
                                }
                                
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text("أوافق على")
                                        .font(.subheadline)
                                        .foregroundColor(ColorPalette.textPrimary)
                                    
                                    HStack(spacing: 5) {
                                        Button("الشروط والأحكام") {
                                            // Show terms
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(ColorPalette.primary)
                                        .underline()
                                        
                                        Text("و")
                                            .font(.subheadline)
                                            .foregroundColor(ColorPalette.textPrimary)
                                        
                                        Button("سياسة الخصوصية") {
                                            // Show privacy policy
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(ColorPalette.primary)
                                        .underline()
                                    }
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(ColorPalette.error)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                        
                        // Register Button
                        Button(action: {
                            viewModel.register()
                        }) {
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("جاري إنشاء الحساب...")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(ColorPalette.primary)
                                .cornerRadius(25)
                            } else {
                                Text("إنشاء حساب")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(ColorPalette.primary)
                                    .cornerRadius(25)
                            }
                        }
                        .disabled(viewModel.isLoading || !viewModel.agreeToTerms)
                        
                        // Login Link
                        HStack {
                            Text("لديك حساب بالفعل؟")
                                .font(.subheadline)
                                .foregroundColor(ColorPalette.textSecondary)
                            
                            Button("سجل دخولك") {
                                dismiss()
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorPalette.primary)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .background(ColorPalette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") {
                        dismiss()
                    }
                    .foregroundColor(ColorPalette.primary)
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorPalette.primary)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ColorPalette.primary)
            Spacer()
        }
        .padding(.bottom, 5)
    }
}

struct PasswordRequirementsView: View {
    let password: String
    
    private var requirements: [(String, Bool)] {
        [
            ("8 أحرف على الأقل", password.count >= 8),
            ("حرف كبير واحد على الأقل", password.range(of: "[A-Z]", options: .regularExpression) != nil),
            ("حرف صغير واحد على الأقل", password.range(of: "[a-z]", options: .regularExpression) != nil),
            ("رقم واحد على الأقل", password.range(of: "[0-9]", options: .regularExpression) != nil),
            ("رمز خاص واحد على الأقل", password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil)
        ]
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            ForEach(requirements, id: \.0) { requirement in
                HStack {
                    Spacer()
                    Text(requirement.0)
                        .font(.caption)
                        .foregroundColor(requirement.1 ? ColorPalette.success : ColorPalette.textSecondary)
                    Image(systemName: requirement.1 ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundColor(requirement.1 ? ColorPalette.success : Color.gray)
                }
            }
        }
        .padding()
        .background(ColorPalette.surfaceBackground)
        .cornerRadius(8)
        .padding(.top, 5)
    }
}

#Preview {
    SignupView()
}
