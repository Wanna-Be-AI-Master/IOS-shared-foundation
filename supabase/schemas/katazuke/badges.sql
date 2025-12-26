-- ============================================
-- かろやか (katazuke-app) 専用スキーマ
-- バッジテーブル
-- ============================================

-- ============================================
-- 列挙型定義
-- ============================================

-- バッジの種類
CREATE TYPE katazuke_badge_type AS ENUM (
    -- 連続記録バッジ
    'first_step',           -- 初めての一歩
    'week_streak',          -- 1週間連続
    'two_week_streak',      -- 2週間連続
    'month_streak',         -- 1ヶ月連続
    'hundred_day_streak',   -- 100日連続

    -- 累計数バッジ
    'ten_items',            -- 10個達成
    'fifty_items',          -- 50個達成
    'hundred_items',        -- 100個達成
    'minimalist',           -- 365個達成
    'master',               -- 1000個達成

    -- カテゴリマスターバッジ
    'clothing_master',      -- 衣類整理の達人
    'books_master',         -- 書籍整理の達人

    -- 特殊バッジ
    'eco_friendly',         -- エコフレンドリー
    'seller_pro'            -- 販売のプロ
);

-- バッジのレアリティ
CREATE TYPE katazuke_badge_rarity AS ENUM (
    'common',       -- コモン
    'uncommon',     -- アンコモン
    'rare',         -- レア
    'epic',         -- エピック
    'legendary'     -- レジェンダリー
);

-- ============================================
-- badgesテーブル（獲得バッジ）
-- ============================================

