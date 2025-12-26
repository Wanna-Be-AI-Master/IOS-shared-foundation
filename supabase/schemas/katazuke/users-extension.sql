-- ============================================
-- かろやか (katazuke-app) 専用
-- usersテーブルの拡張フィールド
-- ============================================

-- ============================================
-- usersテーブルに追加カラム
-- ============================================

-- 連続記録日数（キャッシュ用）
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS streak_count INTEGER NOT NULL DEFAULT 0;

-- 最後に記録した日付
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS last_record_date DATE;

-- インデックス
CREATE INDEX IF NOT EXISTS idx_users_streak_count ON public.users(streak_count);
CREATE INDEX IF NOT EXISTS idx_users_last_record_date ON public.users(last_record_date);

-- コメント
COMMENT ON COLUMN public.users.streak_count IS '連続記録日数（キャッシュ）';
COMMENT ON COLUMN public.users.last_record_date IS '最後に記録した日付';

-- ============================================
-- 設定JSONBのスキーマ定義（ドキュメント用）
-- ============================================

/*
かろやかアプリのsettings JSONBスキーマ:

{
  "notification_enabled": boolean,      // 通知有効フラグ
  "notification_hour": number,          // 通知時間（時）0-23
  "notification_minute": number,        // 通知時間（分）0-59
  "appearance_mode": string,            // 外観モード: "system" | "light" | "dark"
  "default_category": string | null     // デフォルトカテゴリ
}

デフォルト値:
{
  "notification_enabled": true,
  "notification_hour": 21,
  "notification_minute": 0,
  "appearance_mode": "system",
  "default_category": null
}
*/

-- ============================================
-- 関数: 記録追加時にユーザー統計を更新
-- ============================================

CREATE OR REPLACE FUNCTION update_user_stats_on_record()
RETURNS TRIGGER AS $$
DECLARE
    new_streak INTEGER;
BEGIN
    -- 連続日数を計算
    SELECT get_streak_count(NEW.user_id) INTO new_streak;

    -- ユーザーの統計を更新
    UPDATE public.users
    SET
        streak_count = new_streak,
        last_record_date = NEW.recorded_at,
        updated_at = NOW()
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガー
CREATE TRIGGER update_user_stats_after_record
    AFTER INSERT ON public.records
    FOR EACH ROW
    EXECUTE FUNCTION update_user_stats_on_record();

COMMENT ON FUNCTION update_user_stats_on_record IS '記録追加時にユーザー統計を更新';

-- ============================================
-- ビュー: ユーザーダッシュボード情報
-- ============================================

CREATE OR REPLACE VIEW public.user_dashboard AS
SELECT
    u.id,
    u.display_name,
    u.streak_count,
    u.last_record_date,
    u.is_premium,
    (SELECT COUNT(*) FROM public.records WHERE user_id = u.id) AS total_records,
    (SELECT COUNT(*) FROM public.records WHERE user_id = u.id AND recorded_at >= DATE_TRUNC('month', CURRENT_DATE)) AS this_month_records,
    (SELECT COUNT(*) FROM public.badges WHERE user_id = u.id) AS badge_count
FROM public.users u;

COMMENT ON VIEW public.user_dashboard IS 'ユーザーダッシュボード情報ビュー';

-- ============================================
-- 関数: ユーザー初期化（新規登録時）
-- ============================================

CREATE OR REPLACE FUNCTION initialize_katazuke_user(
    p_user_id UUID,
    p_display_name TEXT DEFAULT 'ゲスト'
)
RETURNS public.users AS $$
DECLARE
    new_user public.users;
BEGIN
    INSERT INTO public.users (
        id,
        display_name,
        streak_count,
        settings
    ) VALUES (
        p_user_id,
        p_display_name,
        0,
        '{
            "notification_enabled": true,
            "notification_hour": 21,
            "notification_minute": 0,
            "appearance_mode": "system",
            "default_category": null
        }'::jsonb
    )
    RETURNING * INTO new_user;

    RETURN new_user;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION initialize_katazuke_user IS 'かろやかアプリ用のユーザー初期化';
