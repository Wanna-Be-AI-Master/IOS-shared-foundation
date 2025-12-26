# エラーハンドリングガイド

## 概要

アプリケーション全体で一貫したエラー処理を実現するためのガイドライン。

---

## エラー分類

### レイヤー別

| レイヤー | エラー種別 | 例 |
|----------|-----------|-----|
| Network | 通信エラー | タイムアウト、接続エラー |
| API | サーバーエラー | 401, 404, 500 |
| Validation | 検証エラー | 入力不正 |
| Business | ビジネスロジックエラー | 制限超過 |
| System | システムエラー | メモリ不足 |

### ユーザー起因 vs システム起因

| 種別 | 説明 | 対処 |
|------|------|------|
| **ユーザー起因** | ユーザーが修正可能 | 具体的な修正方法を提示 |
| **システム起因** | ユーザーが修正不可 | 再試行を促すか、サポートへ |

---

## エラーコード体系

### コード構造

```
{カテゴリ}_{詳細コード}

例: AUTH_INVALID_CREDENTIAL
    NET_TIMEOUT
    VAL_REQUIRED_FIELD
```

### カテゴリ一覧

| コード | カテゴリ | 説明 |
|--------|----------|------|
| `AUTH` | 認証 | 認証・認可関連 |
| `NET` | ネットワーク | 通信関連 |
| `API` | API | サーバーレスポンス |
| `VAL` | 検証 | 入力検証 |
| `BIZ` | ビジネス | ビジネスルール |
| `SYS` | システム | システムエラー |
| `UNKNOWN` | 不明 | 分類不能 |

---

## 標準エラー定義

### TypeScript

```typescript
/**
 * アプリエラーの基底クラス
 */
export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly userMessage: string,
    public readonly originalError?: Error
  ) {
    super(userMessage);
    this.name = 'AppError';
  }

  /**
   * ユーザーに表示可能か
   */
  get isUserFacing(): boolean {
    return true;
  }

  /**
   * 再試行可能か
   */
  get isRetryable(): boolean {
    return false;
  }
}

/**
 * ネットワークエラー
 */
export class NetworkError extends AppError {
  constructor(originalError?: Error) {
    super(
      'NET_CONNECTION_FAILED',
      '通信エラーが発生しました。接続を確認してください。',
      originalError
    );
    this.name = 'NetworkError';
  }

  get isRetryable(): boolean {
    return true;
  }
}

/**
 * 認証エラー
 */
export class AuthError extends AppError {
  constructor(code: string, message: string, originalError?: Error) {
    super(code, message, originalError);
    this.name = 'AuthError';
  }
}

/**
 * 検証エラー
 */
export class ValidationError extends AppError {
  constructor(
    public readonly field: string,
    message: string
  ) {
    super(`VAL_${field.toUpperCase()}`, message);
    this.name = 'ValidationError';
  }
}

/**
 * ビジネスロジックエラー
 */
export class BusinessError extends AppError {
  constructor(code: string, message: string) {
    super(code, message);
    this.name = 'BusinessError';
  }
}
```

### Swift

