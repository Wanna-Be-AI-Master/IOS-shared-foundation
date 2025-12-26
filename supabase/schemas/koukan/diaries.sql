-- ============================================
-- むすび (koukan-nikki-app) 専用スキーマ
-- 日記帳・メンバー・エントリテーブル
-- ============================================

-- ============================================
-- 列挙型定義
-- ============================================

-- 日記帳タイプ
CREATE TYPE koukan_diary_type AS ENUM (
    'couple',       -- カップル
    'family',       -- 家族
    'friends',      -- 友達
    'anonymous'     -- 匿名
);

-- メンバーロール
CREATE TYPE koukan_member_role AS ENUM (
    'owner',        -- オーナー（作成者）
    'member'        -- メンバー
);

-- ============================================
-- diariesテーブル（日記帳）
-- ============================================

CREATE TABLE IF NOT EXISTS public.diaries (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- 日記帳情報
    name TEXT NOT NULL,
    type koukan_diary_type NOT NULL,

    -- 招待コード
    invite_code TEXT NOT NULL UNIQUE,

    -- 作成者
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- 設定
    settings JSONB NOT NULL DEFAULT '{
        "notifications_enabled": true,
        "theme_name": null
    }'::jsonb,

    -- タイムスタンプ
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_diaries_invite_code ON public.diaries(invite_code);
CREATE INDEX IF NOT EXISTS idx_diaries_created_by ON public.diaries(created_by);
CREATE INDEX IF NOT EXISTS idx_diaries_updated_at ON public.diaries(updated_at);

-- updated_atの自動更新トリガー
CREATE TRIGGER update_diaries_updated_at
    BEFORE UPDATE ON public.diaries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLSを有効化
ALTER TABLE public.diaries ENABLE ROW LEVEL SECURITY;

-- コメント
COMMENT ON TABLE public.diaries IS '日記帳テーブル（むすび専用）';
COMMENT ON COLUMN public.diaries.id IS '日記帳ID';
COMMENT ON COLUMN public.diaries.name IS '日記帳名';
COMMENT ON COLUMN public.diaries.type IS '日記帳タイプ';
COMMENT ON COLUMN public.diaries.invite_code IS '招待コード';
COMMENT ON COLUMN public.diaries.created_by IS '作成者ID';
COMMENT ON COLUMN public.diaries.settings IS '設定（JSON）';

-- ============================================
-- diary_membersテーブル（日記帳メンバー）
-- ============================================

