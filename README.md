# shared-foundation

**かろやか** と **むすび** アプリの共通基盤プロジェクト

## 概要

2つのiOS/モバイルアプリケーションで共有する設計パターン、規約、テンプレートを管理するリポジトリ。

| アプリ | 説明 | 場所 |
|--------|------|------|
| かろやか (katazuke-app) | 片付けトラッカー | `../katazuke-app` |
| むすび (koukan-nikki-app) | 交換日記アプリ | `../koukan-nikki-app` |

## 目的

- アーキテクチャパターンの統一 (Clean Architecture + MVVM)
- コーディング規約の共有
- Supabaseスキーマ設計の共通化
- 認証フローの標準化
- UIデザインシステムの統一

## 構成

```
shared-foundation/
├── docs/          # ドキュメント・ガイド
├── supabase/      # Supabase共通スキーマ
├── templates/     # 設定テンプレート
└── design/        # デザインシステム
```

## 詳細計画

[PLAN.md](./PLAN.md) を参照
