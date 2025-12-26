/**
 * API関連の型定義
 * レスポンス、エラー、ページネーション
 */
/**
 * 標準APIレスポンス
 */
export interface ApiResponse<T> {
    /** レスポンスデータ */
    data: T | null;
    /** エラー情報 */
    error: ApiError | null;
}
/**
 * APIエラー
 */
export interface ApiError {
    /** エラーコード */
    code: string;
    /** ユーザー向けメッセージ */
    message: string;
    /** 追加情報 */
    details?: Record<string, unknown>;
}
/**
 * ページネーション付きレスポンス
 */
export interface PaginatedResponse<T> {
    /** データ配列 */
    data: T[];
    /** ページネーション情報 */
    pagination: PaginationInfo;
}
/**
 * ページネーション情報
 */
export interface PaginationInfo {
    /** 現在のページ */
    page: number;
    /** 1ページあたりの件数 */
    limit: number;
    /** 総件数 */
    total: number;
    /** 次のページがあるか */
    hasMore: boolean;
}
/**
 * 共通エラーコード
 */
export type ErrorCode = 'NET_TIMEOUT' | 'NET_OFFLINE' | 'NET_UNKNOWN' | 'API_NOT_FOUND' | 'API_FORBIDDEN' | 'API_CONFLICT' | 'API_SERVER_ERROR' | 'VAL_REQUIRED_FIELD' | 'VAL_INVALID_FORMAT' | 'VAL_TOO_SHORT' | 'VAL_TOO_LONG';
/**
 * 成功レスポンスを作成
 */
export declare function createSuccessResponse<T>(data: T): ApiResponse<T>;
/**
 * エラーレスポンスを作成
 */
export declare function createErrorResponse<T>(code: string, message: string, details?: Record<string, unknown>): ApiResponse<T>;
/**
 * レスポンスが成功かどうかを判定
 */
export declare function isSuccess<T>(response: ApiResponse<T>): response is ApiResponse<T> & {
    data: T;
};
/**
 * レスポンスがエラーかどうかを判定
 */
export declare function isError<T>(response: ApiResponse<T>): response is ApiResponse<T> & {
    error: ApiError;
};
//# sourceMappingURL=api.d.ts.map