```swift
/// アプリエラープロトコル
protocol AppErrorProtocol: Error {
    var code: String { get }
    var userMessage: String { get }
    var isRetryable: Bool { get }
}

/// アプリエラー
enum AppError: AppErrorProtocol {
    case network(NetworkError)
    case auth(AuthError)
    case validation(ValidationError)
    case business(BusinessError)
    case system(SystemError)
    case unknown(Error)

    var code: String {
        switch self {
        case .network(let error): return error.code
        case .auth(let error): return error.code
        case .validation(let error): return error.code
        case .business(let error): return error.code
        case .system(let error): return error.code
        case .unknown: return "UNKNOWN_ERROR"
        }
    }

    var userMessage: String {
        switch self {
        case .network(let error): return error.userMessage
        case .auth(let error): return error.userMessage
        case .validation(let error): return error.userMessage
        case .business(let error): return error.userMessage
        case .system(let error): return error.userMessage
        case .unknown: return "予期しないエラーが発生しました"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .network: return true
        case .auth, .validation, .business: return false
        case .system, .unknown: return true
        }
    }
}

/// ネットワークエラー
enum NetworkError: AppErrorProtocol {
    case connectionFailed
    case timeout
    case noInternet

    var code: String {
        switch self {
        case .connectionFailed: return "NET_CONNECTION_FAILED"
        case .timeout: return "NET_TIMEOUT"
        case .noInternet: return "NET_NO_INTERNET"
        }
    }

    var userMessage: String {
        switch self {
        case .connectionFailed: return "通信エラーが発生しました"
        case .timeout: return "通信がタイムアウトしました"
        case .noInternet: return "インターネットに接続されていません"
        }
    }

    var isRetryable: Bool { true }
}

/// 認証エラー
enum AuthError: AppErrorProtocol {
    case invalidCredential
    case sessionExpired
    case userNotFound
    case accountDeleted

    var code: String {
        switch self {
        case .invalidCredential: return "AUTH_INVALID_CREDENTIAL"
        case .sessionExpired: return "AUTH_SESSION_EXPIRED"
        case .userNotFound: return "AUTH_USER_NOT_FOUND"
        case .accountDeleted: return "AUTH_ACCOUNT_DELETED"
        }
    }

    var userMessage: String {
        switch self {
        case .invalidCredential: return "ログインに失敗しました"
        case .sessionExpired: return "セッションが切れました。再度ログインしてください"
        case .userNotFound: return "ユーザーが見つかりません"
        case .accountDeleted: return "アカウントは削除されています"
        }
    }

    var isRetryable: Bool { false }
}

/// 検証エラー
struct ValidationError: AppErrorProtocol {
    let field: String
    let userMessage: String

    var code: String { "VAL_\(field.uppercased())" }
    var isRetryable: Bool { false }
}

/// ビジネスロジックエラー
enum BusinessError: AppErrorProtocol {
    case limitExceeded(feature: String)
    case premiumRequired
    case alreadyExists
    case notAllowed

    var code: String {
        switch self {
        case .limitExceeded: return "BIZ_LIMIT_EXCEEDED"
        case .premiumRequired: return "BIZ_PREMIUM_REQUIRED"
        case .alreadyExists: return "BIZ_ALREADY_EXISTS"
        case .notAllowed: return "BIZ_NOT_ALLOWED"
        }
    }

    var userMessage: String {
        switch self {
        case .limitExceeded(let feature):
            return "\(feature)の上限に達しました"
        case .premiumRequired:
            return "この機能はプレミアム会員限定です"
        case .alreadyExists:
            return "既に存在します"
        case .notAllowed:
            return "この操作は許可されていません"
        }
    }

    var isRetryable: Bool { false }
}

/// システムエラー
enum SystemError: AppErrorProtocol {
    case unexpected
    case maintenance

    var code: String {
        switch self {
        case .unexpected: return "SYS_UNEXPECTED"
        case .maintenance: return "SYS_MAINTENANCE"
        }
    }

    var userMessage: String {
        switch self {
        case .unexpected: return "予期しないエラーが発生しました"
        case .maintenance: return "現在メンテナンス中です"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .unexpected: return true
        case .maintenance: return false
        }
    }
}
```

---

## Supabaseエラーの変換

### TypeScript

