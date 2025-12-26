# 設定管理ガイド

## 概要

アプリケーションの設定管理に関する標準規約を定義する。

---

## ディレクトリ構造

```
project/
├── .env                    # ローカル環境変数（Git管理外）
├── .env.example            # 環境変数テンプレート
│
├── constants/              # TypeScript
│   ├── Config.ts          # アプリ設定
│   └── Colors.ts          # 色定義
│
└── Core/                   # Swift
    └── Constants/
        ├── AppConfig.swift    # アプリ設定
        ├── AppConstants.swift # 定数
        └── Colors.swift       # 色定義
```

---

## 環境変数管理

### 原則

1. **機密情報は環境変数で管理**
   - API キー、シークレット
   - データベース接続情報
   - 外部サービス認証情報

2. **.env ファイルはGit管理外**
   ```gitignore
   # .gitignore
   .env
   .env.local
   .env.*.local
   ```

3. **.env.example は必ずコミット**
   - プレースホルダー値で記述
   - 新規開発者が参照できるように

### TypeScript (Expo)

```typescript
// 環境変数の読み込み
export const SUPABASE_CONFIG = {
  url: process.env.EXPO_PUBLIC_SUPABASE_URL || '',
  anonKey: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || '',
};
```

**注意**: `EXPO_PUBLIC_` プレフィックスが必要

### Swift (iOS)

```swift
// Info.plist経由で読み込み
static var url: String {
    Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
}
```

**設定方法**:
1. xcconfig ファイルで環境変数を定義
2. Info.plist で `$(VARIABLE_NAME)` として参照

---

## 設定ファイル構成

### 必須セクション

| セクション | 説明 | 例 |
|------------|------|-----|
| `APP_INFO` | アプリ基本情報 | 名前、バージョン、Bundle ID |
| `SUPABASE_CONFIG` | Supabase接続情報 | URL、Anon Key |
| `LIMITS` | 制限値 | 無料/プレミアムの制限 |
| `STORAGE_KEYS` | ストレージキー | UserDefaultsのキー |
| `URLS` | 外部URL | プライバシーポリシー、利用規約 |

### オプションセクション

| セクション | 説明 | 必要な場合 |
|------------|------|-----------|
| `REVENUECAT_CONFIG` | 課金設定 | 課金機能がある場合 |
| `PRICING` | 価格設定 | 課金機能がある場合 |
| `FEATURES` | 機能フラグ | A/Bテストや段階リリース |
| `DIARY_TYPES` | ドメイン固有の定数 | アプリによる |

---

## 型安全性

### TypeScript

```typescript
// as const を使用して型を固定
export const LIMITS = {
  free: {
    maxItems: 10,
  },
  premium: {
    maxItems: -1,
  },
} as const;

// 型エクスポート
export type Limits = typeof LIMITS;
```

### Swift

```swift
// enumで名前空間を分離
enum Limits {
    enum Free {
        static let maxItems = 10
    }
    enum Premium {
        static let maxItems = Int.max
    }
}
```

---

## 環境別設定

### 開発 / ステージング / 本番

```
.env.development   # 開発環境
.env.staging       # ステージング環境
.env.production    # 本番環境
```

### TypeScript での切り替え

```typescript
// アプリ起動時に環境を判定
const ENV = process.env.EXPO_PUBLIC_APP_ENV || 'development';

export const API_URL = {
  development: 'http://localhost:3000',
  staging: 'https://staging-api.example.com',
  production: 'https://api.example.com',
}[ENV];
```

### Swift での切り替え

```swift
// ビルド設定で切り替え
#if DEBUG
let environment = "development"
#else
let environment = "production"
#endif
```

**xcconfig による方法**:
1. `Development.xcconfig` と `Production.xcconfig` を作成
2. Xcode のビルド設定で環境ごとに xcconfig を割り当て

---

## 機能フラグ

### 目的

- 段階的な機能リリース
- A/Bテスト
- 緊急時の機能無効化

### 実装例

```typescript
export const FEATURES = {
  premium: process.env.EXPO_PUBLIC_FEATURE_PREMIUM === 'true',
  pushNotifications: process.env.EXPO_PUBLIC_FEATURE_PUSH_NOTIFICATIONS === 'true',
  analytics: process.env.EXPO_PUBLIC_FEATURE_ANALYTICS === 'true',
} as const;

// 使用例
if (FEATURES.premium) {
  showPremiumFeatures();
}
```

