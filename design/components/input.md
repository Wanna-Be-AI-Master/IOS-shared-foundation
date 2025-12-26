# Input コンポーネント仕様

## 概要

テキスト入力フィールドの仕様を定義する。

---

## バリエーション

### タイプ

| タイプ | 説明 | 用途 |
|--------|------|------|
| **Text** | 標準テキスト入力 | 名前、メモ |
| **Email** | メール形式 | メールアドレス |
| **Password** | パスワード（マスク） | パスワード入力 |
| **Number** | 数値入力 | 数量、金額 |
| **Phone** | 電話番号 | 電話番号 |
| **Multiline** | 複数行テキスト | 長文入力 |

### サイズ

| サイズ | 高さ | フォントサイズ | 用途 |
|--------|------|----------------|------|
| Small | 40px | 14px | コンパクトなフォーム |
| Medium | 48px | 16px | 標準フォーム |
| Large | 56px | 18px | 重要な入力 |

---

## ビジュアル仕様

### 基本構造

```
┌─ ラベル（任意）─────────────────────┐
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🔍 プレースホルダー      ✕  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ヘルパーテキスト / エラーメッセージ  │
└─────────────────────────────────────┘
```

### 寸法

```
外側マージン: 0
内側パディング: 12px 16px
角丸: 12px
ボーダー幅: 1px（フォーカス時 2px）
```

### アイコン

| 位置 | サイズ | マージン |
|------|--------|----------|
| Leading（左） | 20px | 右 8px |
| Trailing（右） | 20px | 左 8px |

---

## 状態

### デフォルト (Default)

```
背景: #F5F5F5 (Light) / #2A2A2A (Dark)
ボーダー: なし or #E0E0E0
テキスト: プライマリテキスト色
プレースホルダー: セカンダリテキスト色
```

### フォーカス (Focused)

```
背景: #FFFFFF (Light) / #3A3A3A (Dark)
ボーダー: 2px solid プライマリカラー
シャドウ: 0 0 0 3px rgba(primary, 0.1)
```

### 入力済み (Filled)

```
背景: デフォルトと同じ
ボーダー: #E0E0E0
テキスト: プライマリテキスト色
```

### エラー (Error)

```
背景: rgba(error, 0.05)
ボーダー: 2px solid エラーカラー
ヘルパーテキスト: エラーカラー
アイコン: エラーアイコン（右側）
```

### 無効 (Disabled)

```
背景: #F0F0F0
ボーダー: #E0E0E0
テキスト: #999999
不透明度: 60%
操作: 不可
```

---

## ラベルとヘルパーテキスト

### ラベル

| 属性 | 値 |
|------|-----|
| 位置 | 入力フィールドの上 |
| フォントサイズ | 14px |
| フォントウェイト | 500 (Medium) |
| マージン下 | 6px |
| 色 | プライマリテキスト色 |

### 必須マーク

```
ラベル *

* は赤色（エラーカラー）
```

### ヘルパーテキスト

| 属性 | 値 |
|------|-----|
| 位置 | 入力フィールドの下 |
| フォントサイズ | 12px |
| マージン上 | 4px |
| 色 | セカンダリテキスト色（通常） / エラー色（エラー時） |

---

## 文字数カウンター

### 表示条件

- `maxLength` が設定されている場合
- 入力文字数が `maxLength * 0.8` を超えた場合（オプション）

### 表示形式

```
123 / 500

位置: 右下
フォントサイズ: 12px
色: セカンダリテキスト色
警告: 残り20%で警告色
```

---

## Props / パラメータ

### TypeScript (React Native)