```typescript
import { PostgrestError, AuthError as SupabaseAuthError } from '@supabase/supabase-js';

/**
 * Supabaseエラーをアプリエラーに変換
 */
export function convertSupabaseError(error: PostgrestError | SupabaseAuthError): AppError {
  // Postgrestエラー
  if ('code' in error && typeof error.code === 'string') {
    switch (error.code) {
      case 'PGRST116':
        return new BusinessError('BIZ_NOT_FOUND', 'データが見つかりません');

      case '23505':
        return new BusinessError('BIZ_ALREADY_EXISTS', '既に存在します');

      case '23503':
        return new BusinessError('BIZ_REFERENCE_ERROR', '関連するデータが存在しません');

      case '42501':
        return new AuthError('AUTH_PERMISSION_DENIED', 'アクセス権限がありません');

      default:
        return new AppError(
          `API_${error.code}`,
          'サーバーエラーが発生しました',
          new Error(error.message)
        );
    }
  }

  // 認証エラー
  if ('message' in error) {
    const message = error.message.toLowerCase();

    if (message.includes('invalid login')) {
      return new AuthError('AUTH_INVALID_CREDENTIAL', 'ログイン情報が正しくありません');
    }

    if (message.includes('email not confirmed')) {
      return new AuthError('AUTH_EMAIL_NOT_CONFIRMED', 'メールアドレスが確認されていません');
    }

    if (message.includes('jwt expired')) {
      return new AuthError('AUTH_SESSION_EXPIRED', 'セッションが期限切れです');
    }
  }

  return new AppError('UNKNOWN_ERROR', '予期しないエラーが発生しました', new Error(String(error)));
}
```

### Swift

```swift
import Supabase

/// Supabaseエラーを変換
func convertSupabaseError(_ error: Error) -> AppError {
    // PostgrestError
    if let postgrestError = error as? PostgrestError {
        switch postgrestError.code {
        case "PGRST116":
            return .business(.notFound)
        case "23505":
            return .business(.alreadyExists)
        case "42501":
            return .auth(.permissionDenied)
        default:
            return .unknown(error)
        }
    }

    // AuthError
    if let authError = error as? AuthError {
        switch authError {
        case .sessionNotFound:
            return .auth(.sessionExpired)
        default:
            return .auth(.invalidCredential)
        }
    }

    // ネットワークエラー
    if let urlError = error as? URLError {
        switch urlError.code {
        case .notConnectedToInternet:
            return .network(.noInternet)
        case .timedOut:
            return .network(.timeout)
        default:
            return .network(.connectionFailed)
        }
    }

    return .unknown(error)
}
```

---

## エラー表示

### ユーザーメッセージガイドライン

| ✅ 良い例 | ❌ 悪い例 |
|-----------|----------|
| 「通信エラーが発生しました」 | 「NetworkError: connection refused」 |
| 「入力内容を確認してください」 | 「ValidationError: field is required」 |
| 「再度ログインしてください」 | 「JWT token expired」 |

### メッセージ作成原則

1. **技術用語を避ける**
2. **次のアクションを示す**
3. **丁寧な表現を使う**
4. **短く簡潔に**

### トースト/アラート表示

```typescript
/**
 * エラーをユーザーに表示
 */
export function showError(error: AppError): void {
  // 再試行可能なエラー
  if (error.isRetryable) {
    showToast({
      type: 'error',
      message: error.userMessage,
      action: {
        label: '再試行',
        onPress: () => retryLastAction(),
      },
    });
    return;
  }

  // 認証エラー
  if (error instanceof AuthError) {
    showAlert({
      title: 'ログインが必要です',
      message: error.userMessage,
      buttons: [
        { text: 'ログイン', onPress: () => navigateToLogin() },
      ],
    });
    return;
  }

  // その他のエラー
  showToast({
    type: 'error',
    message: error.userMessage,
  });
}
```

---

## ロギング

### ログレベル

| レベル | 用途 | 例 |
|--------|------|-----|
| `debug` | 開発時のデバッグ | API呼び出しの詳細 |
| `info` | 通常の情報 | ユーザーアクション |
| `warn` | 警告 | 非推奨機能の使用 |
| `error` | エラー | 例外発生 |
| `fatal` | 致命的エラー | アプリクラッシュ |

### エラーログ

