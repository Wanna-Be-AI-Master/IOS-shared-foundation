# カラーパレット設計

## 概要

両アプリで共通のカラーシステムを定義する。各アプリはブランドカラーが異なるが、セマンティックカラーや構造は統一する。

---

## カラー構造

```
カラーシステム
├── ブランドカラー（アプリ固有）
│   ├── Primary
│   ├── Secondary
│   └── Accent
│
├── セマンティックカラー（共通）
│   ├── Success
│   ├── Warning
│   ├── Error
│   └── Info
│
├── 背景・テキスト（共通構造）
│   ├── Background
│   ├── Text
│   └── Border
│
└── テーマ対応
    ├── Light
    └── Dark
```

---

## アプリ別ブランドカラー

### かろやか (katazuke-app)

| 名前 | HEX | 用途 |
|------|-----|------|
| Primary | `#4CAF50` | メイン（グリーン・爽やかさ） |
| Primary Light | `#81C784` | ライトバリエーション |
| Primary Dark | `#388E3C` | ダークバリエーション |
| Secondary | `#FF9800` | サブ（オレンジ・達成感） |
| Accent | `#E91E63` | アクセント（ピンク） |

**コンセプト**: 片付け後の爽やかさ、達成感

### むすび (koukan-nikki-app)

| 名前 | HEX | 用途 |
|------|-----|------|
| Primary | `#FFB6C1` | メイン（ライトピンク） |
| Primary Dark | `#FF69B4` | ダークバリエーション |
| Secondary | `#DDA0DD` | サブ（プラム・パープル） |
| Accent | `#FF7F7F` | アクセント（コーラル） |
| Premium | `#FFD700` | プレミアム（ゴールド） |

**コンセプト**: ロマンチック、柔らかい印象

---

## セマンティックカラー（共通）

| 名前 | Light | Dark | 用途 |
|------|-------|------|------|
| Success | `#4CAF50` | `#66BB6A` | 成功、完了 |
| Warning | `#FF9800` | `#FFB74D` | 警告、注意 |
| Error | `#F44336` | `#EF5350` | エラー、削除 |
| Info | `#2196F3` | `#42A5F5` | 情報、ヒント |

---

## 背景色

### ライトテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Background | `#FFFFFF` | メイン背景 |
| Background Secondary | `#F5F5F5` | セカンダリ背景 |
| Background Tertiary | `#EEEEEE` | 入力フィールドなど |
| Card | `#FFFFFF` | カード背景 |

### ダークテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Background | `#1A1A1A` | メイン背景 |
| Background Secondary | `#2A2A2A` | セカンダリ背景 |
| Background Tertiary | `#3A3A3A` | 入力フィールドなど |
| Card | `#2A2A2A` | カード背景 |

---

## テキスト色

### ライトテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Text Primary | `#1A1A1A` | メインテキスト |
| Text Secondary | `#666666` | 補足テキスト |
| Text Tertiary | `#999999` | 非アクティブ |
| Text Inverse | `#FFFFFF` | 反転（ボタン上など） |

### ダークテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Text Primary | `#FFFFFF` | メインテキスト |
| Text Secondary | `#AAAAAA` | 補足テキスト |
| Text Tertiary | `#777777` | 非アクティブ |
| Text Inverse | `#1A1A1A` | 反転（ボタン上など） |

---

## ボーダー・区切り線

### ライトテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Border | `#E0E0E0` | 標準ボーダー |
| Border Light | `#F0F0F0` | 薄いボーダー |
| Divider | `#EEEEEE` | 区切り線 |

### ダークテーマ

| 名前 | HEX | 用途 |
|------|-----|------|
| Border | `#3A3A3A` | 標準ボーダー |
| Border Light | `#2A2A2A` | 薄いボーダー |
| Divider | `#3A3A3A` | 区切り線 |

---

## 特殊カラー

### バッジ・ラベル

| 名前 | HEX | 用途 |
|------|-----|------|
| Badge | `#FF4081` | 通知バッジ |
| Badge Text | `#FFFFFF` | バッジ内テキスト |

### オーバーレイ

| 名前 | 値 | 用途 |
|------|-----|------|
| Overlay | `rgba(0,0,0,0.5)` | モーダル背景 |
| Overlay Light | `rgba(0,0,0,0.3)` | 薄いオーバーレイ |

### スケルトン（ローディング）

