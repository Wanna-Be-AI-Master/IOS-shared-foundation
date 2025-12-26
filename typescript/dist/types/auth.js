/**
 * 認証関連の型定義
 * Apple Sign-In、セッション管理
 */
// ========================================
// ユーティリティ関数
// ========================================
/**
 * セッションが有効かどうかを判定
 */
export function isSessionValid(session) {
    if (!session)
        return false;
    return session.expiresAt > new Date();
}
/**
 * Apple認証情報からフルネームを取得
 */
export function getFullNameFromCredential(credential) {
    if (!credential.fullName)
        return null;
    const { givenName, familyName } = credential.fullName;
    if (!givenName && !familyName)
        return null;
    return [familyName, givenName].filter(Boolean).join(' ');
}
//# sourceMappingURL=auth.js.map