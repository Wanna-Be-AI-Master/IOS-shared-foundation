# Button コンポーネント仕様

## 概要

アプリケーション全体で使用するボタンコンポーネントの仕様を定義する。

---

## バリエーション

### サイズ

| サイズ | 高さ | パディング | フォントサイズ | 用途 |
|--------|------|------------|----------------|------|
| Small | 32px | 12px 16px | 14px | インラインアクション |
| Medium | 44px | 14px 20px | 16px | 標準ボタン |
| Large | 56px | 16px 24px | 18px | 主要アクション |

### スタイル

| スタイル | 説明 | 用途 |
|----------|------|------|
| **Primary** | 塗りつぶし（プライマリ色） | 主要アクション（保存、送信） |
| **Secondary** | アウトライン | 副次アクション（キャンセル） |
| **Tertiary** | テキストのみ | 補助アクション（詳細を見る） |
| **Destructive** | 赤色塗りつぶし | 削除、ログアウト |
| **Ghost** | 透明背景 | ナビゲーション |

---

## ビジュアル仕様

### Primary Button

```
┌─────────────────────────────────────┐
│                                     │
│           ボタンテキスト              │
│                                     │
└─────────────────────────────────────┘

背景: プライマリカラー（グラデーション可）
テキスト: 白（#FFFFFF）
角丸: 12px
影: 0 2px 8px rgba(0,0,0,0.15)
```

### Secondary Button

```
┌─────────────────────────────────────┐
│                                     │
│           ボタンテキスト              │
│                                     │
└─────────────────────────────────────┘

背景: 透明
ボーダー: 1.5px solid プライマリカラー
テキスト: プライマリカラー
角丸: 12px
```

### Tertiary Button

```
           ボタンテキスト

背景: なし
テキスト: プライマリカラー
下線: なし（ホバー時に表示）
```

---

## 状態

### 通常 (Default)

```
背景: プライマリカラー
不透明度: 100%
```

### ホバー (Hover) ※Web/iPad

```
背景: プライマリダーク
スケール: 1.02
```

### 押下 (Pressed)

```
背景: プライマリダーク
スケール: 0.98
不透明度: 90%
```

### 無効 (Disabled)

```
背景: #E0E0E0
テキスト: #999999
不透明度: 60%
操作: 不可
```

### ローディング (Loading)

```
テキスト: 非表示
スピナー: 中央に表示（白色）
操作: 不可
```

---

## アイコン対応

### アイコン位置

| 位置 | 説明 |
|------|------|
| Leading | テキストの左側 |
| Trailing | テキストの右側 |
| Only | アイコンのみ（テキストなし） |

### アイコンサイズ

| ボタンサイズ | アイコンサイズ | マージン |
|--------------|----------------|----------|
| Small | 16px | 6px |
| Medium | 20px | 8px |
| Large | 24px | 10px |

---

## アニメーション

### トランジション

```
duration: 150ms
easing: ease-out
properties: transform, background-color, opacity
```

### 押下時

```typescript
// React Native
transform: [{ scale: 0.98 }]
```

```swift
// SwiftUI
.scaleEffect(isPressed ? 0.98 : 1.0)
```

---

## Props / パラメータ

### TypeScript (React Native)

```typescript
interface ButtonProps {
  // 必須
  title: string;
  onPress: () => void;

  // オプション
  variant?: 'primary' | 'secondary' | 'tertiary' | 'destructive' | 'ghost';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;

  // アイコン
  icon?: React.ReactNode;
  iconPosition?: 'leading' | 'trailing';

  // スタイル
  style?: ViewStyle;
  textStyle?: TextStyle;
}
```

### Swift (SwiftUI)

```swift
struct AppButton: View {
    // 必須
    let title: String
    let action: () -> Void

    // オプション
    var variant: ButtonVariant = .primary
    var size: ButtonSize = .medium
    var isDisabled: Bool = false
    var isLoading: Bool = false
    var fullWidth: Bool = false

    // アイコン
    var icon: Image? = nil
    var iconPosition: IconPosition = .leading

    enum ButtonVariant {
        case primary, secondary, tertiary, destructive, ghost
    }

    enum ButtonSize {
        case small, medium, large
    }

    enum IconPosition {
        case leading, trailing
    }
}
```

