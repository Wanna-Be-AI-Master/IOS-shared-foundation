# Apple Sign-In 認証フロー設計

## 概要

本ドキュメントは、Apple Sign-InとSupabaseを組み合わせた認証フローの標準仕様を定義する。

### 対象アプリ
- **かろやか** (katazuke-app) - iOS (Swift/SwiftUI)
- **むすび** (koukan-nikki-app) - React Native (Expo)

---

## 認証フロー全体図

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Apple Sign-In フロー                            │
└─────────────────────────────────────────────────────────────────────────┘

    ユーザー              アプリ                 Apple              Supabase
       │                   │                     │                    │
       │  1. ログインボタン │                     │                    │
       │ ─────────────────>│                     │                    │
       │                   │                     │                    │
       │                   │  2. Nonce生成       │                    │
       │                   │  (SHA256ハッシュ)    │                    │
       │                   │                     │                    │
       │                   │  3. 認証リクエスト   │                    │
       │                   │ ───────────────────>│                    │
       │                   │   (hashedNonce)     │                    │
       │                   │                     │                    │
       │  4. Face ID/      │                     │                    │
       │     Touch ID      │                     │                    │
       │<──────────────────│<────────────────────│                    │
       │                   │                     │                    │
       │  5. 認証許可      │                     │                    │
       │ ─────────────────>│<────────────────────│                    │
       │                   │  6. credential返却  │                    │
       │                   │   (identityToken,   │                    │
       │                   │    user, email,     │                    │
       │                   │    fullName)        │                    │
       │                   │                     │                    │
       │                   │  7. Supabase認証    │                    │
       │                   │ ─────────────────────────────────────────>│
       │                   │   (idToken + nonce) │                    │
       │                   │                     │                    │
       │                   │  8. セッション発行   │                    │
       │                   │<─────────────────────────────────────────│
       │                   │   (session)         │                    │
       │                   │                     │                    │
       │                   │  9. ユーザー存在確認 │                    │
       │                   │ ─────────────────────────────────────────>│
       │                   │                     │                    │
       │                   │  10. ユーザー情報   │                    │
       │                   │<─────────────────────────────────────────│
       │                   │                     │                    │
       │ 11. 完了           │                     │                    │
       │<──────────────────│                     │                    │
       │                   │                     │                    │
```

---

## 認証状態 (AuthState)

アプリの認証状態は以下の4つに分類される：

| 状態 | 説明 | 遷移先 |
|------|------|--------|
| `loading` | 認証状態を確認中 | 他の全状態 |
| `unauthenticated` | 未認証（ログイン画面表示） | `profileSetup` or `authenticated` |
| `profileSetup` | 認証済みだがプロフィール未設定 | `authenticated` |
| `authenticated` | 認証完了（メイン画面表示） | `unauthenticated` |

### 状態遷移図

```
                    ┌───────────────┐
                    │    loading    │
                    └───────┬───────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌───────────────┐ ┌───────────┐ ┌───────────────┐
    │unauthenticated│ │profileSetup│ │ authenticated │
    └───────┬───────┘ └─────┬─────┘ └───────┬───────┘
            │               │               │
            │ signIn        │ complete      │ signOut
            └───────────────┼───────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ authenticated │
                    └───────────────┘
```

---

## Nonce（ノンス）生成

### 目的
リプレイ攻撃を防ぐためのワンタイムトークン。

### 生成手順

1. ランダム文字列（rawNonce）を生成
2. SHA256でハッシュ化（hashedNonce）
3. hashedNonceをApple認証リクエストに送信
4. rawNonceをSupabase認証に送信

### TypeScript実装 (React Native)

```typescript
import * as Crypto from 'expo-crypto';

/**
 * ノンスを生成
 * @param length ノンスの長さ（デフォルト: 32）
 * @returns rawNonce（ハッシュ前）
 */
function generateNonce(length = 32): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  const randomValues = new Uint8Array(length);
  crypto.getRandomValues(randomValues);
  for (let i = 0; i < length; i++) {
    result += chars[randomValues[i] % chars.length];
  }
  return result;
}

