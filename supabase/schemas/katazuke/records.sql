-- ============================================
-- かろやか (katazuke-app) 専用スキーマ
-- 片付け記録テーブル
-- ============================================

-- ============================================
-- 列挙型定義
-- ============================================

-- カテゴリ（片付け対象の種類）
CREATE TYPE katazuke_category AS ENUM (
    'clothing',       -- 衣類
    'books',          -- 本・雑誌
    'miscellaneous',  -- 雑貨
    'electronics',    -- 家電
    'documents',      -- 書類
    'other'           -- その他
);

-- 手放した理由
CREATE TYPE katazuke_reason AS ENUM (
    'not_used',       -- 使わなくなった
    'duplicate',      -- 重複している
    'broken',         -- 壊れた
    'outdated',       -- 古くなった
    'space',          -- スペースを空けたい
    'lifestyle',      -- ライフスタイルの変化
    'other'           -- その他
);

-- 処理方法
CREATE TYPE katazuke_disposal_method AS ENUM (
    'discard',        -- 捨てる
    'sell',           -- 売る
    'donate',         -- 寄付する
    'give',           -- 譲る
    'recycle',        -- リサイクル
    'other'           -- その他
);

-- ============================================
-- recordsテーブル（片付け記録）
-- ============================================

CREATE TABLE IF NOT EXISTS public.records (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- ユーザーID
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- 片付け情報
    category katazuke_category NOT NULL,
    reason katazuke_reason NOT NULL,
    disposal_method katazuke_disposal_method NOT NULL,

    -- 詳細情報
    memo TEXT,
    image_url TEXT,

    -- 日時
    recorded_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_records_user_id ON public.records(user_id);
CREATE INDEX IF NOT EXISTS idx_records_recorded_at ON public.records(recorded_at);
CREATE INDEX IF NOT EXISTS idx_records_category ON public.records(category);
CREATE INDEX IF NOT EXISTS idx_records_user_recorded ON public.records(user_id, recorded_at);

-- RLSを有効化
ALTER TABLE public.records ENABLE ROW LEVEL SECURITY;

-- RLSポリシー（自分のデータのみアクセス可能）
CREATE POLICY "records_select_own" ON public.records
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "records_insert_own" ON public.records
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "records_update_own" ON public.records
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "records_delete_own" ON public.records
    FOR DELETE USING (auth.uid() = user_id);

-- コメント
COMMENT ON TABLE public.records IS '片付け記録テーブル（かろやか専用）';
COMMENT ON COLUMN public.records.id IS '記録ID';
COMMENT ON COLUMN public.records.user_id IS 'ユーザーID';
COMMENT ON COLUMN public.records.category IS 'カテゴリ';
COMMENT ON COLUMN public.records.reason IS '手放した理由';
COMMENT ON COLUMN public.records.disposal_method IS '処理方法';
COMMENT ON COLUMN public.records.memo IS 'メモ';
COMMENT ON COLUMN public.records.image_url IS '画像URL';
COMMENT ON COLUMN public.records.recorded_at IS '記録日';
COMMENT ON COLUMN public.records.created_at IS '作成日時';

-- ============================================
-- ビュー: 統計情報
-- ============================================

-- 月別統計ビュー
CREATE OR REPLACE VIEW public.records_monthly_stats AS
SELECT
    user_id,
    DATE_TRUNC('month', recorded_at) AS month,
    COUNT(*) AS total_count,
    COUNT(*) FILTER (WHERE category = 'clothing') AS clothing_count,
    COUNT(*) FILTER (WHERE category = 'books') AS books_count,
    COUNT(*) FILTER (WHERE category = 'miscellaneous') AS miscellaneous_count,
    COUNT(*) FILTER (WHERE category = 'electronics') AS electronics_count,
    COUNT(*) FILTER (WHERE category = 'documents') AS documents_count,
    COUNT(*) FILTER (WHERE category = 'other') AS other_count
FROM public.records
GROUP BY user_id, DATE_TRUNC('month', recorded_at);

-- カテゴリ別統計ビュー
CREATE OR REPLACE VIEW public.records_category_stats AS
SELECT
    user_id,
    category,
    COUNT(*) AS count,
    COUNT(*) FILTER (WHERE disposal_method = 'discard') AS discard_count,
    COUNT(*) FILTER (WHERE disposal_method = 'sell') AS sell_count,
    COUNT(*) FILTER (WHERE disposal_method = 'donate') AS donate_count,
    COUNT(*) FILTER (WHERE disposal_method = 'give') AS give_count,
    COUNT(*) FILTER (WHERE disposal_method = 'recycle') AS recycle_count
FROM public.records
GROUP BY user_id, category;

-- ============================================
-- 関数: 連続記録日数を計算
-- ============================================

CREATE OR REPLACE FUNCTION get_streak_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    streak INTEGER := 0;
    current_date DATE := CURRENT_DATE;
    check_date DATE;
    has_record BOOLEAN;
BEGIN
    -- 今日から遡って連続記録日数を計算
    check_date := current_date;

    LOOP
        SELECT EXISTS (
            SELECT 1 FROM public.records
            WHERE user_id = p_user_id
            AND recorded_at = check_date
        ) INTO has_record;

        IF has_record THEN
            streak := streak + 1;
            check_date := check_date - 1;
        ELSE
            -- 今日の記録がない場合、昨日から計算
            IF check_date = current_date THEN
                check_date := current_date - 1;
                CONTINUE;
            ELSE
                EXIT;
            END IF;
        END IF;
    END LOOP;

    RETURN streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_streak_count IS 'ユーザーの連続記録日数を計算';
