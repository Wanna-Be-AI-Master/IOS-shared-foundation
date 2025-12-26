/**
 * エラー処理ユーティリティ
 * 共通エラークラス、AWSエラー変換
 */

// ========================================
// エラーコード
// ========================================

/**
 * エラーカテゴリ
 */
export type ErrorCategory =
  | 'AUTH'    // 認証エラー
  | 'NET'     // ネットワークエラー
  | 'API'     // APIエラー
  | 'VAL'     // バリデーションエラー
  | 'BIZ'     // ビジネスロジックエラー
  | 'SYS';    // システムエラー

/**
 * 共通エラーコード
 */
export const ERROR_CODES = {
  // 認証
  AUTH_INVALID_CREDENTIAL: 'AUTH_INVALID_CREDENTIAL',
  AUTH_SESSION_EXPIRED: 'AUTH_SESSION_EXPIRED',
  AUTH_USER_NOT_FOUND: 'AUTH_USER_NOT_FOUND',
  AUTH_CANCELLED: 'AUTH_CANCELLED',

  // ネットワーク
  NET_TIMEOUT: 'NET_TIMEOUT',
  NET_OFFLINE: 'NET_OFFLINE',
  NET_UNKNOWN: 'NET_UNKNOWN',

  // API
  API_NOT_FOUND: 'API_NOT_FOUND',
  API_FORBIDDEN: 'API_FORBIDDEN',
  API_CONFLICT: 'API_CONFLICT',
  API_SERVER_ERROR: 'API_SERVER_ERROR',

  // バリデーション
  VAL_REQUIRED_FIELD: 'VAL_REQUIRED_FIELD',
  VAL_INVALID_FORMAT: 'VAL_INVALID_FORMAT',
  VAL_TOO_SHORT: 'VAL_TOO_SHORT',
  VAL_TOO_LONG: 'VAL_TOO_LONG',

  // ビジネス
  BIZ_LIMIT_EXCEEDED: 'BIZ_LIMIT_EXCEEDED',
  BIZ_ALREADY_EXISTS: 'BIZ_ALREADY_EXISTS',
  BIZ_NOT_ALLOWED: 'BIZ_NOT_ALLOWED',

  // システム
  SYS_UNKNOWN: 'SYS_UNKNOWN',
} as const;

export type ErrorCodeType = typeof ERROR_CODES[keyof typeof ERROR_CODES];

// ========================================
// エラークラス
// ========================================

/**
 * アプリケーションエラー基底クラス
 */
export class AppError extends Error {
  constructor(
    /** エラーコード */
    public readonly code: string,
    /** ユーザー向けメッセージ */
    public readonly userMessage: string,
    /** 元のエラー */
    public readonly originalError?: Error
  ) {
    super(userMessage);
    this.name = 'AppError';
  }

  /** リトライ可能かどうか */
  get isRetryable(): boolean {
    return this.code.startsWith('NET_');
  }

  /** エラーカテゴリ */
  get category(): ErrorCategory {
    const prefix = this.code.split('_')[0];
    return (prefix as ErrorCategory) || 'SYS';
  }
}

/**
 * ネットワークエラー
 */
export class NetworkError extends AppError {
  constructor(
    code: string = ERROR_CODES.NET_UNKNOWN,
    message: string = 'ネットワークエラーが発生しました',
    originalError?: Error
  ) {
    super(code, message, originalError);
    this.name = 'NetworkError';
  }

  override get isRetryable(): boolean {
    return true;
  }
}

/**
 * 認証エラー
 */
export class AuthError extends AppError {
  constructor(
    code: string = ERROR_CODES.AUTH_INVALID_CREDENTIAL,
    message: string = '認証エラーが発生しました',
    originalError?: Error
  ) {
    super(code, message, originalError);
    this.name = 'AuthError';
  }
}

/**
 * バリデーションエラー
 */
export class ValidationError extends AppError {
  constructor(
    code: string = ERROR_CODES.VAL_REQUIRED_FIELD,
    message: string = '入力内容を確認してください',
    /** フィールド名 */
    public readonly field?: string,
    originalError?: Error
  ) {
    super(code, message, originalError);
    this.name = 'ValidationError';
  }
}

// ========================================
// AWS Cognitoエラー変換
// ========================================

/**
 * AWS Cognitoエラーコードとメッセージのマッピング
 */
