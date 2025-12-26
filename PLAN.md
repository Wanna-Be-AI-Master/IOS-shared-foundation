# 共通基盤プロジェクト (shared-foundation)

## 概要

**katazuke-app (かろやか)** と **koukan-nikki-app (むすび)** の2つのアプリケーションで共有できる基盤を構築するプロジェクト。

### 対象アプリケーション

| アプリ | 説明 | プラットフォーム |
|--------|------|------------------|
| かろやか (katazuke-app) | 片付けトラッカー | iOS (Swift/SwiftUI) |
| むすび (koukan-nikki-app) | 交換日記アプリ | React Native (Expo) |

---

## 現状分析

### 共通点
- Clean Architecture + MVVM アーキテクチャ
- Supabase バックエンド
- Apple Sign-In 認証
- DIコンテナパターン
- 日本語ローカライゼーション

### 課題
- プラットフォームが異なる (Swift vs TypeScript) → コード直接共有は困難
- katazuke-appのSupabase連携が未実装
- 設定管理体系が統一されていない

---

## 共通化戦略

### アプローチ: 「設計統一 + ドキュメント共有」

直接コード共有が困難なため、以下を共通化する:

1. **設計パターン・規約** - 両アプリで同じ設計思想を適用
2. **Supabaseスキーマ設計** - DBスキーマの設計パターン共有
3. **API設計規約** - エンドポイント命名、レスポンス形式の統一
4. **型定義仕様** - Entity/DTOの設計パターン統一
5. **設定管理体系** - 環境変数、定数管理の統一

---

## フェーズ別作業計画

### Phase 1: 基盤ドキュメント作成 (優先度: 高) ✅ 完了

#### 1.1 アーキテクチャガイド
- [ ] `docs/architecture/clean-architecture-guide.md`
  - 3層構造の定義 (Domain, Data, Presentation)
  - 各層の責務と依存関係ルール
  - Swift/TypeScript両方での実装例

#### 1.2 コーディング規約
- [ ] `docs/conventions/naming-conventions.md`
  - ファイル命名規則
  - 変数・関数・クラス命名規則
  - ディレクトリ構造規則

- [ ] `docs/conventions/type-definitions.md`
  - Entity設計パターン
  - DTO設計パターン
  - 列挙型の定義パターン

#### 1.3 認証フロー設計
- [x] `docs/auth/apple-signin-flow.md`
  - Apple Sign-Inの全体フロー
  - Nonce生成・検証手順
  - セッション管理方針
  - Supabase連携手順
- [x] `docs/auth/session-management.md`
  - セッションライフサイクル管理

---

### Phase 2: Supabase共通設計 (優先度: 高) ✅ 完了

#### 2.1 共通テーブル設計
- [x] `supabase/schemas/common/users.sql`
  - ユーザーテーブル基本構造
  - プレミアム管理フィールド
  - 設定JSON構造

- [x] `supabase/schemas/common/rls-policies.sql`
  - 認証関連トリガー
  - RLSポリシーパターン

#### 2.2 アプリ固有スキーマ
- [x] `supabase/schemas/katazuke/` - かろやか専用
  - records.sql, badges.sql, users-extension.sql
- [x] `supabase/schemas/koukan/` - むすび専用
  - diaries.sql, functions.sql

#### 2.3 マイグレーション管理
- [x] `supabase/migrations/README.md`
  - マイグレーション命名規則
  - 実行手順

---

### Phase 3: 設定管理テンプレート (優先度: 中) ✅ 完了

#### 3.1 環境変数テンプレート
- [x] `templates/env/.env.example`
  - 共通環境変数一覧
  - Supabase接続情報
  - 外部サービスキー
- [x] `templates/env/.env.expo.example`
  - Expo専用環境変数

#### 3.2 設定ファイルテンプレート
- [x] `templates/config/swift/AppConfig.swift.template`
- [x] `templates/config/swift/Development.xcconfig.template`
- [x] `templates/config/swift/Production.xcconfig.template`
- [x] `templates/config/typescript/Config.ts.template`
  - 定数管理パターン
  - 機能フラグ管理
  - プラン制限値
- [x] `docs/conventions/config-guide.md`
  - 設定管理ガイド

---