/**
 * ノンスをSHA256でハッシュ化
 */
async function hashNonce(rawNonce: string): Promise<string> {
  return await Crypto.digestStringAsync(
    Crypto.CryptoDigestAlgorithm.SHA256,
    rawNonce
  );
}
```

### Swift実装 (iOS)

```swift
import CryptoKit

/// ノンスを生成
/// - Parameter length: ノンスの長さ（デフォルト: 32）
/// - Returns: rawNonce（ハッシュ前）
func generateNonce(length: Int = 32) -> String {
    let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    var result = ""
    var random = SystemRandomNumberGenerator()
    for _ in 0..<length {
        result.append(chars.randomElement(using: &random)!)
    }
    return result
}

/// ノンスをSHA256でハッシュ化
/// - Parameter input: rawNonce
/// - Returns: hashedNonce
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}
```

---

## Apple認証リクエスト

### TypeScript実装 (Expo)

```typescript
import * as AppleAuthentication from 'expo-apple-authentication';

async function requestAppleAuthentication(hashedNonce: string) {
  const credential = await AppleAuthentication.signInAsync({
    requestedScopes: [
      AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
      AppleAuthentication.AppleAuthenticationScope.EMAIL,
    ],
    nonce: hashedNonce,
  });

  return {
    identityToken: credential.identityToken,
    authorizationCode: credential.authorizationCode,
    user: credential.user,  // Apple User ID
    email: credential.email,
    fullName: credential.fullName,
  };
}
```

### Swift実装 (AuthenticationServices)

```swift
import AuthenticationServices

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {

    private var currentNonce: String?

    func startSignIn() {
        let rawNonce = generateNonce()
        currentNonce = rawNonce
        let hashedNonce = sha256(rawNonce)

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let idTokenString = String(data: identityToken, encoding: .utf8),
              let nonce = currentNonce
        else { return }

        // Supabaseに送信
        Task {
            await signInToSupabase(idToken: idTokenString, nonce: nonce)
        }
    }
}
```

---

## Supabase認証

### TypeScript実装

```typescript
import { supabase } from '@/services/supabase';

/**
 * Apple Sign-InでSupabaseに認証
 * @param idToken Apple Identity Token
 * @param nonce rawNonce（ハッシュ前）
 */
async function signInWithApple(idToken: string, nonce: string): Promise<Session> {
  const { data, error } = await supabase.auth.signInWithIdToken({
    provider: 'apple',
    token: idToken,
    nonce,
  });

  if (error) throw error;
  if (!data.session) throw new Error('セッションを取得できませんでした');

  return data.session;
}
```

### Swift実装 (Supabase Swift SDK)

```swift
import Supabase

/// Apple Sign-InでSupabaseに認証
func signInWithApple(idToken: String, nonce: String) async throws -> Session {
    let session = try await supabase.auth.signInWithIdToken(
        credentials: .init(
            provider: .apple,
            idToken: idToken,
            nonce: nonce
        )
    )
    return session
}
```

---

## ユーザー存在確認と作成

### フロー

```
認証成功
    │
    ▼
usersテーブルを確認
    │
    ├── ユーザー存在 → authenticated状態へ
    │
    └── ユーザー不在 → profileSetup状態へ
                          │
                          ▼
                    プロフィール設定画面
                          │
                          ▼
                    usersテーブルに挿入
                          │
                          ▼
                    authenticated状態へ
```

### TypeScript実装

```typescript
async function checkUserExists(userId: string): Promise<User | null> {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .single();

  if (error?.code === 'PGRST116') return null; // レコードなし
  if (error) throw error;

  return transformUser(data);
}

