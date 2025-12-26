# 共通UIコンポーネントガイド

## 概要

両アプリで共通して使用するUIコンポーネントの設計ガイドライン。

---

## コンポーネント一覧

### 基本コンポーネント

| コンポーネント | 説明 | 仕様書 |
|----------------|------|--------|
| **Button** | ボタン | [button.md](./button.md) |
| **Input** | テキスト入力 | [input.md](./input.md) |
| **Card** | カード | [card.md](./card.md) |

### 追加コンポーネント（未実装）

| コンポーネント | 説明 | 優先度 |
|----------------|------|--------|
| Avatar | ユーザーアイコン | 高 |
| Badge | 通知バッジ | 高 |
| LoadingView | ローディング表示 | 高 |
| EmptyView | 空状態表示 | 中 |
| Modal | モーダル | 中 |
| Toast | トースト通知 | 中 |
| Selector | 選択コンポーネント | 中 |
| ProgressBar | 進捗バー | 低 |

---

## 設計原則

### 1. 一貫性 (Consistency)

- 同じ目的には同じコンポーネントを使用
- サイズ・間隔・色の統一
- インタラクションパターンの統一

### 2. アクセシビリティ (Accessibility)

- 最小タップ領域: 44x44px
- コントラスト比: WCAG 2.1 AA準拠
- VoiceOver / TalkBack対応
- ダイナミックタイプ対応

### 3. レスポンシブ (Responsive)

- 様々な画面サイズに対応
- iPad / タブレット対応
- 横向き / 縦向き対応

### 4. パフォーマンス (Performance)

- 軽量な実装
- 不要な再レンダリングを避ける
- アニメーションは60fps維持

---

## 共通スタイル

### 間隔 (Spacing)

| 名前 | 値 | 用途 |
|------|-----|------|
| `xxs` | 4px | 最小間隔 |
| `xs` | 8px | 密な間隔 |
| `sm` | 12px | 小さい間隔 |
| `md` | 16px | 標準間隔 |
| `lg` | 24px | 大きい間隔 |
| `xl` | 32px | セクション間 |
| `xxl` | 48px | ページ間 |

### 角丸 (Border Radius)

| 名前 | 値 | 用途 |
|------|-----|------|
| `xs` | 4px | 小さい要素 |
| `sm` | 8px | ボタン小 |
| `md` | 12px | カード、ボタン |
| `lg` | 16px | モーダル |
| `xl` | 24px | ボトムシート |
| `full` | 9999px | 円形 |

### フォントサイズ

| 名前 | サイズ | 用途 |
|------|--------|------|
| `xs` | 12px | キャプション |
| `sm` | 14px | ヘルパーテキスト |
| `md` | 16px | 本文 |
| `lg` | 18px | 見出し3 |
| `xl` | 20px | 見出し2 |
| `2xl` | 24px | 見出し1 |
| `3xl` | 32px | ページタイトル |

### フォントウェイト

| 名前 | 値 | 用途 |
|------|-----|------|
| Regular | 400 | 本文 |
| Medium | 500 | ラベル |
| SemiBold | 600 | ボタン、見出し |
| Bold | 700 | 強調 |

---

## アニメーション

### 標準トランジション

```typescript
// React Native
const ANIMATION_DURATION = 150; // ms
const ANIMATION_EASING = Easing.out(Easing.ease);
```

```swift
// SwiftUI
let animationDuration = 0.15
let animation = Animation.easeOut(duration: animationDuration)
```

### プレスフィードバック

```
スケール: 0.98
不透明度: 0.95
時間: 150ms
イージング: ease-out
```

### ページ遷移

```
時間: 300ms
イージング: ease-in-out
```

---

## コンポーネント構造

### ファイル構成

```
components/
├── ui/                     # 基本UIコンポーネント
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Card.tsx
│   ├── Avatar.tsx
│   ├── Badge.tsx
│   ├── LoadingView.tsx
│   ├── EmptyView.tsx
│   └── index.ts           # エクスポート
│
├── forms/                  # フォーム関連
│   ├── FormField.tsx
│   ├── Select.tsx
│   └── DatePicker.tsx
│
└── feedback/               # フィードバック
    ├── Modal.tsx
    ├── Toast.tsx
    └── Alert.tsx
```

