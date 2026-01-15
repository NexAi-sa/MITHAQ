import SwiftUI

@main
struct MithaqApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedTab: TabItem = .home
    
    enum TabItem: String, CaseIterable {
        case home = "الرئيسية"
        case search = "البحث"
        case matches = "المطابقات"
        case messages = "الرسائل"
        case profile = "الملف الشخصي"
    }
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let isVerified: Bool
    let profileCompleted: Bool
}