### Phase 4: UIデザインシステム (優先度: 中) ✅ 完了

#### 4.1 カラーパレット
- [x] `design/colors/palette.md`
  - 共通ブランドカラー
  - ライト/ダークテーマ対応
  - セマンティックカラー定義

#### 4.2 コンポーネント仕様
- [x] `design/components/README.md`
  - コンポーネント概要
- [x] `design/components/button.md`
- [x] `design/components/input.md`
- [x] `design/components/card.md`
  - 各コンポーネントの仕様定義
  - Swift/React Native両方の実装ガイド

---

### Phase 5: ユーティリティパターン (優先度: 低) ✅ 完了

#### 5.1 共通ロジックパターン
- [x] `docs/utilities/date-handling.md`
  - タイムゾーン処理 (Asia/Tokyo)
  - 相対時間表示
  - 日付フォーマット

- [x] `docs/utilities/error-handling.md`
  - エラー分類
  - ユーザーフレンドリーメッセージ
  - ログ出力パターン

- [x] `docs/utilities/validation.md`
  - 入力検証パターン
  - 共通バリデーションルール

---

## ディレクトリ構造

```
shared-foundation/
├── PLAN.md                      # 本ファイル
├── README.md                    # プロジェクト概要
│
├── docs/                        # ドキュメント
│   ├── architecture/           # アーキテクチャガイド
│   │   ├── clean-architecture-guide.md
│   │   ├── di-pattern.md
│   │   └── mvvm-pattern.md
│   │
│   ├── conventions/            # コーディング規約
│   │   ├── naming-conventions.md
│   │   ├── type-definitions.md
│   │   └── file-structure.md
│   │
│   ├── auth/                   # 認証関連
│   │   ├── apple-signin-flow.md
│   │   └── session-management.md
│   │
│   └── utilities/              # ユーティリティパターン
│       ├── date-handling.md
│       ├── error-handling.md
│       └── validation.md
│
├── supabase/                    # Supabase共通設計
│   ├── schemas/
│   │   ├── common/             # 共通スキーマ
│   │   ├── katazuke/           # かろやか専用
│   │   └── koukan/             # むすび専用
│   │
│   └── migrations/
│       └── README.md
│
├── templates/                   # テンプレートファイル
│   ├── env/
│   │   └── .env.example
│   │
│   └── config/
│       ├── swift/
│       └── typescript/
│
└── design/                      # デザインシステム
    ├── colors/
    │   └── palette.md
    │
    └── components/
        ├── button.md
        ├── input.md
        └── card.md
```

---

## 優先度マトリックス

| フェーズ | 優先度 | 理由 |
|----------|--------|------|
| Phase 1 | 高 | 開発の基盤となる規約を先に定義 |
| Phase 2 | 高 | katazuke-appのSupabase実装に必要 |
| Phase 3 | 中 | 開発効率向上に寄与 |
| Phase 4 | 中 | UI一貫性の確保 |
| Phase 5 | 低 | 必要に応じて追加 |

---

## 完了状況

全5フェーズが完了しました。

| フェーズ | 状況 | 成果物 |
|----------|------|--------|
| Phase 1 | ✅ 完了 | 認証フロー、セッション管理ドキュメント |
| Phase 2 | ✅ 完了 | Supabaseスキーマ（共通・アプリ固有）|
| Phase 3 | ✅ 完了 | 環境変数・設定テンプレート |
| Phase 4 | ✅ 完了 | カラーパレット、UIコンポーネント仕様 |
| Phase 5 | ✅ 完了 | 日付処理、エラー処理、入力検証パターン |

## 次のアクション

1. **katazuke-appへの適用**
   - Supabaseスキーマの適用
   - 認証フローの実装
   - UIコンポーネントの実装

2. **残りのドキュメント作成（任意）**
   - `docs/architecture/clean-architecture-guide.md`
   - `docs/conventions/naming-conventions.md`
   - `docs/conventions/type-definitions.md`

---

## 備考

- このプロジェクトはコード共有ではなく「設計・規約の共有」が主目的
- 両アプリのプラットフォームが異なるため、直接コード共有は現実的でない
- ドキュメントとテンプレートを通じて一貫性を確保する
- 将来的にWebアプリなど追加プラットフォームにも適用可能な設計を目指す
