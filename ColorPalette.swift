import SwiftUI

struct ColorPalette {
    // Primary colors from logo - Maroon/Burgundy
    static let primary = Color(red: 128/255, green: 0/255, blue: 32/255) // #800020
    static let primaryDark = Color(red: 100/255, green: 0/255, blue: 25/255) // #640019
    static let primaryLight = Color(red: 160/255, green: 20/255, blue: 60/255) // #A0143C
    
    // Secondary colors - Light Beige/Gold
    static let secondary = Color(red: 245/255, green: 235/255, blue: 220/255) // #F5EBDC
    static let secondaryDark = Color(red: 235/255, green: 225/255, blue: 210/255) // #EBE1D2
    static let accent = Color(red: 212/255, green: 175/255, blue: 55/255) // #D4AF37
    
    // Text colors
    static let textPrimary = Color(red: 51/255, green: 51/255, blue: 51/255) // #333333
    static let textSecondary = Color(red: 102/255, green: 102/255, blue: 102/255) // #666666
    static let textLight = Color.white
    
    // Background colors
    static let background = Color(red: 250/255, green: 248/255, blue: 245/255) // #FAF8F5
    static let cardBackground = Color.white
    static let surfaceBackground = Color(red: 248/255, green: 246/255, blue: 243/255) // #F8F6F3
    
    // Status colors
    static let success = Color(red: 76/255, green: 175/255, blue: 80/255) // #4CAF50
    static let warning = Color(red: 255/255, green: 193/255, blue: 7/255) // #FFC107
    static let error = Color(red: 244/255, green: 67/255, blue: 54/255) // #F44336
    static let info = Color(red: 33/255, green: 150/255, blue: 243/255) // #2196F3
    
    // Compatibility colors
    static let compatibilityExcellent = Color(red: 76/255, green: 175/255, blue: 80/255) // #4CAF50
    static let compatibilityGood = Color(red: 139/255, green: 195/255, blue: 74/255) // #8BC34A
    static let compatibilityAverage = Color(red: 255/255, green: 193/255, blue: 7/255) // #FFC107
    static let compatibilityPoor = Color(red: 255/255, green: 152/255, blue: 0/255) // #FF9800
}

extension Color {
    static let mithaqPrimary = ColorPalette.primary
    static let mithaqSecondary = ColorPalette.secondary
    static let mithaqAccent = ColorPalette.accent
}
