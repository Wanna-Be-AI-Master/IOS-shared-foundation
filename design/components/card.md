# Card コンポーネント仕様

## 概要

コンテンツをグループ化して表示するカードコンポーネントの仕様を定義する。

---

## バリエーション

### スタイル

| スタイル | 説明 | 用途 |
|----------|------|------|
| **Elevated** | 影付きカード | 一般的なコンテンツ |
| **Outlined** | ボーダー付きカード | リスト項目 |
| **Filled** | 背景色付きカード | 強調コンテンツ |

### サイズ

| サイズ | パディング | 角丸 | 用途 |
|--------|------------|------|------|
| Small | 12px | 8px | コンパクト表示 |
| Medium | 16px | 12px | 標準 |
| Large | 20px | 16px | 詳細表示 |

---

## ビジュアル仕様

### Elevated Card

```
┌─────────────────────────────────────┐
│                                     │
│   コンテンツ領域                     │
│                                     │
└─────────────────────────────────────┘
    ▼ 影

背景: #FFFFFF (Light) / #2A2A2A (Dark)
角丸: 12px
影: 0 2px 8px rgba(0, 0, 0, 0.08)
パディング: 16px
```

### Outlined Card

```
┌─────────────────────────────────────┐
│                                     │
│   コンテンツ領域                     │
│                                     │
└─────────────────────────────────────┘

背景: 透明
ボーダー: 1px solid #E0E0E0
角丸: 12px
パディング: 16px
```

### Filled Card

```
┌─────────────────────────────────────┐
│                                     │
│   コンテンツ領域                     │
│                                     │
└─────────────────────────────────────┘

背景: セカンダリ背景色
ボーダー: なし
角丸: 12px
パディング: 16px
```

---

## 構造パターン

### 基本構造

```
┌─────────────────────────────────────┐
│  ヘッダー（オプション）               │
├─────────────────────────────────────┤
│                                     │
│  コンテンツ                          │
│                                     │
├─────────────────────────────────────┤
│  フッター（オプション）               │
└─────────────────────────────────────┘
```

### メディアカード

```
┌─────────────────────────────────────┐
│                                     │
│         画像 / メディア              │
│                                     │
├─────────────────────────────────────┤
│  タイトル                            │
│  サブタイトル                        │
│  説明文...                          │
├─────────────────────────────────────┤
│  [アクション1]  [アクション2]         │
└─────────────────────────────────────┘
```

### リストアイテムカード

```
┌─────────────────────────────────────┐
│  🔵  タイトル              詳細 >   │
│      サブタイトル                    │
└─────────────────────────────────────┘
```

---

## 状態

### デフォルト

```
背景: カード背景色
影: 標準影
```

### 押下可能（タッチ時）

```
背景: 少し暗く（opacity 0.95）
スケール: 0.98
transition: 150ms ease-out
```

### 選択済み

```
ボーダー: 2px solid プライマリカラー
背景: rgba(primary, 0.05)
```

### 無効

```
不透明度: 0.5
操作: 不可
```

---

## 影の仕様

### Elevation レベル

| レベル | 影 | 用途 |
|--------|-----|------|
| 0 | なし | フラットカード |
| 1 | `0 1px 3px rgba(0,0,0,0.08)` | 軽い浮き上がり |
| 2 | `0 2px 8px rgba(0,0,0,0.12)` | 標準カード |
| 3 | `0 4px 16px rgba(0,0,0,0.16)` | モーダル、重要カード |

### ダークモードでの影

```
ダークモードでは影を薄くする
opacity: 0.3 (ライトモードの半分程度)
```

---

## Props / パラメータ

### TypeScript (React Native)

```typescript
interface CardProps {
  // コンテンツ
  children: React.ReactNode;

  // スタイル
  variant?: 'elevated' | 'outlined' | 'filled';
  size?: 'small' | 'medium' | 'large';

  // インタラクション
  onPress?: () => void;
  disabled?: boolean;

  // 状態
  selected?: boolean;

  // カスタムスタイル
  style?: ViewStyle;
}

interface CardHeaderProps {
  title: string;
  subtitle?: string;
  leading?: React.ReactNode;  // 左側アイコン
  trailing?: React.ReactNode; // 右側アクション
}

interface CardFooterProps {
  children: React.ReactNode;
}
```

### Swift (SwiftUI)

```swift
struct AppCard<Content: View>: View {
    let content: Content

    var variant: CardVariant = .elevated
    var size: CardSize = .medium
    var isSelected: Bool = false
    var isDisabled: Bool = false
    var onTap: (() -> Void)? = nil

    enum CardVariant {
        case elevated, outlined, filled
    }

    enum CardSize {
        case small, medium, large

        var padding: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
    }
}
```

---

## 実装例

### TypeScript (React Native)