### 命名規則

| 種類 | 規則 | 例 |
|------|------|-----|
| コンポーネント名 | PascalCase | `Button`, `CardHeader` |
| Props型 | コンポーネント名 + Props | `ButtonProps` |
| スタイル変数 | camelCase | `primaryButton` |
| バリアント | 小文字 | `primary`, `secondary` |

---

## Props設計ガイドライン

### 共通Props

```typescript
interface CommonProps {
  // スタイル
  style?: ViewStyle;
  className?: string;

  // テスト
  testID?: string;

  // アクセシビリティ
  accessibilityLabel?: string;
  accessibilityHint?: string;
}
```

### バリアントの設計

```typescript
// ❌ 悪い例: boolean複数
interface ButtonProps {
  isPrimary?: boolean;
  isSecondary?: boolean;
  isDestructive?: boolean;
}

// ✅ 良い例: union type
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'destructive';
}
```

### サイズの設計

```typescript
// ✅ 文字列で統一
type Size = 'small' | 'medium' | 'large';

// サイズに応じた値のマッピング
const sizeMap = {
  small: { height: 32, fontSize: 14 },
  medium: { height: 44, fontSize: 16 },
  large: { height: 56, fontSize: 18 },
};
```

---

## テーマ対応

### カラーの参照

```typescript
// ✅ テーマ変数を使用
import { useColorScheme } from 'react-native';
import { Colors } from '@/constants/Colors';

const colorScheme = useColorScheme();
const colors = Colors[colorScheme ?? 'light'];
```

```swift
// ✅ SwiftUIのシステムカラー
Color(uiColor: .systemBackground)
Color(uiColor: .label)

// または、Environment
@Environment(\.colorScheme) var colorScheme
```

### ダークモード切り替え

```typescript
// スタイル定義
const styles = StyleSheet.create({
  container: {
    backgroundColor: Colors.light.background, // デフォルト
  },
});

// 動的に適用
<View style={[styles.container, { backgroundColor: colors.background }]} />
```

---

## アクセシビリティチェックリスト

### 全コンポーネント共通

- [ ] `accessibilityLabel` 設定
- [ ] `accessibilityHint` 設定（必要な場合）
- [ ] `accessibilityRole` 設定
- [ ] 最小タップ領域 44x44px
- [ ] コントラスト比 4.5:1以上

### インタラクティブ要素

- [ ] `accessibilityState` で状態を通知
- [ ] 無効状態を適切に通知
- [ ] フォーカス順序が論理的

### テスト方法

1. VoiceOver/TalkBack でナビゲーション
2. フォントサイズ最大でテスト
3. コントラストチェッカーで検証
4. キーボード操作（iPad）

---

## パフォーマンス最適化

### React Native

```typescript
// メモ化
const MemoizedCard = React.memo(Card);

// コールバックのメモ化
const handlePress = useCallback(() => {
  // ...
}, [dependency]);

// 重い計算のメモ化
const computedValue = useMemo(() => {
  return expensiveCalculation(data);
}, [data]);
```

### SwiftUI

```swift
// @State は最小限に
@State private var isPressed = false  // ローカル状態のみ

// 重い計算は computed property を避ける
// 代わりに onChange で計算

// Equatable を適切に実装
struct CardItem: Equatable {
    let id: UUID
    let title: String
}
```

---

## 実装チェックリスト

### 新規コンポーネント作成時

- [ ] 仕様書を作成（このディレクトリに）
- [ ] TypeScript型定義
- [ ] 全バリアント実装
- [ ] 全状態（disabled, loading等）実装
- [ ] ダークモード対応
- [ ] アクセシビリティ対応
- [ ] アニメーション対応
- [ ] テスト作成
- [ ] Storybook / プレビュー作成

### コードレビュー観点

- [ ] 設計原則に従っているか
- [ ] Props設計が適切か
- [ ] パフォーマンス問題がないか
- [ ] アクセシビリティ対応しているか
- [ ] 既存コンポーネントと一貫性があるか