```typescript
interface InputProps {
  // 値とハンドラー
  value: string;
  onChangeText: (text: string) => void;

  // ラベル・プレースホルダー
  label?: string;
  placeholder?: string;
  helperText?: string;

  // 入力タイプ
  type?: 'text' | 'email' | 'password' | 'number' | 'phone';
  keyboardType?: KeyboardTypeOptions;
  secureTextEntry?: boolean;
  multiline?: boolean;
  numberOfLines?: number;

  // 状態
  error?: string;
  disabled?: boolean;
  required?: boolean;

  // 制限
  maxLength?: number;
  showCharacterCount?: boolean;

  // アイコン
  leadingIcon?: React.ReactNode;
  trailingIcon?: React.ReactNode;
  onTrailingIconPress?: () => void;

  // その他
  autoFocus?: boolean;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  autoComplete?: string;
  returnKeyType?: ReturnKeyTypeOptions;
  onSubmitEditing?: () => void;

  // スタイル
  style?: ViewStyle;
  inputStyle?: TextStyle;
}
```

### Swift (SwiftUI)

```swift
struct AppTextField: View {
    // 値
    @Binding var text: String

    // ラベル・プレースホルダー
    var label: String? = nil
    var placeholder: String = ""
    var helperText: String? = nil

    // 状態
    var error: String? = nil
    var isDisabled: Bool = false
    var isRequired: Bool = false

    // 制限
    var maxLength: Int? = nil
    var showCharacterCount: Bool = false

    // アイコン
    var leadingIcon: Image? = nil
    var trailingIcon: Image? = nil
    var onTrailingIconTap: (() -> Void)? = nil

    // フォーカス
    @FocusState private var isFocused: Bool
}
```

---

## 実装例

### TypeScript (React Native)

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  ViewStyle,
} from 'react-native';
import { Colors } from '@/constants/Colors';

interface InputProps {
  value: string;
  onChangeText: (text: string) => void;
  label?: string;
  placeholder?: string;
  helperText?: string;
  error?: string;
  disabled?: boolean;
  required?: boolean;
  maxLength?: number;
  showCharacterCount?: boolean;
  secureTextEntry?: boolean;
  multiline?: boolean;
  numberOfLines?: number;
  style?: ViewStyle;
}

export function Input({
  value,
  onChangeText,
  label,
  placeholder,
  helperText,
  error,
  disabled = false,
  required = false,
  maxLength,
  showCharacterCount = false,
  secureTextEntry = false,
  multiline = false,
  numberOfLines = 1,
  style,
}: InputProps) {
  const [isFocused, setIsFocused] = useState(false);
  const hasError = !!error;

  return (
    <View style={[styles.container, style]}>
      {/* ラベル */}
      {label && (
        <Text style={styles.label}>
          {label}
          {required && <Text style={styles.required}> *</Text>}
        </Text>
      )}

      {/* 入力フィールド */}
      <View
        style={[
          styles.inputContainer,
          isFocused && styles.inputFocused,
          hasError && styles.inputError,
          disabled && styles.inputDisabled,
        ]}
      >
        <TextInput
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={Colors.light.textTertiary}
          editable={!disabled}
          secureTextEntry={secureTextEntry}
          multiline={multiline}
          numberOfLines={numberOfLines}
          maxLength={maxLength}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          style={[
            styles.input,
            multiline && styles.multilineInput,
            disabled && styles.disabledText,
          ]}
        />
      </View>

      {/* ヘルパーテキスト / エラー / 文字数 */}
      <View style={styles.footer}>
        {(error || helperText) && (
          <Text style={[styles.helperText, hasError && styles.errorText]}>
            {error || helperText}
          </Text>
        )}

        {showCharacterCount && maxLength && (
          <Text style={styles.characterCount}>
            {value.length} / {maxLength}
          </Text>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },

  label: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.light.text,
    marginBottom: 6,
  },

  required: {
    color: Colors.light.error,
  },

  inputContainer: {
    backgroundColor: Colors.light.backgroundSecondary,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'transparent',
  },

  inputFocused: {
    backgroundColor: Colors.light.background,
    borderWidth: 2,
    borderColor: Colors.light.primary,
  },

  inputError: {
    backgroundColor: 'rgba(244, 67, 54, 0.05)',
    borderWidth: 2,
    borderColor: Colors.light.error,
  },

  inputDisabled: {
    backgroundColor: '#F0F0F0',
    opacity: 0.6,
  },

  input: {
    height: 48,
    paddingHorizontal: 16,
    fontSize: 16,
    color: Colors.light.text,
  },

  multilineInput: {
    height: 'auto',
    minHeight: 100,
    paddingVertical: 12,
    textAlignVertical: 'top',
  },

  disabledText: {
    color: Colors.light.textTertiary,
  },

  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 4,
  },

  helperText: {
    fontSize: 12,
    color: Colors.light.textSecondary,
  },

  errorText: {
    color: Colors.light.error,
  },

  characterCount: {
    fontSize: 12,
    color: Colors.light.textSecondary,
  },
});
```

### Swift (SwiftUI)

```swift
import SwiftUI

