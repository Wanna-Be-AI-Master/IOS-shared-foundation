import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - DesignTokens

/// デザイントークン
/// カラー、スペーシング、タイポグラフィを統一管理
public enum DesignTokens {

    // MARK: - Colors

    /// カラーパレット
    public enum Colors {

        // MARK: - Primary Colors

        /// プライマリカラー（かろやか: ミントグリーン）
        public static let primaryKaroyaka = Color(hex: "#4ECDC4")

        /// プライマリカラー（むすび: コーラルピンク）
        public static let primaryMusubi = Color(hex: "#FF6B6B")

        // MARK: - Semantic Colors

        /// 成功
        public static let success = Color(hex: "#4CAF50")

        /// 警告
        public static let warning = Color(hex: "#FF9800")

        /// エラー
        public static let error = Color(hex: "#F44336")

        /// 情報
        public static let info = Color(hex: "#2196F3")

        // MARK: - Neutral Colors

        /// 背景（ライト）
        public static let backgroundLight = Color(hex: "#FAFAFA")

        /// 背景（ダーク）
        public static let backgroundDark = Color(hex: "#121212")

        /// サーフェス（ライト）
        public static let surfaceLight = Color.white

        /// サーフェス（ダーク）
        public static let surfaceDark = Color(hex: "#1E1E1E")

        /// テキスト（プライマリ・ライト）
        public static let textPrimaryLight = Color(hex: "#212121")

        /// テキスト（プライマリ・ダーク）
        public static let textPrimaryDark = Color(hex: "#FAFAFA")

        /// テキスト（セカンダリ・ライト）
        public static let textSecondaryLight = Color(hex: "#757575")

        /// テキスト（セカンダリ・ダーク）
        public static let textSecondaryDark = Color(hex: "#B0B0B0")

        /// ディバイダー（ライト）
        public static let dividerLight = Color(hex: "#E0E0E0")

        /// ディバイダー（ダーク）
        public static let dividerDark = Color(hex: "#424242")

        // MARK: - Badge Rarity Colors

        /// バッジレアリティ: コモン
        public static let badgeCommon = Color(hex: "#9E9E9E")

        /// バッジレアリティ: レア
        public static let badgeRare = Color(hex: "#2196F3")

        /// バッジレアリティ: エピック
        public static let badgeEpic = Color(hex: "#9C27B0")

        /// バッジレアリティ: レジェンダリー
        public static let badgeLegendary = Color(hex: "#FF9800")

        // MARK: - Category Colors (Karoyaka)

        /// カテゴリ: 衣類
        public static let categoryClothing = Color(hex: "#E91E63")

        /// カテゴリ: 書類
        public static let categoryDocuments = Color(hex: "#3F51B5")

        /// カテゴリ: 雑貨
        public static let categoryMiscellaneous = Color(hex: "#009688")

        /// カテゴリ: 電子機器
        public static let categoryElectronics = Color(hex: "#607D8B")

        /// カテゴリ: 本
        public static let categoryBooks = Color(hex: "#795548")

        /// カテゴリ: その他
        public static let categoryOther = Color(hex: "#9E9E9E")

        // MARK: - Gradient

        /// グラデーション（かろやか）
        public static let gradientKaroyaka: [Color] = [
            Color(hex: "#4ECDC4"),
            Color(hex: "#44A08D")
        ]

        /// グラデーション（むすび）
        public static let gradientMusubi: [Color] = [
            Color(hex: "#FF6B6B"),
            Color(hex: "#FFA07A")
        ]
    }

    // MARK: - Spacing

    /// スペーシング
    public enum Spacing {
        /// 4pt
        public static let xxs: CGFloat = 4

        /// 8pt
        public static let xs: CGFloat = 8

        /// 12pt
        public static let sm: CGFloat = 12

        /// 16pt
        public static let md: CGFloat = 16

        /// 24pt
        public static let lg: CGFloat = 24

        /// 32pt
        public static let xl: CGFloat = 32

        /// 48pt
        public static let xxl: CGFloat = 48

        /// 64pt
        public static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius

    /// 角丸
    public enum CornerRadius {
        /// 4pt
        public static let xs: CGFloat = 4

        /// 8pt
        public static let sm: CGFloat = 8

        /// 12pt
        public static let md: CGFloat = 12

        /// 16pt
        public static let lg: CGFloat = 16

        /// 24pt
        public static let xl: CGFloat = 24

        /// 完全な円
        public static let full: CGFloat = 9999
    }

    // MARK: - Typography

    /// タイポグラフィ
    public enum Typography {

        /// 見出し1
        public static let h1: Font = .system(size: 32, weight: .bold)

        /// 見出し2
        public static let h2: Font = .system(size: 24, weight: .bold)

        /// 見出し3
        public static let h3: Font = .system(size: 20, weight: .semibold)

        /// 見出し4
        public static let h4: Font = .system(size: 18, weight: .semibold)

        /// 本文（大）
        public static let bodyLarge: Font = .system(size: 17, weight: .regular)

        /// 本文（標準）
        public static let body: Font = .system(size: 15, weight: .regular)

        /// 本文（小）
        public static let bodySmall: Font = .system(size: 13, weight: .regular)

        /// キャプション
        public static let caption: Font = .system(size: 12, weight: .regular)

        /// ラベル
        public static let label: Font = .system(size: 14, weight: .medium)

        /// ボタン
        public static let button: Font = .system(size: 16, weight: .semibold)
    }

    // MARK: - Shadow

    /// シャドウ
    public enum Shadow {

        /// 小さいシャドウ
        public static let sm = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )

        /// 標準シャドウ
        public static let md = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )

        /// 大きいシャドウ
        public static let lg = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )

        /// シャドウスタイル
        public struct ShadowStyle {
            public let color: Color
            public let radius: CGFloat
            public let x: CGFloat
            public let y: CGFloat
        }
    }

    // MARK: - Animation

    /// アニメーション
    public enum Animation {
        /// 速い
        public static let fast: SwiftUI.Animation = .easeInOut(duration: 0.15)

        /// 標準
        public static let normal: SwiftUI.Animation = .easeInOut(duration: 0.25)

        /// 遅い
        public static let slow: SwiftUI.Animation = .easeInOut(duration: 0.4)

        /// スプリング
        public static let spring: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
    }

    // MARK: - Icon Size

    /// アイコンサイズ
    public enum IconSize {
        /// 16pt
        public static let sm: CGFloat = 16

        /// 24pt
        public static let md: CGFloat = 24

        /// 32pt
        public static let lg: CGFloat = 32

        /// 48pt
        public static let xl: CGFloat = 48
    }
}

// MARK: - Color Extension

extension Color {

    /// HEXコードからColorを生成
    /// - Parameter hex: HEXコード（#RRGGBB または RRGGBB）
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// HEXコードに変換
    public var hexString: String {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components else {
            return "#000000"
        }
        #else
        return "#000000"
        #endif

        #if canImport(UIKit) || canImport(AppKit)
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
        #endif
    }
}

// MARK: - View Extension

extension View {

    /// シャドウを適用
    public func shadow(_ style: DesignTokens.Shadow.ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}
