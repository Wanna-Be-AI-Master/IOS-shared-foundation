/**
 * API関連の型定義
 * レスポンス、エラー、ページネーション
 */
// ========================================
// ユーティリティ関数
// ========================================
/**
 * 成功レスポンスを作成
 */
export function createSuccessResponse(data) {
    return { data, error: null };
}
/**
 * エラーレスポンスを作成
 */
export function createErrorResponse(code, message, details) {
    return {
        data: null,
        error: { code, message, details },
    };
}
/**
 * レスポンスが成功かどうかを判定
 */
export function isSuccess(response) {
    return response.data !== null && response.error === null;
}
/**
 * レスポンスがエラーかどうかを判定
 */
export function isError(response) {
    return response.error !== null;
}
//# sourceMappingURL=api.js.map