```typescript
/**
 * エラーをログに記録
 */
export function logError(error: AppError, context?: Record<string, unknown>): void {
  const logData = {
    code: error.code,
    message: error.message,
    userMessage: error.userMessage,
    stack: error.originalError?.stack,
    context,
    timestamp: new Date().toISOString(),
  };

  // 開発環境
  if (__DEV__) {
    console.error('[AppError]', logData);
    return;
  }

  // 本番環境（Sentry等に送信）
  // Sentry.captureException(error, { extra: logData });
}
```

### 機密情報の除外

```typescript
/**
 * ログから機密情報を除外
 */
function sanitizeForLog(data: Record<string, unknown>): Record<string, unknown> {
  const sensitiveKeys = ['password', 'token', 'secret', 'key', 'credential'];
  const result = { ...data };

  for (const key of Object.keys(result)) {
    if (sensitiveKeys.some(s => key.toLowerCase().includes(s))) {
      result[key] = '[REDACTED]';
    }
  }

  return result;
}
```

---

## グローバルエラーハンドラー

### React Native

```typescript
import { ErrorUtils } from 'react-native';

// グローバルエラーハンドラー設定
export function setupGlobalErrorHandler(): void {
  // JavaScript エラー
  ErrorUtils.setGlobalHandler((error, isFatal) => {
    logError(new AppError('SYS_UNEXPECTED', '予期しないエラー', error));

    if (isFatal) {
      // 致命的エラーの場合、クラッシュレポート送信
      // crashlytics.recordError(error);
    }
  });

  // Promise の未処理拒否
  const originalHandler = global.onunhandledrejection;
  global.onunhandledrejection = (event) => {
    logError(new AppError('SYS_UNHANDLED_PROMISE', 'Unhandled Promise', event.reason));
    originalHandler?.(event);
  };
}
```

### Swift

```swift
// AppDelegate または App初期化時
func setupGlobalErrorHandler() {
    // 未捕捉例外のハンドラー
    NSSetUncaughtExceptionHandler { exception in
        let error = SystemError.unexpected
        // ログ送信
        print("Uncaught exception: \(exception)")
    }
}
```

---

## Result型パターン

### TypeScript

```typescript
/**
 * Result型（成功 or エラー）
 */
export type Result<T, E = AppError> =
  | { success: true; data: T }
  | { success: false; error: E };

/**
 * 成功を返す
 */
export function ok<T>(data: T): Result<T> {
  return { success: true, data };
}

/**
 * エラーを返す
 */
export function err<E = AppError>(error: E): Result<never, E> {
  return { success: false, error };
}

// 使用例
async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      return err(convertSupabaseError(error));
    }

    return ok(transformUser(data));
  } catch (e) {
    return err(new NetworkError(e as Error));
  }
}

// 呼び出し側
const result = await fetchUser('123');
if (result.success) {
  console.log(result.data);
} else {
  showError(result.error);
}
```

### Swift

```swift
/// Result型のエイリアス
typealias AppResult<T> = Result<T, AppError>

// 使用例
func fetchUser(id: UUID) async -> AppResult<User> {
    do {
        let response = try await supabase
            .from("users")
            .select()
            .eq("id", id.uuidString)
            .single()
            .execute()

        return .success(transformUser(response.data))
    } catch {
        return .failure(convertSupabaseError(error))
    }
}

// 呼び出し側
let result = await fetchUser(id: userId)
switch result {
case .success(let user):
    print(user)
case .failure(let error):
    showError(error)
}
```

---

## チェックリスト

- [ ] エラー分類が適切に定義されているか
- [ ] ユーザー向けメッセージが分かりやすいか
- [ ] 技術的詳細がユーザーに漏れていないか
- [ ] 再試行可能なエラーを正しく判定しているか
- [ ] ログに機密情報が含まれていないか
- [ ] グローバルエラーハンドラーが設定されているか
