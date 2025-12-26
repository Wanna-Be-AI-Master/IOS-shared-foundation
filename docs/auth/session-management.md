# セッション管理設計

## 概要

Supabaseを使用したセッション管理の標準仕様を定義する。

---

## セッションライフサイクル

```
┌─────────────────────────────────────────────────────────────────┐
│                    セッションライフサイクル                       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────┐     認証成功      ┌──────────┐
    │  未認証   │ ───────────────> │ アクティブ │
    └──────────┘                   └────┬─────┘
         ▲                              │
         │                              │ 自動更新
         │                              ▼
         │                         ┌──────────┐
         │        期限切れ          │  更新中   │
         │ <───────────────────────┴──────────┘
         │                              │
         │                              │ 更新成功
         │                              ▼
         │                         ┌──────────┐
         │                         │ アクティブ │
         │                         └──────────┘
         │
         │  ログアウト / トークン無効化
         └──────────────────────────────────────
```

---

## Supabaseセッション構成

### セッションデータ構造

```typescript
interface Session {
  access_token: string;       // JWTアクセストークン（短期）
  refresh_token: string;      // リフレッシュトークン（長期）
  expires_in: number;         // アクセストークン有効期限（秒）
  expires_at: number;         // 有効期限タイムスタンプ
  token_type: 'bearer';
  user: User;                 // Supabase Auth ユーザー情報
}
```

### トークン有効期限

| トークン種別 | デフォルト有効期限 | 推奨設定 |
|-------------|-------------------|----------|
| Access Token | 1時間 | 1時間（変更不可） |
| Refresh Token | 無期限 | 7日（Supabaseダッシュボードで設定） |

---

## セキュアストレージ

### 保存場所

| プラットフォーム | ストレージ | ライブラリ |
|------------------|-----------|-----------|
| iOS (Native) | Keychain | Security.framework |
| React Native | SecureStore | expo-secure-store |
| Android | EncryptedSharedPreferences | expo-secure-store |

### NG例（使用禁止）

- `UserDefaults` / `AsyncStorage` - 暗号化されていない
- `localStorage` - Web用、モバイルでは使用不可
- 平文でのファイル保存

---

## TypeScript実装 (React Native)

### Supabaseクライアント初期化

```typescript
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';

// SecureStoreアダプター
const ExpoSecureStoreAdapter = {
  getItem: async (key: string): Promise<string | null> => {
    return await SecureStore.getItemAsync(key);
  },
  setItem: async (key: string, value: string): Promise<void> => {
    await SecureStore.setItemAsync(key, value);
  },
  removeItem: async (key: string): Promise<void> => {
    await SecureStore.deleteItemAsync(key);
  },
};

// Supabaseクライアント
export const supabase: SupabaseClient = createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: true,      // 自動トークン更新
      persistSession: true,         // セッション永続化
      detectSessionInUrl: false,    // モバイルではfalse
    },
  }
);
```

### セッション取得

```typescript
/**
 * 現在のセッションを取得
 */
export async function getSession(): Promise<Session | null> {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.error('セッション取得エラー:', error);
    return null;
  }
  return data.session;
}

/**
 * 現在のユーザーIDを取得
 */
export async function getCurrentUserId(): Promise<string | null> {
  const session = await getSession();
  return session?.user?.id ?? null;
}
```

### セッション監視

```typescript
import { useEffect } from 'react';

function useAuthStateListener(
  onStateChange: (session: Session | null) => void
) {
  useEffect(() => {
    // 認証状態変更をリッスン
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        console.log('Auth event:', event);

        switch (event) {
          case 'SIGNED_IN':
            onStateChange(session);
            break;
          case 'SIGNED_OUT':
            onStateChange(null);
            break;
          case 'TOKEN_REFRESHED':
            console.log('トークンが更新されました');
            onStateChange(session);
            break;
          case 'USER_UPDATED':
            onStateChange(session);
            break;
        }
      }
    );

    // クリーンアップ
    return () => {
      subscription.unsubscribe();
    };
  }, [onStateChange]);
}
```

### サインアウト

```typescript
/**
 * サインアウト
 */
export async function signOut(): Promise<void> {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
}
```

---

## Swift実装 (iOS)

### Supabaseクライアント初期化

```swift
import Supabase

// グローバルクライアント
let supabase = SupabaseClient(
    supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
    supabaseKey: "YOUR_SUPABASE_ANON_KEY",
    options: SupabaseClientOptions(
        auth: AuthClientOptions(
            storage: KeychainLocalStorage()  // Keychain使用
        )
    )
)
```

### Keychainストレージ実装

```swift
import Security
import Foundation

/// Keychainを使用したセッションストレージ
final class KeychainLocalStorage: AuthLocalStorage {

    private let service = "com.yourapp.supabase"

    func store(key: String, value: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ]

        // 既存の項目を削除
        SecItemDelete(query as CFDictionary)

        // 新しい項目を追加
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func retrieve(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        return result as? Data
    }

    func remove(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
}
```

### セッション管理