CREATE TABLE IF NOT EXISTS public.diary_members (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- リレーション
    diary_id UUID NOT NULL REFERENCES public.diaries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- ロール
    role koukan_member_role NOT NULL DEFAULT 'member',

    -- 参加日時
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- 重複参加防止
    UNIQUE(diary_id, user_id)
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_diary_members_diary_id ON public.diary_members(diary_id);
CREATE INDEX IF NOT EXISTS idx_diary_members_user_id ON public.diary_members(user_id);

-- RLSを有効化
ALTER TABLE public.diary_members ENABLE ROW LEVEL SECURITY;

-- コメント
COMMENT ON TABLE public.diary_members IS '日記帳メンバーテーブル';
COMMENT ON COLUMN public.diary_members.diary_id IS '日記帳ID';
COMMENT ON COLUMN public.diary_members.user_id IS 'ユーザーID';
COMMENT ON COLUMN public.diary_members.role IS 'ロール';
COMMENT ON COLUMN public.diary_members.joined_at IS '参加日時';

-- ============================================
-- entriesテーブル（日記エントリ）
-- ============================================

CREATE TABLE IF NOT EXISTS public.entries (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- リレーション
    diary_id UUID NOT NULL REFERENCES public.diaries(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

    -- コンテンツ
    content TEXT NOT NULL,
    question TEXT,
    images TEXT[] NOT NULL DEFAULT '{}',

    -- タイムスタンプ
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_entries_diary_id ON public.entries(diary_id);
CREATE INDEX IF NOT EXISTS idx_entries_user_id ON public.entries(user_id);
CREATE INDEX IF NOT EXISTS idx_entries_created_at ON public.entries(created_at);
CREATE INDEX IF NOT EXISTS idx_entries_diary_created ON public.entries(diary_id, created_at);

-- updated_atの自動更新トリガー
CREATE TRIGGER update_entries_updated_at
    BEFORE UPDATE ON public.entries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLSを有効化
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;

-- コメント
COMMENT ON TABLE public.entries IS '日記エントリテーブル';
COMMENT ON COLUMN public.entries.diary_id IS '日記帳ID';
COMMENT ON COLUMN public.entries.user_id IS '作成者ID';
COMMENT ON COLUMN public.entries.content IS '本文';
COMMENT ON COLUMN public.entries.question IS '質問（オプション）';
COMMENT ON COLUMN public.entries.images IS '画像URL配列';

-- ============================================
-- entry_readsテーブル（既読）
-- ============================================

CREATE TABLE IF NOT EXISTS public.entry_reads (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- リレーション
    entry_id UUID NOT NULL REFERENCES public.entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- 既読日時
    read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- 重複既読防止
    UNIQUE(entry_id, user_id)
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_entry_reads_entry_id ON public.entry_reads(entry_id);
CREATE INDEX IF NOT EXISTS idx_entry_reads_user_id ON public.entry_reads(user_id);

-- RLSを有効化
ALTER TABLE public.entry_reads ENABLE ROW LEVEL SECURITY;

-- コメント
COMMENT ON TABLE public.entry_reads IS '既読テーブル';
COMMENT ON COLUMN public.entry_reads.entry_id IS 'エントリID';
COMMENT ON COLUMN public.entry_reads.user_id IS 'ユーザーID';
COMMENT ON COLUMN public.entry_reads.read_at IS '既読日時';

-- ============================================
-- RLSポリシー
-- ============================================

-- diaries: メンバーのみアクセス可能
CREATE POLICY "diaries_select_member" ON public.diaries
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.diary_members
            WHERE diary_members.diary_id = diaries.id
            AND diary_members.user_id = auth.uid()
        )
    );

CREATE POLICY "diaries_insert_authenticated" ON public.diaries
    FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "diaries_update_owner" ON public.diaries
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.diary_members
            WHERE diary_members.diary_id = diaries.id
            AND diary_members.user_id = auth.uid()
            AND diary_members.role = 'owner'
        )
    );

CREATE POLICY "diaries_delete_owner" ON public.diaries
    FOR DELETE
    USING (auth.uid() = created_by);

-- diary_members: メンバーのみ参照可能
CREATE POLICY "diary_members_select" ON public.diary_members
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.diary_members dm
            WHERE dm.diary_id = diary_members.diary_id
            AND dm.user_id = auth.uid()
        )
    );

CREATE POLICY "diary_members_insert" ON public.diary_members
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "diary_members_delete_self" ON public.diary_members
    FOR DELETE
    USING (auth.uid() = user_id);

-- entries: メンバーのみアクセス可能
CREATE POLICY "entries_select_member" ON public.entries
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.diary_members
            WHERE diary_members.diary_id = entries.diary_id
            AND diary_members.user_id = auth.uid()
        )
    );

CREATE POLICY "entries_insert_member" ON public.entries
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM public.diary_members
            WHERE diary_members.diary_id = entries.diary_id
            AND diary_members.user_id = auth.uid()
        )
    );

CREATE POLICY "entries_update_own" ON public.entries
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "entries_delete_own" ON public.entries
    FOR DELETE
    USING (auth.uid() = user_id);

-- entry_reads: 自分の既読のみ
CREATE POLICY "entry_reads_select_member" ON public.entry_reads
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.entries e
            JOIN public.diary_members dm ON dm.diary_id = e.diary_id
            WHERE e.id = entry_reads.entry_id
            AND dm.user_id = auth.uid()
        )
    );

CREATE POLICY "entry_reads_insert_own" ON public.entry_reads
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);