struct AppTextField: View {
    @Binding var text: String

    var label: String? = nil
    var placeholder: String = ""
    var helperText: String? = nil
    var error: String? = nil
    var isDisabled: Bool = false
    var isRequired: Bool = false
    var maxLength: Int? = nil
    var showCharacterCount: Bool = false

    @FocusState private var isFocused: Bool

    private var hasError: Bool { error != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // ラベル
            if let label = label {
                HStack(spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)

                    if isRequired {
                        Text("*")
                            .foregroundColor(AppColors.error)
                    }
                }
            }

            // 入力フィールド
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .disabled(isDisabled)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: isFocused || hasError ? 2 : 0)
                )
                .onChange(of: text) { newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }

            // フッター
            HStack {
                // ヘルパーテキスト / エラー
                if let error = error {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.error)
                } else if let helperText = helperText {
                    Text(helperText)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // 文字数カウンター
                if showCharacterCount, let maxLength = maxLength {
                    Text("\(text.count) / \(maxLength)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return Color(hex: "F0F0F0")
        } else if hasError {
            return Color(hex: "F44336").opacity(0.05)
        } else if isFocused {
            return AppColors.background
        } else {
            return AppColors.secondaryBackground
        }
    }

    private var borderColor: Color {
        if hasError {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return .clear
        }
    }
}

// プレビュー
#Preview {
    VStack(spacing: 20) {
        AppTextField(
            text: .constant(""),
            label: "名前",
            placeholder: "名前を入力",
            isRequired: true
        )

        AppTextField(
            text: .constant("入力済みテキスト"),
            label: "メモ",
            placeholder: "メモを入力",
            helperText: "任意項目です"
        )

        AppTextField(
            text: .constant("エラーあり"),
            label: "メールアドレス",
            placeholder: "example@email.com",
            error: "正しいメールアドレスを入力してください"
        )

        AppTextField(
            text: .constant("Hello"),
            label: "メッセージ",
            placeholder: "メッセージを入力",
            maxLength: 100,
            showCharacterCount: true
        )
    }
    .padding()
}
```

---

## アクセシビリティ

### 必須対応

- [ ] `accessibilityLabel` にラベルを設定
- [ ] エラー時は `accessibilityHint` でエラー内容を通知
- [ ] 必須フィールドは音声で伝える
- [ ] フォーカス順序を適切に設定

### VoiceOver対応

```swift
TextField(placeholder, text: $text)
    .accessibilityLabel(label ?? placeholder)
    .accessibilityHint(error ?? helperText ?? "")
    .accessibilityValue(text.isEmpty ? "空" : text)
```

---

## チェックリスト

- [ ] 全タイプ（text, email, password等）を実装
- [ ] ラベル・ヘルパーテキスト対応
- [ ] エラー状態を実装
- [ ] 無効状態を実装
- [ ] 文字数カウンター実装
- [ ] アイコン対応
- [ ] アクセシビリティ対応
- [ ] ダークモード対応