CREATE TABLE IF NOT EXISTS public.badges (
    -- 主キー
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- ユーザーID
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

    -- バッジ情報
    badge_type katazuke_badge_type NOT NULL,

    -- 獲得日時
    earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- 重複獲得防止
    UNIQUE(user_id, badge_type)
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_badges_user_id ON public.badges(user_id);
CREATE INDEX IF NOT EXISTS idx_badges_badge_type ON public.badges(badge_type);
CREATE INDEX IF NOT EXISTS idx_badges_earned_at ON public.badges(earned_at);

-- RLSを有効化
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;

-- RLSポリシー（自分のデータのみアクセス可能）
CREATE POLICY "badges_select_own" ON public.badges
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "badges_insert_own" ON public.badges
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- バッジは削除不可（獲得後は永続）
-- DELETE ポリシーは作成しない

-- コメント
COMMENT ON TABLE public.badges IS 'バッジテーブル（かろやか専用）';
COMMENT ON COLUMN public.badges.id IS 'バッジID';
COMMENT ON COLUMN public.badges.user_id IS 'ユーザーID';
COMMENT ON COLUMN public.badges.badge_type IS 'バッジの種類';
COMMENT ON COLUMN public.badges.earned_at IS '獲得日時';

-- ============================================
-- バッジ定義テーブル（マスターデータ）
-- ============================================

CREATE TABLE IF NOT EXISTS public.badge_definitions (
    -- バッジタイプが主キー
    badge_type katazuke_badge_type PRIMARY KEY,

    -- 表示情報
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,

    -- レアリティ
    rarity katazuke_badge_rarity NOT NULL,

    -- 獲得条件
    condition_type TEXT NOT NULL,  -- 'streak', 'count', 'category', 'disposal'
    condition_value INTEGER NOT NULL
);

-- バッジ定義データを挿入
INSERT INTO public.badge_definitions (badge_type, display_name, description, icon, rarity, condition_type, condition_value) VALUES
    -- 連続記録バッジ
    ('first_step', 'はじめの一歩', '初めての片付け記録', '🌱', 'common', 'count', 1),
    ('week_streak', '1週間連続', '7日間連続で記録', '🔥', 'uncommon', 'streak', 7),
    ('two_week_streak', '2週間連続', '14日間連続で記録', '🔥', 'uncommon', 'streak', 14),
    ('month_streak', '1ヶ月連続', '30日間連続で記録', '⭐', 'rare', 'streak', 30),
    ('hundred_day_streak', '100日連続', '100日間連続で記録', '💫', 'epic', 'streak', 100),

    -- 累計数バッジ
    ('ten_items', '10個達成', '累計10個の物を手放した', '🎯', 'common', 'count', 10),
    ('fifty_items', '50個達成', '累計50個の物を手放した', '🎖️', 'uncommon', 'count', 50),
    ('hundred_items', '100個達成', '累計100個の物を手放した', '🏆', 'rare', 'count', 100),
    ('minimalist', 'ミニマリスト', '累計365個の物を手放した', '👑', 'epic', 'count', 365),
    ('master', '片付けマスター', '累計1000個の物を手放した', '🏅', 'legendary', 'count', 1000),

    -- カテゴリマスターバッジ
    ('clothing_master', '衣類整理の達人', '衣類を50個以上手放した', '👗', 'rare', 'category', 50),
    ('books_master', '書籍整理の達人', '本を50個以上手放した', '📖', 'rare', 'category', 50),

    -- 特殊バッジ
    ('eco_friendly', 'エコフレンドリー', 'リサイクルで10回以上処理', '🌍', 'rare', 'disposal', 10),
    ('seller_pro', '販売のプロ', '販売で10回以上処理', '💹', 'rare', 'disposal', 10)
ON CONFLICT (badge_type) DO NOTHING;

COMMENT ON TABLE public.badge_definitions IS 'バッジ定義マスターテーブル';

-- ============================================
-- 関数: バッジ獲得チェック
-- ============================================

-- 累計数でバッジチェック
CREATE OR REPLACE FUNCTION check_count_badges(p_user_id UUID)
RETURNS SETOF katazuke_badge_type AS $$
DECLARE
    total_count INTEGER;
    badge katazuke_badge_type;
BEGIN
    -- 総記録数を取得
    SELECT COUNT(*) INTO total_count
    FROM public.records
    WHERE user_id = p_user_id;

    -- 条件を満たすバッジを返す
    FOR badge IN
        SELECT bd.badge_type
        FROM public.badge_definitions bd
        WHERE bd.condition_type = 'count'
        AND bd.condition_value <= total_count
        AND NOT EXISTS (
            SELECT 1 FROM public.badges b
            WHERE b.user_id = p_user_id
            AND b.badge_type = bd.badge_type
        )
    LOOP
        RETURN NEXT badge;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 連続日数でバッジチェック
CREATE OR REPLACE FUNCTION check_streak_badges(p_user_id UUID)
RETURNS SETOF katazuke_badge_type AS $$
DECLARE
    streak_count INTEGER;
    badge katazuke_badge_type;
BEGIN
    -- 連続日数を取得
    SELECT get_streak_count(p_user_id) INTO streak_count;

    -- 条件を満たすバッジを返す
    FOR badge IN
        SELECT bd.badge_type
        FROM public.badge_definitions bd
        WHERE bd.condition_type = 'streak'
        AND bd.condition_value <= streak_count
        AND NOT EXISTS (
            SELECT 1 FROM public.badges b
            WHERE b.user_id = p_user_id
            AND b.badge_type = bd.badge_type
        )
    LOOP
        RETURN NEXT badge;
    END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- バッジを付与
CREATE OR REPLACE FUNCTION award_badge(p_user_id UUID, p_badge_type katazuke_badge_type)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO public.badges (user_id, badge_type)
    VALUES (p_user_id, p_badge_type)
    ON CONFLICT (user_id, badge_type) DO NOTHING;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION check_count_badges IS '累計数に基づく獲得可能バッジをチェック';
COMMENT ON FUNCTION check_streak_badges IS '連続日数に基づく獲得可能バッジをチェック';
COMMENT ON FUNCTION award_badge IS 'バッジを付与';

-- ============================================
-- トリガー: 記録追加時にバッジをチェック
-- ============================================

CREATE OR REPLACE FUNCTION trigger_check_badges()
RETURNS TRIGGER AS $$
DECLARE
    badge_to_award katazuke_badge_type;
BEGIN
    -- 累計数バッジをチェック
    FOR badge_to_award IN SELECT * FROM check_count_badges(NEW.user_id) LOOP
        PERFORM award_badge(NEW.user_id, badge_to_award);
    END LOOP;

    -- 連続日数バッジをチェック
    FOR badge_to_award IN SELECT * FROM check_streak_badges(NEW.user_id) LOOP
        PERFORM award_badge(NEW.user_id, badge_to_award);
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER check_badges_after_record
    AFTER INSERT ON public.records
    FOR EACH ROW
    EXECUTE FUNCTION trigger_check_badges();

COMMENT ON FUNCTION trigger_check_badges IS '記録追加時にバッジ獲得をチェックするトリガー関数';
