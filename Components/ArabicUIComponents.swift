import SwiftUI

// MARK: - Arabic Text Field
struct ArabicTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    @State private var isShowingPassword = false
    
    var body: some View {
        HStack(spacing: 12) {
            if isSecure {
                Group {
                    if isShowingPassword {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(autocapitalization)
                            .textDirection(.rightToLeft)
                    } else {
                        SecureField(placeholder, text: $text)
                            .textDirection(.rightToLeft)
                    }
                }
                
                Button(action: {
                    isShowingPassword.toggle()
                }) {
                    Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(ColorPalette.textSecondary)
                }
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalization)
                    .textDirection(.rightToLeft)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Arabic Button
struct ArabicButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case danger
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(25)
        }
        .disabled(isDisabled || isLoading)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .danger:
            return .white
        case .secondary:
            return ColorPalette.textPrimary
        case .outline:
            return ColorPalette.primary
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ColorPalette.primary
        case .secondary:
            return ColorPalette.secondary
        case .outline:
            return Color.clear
        case .danger:
            return ColorPalette.error
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .secondary, .danger:
            return Color.clear
        case .outline:
            return ColorPalette.primary
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .secondary, .danger:
            return 0
        case .outline:
            return 2
        }
    }
}

// MARK: - Arabic Picker
struct ArabicPicker<T: Hashable & CaseIterable>: View where T.AllCases.Element == T {
    let title: String
    @Binding var selection: T
    let options: [T]
    let displayValue: (T) -> String
    
    init(title: String, selection: Binding<T>, displayValue: @escaping (T) -> String) {
        self.title = title
        self._selection = selection
        self.options = Array(T.allCases)
        self.displayValue = displayValue
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.textPrimary)
            
            HStack {
                Spacer()
                
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                        }) {
                            HStack {
                                Text(displayValue(option))
                                Spacer()
                                if selection == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ColorPalette.primary)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(displayValue(selection))
                            .foregroundColor(ColorPalette.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Arabic Toggle
struct ArabicToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.textPrimary)
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ColorPalette.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Arabic Card
struct ArabicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Arabic Section Header
struct ArabicSectionHeader: View {
    let title: String
    let icon: String
    let action: (() -> Void)?
    
    init(title: String, icon: String, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorPalette.primary)
                .font(.title3)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ColorPalette.primary)
            
            Spacer()
            
            if let action = action {
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(ColorPalette.primary)
                }
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Arabic Alert
struct ArabicAlert: ViewModifier {
    let isPresented: Binding<Bool>
    let title: String
    let message: String
    let primaryButton: String
    let secondaryButton: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                Button(primaryButton, action: primaryAction)
                if let secondaryButton = secondaryButton,
                   let secondaryAction = secondaryAction {
                    Button(secondaryButton, role: .cancel, action: secondaryAction)
                }
            } message: {
                Text(message)
            }
    }
}

extension View {
    func arabicAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButton: String = "موافق",
        secondaryButton: String? = nil,
        primaryAction: @escaping () -> Void = {},
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(ArabicAlert(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButton: primaryButton,
            secondaryButton: secondaryButton,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        ))
    }
}

// MARK: - Arabic Loading View
struct ArabicLoadingView: View {
    let message: String
    
    init(message: String = "جاري التحميل...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.primary))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(ColorPalette.textPrimary)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Arabic Empty State View
struct ArabicEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(ColorPalette.textSecondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(ColorPalette.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(ColorPalette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle,
               let action = action {
                ArabicButton(title: actionTitle, action: action, style: .outline)
                    .padding(.horizontal, 30)
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Arabic Badge
struct ArabicBadge: View {
    let text: String
    let color: Color
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case medium
        case large
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(color)
            .cornerRadius(cornerRadius)
    }
    
    private var font: Font {
        switch size {
        case .small:
            return .caption2
        case .medium:
            return .caption
        case .large:
            return .subheadline
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 6
        case .medium:
            return 8
        case .large:
            return 12
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 2
        case .medium:
            return 4
        case .large:
            return 6
        }
    }
    
    private var cornerRadius: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 10
        case .large:
            return 12
        }
    }
}

// MARK: - Arabic Segmented Control
struct ArabicSegmentedControl<T: Hashable & CaseIterable>: View where T.AllCases.Element == T {
    @Binding var selection: T
    let options: [T]
    let displayValue: (T) -> String
    
    init(selection: Binding<T>, displayValue: @escaping (T) -> String) {
        self._selection = selection
        self.options = Array(T.allCases)
        self.displayValue = displayValue
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(displayValue(option))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selection == option ? .white : ColorPalette.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(selection == option ? ColorPalette.primary : Color.clear)
                }
            }
        }
        .background(ColorPalette.surfaceBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ArabicTextField(placeholder: "البريد الإلكتروني", text: .constant(""))
        
        ArabicButton(title: "تسجيل الدخول", action: {}, isLoading: false)
        
        ArabicPicker(title: "الجنس", selection: .constant(.male)) { option in
            option.rawValue
        }
        
        ArabicToggle(title: "تلقي الإشعارات", isOn: .constant(true))
        
        ArabicBadge(text: "جديد", color: ColorPalette.success, size: .medium)
    }
    .padding()
}