---

## ストレージキー管理

### 原則

1. **一箇所で定義**
   - 重複を避ける
   - 変更時の影響範囲を限定

2. **命名規則**
   - camelCase を使用
   - 機能を明確に示す名前

### 例

```typescript
export const STORAGE_KEYS = {
  // 認証関連
  authToken: 'authToken',
  userId: 'userId',

  // 設定関連
  hasCompletedOnboarding: 'hasCompletedOnboarding',
  colorScheme: 'colorScheme',
  notificationSettings: 'notificationSettings',

  // キャッシュ関連
  lastSyncTime: 'lastSyncTime',
} as const;
```

---

## 制限値設計

### 無料/プレミアムの区別

```typescript
export const LIMITS = {
  free: {
    maxDiaries: 1,
    maxPhotosPerEntry: 1,
    maxRecordsPerMonth: 30,
  },
  premium: {
    maxDiaries: -1,          // 無制限
    maxPhotosPerEntry: 4,
    maxRecordsPerMonth: -1,  // 無制限
  },
} as const;
```

### 使用例

```typescript
function canCreateDiary(user: User, currentCount: number): boolean {
  const limit = user.isPremium
    ? LIMITS.premium.maxDiaries
    : LIMITS.free.maxDiaries;

  // -1 は無制限を意味する
  return limit === -1 || currentCount < limit;
}
```

---

## 価格設定

### 日本円での設定

```typescript
export const PRICING = {
  // 月額プラン
  monthlyPremium: 380,

  // 年額プラン（割引適用）
  yearlyPremium: 2980,

  // 割引率の計算
  get yearlyDiscount() {
    const monthlyTotal = this.monthlyPremium * 12;
    return Math.round((1 - this.yearlyPremium / monthlyTotal) * 100);
  },
} as const;
```

### App Store Connect との整合性

App Store の価格帯に合わせて設定:
- 380円 → Tier 4
- 2980円 → Tier 29

---

## URL管理

### 外部URLの一元管理

```typescript
export const URLS = {
  // 法的ドキュメント
  privacyPolicy: 'https://example.com/privacy',
  termsOfService: 'https://example.com/terms',

  // サポート
  support: 'https://example.com/support',
  faq: 'https://example.com/faq',

  // ストア
  appStore: 'https://apps.apple.com/app/example/id0000000000',
  playStore: 'https://play.google.com/store/apps/details?id=com.example.app',

  // ソーシャル
  twitter: 'https://twitter.com/example',
  instagram: 'https://instagram.com/example',
} as const;
```

---

## セキュリティ考慮事項

### 機密情報の取り扱い

| 情報 | 保存場所 | 備考 |
|------|----------|------|
| Supabase Anon Key | 環境変数 | クライアント公開可 |
| Supabase Service Key | サーバーのみ | 絶対に公開しない |
| RevenueCat API Key | 環境変数 | クライアント公開可 |
| ユーザートークン | SecureStore/Keychain | 暗号化ストレージ |

### やってはいけないこと

```typescript
// ❌ ハードコード
const API_KEY = 'sk_live_xxxxx';

// ❌ ログ出力
console.log('Token:', user.accessToken);

// ❌ 平文保存
AsyncStorage.setItem('token', accessToken);
```

### 正しい方法

```typescript
// ✅ 環境変数から読み込み
const API_KEY = process.env.EXPO_PUBLIC_API_KEY;

// ✅ シークレットはマスク
console.log('Token:', '***' + token.slice(-4));

// ✅ SecureStoreを使用
SecureStore.setItemAsync('token', accessToken);
```

---

## チェックリスト

### 新規プロジェクト

- [ ] `.env.example` を作成
- [ ] `.gitignore` に `.env` を追加
- [ ] `Config.ts` または `AppConfig.swift` を作成
- [ ] 環境変数の読み込みを実装
- [ ] 機密情報がハードコードされていないことを確認

### リリース前

- [ ] 本番環境の環境変数が設定されている
- [ ] テスト用の値が残っていないことを確認
- [ ] 機能フラグが適切に設定されている
- [ ] URL が本番環境を指している