---

## 実装例

### TypeScript (React Native)

```typescript
import React from 'react';
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
} from 'react-native';
import { Colors } from '@/constants/Colors';

interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'destructive';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
  style?: ViewStyle;
}

export function Button({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  disabled = false,
  loading = false,
  fullWidth = false,
  style,
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={isDisabled}
      activeOpacity={0.8}
      style={[
        styles.base,
        styles[variant],
        styles[size],
        fullWidth && styles.fullWidth,
        isDisabled && styles.disabled,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color="#FFFFFF" />
      ) : (
        <Text style={[styles.text, styles[`${variant}Text`], styles[`${size}Text`]]}>
          {title}
        </Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  base: {
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
  },

  // Variants
  primary: {
    backgroundColor: Colors.light.primary,
  },
  secondary: {
    backgroundColor: 'transparent',
    borderWidth: 1.5,
    borderColor: Colors.light.primary,
  },
  destructive: {
    backgroundColor: Colors.light.error,
  },

  // Sizes
  small: {
    height: 32,
    paddingHorizontal: 16,
  },
  medium: {
    height: 44,
    paddingHorizontal: 20,
  },
  large: {
    height: 56,
    paddingHorizontal: 24,
  },

  // Text
  text: {
    fontWeight: '600',
  },
  primaryText: {
    color: '#FFFFFF',
  },
  secondaryText: {
    color: Colors.light.primary,
  },
  destructiveText: {
    color: '#FFFFFF',
  },
  smallText: {
    fontSize: 14,
  },
  mediumText: {
    fontSize: 16,
  },
  largeText: {
    fontSize: 18,
  },

  // States
  disabled: {
    opacity: 0.6,
  },
  fullWidth: {
    width: '100%',
  },
});
```

### Swift (SwiftUI)

```swift
import SwiftUI

struct AppButton: View {
    let title: String
    let action: () -> Void

    var variant: Variant = .primary
    var size: Size = .medium
    var isDisabled: Bool = false
    var isLoading: Bool = false
    var fullWidth: Bool = false

    enum Variant {
        case primary, secondary, destructive
    }

    enum Size {
        case small, medium, large

        var height: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 16
            case .large: return 18
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                }
            }
            .frame(height: size.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, size.padding)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: variant == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return AppColors.primary
        case .secondary:
            return .clear
        case .destructive:
            return AppColors.error
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .destructive:
            return .white
        case .secondary:
            return AppColors.primary
        }
    }

    private var borderColor: Color {
        variant == .secondary ? AppColors.primary : .clear
    }
}

// プレビュー
#Preview {
    VStack(spacing: 16) {
        AppButton(title: "Primary", action: {})
        AppButton(title: "Secondary", action: {}, variant: .secondary)
        AppButton(title: "Destructive", action: {}, variant: .destructive)
        AppButton(title: "Loading", action: {}, isLoading: true)
        AppButton(title: "Disabled", action: {}, isDisabled: true)
        AppButton(title: "Full Width", action: {}, fullWidth: true)
    }
    .padding()
}
```

---

## アクセシビリティ

### 必須対応

- [ ] `accessibilityLabel` を設定
- [ ] `accessibilityHint` で動作を説明
- [ ] `accessibilityRole="button"` を設定
- [ ] 無効時は `accessibilityState={{ disabled: true }}`
- [ ] 最小タップ領域: 44x44px

### 実装例

```typescript
<TouchableOpacity
  accessibilityLabel={title}
  accessibilityHint={`${title}を実行します`}
  accessibilityRole="button"
  accessibilityState={{ disabled: isDisabled }}
  // ...
>
```

---

## チェックリスト

- [ ] 全サイズバリエーションを実装
- [ ] 全スタイルバリエーションを実装
- [ ] 無効状態を実装
- [ ] ローディング状態を実装
- [ ] アイコン対応
- [ ] アクセシビリティ対応
- [ ] ダークモード対応
- [ ] アニメーション対応
