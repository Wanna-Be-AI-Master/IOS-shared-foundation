/**
 * エラー処理ユーティリティ
 * 共通エラークラス、AWSエラー変換
 */
/**
 * エラーカテゴリ
 */
export type ErrorCategory = 'AUTH' | 'NET' | 'API' | 'VAL' | 'BIZ' | 'SYS';
/**
 * 共通エラーコード
 */
export declare const ERROR_CODES: {
    readonly AUTH_INVALID_CREDENTIAL: "AUTH_INVALID_CREDENTIAL";
    readonly AUTH_SESSION_EXPIRED: "AUTH_SESSION_EXPIRED";
    readonly AUTH_USER_NOT_FOUND: "AUTH_USER_NOT_FOUND";
    readonly AUTH_CANCELLED: "AUTH_CANCELLED";
    readonly NET_TIMEOUT: "NET_TIMEOUT";
    readonly NET_OFFLINE: "NET_OFFLINE";
    readonly NET_UNKNOWN: "NET_UNKNOWN";
    readonly API_NOT_FOUND: "API_NOT_FOUND";
    readonly API_FORBIDDEN: "API_FORBIDDEN";
    readonly API_CONFLICT: "API_CONFLICT";
    readonly API_SERVER_ERROR: "API_SERVER_ERROR";
    readonly VAL_REQUIRED_FIELD: "VAL_REQUIRED_FIELD";
    readonly VAL_INVALID_FORMAT: "VAL_INVALID_FORMAT";
    readonly VAL_TOO_SHORT: "VAL_TOO_SHORT";
    readonly VAL_TOO_LONG: "VAL_TOO_LONG";
    readonly BIZ_LIMIT_EXCEEDED: "BIZ_LIMIT_EXCEEDED";
    readonly BIZ_ALREADY_EXISTS: "BIZ_ALREADY_EXISTS";
    readonly BIZ_NOT_ALLOWED: "BIZ_NOT_ALLOWED";
    readonly SYS_UNKNOWN: "SYS_UNKNOWN";
};
export type ErrorCodeType = typeof ERROR_CODES[keyof typeof ERROR_CODES];
/**
 * アプリケーションエラー基底クラス
 */
export declare class AppError extends Error {
    /** エラーコード */
    readonly code: string;
    /** ユーザー向けメッセージ */
    readonly userMessage: string;
    /** 元のエラー */
    readonly originalError?: Error | undefined;
    constructor(
    /** エラーコード */
    code: string, 
    /** ユーザー向けメッセージ */
    userMessage: string, 
    /** 元のエラー */
    originalError?: Error | undefined);
    /** リトライ可能かどうか */
    get isRetryable(): boolean;
    /** エラーカテゴリ */
    get category(): ErrorCategory;
}
/**
 * ネットワークエラー
 */
export declare class NetworkError extends AppError {
    constructor(code?: string, message?: string, originalError?: Error);
    get isRetryable(): boolean;
}
/**
 * 認証エラー
 */
export declare class AuthError extends AppError {
    constructor(code?: string, message?: string, originalError?: Error);
}
/**
 * バリデーションエラー
 */
export declare class ValidationError extends AppError {
    /** フィールド名 */
    readonly field?: string | undefined;
    constructor(code?: string, message?: string, 
    /** フィールド名 */
    field?: string | undefined, originalError?: Error);
}
/**
 * AWS Cognitoエラーを変換
 */
export declare function mapCognitoError(error: {
    name?: string;
    code?: string;
    message?: string;
}): AppError;
/**
 * HTTPエラーを変換
 */
export declare function mapHttpError(status: number, message?: string): AppError;
/**
 * エラーからユーザー向けメッセージを取得
 */
export declare function getErrorMessage(error: unknown): string;
/**
 * エラーかどうかを判定
 */
export declare function isAppError(error: unknown): error is AppError;
//# sourceMappingURL=error.d.ts.map