```typescript
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ViewStyle,
} from 'react-native';
import { Colors } from '@/constants/Colors';

interface CardProps {
  children: React.ReactNode;
  variant?: 'elevated' | 'outlined' | 'filled';
  size?: 'small' | 'medium' | 'large';
  onPress?: () => void;
  disabled?: boolean;
  selected?: boolean;
  style?: ViewStyle;
}

export function Card({
  children,
  variant = 'elevated',
  size = 'medium',
  onPress,
  disabled = false,
  selected = false,
  style,
}: CardProps) {
  const Container = onPress ? TouchableOpacity : View;
  const containerProps = onPress
    ? { onPress, disabled, activeOpacity: 0.95 }
    : {};

  return (
    <Container
      {...containerProps}
      style={[
        styles.base,
        styles[variant],
        styles[size],
        selected && styles.selected,
        disabled && styles.disabled,
        style,
      ]}
    >
      {children}
    </Container>
  );
}

// サブコンポーネント
export function CardHeader({
  title,
  subtitle,
  leading,
  trailing,
}: {
  title: string;
  subtitle?: string;
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
}) {
  return (
    <View style={styles.header}>
      {leading && <View style={styles.headerLeading}>{leading}</View>}
      <View style={styles.headerContent}>
        <Text style={styles.headerTitle}>{title}</Text>
        {subtitle && <Text style={styles.headerSubtitle}>{subtitle}</Text>}
      </View>
      {trailing && <View style={styles.headerTrailing}>{trailing}</View>}
    </View>
  );
}

export function CardContent({ children }: { children: React.ReactNode }) {
  return <View style={styles.content}>{children}</View>;
}

export function CardFooter({ children }: { children: React.ReactNode }) {
  return <View style={styles.footer}>{children}</View>;
}

const styles = StyleSheet.create({
  base: {
    borderRadius: 12,
    overflow: 'hidden',
  },

  // Variants
  elevated: {
    backgroundColor: Colors.light.card,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  outlined: {
    backgroundColor: 'transparent',
    borderWidth: 1,
    borderColor: Colors.light.border,
  },
  filled: {
    backgroundColor: Colors.light.backgroundSecondary,
  },

  // Sizes
  small: {
    padding: 12,
    borderRadius: 8,
  },
  medium: {
    padding: 16,
    borderRadius: 12,
  },
  large: {
    padding: 20,
    borderRadius: 16,
  },

  // States
  selected: {
    borderWidth: 2,
    borderColor: Colors.light.primary,
    backgroundColor: `${Colors.light.primary}10`,
  },
  disabled: {
    opacity: 0.5,
  },

  // Header
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  headerLeading: {
    marginRight: 12,
  },
  headerContent: {
    flex: 1,
  },
  headerTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: Colors.light.text,
  },
  headerSubtitle: {
    fontSize: 14,
    color: Colors.light.textSecondary,
    marginTop: 2,
  },
  headerTrailing: {
    marginLeft: 12,
  },

  // Content
  content: {
    marginBottom: 12,
  },

  // Footer
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: Colors.light.divider,
  },
});
```

### Swift (SwiftUI)

```swift
import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content

    var variant: Variant = .elevated
    var size: Size = .medium
    var isSelected: Bool = false
    var isDisabled: Bool = false
    var onTap: (() -> Void)? = nil

    @State private var isPressed = false

    enum Variant {
        case elevated, outlined, filled
    }

    enum Size {
        case small, medium, large

        var padding: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
    }

    init(
        variant: Variant = .elevated,
        size: Size = .medium,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.size = size
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        content
            .padding(size.padding)
            .background(backgroundColor)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .onTapGesture {
                guard !isDisabled, let onTap = onTap else { return }
                onTap()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if onTap != nil && !isDisabled {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in isPressed = false }
            )
    }

    private var backgroundColor: Color {
        switch variant {
        case .elevated:
            return AppColors.background
        case .outlined:
            return .clear
        case .filled:
            return AppColors.secondaryBackground
        }
    }

    private var borderColor: Color {
        if isSelected {
            return AppColors.primary
        }
        switch variant {
        case .outlined:
            return Color(hex: "E0E0E0")
        default:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        if isSelected { return 2 }
        if variant == .outlined { return 1 }
        return 0
    }

    private var shadowColor: Color {
        variant == .elevated ? Color.black.opacity(0.08) : .clear
    }

    private var shadowRadius: CGFloat {
        variant == .elevated ? 8 : 0
    }

    private var shadowY: CGFloat {
        variant == .elevated ? 2 : 0
    }
}

// カードヘッダー
struct CardHeader: View {
    let title: String
    var subtitle: String? = nil
    var leading: AnyView? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let leading = leading {
                leading
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            if let trailing = trailing {
                trailing
            }
        }
    }
}

// プレビュー
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            AppCard(variant: .elevated) {
                VStack(alignment: .leading) {
                    Text("Elevated Card")
                        .font(.headline)
                    Text("影付きのカードです")
                        .foregroundColor(.secondary)
                }
            }

            AppCard(variant: .outlined) {
                VStack(alignment: .leading) {
                    Text("Outlined Card")
                        .font(.headline)
                    Text("ボーダー付きのカードです")
                        .foregroundColor(.secondary)
                }
            }

            AppCard(variant: .filled) {
                VStack(alignment: .leading) {
                    Text("Filled Card")
                        .font(.headline)
                    Text("背景色付きのカードです")
                        .foregroundColor(.secondary)
                }
            }

            AppCard(isSelected: true) {
                Text("Selected Card")
            }

            AppCard(onTap: { print("tapped") }) {
                Text("Tappable Card")
            }
        }
        .padding()
    }
}
```

---

## アクセシビリティ

### 必須対応

- [ ] タップ可能なカードは `accessibilityRole="button"`
- [ ] カード内容を `accessibilityLabel` で説明
- [ ] 選択状態を `accessibilityState={{ selected }}` で通知
- [ ] グループ化: `accessibilityRole="summary"`

### VoiceOver対応

```swift
AppCard(onTap: { ... }) {
    // ...
}
.accessibilityElement(children: .combine)
.accessibilityLabel("日記エントリ: \(title)")
.accessibilityHint("タップして詳細を表示")
.accessibilityAddTraits(.isButton)
```

---

## チェックリスト

- [ ] 全バリアント（elevated, outlined, filled）を実装
- [ ] 全サイズ（small, medium, large）を実装
- [ ] タップ可能状態を実装
- [ ] 選択状態を実装
- [ ] 無効状態を実装
- [ ] ヘッダー・コンテンツ・フッター構造
- [ ] アクセシビリティ対応
- [ ] ダークモード対応