async function createUser(input: UserCreateInput): Promise<User> {
  const userId = await getCurrentUserId();
  if (!userId) throw new Error('認証されていません');

  const { data, error } = await supabase
    .from('users')
    .insert({
      id: userId,
      apple_id: input.appleId,
      email: input.email,
      display_name: input.displayName,
      settings: {
        notification_enabled: true,
        // アプリ固有の設定...
      },
    })
    .select()
    .single();

  if (error) throw error;
  return transformUser(data);
}
```

---

## Apple認証情報の注意点

### 初回のみ取得可能な情報

Appleはユーザーのプライバシー保護のため、以下の情報を**初回認証時のみ**提供する：

| 情報 | 初回のみ | 備考 |
|------|----------|------|
| `user` (Apple User ID) | × | 毎回取得可能 |
| `identityToken` | × | 毎回取得可能 |
| `email` | ○ | 初回のみ、Hide My Emailの場合はリレーアドレス |
| `fullName` | ○ | 初回のみ |

### 対処法

1. **初回認証時に必ず保存する**
   - email と fullName は初回認証時にDBに保存
   - 2回目以降は取得不可

2. **一時保存してプロフィール設定へ**
   ```typescript
   // 認証後すぐにプロフィール設定へ遷移
   setPendingCredential({
     appleId: credential.user,
     email: credential.email,
     fullName: formatFullName(credential.fullName),
   });
   setAuthState('profileSetup');
   ```

3. **ユーザーにシミュレーターテスト時の注意喚起**
   - シミュレーターで一度サインインすると、email/fullNameが取得できなくなる
   - 設定 > Apple ID > サインインとセキュリティ > Appleでサインイン から削除して再テスト

---

## エラーハンドリング

### 共通エラー種別

| エラーコード | 説明 | ユーザー向けメッセージ |
|--------------|------|------------------------|
| `user_canceled` | ユーザーがキャンセル | (何も表示しない) |
| `invalid_credential` | 認証情報が無効 | ログインに失敗しました。もう一度お試しください。 |
| `network_error` | 通信エラー | 通信エラーが発生しました。接続を確認してください。 |
| `session_expired` | セッション期限切れ | 再度ログインしてください。 |
| `user_not_found` | ユーザーが見つからない | アカウントが見つかりません。 |

### TypeScript実装

```typescript
async function handleSignIn() {
  try {
    await signInWithApple();
  } catch (error) {
    const err = error as Error;

    // ユーザーキャンセルは無視
    if (err.message?.includes('canceled')) {
      return;
    }

    // エラーメッセージを設定
    setError('ログインに失敗しました。もう一度お試しください。');
    console.error('Sign-in error:', err);
  }
}
```

---

## セキュリティ考慮事項

### 必須対策

1. **Nonce必須**
   - リプレイ攻撃防止のため必ずNonceを使用
   - 毎回新しいNonceを生成

2. **セキュアストレージ**
   - セッショントークンはSecureStore/Keychainに保存
   - UserDefaultsには保存しない

3. **トークン検証**
   - Supabase側でidentityTokenを検証
   - クライアントでは追加検証不要

4. **HTTPS通信**
   - 全API通信はHTTPS必須

### 推奨対策

1. **セッション有効期限**
   - 適切な有効期限を設定（推奨: 7日）
   - 自動リフレッシュを有効化

2. **認証状態監視**
   - onAuthStateChangeでリアルタイム監視
   - サーバー側でのセッション無効化に対応

---

## プラットフォーム別実装チェックリスト

### TypeScript (React Native / Expo)

- [ ] `expo-apple-authentication` インストール
- [ ] `expo-crypto` インストール
- [ ] `expo-secure-store` インストール
- [ ] app.json に entitlements 設定
- [ ] Supabase クライアント初期化（SecureStoreアダプター）
- [ ] AuthContext 実装
- [ ] ログイン画面 UI
- [ ] プロフィール設定画面 UI
- [ ] 認証状態によるルーティング

### Swift (iOS Native)

- [ ] Sign in with Apple capability 有効化
- [ ] Supabase Swift SDK インストール
- [ ] ASAuthorizationControllerDelegate 実装
- [ ] Keychain でセッション保存
- [ ] AuthViewModel 実装
- [ ] ログイン画面 UI (SwiftUI)
- [ ] プロフィール設定画面 UI
- [ ] NavigationStack でルーティング

---

## 参考リンク

- [Apple Developer - Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Supabase Docs - Apple Auth](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [Expo - Apple Authentication](https://docs.expo.dev/versions/latest/sdk/apple-authentication/)
