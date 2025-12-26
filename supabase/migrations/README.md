# Supabase マイグレーションガイド

## 概要

このディレクトリはSupabaseデータベースマイグレーションを管理する。

---

## ディレクトリ構造

```
supabase/
├── schemas/
│   ├── common/                 # 共通スキーマ
│   │   ├── users.sql          # ユーザーテーブル
│   │   └── rls-policies.sql   # RLSポリシーテンプレート
│   │
│   ├── katazuke/              # かろやか専用
│   │   ├── records.sql        # 片付け記録テーブル
│   │   ├── badges.sql         # バッジテーブル
│   │   └── users-extension.sql # ユーザー拡張
│   │
│   └── koukan/                # むすび専用
│       ├── diaries.sql        # 日記帳テーブル
│       └── functions.sql      # 関数・プロシージャ
│
└── migrations/
    └── README.md              # 本ファイル
```

---

## マイグレーション命名規則

```
YYYYMMDDHHMMSS_description.sql
```

### 例

```
20241226100000_create_users_table.sql
20241226100100_create_records_table.sql
20241226100200_add_streak_count_to_users.sql
```

---

## 実行順序

### 新規プロジェクト

1. **共通スキーマ**（必須）
   ```bash
   # 1. ユーザーテーブル
   psql -f schemas/common/users.sql

   # 2. RLSヘルパー関数
   psql -f schemas/common/rls-policies.sql
   ```

2. **アプリ固有スキーマ**

   **かろやか (katazuke-app):**
   ```bash
   psql -f schemas/katazuke/users-extension.sql
   psql -f schemas/katazuke/records.sql
   psql -f schemas/katazuke/badges.sql
   ```

   **むすび (koukan-nikki-app):**
   ```bash
   psql -f schemas/koukan/diaries.sql
   psql -f schemas/koukan/functions.sql
   ```

---

## Supabase CLI を使用する場合

### プロジェクト初期化

```bash
# Supabase CLIインストール
npm install -g supabase

# プロジェクト初期化
supabase init

# ローカル開発環境起動
supabase start
```

### マイグレーション作成

```bash
# 新しいマイグレーション作成
supabase migration new create_users_table

# マイグレーション適用
supabase db push
```

### リモートDBと同期

```bash
# リモートからスキーマを取得
supabase db pull

# リモートにプッシュ
supabase db push
```

---

## テーブル一覧

### 共通テーブル

| テーブル | 説明 | 用途 |
|----------|------|------|
| `users` | ユーザー情報 | 両アプリ共通 |

### かろやか専用

| テーブル | 説明 |
|----------|------|
| `records` | 片付け記録 |
| `badges` | 獲得バッジ |
| `badge_definitions` | バッジ定義マスター |

### むすび専用

| テーブル | 説明 |
|----------|------|
| `diaries` | 日記帳 |
| `diary_members` | 日記帳メンバー |
| `entries` | 日記エントリ |
| `entry_reads` | 既読情報 |

---

## RLSポリシー一覧

### 共通パターン

| パターン | 用途 |
|----------|------|
| `*_select_own` | 自分のデータのみ参照可能 |
| `*_insert_own` | 自分のデータのみ挿入可能 |
| `*_update_own` | 自分のデータのみ更新可能 |
| `*_delete_own` | 自分のデータのみ削除可能 |

### グループアクセス

| パターン | 用途 |
|----------|------|
| `*_select_member` | グループメンバーのみ参照可能 |
| `*_insert_member` | グループメンバーのみ挿入可能 |
| `*_update_owner` | オーナーのみ更新可能 |
| `*_delete_owner` | オーナーのみ削除可能 |

---

## 関数一覧

### 共通関数

| 関数 | 説明 |
|------|------|
| `update_updated_at_column()` | updated_atの自動更新トリガー |
| `is_group_member(group_id)` | グループメンバーかチェック |
| `is_group_owner(group_id)` | グループオーナーかチェック |
| `is_premium_user()` | プレミアム会員かチェック |

### かろやか専用

| 関数 | 説明 |
|------|------|
| `get_streak_count(user_id)` | 連続記録日数を計算 |
| `check_count_badges(user_id)` | 累計数バッジをチェック |
| `check_streak_badges(user_id)` | 連続日数バッジをチェック |
| `award_badge(user_id, badge_type)` | バッジを付与 |
| `initialize_katazuke_user(user_id, display_name)` | ユーザー初期化 |

### むすび専用

| 関数 | 説明 |
|------|------|
| `generate_invite_code()` | 招待コード生成 |
| `join_diary(invite_code, user_id)` | 日記帳に参加 |
| `mark_as_read(entry_id, user_id)` | エントリを既読にする |
| `get_unread_count(diary_id, user_id)` | 未読数を取得 |
| `leave_diary(diary_id, user_id)` | 日記帳から退出 |
| `transfer_ownership(diary_id, current_owner_id, new_owner_id)` | オーナー権限移譲 |
| `initialize_koukan_user(user_id, display_name, apple_id, email)` | ユーザー初期化 |

---

## ストレージバケット

### かろやか

| バケット | 用途 |
|----------|------|
| `record-images` | 片付け記録の画像 |
| `profile-images` | プロフィール画像 |

### むすび

| バケット | 用途 |
|----------|------|
| `diary-images` | 日記エントリの画像 |
| `profile-images` | プロフィール画像（共通） |

---

## Realtime設定

### むすび（リアルタイム通知）

```sql
-- entriesテーブルのリアルタイムを有効化
ALTER PUBLICATION supabase_realtime ADD TABLE entries;
ALTER PUBLICATION supabase_realtime ADD TABLE entry_reads;
```

### かろやか

リアルタイム通知は不要（個人用アプリ）

---

## トラブルシューティング

### RLSエラー

```
new row violates row-level security policy
```

→ ポリシーの条件を確認。`auth.uid()`が正しく設定されているか。

### 外部キーエラー

```
foreign key constraint violation
```

→ 参照先テーブルにデータが存在するか確認。

### マイグレーション競合

```
migration already applied
```

→ `supabase migration repair` でステータスをリセット。

---

## 環境別設定

### 開発環境

```bash
# .env.local
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 本番環境

```bash
# .env.production
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## チェックリスト

### マイグレーション前

- [ ] 開発環境でテスト済み
- [ ] RLSポリシーが正しく設定されている
- [ ] インデックスが適切に設定されている
- [ ] バックアップを取得

### マイグレーション後

- [ ] テーブルが正しく作成されている
- [ ] RLSが有効になっている
- [ ] 関数が正しく動作する
- [ ] クライアントからアクセス可能
