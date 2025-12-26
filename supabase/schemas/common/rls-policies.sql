-- ============================================
-- 共通 RLS ポリシーテンプレート
-- Row Level Security の標準パターン
-- ============================================

-- ============================================
-- パターン1: 自分のデータのみアクセス可能
-- 用途: users, user_settings など個人データ
-- ============================================

/*
-- RLSを有効化
ALTER TABLE public.{table_name} ENABLE ROW LEVEL SECURITY;

-- 自分のデータのみ参照可能
CREATE POLICY "{table_name}_select_own" ON public.{table_name}
    FOR SELECT
    USING (auth.uid() = user_id);

-- 自分のデータのみ挿入可能
CREATE POLICY "{table_name}_insert_own" ON public.{table_name}
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 自分のデータのみ更新可能
CREATE POLICY "{table_name}_update_own" ON public.{table_name}
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 自分のデータのみ削除可能
CREATE POLICY "{table_name}_delete_own" ON public.{table_name}
    FOR DELETE
    USING (auth.uid() = user_id);
*/

-- ============================================
-- パターン2: グループメンバーがアクセス可能
-- 用途: diaries, entries など共有データ
-- ============================================

/*
-- 前提: diary_membersテーブルでメンバー管理

-- メンバーのみ参照可能
CREATE POLICY "{table_name}_select_member" ON public.{table_name}
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.diary_members
            WHERE diary_members.diary_id = {table_name}.diary_id
            AND diary_members.user_id = auth.uid()
        )
    );

-- 作成者のみ削除可能
CREATE POLICY "{table_name}_delete_owner" ON public.{table_name}
    FOR DELETE
    USING (user_id = auth.uid());
*/

-- ============================================
-- パターン3: 作成者 + 管理者がアクセス可能
-- 用途: プレミアム機能、管理系データ
-- ============================================

/*
-- 自分または管理者が参照可能
CREATE POLICY "{table_name}_select_admin" ON public.{table_name}
    FOR SELECT
    USING (
        auth.uid() = user_id
        OR
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND users.role = 'admin'
        )
    );
*/

-- ============================================
-- パターン4: 公開 + 非公開の混合
-- 用途: 一部公開可能なコンテンツ
-- ============================================

/*
-- 公開データまたは自分のデータを参照可能
CREATE POLICY "{table_name}_select_public" ON public.{table_name}
    FOR SELECT
    USING (
        is_public = true
        OR
        auth.uid() = user_id
    );
*/

-- ============================================
-- ヘルパー関数
-- ============================================

-- ユーザーがグループのメンバーかチェック
CREATE OR REPLACE FUNCTION is_group_member(p_group_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.diary_members
        WHERE diary_id = p_group_id
        AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ユーザーがグループのオーナーかチェック
CREATE OR REPLACE FUNCTION is_group_owner(p_group_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.diary_members
        WHERE diary_id = p_group_id
        AND user_id = auth.uid()
        AND role = 'owner'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ユーザーがプレミアム会員かチェック
CREATE OR REPLACE FUNCTION is_premium_user()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users
        WHERE id = auth.uid()
        AND is_premium = true
        AND (premium_expires_at IS NULL OR premium_expires_at > NOW())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- セキュリティのベストプラクティス
-- ============================================

/*
1. 常にRLSを有効化する
   ALTER TABLE public.{table_name} ENABLE ROW LEVEL SECURITY;

2. すべての操作にポリシーを定義する
   - SELECT, INSERT, UPDATE, DELETE すべてに明示的なポリシー

3. SECURITY DEFINER関数は最小限に
   - 必要な場合のみ使用
   - 権限を絞る

4. auth.uid()を活用
   - 現在の認証ユーザーのUUIDを取得
   - 信頼できる値

5. JOINを避けてサブクエリを使用
   - パフォーマンス向上
   - セキュリティ強化

6. インデックスを適切に設定
   - RLSクエリで使用するカラムにインデックス
   - 例: user_id, diary_id など
*/

-- ============================================
-- コメント
-- ============================================
COMMENT ON FUNCTION is_group_member IS 'ユーザーがグループのメンバーかチェック';
COMMENT ON FUNCTION is_group_owner IS 'ユーザーがグループのオーナーかチェック';
COMMENT ON FUNCTION is_premium_user IS 'ユーザーがプレミアム会員かチェック';
