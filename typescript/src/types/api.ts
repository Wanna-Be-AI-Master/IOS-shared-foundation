/**
 * API関連の型定義
 * レスポンス、エラー、ページネーション
 */

// ========================================
// APIレスポンス
// ========================================

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

// ========================================
// エラーコード
// ========================================

/**
 * 共通エラーコード
 */
export type ErrorCode =
  // ネットワークエラー
  | 'NET_TIMEOUT'
  | 'NET_OFFLINE'
  | 'NET_UNKNOWN'
  // APIエラー
  | 'API_NOT_FOUND'
  | 'API_FORBIDDEN'
  | 'API_CONFLICT'
  | 'API_SERVER_ERROR'
  // バリデーションエラー
  | 'VAL_REQUIRED_FIELD'
  | 'VAL_INVALID_FORMAT'
  | 'VAL_TOO_SHORT'
  | 'VAL_TOO_LONG';

// ========================================
// ユーティリティ関数
// ========================================

/**
 * 成功レスポンスを作成
 */
export function createSuccessResponse<T>(data: T): ApiResponse<T> {
  return { data, error: null };
}

/**
 * エラーレスポンスを作成
 */
export function createErrorResponse<T>(
  code: string,
  message: string,
  details?: Record<string, unknown>
): ApiResponse<T> {
  return {
    data: null,
    error: { code, message, details },
  };
}

/**
 * レスポンスが成功かどうかを判定
 */
export function isSuccess<T>(response: ApiResponse<T>): response is ApiResponse<T> & { data: T } {
  return response.data !== null && response.error === null;
}

/**
 * レスポンスがエラーかどうかを判定
 */
export function isError<T>(response: ApiResponse<T>): response is ApiResponse<T> & { error: ApiError } {
  return response.error !== null;
}