```swift
/// 現在のセッションを取得
func getSession() async throws -> Session? {
    return try await supabase.auth.session
}

/// セッション更新を監視
func observeAuthState() async {
    for await (event, session) in supabase.auth.authStateChanges {
        switch event {
        case .signedIn:
            print("サインイン完了")
            await handleSignedIn(session: session)
        case .signedOut:
            print("サインアウト完了")
            await handleSignedOut()
        case .tokenRefreshed:
            print("トークン更新完了")
        case .userUpdated:
            print("ユーザー情報更新")
        default:
            break
        }
    }
}

/// サインアウト
func signOut() async throws {
    try await supabase.auth.signOut()
}
```

---

## セッション復元

### アプリ起動時の処理

```
アプリ起動
    │
    ▼
SecureStoreからセッション読み込み
    │
    ├── セッションなし → unauthenticated状態
    │
    └── セッションあり
            │
            ▼
        有効期限確認
            │
            ├── 有効 → セッション使用
            │
            └── 期限切れ
                    │
                    ▼
                自動リフレッシュ
                    │
                    ├── 成功 → 新セッション使用
                    │
                    └── 失敗 → unauthenticated状態
```

### TypeScript実装

```typescript
async function restoreSession(): Promise<boolean> {
  try {
    // Supabaseが自動的にSecureStoreからセッションを読み込む
    const { data, error } = await supabase.auth.getSession();

    if (error) {
      console.error('セッション復元エラー:', error);
      return false;
    }

    if (!data.session) {
      return false;
    }

    // セッションが有効期限切れの場合、自動的にリフレッシュされる
    // autoRefreshToken: true の設定による

    return true;
  } catch (error) {
    console.error('セッション復元失敗:', error);
    return false;
  }
}
```

### Swift実装

```swift
func restoreSession() async -> Bool {
    do {
        // Supabaseが自動的にKeychainからセッションを読み込む
        let session = try await supabase.auth.session

        if session != nil {
            return true
        }

        return false
    } catch {
        print("セッション復元エラー:", error)
        return false
    }
}
```

---

## セッション無効化シナリオ

### 自動無効化

| シナリオ | 発生条件 | 対処 |
|----------|----------|------|
| トークン期限切れ | access_tokenが期限切れ | 自動リフレッシュ |
| リフレッシュ失敗 | refresh_tokenが無効 | 再ログイン要求 |
| サーバー側無効化 | 管理者操作、パスワード変更等 | 再ログイン要求 |

### 明示的無効化

| アクション | 処理 |
|------------|------|
| ログアウト | `supabase.auth.signOut()` |
| アカウント削除 | ユーザーデータ削除 + サインアウト |
| 全デバイスログアウト | サーバー側で全セッション無効化 |

---

## エラーハンドリング

### セッション関連エラー

```typescript
enum SessionError {
  SESSION_NOT_FOUND = 'session_not_found',
  TOKEN_EXPIRED = 'token_expired',
  REFRESH_FAILED = 'refresh_failed',
  STORAGE_ERROR = 'storage_error',
}

async function handleSessionError(error: Error): Promise<void> {
  const message = error.message.toLowerCase();

  if (message.includes('jwt expired') || message.includes('token expired')) {
    // トークン期限切れ - 自動リフレッシュを試行
    try {
      await supabase.auth.refreshSession();
    } catch (refreshError) {
      // リフレッシュ失敗 - 再ログイン要求
      await signOut();
      navigateToLogin();
    }
  } else if (message.includes('invalid token')) {
    // 無効なトークン - 再ログイン要求
    await signOut();
    navigateToLogin();
  }
}
```

---

## セキュリティベストプラクティス

### 必須

1. **セキュアストレージ使用**
   - iOS: Keychain
   - React Native: expo-secure-store

2. **HTTPS通信**
   - 全API通信はHTTPS必須

3. **トークン漏洩対策**
   - ログ出力禁止
   - デバッグビルドでもトークンを表示しない

### 推奨

1. **バックグラウンド時のセッション検証**
   ```typescript
   import { AppState } from 'react-native';

   AppState.addEventListener('change', async (state) => {
     if (state === 'active') {
       // フォアグラウンド復帰時にセッション確認
       const session = await getSession();
       if (!session) {
         navigateToLogin();
       }
     }
   });
   ```

2. **Jailbreak/Root検出（オプション）**
   - 高セキュリティ要件の場合のみ

3. **セッションログ**
   - 本番環境ではトークン値をログに含めない
   - セッションイベント（ログイン/ログアウト）のみ記録

---

## 環境別設定

### 開発環境

```typescript
const supabaseConfig = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    debug: true,  // 開発時のみ
  },
};
```

### 本番環境

```typescript
const supabaseConfig = {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    debug: false,
  },
};
```

---

## チェックリスト

### 実装確認

- [ ] SecureStore/Keychain でセッション保存
- [ ] autoRefreshToken: true 設定
- [ ] persistSession: true 設定
- [ ] onAuthStateChange リスナー実装
- [ ] アプリ起動時のセッション復元
- [ ] サインアウト機能
- [ ] エラーハンドリング

### セキュリティ確認

- [ ] トークンがログに出力されていないこと
- [ ] UserDefaults/AsyncStorage を使用していないこと
- [ ] HTTPS通信のみ
- [ ] デバッグビルドでも機密情報が露出しないこと
