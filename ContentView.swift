import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
                .tag(AppState.TabItem.home)
            
            SearchView()
                .tabItem {
                    Label("البحث", systemImage: "magnifyingglass")
                }
                .tag(AppState.TabItem.search)
            
            MatchesView()
                .tabItem {
                    Label("المطابقات", systemImage: "heart.fill")
                }
                .tag(AppState.TabItem.matches)
            
            MessagesView()
                .tabItem {
                    Label("الرسائل", systemImage: "message.fill")
                }
                .tag(AppState.TabItem.messages)
            
            ProfileView()
                .tabItem {
                    Label("الملف الشخصي", systemImage: "person.fill")
                }
                .tag(AppState.TabItem.profile)
        }
        .accentColor(ColorPalette.primary)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("مرحباً بك في مثاق")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.primary)
                    .padding()
                
                Text("منصة التوافق والزواج المتقدمة")
                    .font(.title2)
                    .foregroundColor(ColorPalette.textSecondary)
                    .padding(.horizontal)
                
                Spacer()
                
                // Quick Stats
                HStack(spacing: 20) {
                    StatCard(title: "المطابقات", value: "24", icon: "heart.fill")
                    StatCard(title: "الرسائل", value: "8", icon: "message.fill")
                    StatCard(title: "الزيارات", value: "156", icon: "eye.fill")
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("الرئيسية")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorPalette.primary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ColorPalette.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ColorPalette.textSecondary)
        }
        .frame(width: 80, height: 80)
        .background(ColorPalette.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SearchView: View {
    var body: some View {
        NavigationView {
            Text("البحث عن شريك")
                .navigationTitle("البحث")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MatchesView: View {
    var body: some View {
        NavigationView {
            Text("المطابقات")
                .navigationTitle("المطابقات")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MessagesView: View {
    var body: some View {
        NavigationView {
            Text("الرسائل")
                .navigationTitle("الرسائل")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            Text("الملف الشخصي")
                .navigationTitle("الملف الشخصي")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AuthenticationView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo
                VStack(spacing: 10) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(ColorPalette.primary)
                    
                    Text("مثاق")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.primary)
                    
                    Text("منصة التوافق والزواج المتقدمة")
                        .font(.subheadline)
                        .foregroundColor(ColorPalette.textSecondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Auth Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // Handle login
                    }) {
                        Text("تسجيل الدخول")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(ColorPalette.primary)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        // Handle signup
                    }) {
                        Text("إنشاء حساب جديد")
                            .font(.headline)
                            .foregroundColor(ColorPalette.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(ColorPalette.primary, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(ColorPalette.background)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