const COGNITO_ERROR_MAP: Record<string, { code: string; message: string }> = {
  // 認証エラー
  NotAuthorizedException: { code: ERROR_CODES.AUTH_INVALID_CREDENTIAL, message: '認証情報が無効です' },
  UserNotFoundException: { code: ERROR_CODES.AUTH_USER_NOT_FOUND, message: 'ユーザーが見つかりません' },
  UserNotConfirmedException: { code: ERROR_CODES.AUTH_INVALID_CREDENTIAL, message: 'メールアドレスが確認されていません' },
  PasswordResetRequiredException: { code: ERROR_CODES.AUTH_INVALID_CREDENTIAL, message: 'パスワードのリセットが必要です' },
  ExpiredCodeException: { code: ERROR_CODES.AUTH_SESSION_EXPIRED, message: '確認コードの有効期限が切れています' },
  CodeMismatchException: { code: ERROR_CODES.AUTH_INVALID_CREDENTIAL, message: '確認コードが正しくありません' },

  // ユーザー作成エラー
  UsernameExistsException: { code: ERROR_CODES.BIZ_ALREADY_EXISTS, message: '既に登録されています' },
  InvalidPasswordException: { code: ERROR_CODES.VAL_INVALID_FORMAT, message: 'パスワードの形式が正しくありません' },
  InvalidParameterException: { code: ERROR_CODES.VAL_INVALID_FORMAT, message: '入力内容を確認してください' },

  // アクセス制限
  TooManyRequestsException: { code: ERROR_CODES.BIZ_LIMIT_EXCEEDED, message: 'リクエストが多すぎます。しばらくお待ちください' },
  LimitExceededException: { code: ERROR_CODES.BIZ_LIMIT_EXCEEDED, message: '制限を超えました' },

  // トークンエラー
  TokenRefreshException: { code: ERROR_CODES.AUTH_SESSION_EXPIRED, message: 'セッションが期限切れです。再ログインしてください' },
};

/**
 * AWS Cognitoエラーを変換
 */
export function mapCognitoError(error: { name?: string; code?: string; message?: string }): AppError {
  const errorName = error.name || error.code || '';
  const mapped = COGNITO_ERROR_MAP[errorName];

  if (mapped) {
    return new AppError(mapped.code, mapped.message);
  }

  return new AppError(
    ERROR_CODES.SYS_UNKNOWN,
    error.message || '認証エラーが発生しました'
  );
}

// ========================================
// AWS APIエラー変換
// ========================================

/**
 * HTTPステータスコードとエラーのマッピング
 */
const HTTP_ERROR_MAP: Record<number, { code: string; message: string }> = {
  400: { code: ERROR_CODES.VAL_INVALID_FORMAT, message: 'リクエストが正しくありません' },
  401: { code: ERROR_CODES.AUTH_SESSION_EXPIRED, message: '認証が必要です' },
  403: { code: ERROR_CODES.API_FORBIDDEN, message: 'アクセス権限がありません' },
  404: { code: ERROR_CODES.API_NOT_FOUND, message: 'データが見つかりませんでした' },
  409: { code: ERROR_CODES.API_CONFLICT, message: '競合が発生しました' },
  429: { code: ERROR_CODES.BIZ_LIMIT_EXCEEDED, message: 'リクエストが多すぎます' },
  500: { code: ERROR_CODES.API_SERVER_ERROR, message: 'サーバーエラーが発生しました' },
  502: { code: ERROR_CODES.API_SERVER_ERROR, message: 'サーバーが応答しません' },
  503: { code: ERROR_CODES.API_SERVER_ERROR, message: 'サービスが一時的に利用できません' },
};

/**
 * HTTPエラーを変換
 */
export function mapHttpError(status: number, message?: string): AppError {
  const mapped = HTTP_ERROR_MAP[status];

  if (mapped) {
    return new AppError(mapped.code, message || mapped.message);
  }

  if (status >= 500) {
    return new AppError(ERROR_CODES.API_SERVER_ERROR, message || 'サーバーエラーが発生しました');
  }

  return new AppError(ERROR_CODES.SYS_UNKNOWN, message || 'エラーが発生しました');
}

// ========================================
// ユーティリティ関数
// ========================================

/**
 * エラーからユーザー向けメッセージを取得
 */
export function getErrorMessage(error: unknown): string {
  if (error instanceof AppError) {
    return error.userMessage;
  }

  if (error instanceof Error) {
    return error.message;
  }

  return 'エラーが発生しました';
}

/**
 * エラーかどうかを判定
 */
export function isAppError(error: unknown): error is AppError {
  return error instanceof AppError;
}
