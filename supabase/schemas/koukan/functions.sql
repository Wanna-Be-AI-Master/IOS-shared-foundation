-- ============================================
-- むすび (koukan-nikki-app) 専用スキーマ
-- 関数・プロシージャ
-- ============================================

-- ============================================
-- 招待コード生成
-- ============================================

CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    code TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..6 LOOP
        code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_invite_code IS '6桁の招待コードを生成';

-- ============================================
-- 日記帳に参加
-- ============================================

CREATE OR REPLACE FUNCTION join_diary(
    p_invite_code TEXT,
    p_user_id UUID
)
RETURNS UUID AS $$
DECLARE
    v_diary_id UUID;
    v_existing_member UUID;
BEGIN
    -- 招待コードから日記帳を検索
    SELECT id INTO v_diary_id
    FROM public.diaries
    WHERE invite_code = UPPER(p_invite_code);

    IF v_diary_id IS NULL THEN
        RAISE EXCEPTION '招待コードが無効です';
    END IF;

    -- 既に参加済みかチェック
    SELECT id INTO v_existing_member
    FROM public.diary_members
    WHERE diary_id = v_diary_id
    AND user_id = p_user_id;

    IF v_existing_member IS NOT NULL THEN
        RAISE EXCEPTION '既に参加しています';
    END IF;

    -- メンバーとして追加
    INSERT INTO public.diary_members (diary_id, user_id, role)
    VALUES (v_diary_id, p_user_id, 'member');

    RETURN v_diary_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION join_diary IS '招待コードで日記帳に参加';

-- ============================================
-- エントリを既読にする
-- ============================================