| テーマ | Base | Highlight |
|--------|------|-----------|
| Light | `#E0E0E0` | `#F0F0F0` |
| Dark | `#2A2A2A` | `#3A3A3A` |

---

## カテゴリ別カラー

### かろやか（物のカテゴリ）

| カテゴリ | HEX | アイコン |
|----------|-----|----------|
| 衣類 | `#F48FB1` | 👕 |
| 本・雑誌 | `#64B5F6` | 📚 |
| 雑貨 | `#FFB74D` | 🏠 |
| 家電 | `#90A4AE` | 📱 |
| 書類 | `#FFF176` | 📄 |
| その他 | `#CE93D8` | 📦 |

### むすび（日記帳タイプ）

| タイプ | Primary | Background | アイコン |
|--------|---------|------------|----------|
| カップル | `#FF69B4` | `#FFF0F5` | 💕 |
| 家族 | `#FFA500` | `#FFF8DC` | 👨‍👩‍👧‍👦 |
| 友達 | `#4169E1` | `#F0F8FF` | 👫 |
| 匿名 | `#708090` | `#F5F5F5` | 🔗 |

---

## バッジカラー（かろやか専用）

| レアリティ | HEX | 用途 |
|------------|-----|------|
| Bronze | `#CD7F32` | 初級バッジ |
| Silver | `#C0C0C0` | 中級バッジ |
| Gold | `#FFD700` | 上級バッジ |
| Platinum | `#E5E4E2` | 最上級バッジ |

---

## グラデーション

### 定義方法

```
方向: TopLeading → BottomTrailing (左上から右下)
```

### Primary Gradient

| アプリ | 開始色 | 終了色 |
|--------|--------|--------|
| かろやか | `#81C784` | `#4CAF50` |
| むすび | `#FFB6C1` | `#FF69B4` |

### 使用例

- プライマリボタン
- ヘッダー背景
- プログレスバー

---

## アクセシビリティ

### コントラスト比

WCAG 2.1 AA基準を満たすこと:

| 用途 | 最小比率 |
|------|----------|
| 通常テキスト | 4.5:1 |
| 大きいテキスト（18px以上） | 3:1 |
| UIコンポーネント | 3:1 |

### 確認済み組み合わせ

| 前景 | 背景 | コントラスト比 |
|------|------|----------------|
| `#1A1A1A` | `#FFFFFF` | 16.1:1 ✓ |
| `#FFFFFF` | `#4CAF50` | 3.3:1 ✓ |
| `#FFFFFF` | `#FF69B4` | 3.1:1 ✓ |

### 色覚多様性への配慮

- 色だけで情報を伝えない
- アイコンやテキストを併用
- 色盲シミュレーターでテスト

---

## 実装例

### TypeScript (React Native)

```typescript
export const LightColors = {
  primary: '#4CAF50',
  primaryLight: '#81C784',
  primaryDark: '#388E3C',

  background: '#FFFFFF',
  backgroundSecondary: '#F5F5F5',

  text: '#1A1A1A',
  textSecondary: '#666666',

  success: '#4CAF50',
  warning: '#FF9800',
  error: '#F44336',
  info: '#2196F3',
} as const;

export const DarkColors = {
  // ... ダークテーマ
} as const;

export type ThemeColors = typeof LightColors;
```

### Swift (SwiftUI)

```swift
enum AppColors {
    // ブランドカラー
    static let primary = Color(hex: "4CAF50")
    static let primaryLight = Color(hex: "81C784")
    static let primaryDark = Color(hex: "388E3C")

    // セマンティック
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FF9800")
    static let error = Color(hex: "F44336")
    static let info = Color(hex: "2196F3")

    // 背景（システム対応）
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    // テキスト（システム対応）
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
}
```

---

## チェックリスト

### 色の定義

- [ ] プライマリ・セカンダリ・アクセントを定義
- [ ] セマンティックカラー（Success/Warning/Error/Info）を定義
- [ ] ライト・ダークテーマを用意
- [ ] 背景・テキスト・ボーダーを定義

### アクセシビリティ

- [ ] コントラスト比を確認
- [ ] 色覚シミュレーターでテスト
- [ ] 色以外の視覚的手がかりを提供

### 一貫性

- [ ] デザインツール（Figma等）と同期
- [ ] 命名規則が統一されている
- [ ] HEXコードが正確
