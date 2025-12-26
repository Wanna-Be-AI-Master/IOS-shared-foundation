-- ============================================
-- 共通 users テーブル
-- 両アプリで共有するユーザー基本情報
-- ============================================

-- usersテーブル
CREATE TABLE IF NOT EXISTS public.users (
    -- 主キー（Supabase Auth UIDと同期）
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Apple認証情報
    apple_id TEXT UNIQUE,
    email TEXT,

    -- プロフィール
    display_name TEXT NOT NULL,
    profile_image_url TEXT,

    -- プレミアム情報
    is_premium BOOLEAN NOT NULL DEFAULT FALSE,
    premium_expires_at TIMESTAMPTZ,

    -- プッシュ通知
    push_token TEXT,

    -- アプリ固有の設定（JSONB）
    -- 各アプリで異なる設定を柔軟に保存
    settings JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- タイムスタンプ
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON public.users(apple_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_premium ON public.users(is_premium);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- updated_atの自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLSを有効化
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- RLSポリシー
-- 自分のデータのみ参照可能
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- 自分のデータのみ挿入可能
CREATE POLICY "users_insert_own" ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 自分のデータのみ更新可能
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- 自分のデータのみ削除可能
CREATE POLICY "users_delete_own" ON public.users
    FOR DELETE
    USING (auth.uid() = id);

-- ============================================
-- コメント
-- ============================================
COMMENT ON TABLE public.users IS 'ユーザー情報テーブル（共通）';
COMMENT ON COLUMN public.users.id IS 'ユーザーID（Supabase Auth UIDと同期）';
COMMENT ON COLUMN public.users.apple_id IS 'Apple User ID（Sign in with Apple）';
COMMENT ON COLUMN public.users.email IS 'メールアドレス';
COMMENT ON COLUMN public.users.display_name IS '表示名';
COMMENT ON COLUMN public.users.profile_image_url IS 'プロフィール画像URL';
COMMENT ON COLUMN public.users.is_premium IS 'プレミアム会員フラグ';
COMMENT ON COLUMN public.users.premium_expires_at IS 'プレミアム有効期限';
COMMENT ON COLUMN public.users.push_token IS 'プッシュ通知トークン';
COMMENT ON COLUMN public.users.settings IS 'アプリ固有の設定（JSON）';
COMMENT ON COLUMN public.users.created_at IS '作成日時';
COMMENT ON COLUMN public.users.updated_at IS '更新日時';