CREATE OR REPLACE FUNCTION mark_as_read(
    p_entry_id UUID,
    p_user_id UUID
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.entry_reads (entry_id, user_id)
    VALUES (p_entry_id, p_user_id)
    ON CONFLICT (entry_id, user_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION mark_as_read IS 'エントリを既読にする';

-- ============================================
-- 日記帳の未読数を取得
-- ============================================

CREATE OR REPLACE FUNCTION get_unread_count(
    p_diary_id UUID,
    p_user_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    unread INTEGER;
BEGIN
    SELECT COUNT(*) INTO unread
    FROM public.entries e
    WHERE e.diary_id = p_diary_id
    AND e.user_id != p_user_id
    AND NOT EXISTS (
        SELECT 1 FROM public.entry_reads er
        WHERE er.entry_id = e.id
        AND er.user_id = p_user_id
    );

    RETURN unread;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_unread_count IS '日記帳の未読エントリ数を取得';

-- ============================================
-- ユーザーの全日記帳の未読数を取得
-- ============================================

CREATE OR REPLACE FUNCTION get_all_unread_counts(p_user_id UUID)
RETURNS TABLE (
    diary_id UUID,
    unread_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dm.diary_id,
        get_unread_count(dm.diary_id, p_user_id) AS unread_count
    FROM public.diary_members dm
    WHERE dm.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_all_unread_counts IS 'ユーザーの全日記帳の未読数を取得';

-- ============================================
-- 日記帳の最新エントリを取得
-- ============================================

CREATE OR REPLACE FUNCTION get_latest_entry(p_diary_id UUID)
RETURNS public.entries AS $$
DECLARE
    latest public.entries;
BEGIN
    SELECT * INTO latest
    FROM public.entries
    WHERE diary_id = p_diary_id
    ORDER BY created_at DESC
    LIMIT 1;

    RETURN latest;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_latest_entry IS '日記帳の最新エントリを取得';

-- ============================================
-- 日記帳から退出
-- ============================================

CREATE OR REPLACE FUNCTION leave_diary(
    p_diary_id UUID,
    p_user_id UUID
)
RETURNS VOID AS $$
DECLARE
    v_role koukan_member_role;
    v_member_count INTEGER;
BEGIN
    -- ロールを確認
    SELECT role INTO v_role
    FROM public.diary_members
    WHERE diary_id = p_diary_id
    AND user_id = p_user_id;

    IF v_role IS NULL THEN
        RAISE EXCEPTION 'メンバーではありません';
    END IF;

    -- オーナーが退出する場合
    IF v_role = 'owner' THEN
        -- 他のメンバー数を確認
        SELECT COUNT(*) INTO v_member_count
        FROM public.diary_members
        WHERE diary_id = p_diary_id
        AND user_id != p_user_id;

        IF v_member_count > 0 THEN
            RAISE EXCEPTION 'オーナーは他のメンバーがいる間は退出できません。所有権を移譲してください。';
        ELSE
            -- 最後のメンバーの場合、日記帳も削除
            DELETE FROM public.diaries WHERE id = p_diary_id;
            RETURN;
        END IF;
    END IF;

    -- メンバーを削除
    DELETE FROM public.diary_members
    WHERE diary_id = p_diary_id
    AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION leave_diary IS '日記帳から退出';

-- ============================================
-- オーナー権限を移譲
-- ============================================

CREATE OR REPLACE FUNCTION transfer_ownership(
    p_diary_id UUID,
    p_current_owner_id UUID,
    p_new_owner_id UUID
)
RETURNS VOID AS $$
BEGIN
    -- 現在のオーナーか確認
    IF NOT EXISTS (
        SELECT 1 FROM public.diary_members
        WHERE diary_id = p_diary_id
        AND user_id = p_current_owner_id
        AND role = 'owner'
    ) THEN
        RAISE EXCEPTION 'オーナー権限がありません';
    END IF;

    -- 新しいオーナーがメンバーか確認
    IF NOT EXISTS (
        SELECT 1 FROM public.diary_members
        WHERE diary_id = p_diary_id
        AND user_id = p_new_owner_id
    ) THEN
        RAISE EXCEPTION '指定されたユーザーはメンバーではありません';
    END IF;

    -- 現在のオーナーをメンバーに変更
    UPDATE public.diary_members
    SET role = 'member'
    WHERE diary_id = p_diary_id
    AND user_id = p_current_owner_id;

    -- 新しいオーナーを設定
    UPDATE public.diary_members
    SET role = 'owner'
    WHERE diary_id = p_diary_id
    AND user_id = p_new_owner_id;

    -- diariesのcreated_byも更新
    UPDATE public.diaries
    SET created_by = p_new_owner_id
    WHERE id = p_diary_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION transfer_ownership IS 'オーナー権限を移譲';

-- ============================================
-- トリガー: エントリ追加時に日記帳のupdated_atを更新
-- ============================================

CREATE OR REPLACE FUNCTION update_diary_on_entry()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.diaries
    SET updated_at = NOW()
    WHERE id = NEW.diary_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_diary_after_entry
    AFTER INSERT ON public.entries
    FOR EACH ROW
    EXECUTE FUNCTION update_diary_on_entry();

COMMENT ON FUNCTION update_diary_on_entry IS 'エントリ追加時に日記帳のupdated_atを更新';

-- ============================================
-- ユーザー初期化（新規登録時）
-- ============================================

CREATE OR REPLACE FUNCTION initialize_koukan_user(
    p_user_id UUID,
    p_display_name TEXT,
    p_apple_id TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL
)
RETURNS public.users AS $$
DECLARE
    new_user public.users;
BEGIN
    INSERT INTO public.users (
        id,
        apple_id,
        email,
        display_name,
        settings
    ) VALUES (
        p_user_id,
        p_apple_id,
        p_email,
        p_display_name,
        '{
            "notification_new_entry": true,
            "notification_reminder": true,
            "reminder_time": "21:00"
        }'::jsonb
    )
    RETURNING * INTO new_user;

    RETURN new_user;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION initialize_koukan_user IS 'むすびアプリ用のユーザー初期化';
