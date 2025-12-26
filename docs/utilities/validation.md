# 入力検証ガイド

## 概要

入力データの検証に関する標準パターンを定義する。

---

## 基本原則

### 1. 検証のタイミング

| タイミング | 用途 | 例 |
|------------|------|-----|
| **入力時（リアルタイム）** | UX向上 | 文字数制限、フォーマット |
| **フォーカスアウト時** | フィールド単位検証 | メール形式、必須チェック |
| **送信時** | 全体検証 | 相関チェック、API送信前 |
| **サーバーサイド** | セキュリティ | 最終検証、DB制約 |

### 2. エラーメッセージ原則

- **具体的**: 何が問題かを明確に
- **解決策を提示**: どうすれば良いかを示す
- **丁寧な言葉遣い**: ユーザーを責めない

```
❌ 「入力エラー」
❌ 「不正な値です」
✅ 「メールアドレスの形式が正しくありません（例: example@email.com）」
✅ 「パスワードは8文字以上で入力してください」
```

---

## 共通バリデーションルール

### 必須チェック

```typescript
// TypeScript
export function isRequired(value: string | null | undefined): boolean {
  if (value === null || value === undefined) return false;
  return value.trim().length > 0;
}

export function validateRequired(
  value: string | null | undefined,
  fieldName: string
): string | null {
  if (!isRequired(value)) {
    return `${fieldName}を入力してください`;
  }
  return null;
}
```

```swift
// Swift
func isRequired(_ value: String?) -> Bool {
    guard let value = value else { return false }
    return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func validateRequired(_ value: String?, fieldName: String) -> String? {
    guard isRequired(value) else {
        return "\(fieldName)を入力してください"
    }
    return nil
}
```

### 文字数制限

```typescript
// TypeScript
interface LengthOptions {
  min?: number;
  max?: number;
}

export function validateLength(
  value: string,
  options: LengthOptions,
  fieldName: string
): string | null {
  const length = value.length;

  if (options.min !== undefined && length < options.min) {
    return `${fieldName}は${options.min}文字以上で入力してください`;
  }

  if (options.max !== undefined && length > options.max) {
    return `${fieldName}は${options.max}文字以内で入力してください`;
  }

  return null;
}

// 使用例
validateLength(password, { min: 8, max: 100 }, 'パスワード');
```

```swift
// Swift
struct LengthOptions {
    var min: Int?
    var max: Int?
}

func validateLength(
    _ value: String,
    options: LengthOptions,
    fieldName: String
) -> String? {
    let length = value.count

    if let min = options.min, length < min {
        return "\(fieldName)は\(min)文字以上で入力してください"
    }

    if let max = options.max, length > max {
        return "\(fieldName)は\(max)文字以内で入力してください"
    }

    return nil
}
```

### メールアドレス

```typescript
// TypeScript
const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

export function isValidEmail(email: string): boolean {
  return EMAIL_REGEX.test(email);
}

export function validateEmail(email: string): string | null {
  if (!email.trim()) {
    return 'メールアドレスを入力してください';
  }

  if (!isValidEmail(email)) {
    return 'メールアドレスの形式が正しくありません';
  }

  return null;
}
```

```swift
// Swift
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
    let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return predicate.evaluate(with: email)
}

func validateEmail(_ email: String) -> String? {
    let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
        return "メールアドレスを入力してください"
    }

    if !isValidEmail(trimmed) {
        return "メールアドレスの形式が正しくありません"
    }

    return nil
}
```

### パスワード

```typescript
// TypeScript
interface PasswordRules {
  minLength: number;
  requireUppercase?: boolean;
  requireLowercase?: boolean;
  requireNumber?: boolean;
  requireSpecialChar?: boolean;
}

const DEFAULT_PASSWORD_RULES: PasswordRules = {
  minLength: 8,
  requireUppercase: false,
  requireLowercase: false,
  requireNumber: false,
  requireSpecialChar: false,
};

export function validatePassword(
  password: string,
  rules: PasswordRules = DEFAULT_PASSWORD_RULES
): string[] {
  const errors: string[] = [];

  if (password.length < rules.minLength) {
    errors.push(`${rules.minLength}文字以上で入力してください`);
  }

  if (rules.requireUppercase && !/[A-Z]/.test(password)) {
    errors.push('大文字を含めてください');
  }

  if (rules.requireLowercase && !/[a-z]/.test(password)) {
    errors.push('小文字を含めてください');
  }

  if (rules.requireNumber && !/[0-9]/.test(password)) {
    errors.push('数字を含めてください');
  }

  if (rules.requireSpecialChar && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('特殊文字を含めてください');
  }

  return errors;
}

// パスワード強度インジケータ
export type PasswordStrength = 'weak' | 'medium' | 'strong';

export function getPasswordStrength(password: string): PasswordStrength {
  let score = 0;

  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (/[A-Z]/.test(password)) score++;
  if (/[a-z]/.test(password)) score++;
  if (/[0-9]/.test(password)) score++;
  if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) score++;

  if (score <= 2) return 'weak';
  if (score <= 4) return 'medium';
  return 'strong';
}
```

```swift
// Swift
struct PasswordRules {
    var minLength: Int = 8
    var requireUppercase: Bool = false
    var requireLowercase: Bool = false
    var requireNumber: Bool = false
    var requireSpecialChar: Bool = false
}

func validatePassword(_ password: String, rules: PasswordRules = PasswordRules()) -> [String] {
    var errors: [String] = []

    if password.count < rules.minLength {
        errors.append("\(rules.minLength)文字以上で入力してください")
    }

    if rules.requireUppercase && !password.contains(where: { $0.isUppercase }) {
        errors.append("大文字を含めてください")
    }

    if rules.requireLowercase && !password.contains(where: { $0.isLowercase }) {
        errors.append("小文字を含めてください")
    }

    if rules.requireNumber && !password.contains(where: { $0.isNumber }) {
        errors.append("数字を含めてください")
    }

    let specialChars = CharacterSet(charactersIn: "!@#$%^&*(),.?\":{}|<>")
    if rules.requireSpecialChar && password.rangeOfCharacter(from: specialChars) == nil {
        errors.append("特殊文字を含めてください")
    }

    return errors
}

enum PasswordStrength {
    case weak, medium, strong
}

func getPasswordStrength(_ password: String) -> PasswordStrength {
    var score = 0

    if password.count >= 8 { score += 1 }
    if password.count >= 12 { score += 1 }
    if password.contains(where: { $0.isUppercase }) { score += 1 }
    if password.contains(where: { $0.isLowercase }) { score += 1 }
    if password.contains(where: { $0.isNumber }) { score += 1 }

    let specialChars = CharacterSet(charactersIn: "!@#$%^&*(),.?\":{}|<>")
    if password.rangeOfCharacter(from: specialChars) != nil { score += 1 }

    if score <= 2 { return .weak }
    if score <= 4 { return .medium }
    return .strong
}
```

---

## アプリ固有のバリデーション

### Katazuke App

#### 記録の検証

```typescript
// TypeScript
interface RecordValidation {
  category: string;
  reason: string;
  memo?: string;
  photoUrl?: string;
}

export function validateRecord(data: RecordValidation): Record<string, string> {
  const errors: Record<string, string> = {};

  // カテゴリ（必須）
  if (!data.category) {
    errors.category = 'カテゴリを選択してください';
  }

  // 理由（必須）
  if (!data.reason) {
    errors.reason = '理由を選択してください';
  }

  // メモ（任意、最大500文字）
  if (data.memo && data.memo.length > 500) {
    errors.memo = 'メモは500文字以内で入力してください';
  }

  return errors;
}
```

```swift
// Swift
struct RecordInput {
    var category: Category?
    var reason: Reason?
    var memo: String?
    var photoUrl: String?
}

func validateRecord(_ input: RecordInput) -> [String: String] {
    var errors: [String: String] = [:]

    // カテゴリ（必須）
    if input.category == nil {
        errors["category"] = "カテゴリを選択してください"
    }

    // 理由（必須）
    if input.reason == nil {
        errors["reason"] = "理由を選択してください"
    }

    // メモ（任意、最大500文字）
    if let memo = input.memo, memo.count > 500 {
        errors["memo"] = "メモは500文字以内で入力してください"
    }

    return errors
}
```

### Koukan Nikki App

#### 日記エントリの検証

```typescript
// TypeScript
interface DiaryEntryValidation {
  content: string;
  emotionScore?: number;
}

const ENTRY_MIN_LENGTH = 1;
const ENTRY_MAX_LENGTH = 2000;

export function validateDiaryEntry(
  data: DiaryEntryValidation
): Record<string, string> {
  const errors: Record<string, string> = {};

  // 内容（必須、1〜2000文字）
  if (!data.content.trim()) {
    errors.content = '日記の内容を入力してください';
  } else if (data.content.length < ENTRY_MIN_LENGTH) {
    errors.content = `${ENTRY_MIN_LENGTH}文字以上で入力してください`;
  } else if (data.content.length > ENTRY_MAX_LENGTH) {
    errors.content = `${ENTRY_MAX_LENGTH}文字以内で入力してください`;
  }

  // 感情スコア（1〜5）
  if (data.emotionScore !== undefined) {
    if (data.emotionScore < 1 || data.emotionScore > 5) {
      errors.emotionScore = '気分は1〜5の範囲で選択してください';
    }
  }

  return errors;
}

// 日記コード（招待コード）の検証
const DIARY_CODE_REGEX = /^[A-Z0-9]{6}$/;

export function validateDiaryCode(code: string): string | null {
  const trimmed = code.trim().toUpperCase();

  if (!trimmed) {
    return '招待コードを入力してください';
  }

  if (!DIARY_CODE_REGEX.test(trimmed)) {
    return '招待コードは6桁の英数字です';
  }

  return null;
}
```

```swift
// Swift
struct DiaryEntryInput {
    var content: String
    var emotionScore: Int?
}

let entryMinLength = 1
let entryMaxLength = 2000

func validateDiaryEntry(_ input: DiaryEntryInput) -> [String: String] {
    var errors: [String: String] = [:]

    let trimmedContent = input.content.trimmingCharacters(in: .whitespacesAndNewlines)

    // 内容（必須、1〜2000文字）
    if trimmedContent.isEmpty {
        errors["content"] = "日記の内容を入力してください"
    } else if trimmedContent.count < entryMinLength {
        errors["content"] = "\(entryMinLength)文字以上で入力してください"
    } else if trimmedContent.count > entryMaxLength {
        errors["content"] = "\(entryMaxLength)文字以内で入力してください"
    }

    // 感情スコア（1〜5）
    if let score = input.emotionScore {
        if score < 1 || score > 5 {
            errors["emotionScore"] = "気分は1〜5の範囲で選択してください"
        }
    }

    return errors
}

// 日記コード（招待コード）の検証
func validateDiaryCode(_ code: String) -> String? {
    let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if trimmed.isEmpty {
        return "招待コードを入力してください"
    }

    let codeRegex = #"^[A-Z0-9]{6}$"#
    let predicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
    if !predicate.evaluate(with: trimmed) {
        return "招待コードは6桁の英数字です"
    }

    return nil
}
```

---

## バリデーション結果の型

### TypeScript

```typescript
/**
 * バリデーション結果
 */
interface ValidationResult<T> {
  isValid: boolean;
  data?: T;
  errors: Record<string, string>;
}

/**
 * フォームバリデーター
 */
class FormValidator<T extends Record<string, unknown>> {
  private errors: Record<string, string> = {};
  private data: Partial<T> = {};

  constructor(private rawData: T) {}

  /**
   * フィールドを検証
   */
  validate<K extends keyof T>(
    field: K,
    validator: (value: T[K]) => string | null
  ): this {
    const value = this.rawData[field];
    const error = validator(value);

    if (error) {
      this.errors[field as string] = error;
    } else {
      this.data[field] = value;
    }

    return this;
  }

  /**
   * 結果を取得
   */
  getResult(): ValidationResult<T> {
    const isValid = Object.keys(this.errors).length === 0;

    return {
      isValid,
      data: isValid ? (this.data as T) : undefined,
      errors: this.errors,
    };
  }
}

// 使用例
const result = new FormValidator(formData)
  .validate('email', validateEmail)
  .validate('password', (p) => validatePassword(p)[0] || null)
  .getResult();

if (result.isValid) {
  // 送信処理
  submitForm(result.data);
} else {
  // エラー表示
  showErrors(result.errors);
}
```

### Swift

```swift
/// バリデーション結果
struct ValidationResult<T> {
    let isValid: Bool
    let data: T?
    let errors: [String: String]
}

/// フォームバリデーター
class FormValidator<T> {
    private var errors: [String: String] = [:]
    private var validatedData: [String: Any] = [:]
    private let rawData: T

    init(_ data: T) {
        self.rawData = data
    }

    /// フィールドを検証
    @discardableResult
    func validate<V>(
        _ keyPath: KeyPath<T, V>,
        name: String,
        validator: (V) -> String?
    ) -> Self {
        let value = rawData[keyPath: keyPath]
        if let error = validator(value) {
            errors[name] = error
        } else {
            validatedData[name] = value
        }
        return self
    }

    /// 結果を取得
    func getResult() -> ValidationResult<T> {
        let isValid = errors.isEmpty
        return ValidationResult(
            isValid: isValid,
            data: isValid ? rawData : nil,
            errors: errors
        )
    }
}
```

---

## React Native / SwiftUI フォーム連携

### React Native フォームフック

```typescript
import { useState, useCallback } from 'react';

interface UseFormValidationOptions<T> {
  initialValues: T;
  validators: Partial<{
    [K in keyof T]: (value: T[K], allValues: T) => string | null;
  }>;
  onSubmit: (values: T) => Promise<void>;
}

interface UseFormValidationReturn<T> {
  values: T;
  errors: Partial<Record<keyof T, string>>;
  touched: Partial<Record<keyof T, boolean>>;
  isSubmitting: boolean;
  isValid: boolean;
  handleChange: <K extends keyof T>(field: K, value: T[K]) => void;
  handleBlur: <K extends keyof T>(field: K) => void;
  handleSubmit: () => Promise<void>;
  resetForm: () => void;
}

export function useFormValidation<T extends Record<string, unknown>>({
  initialValues,
  validators,
  onSubmit,
}: UseFormValidationOptions<T>): UseFormValidationReturn<T> {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateField = useCallback(
    <K extends keyof T>(field: K, value: T[K]): string | null => {
      const validator = validators[field];
      if (!validator) return null;
      return validator(value, values);
    },
    [validators, values]
  );

  const validateAll = useCallback((): boolean => {
    const newErrors: Partial<Record<keyof T, string>> = {};
    let isValid = true;

    for (const field of Object.keys(validators) as Array<keyof T>) {
      const error = validateField(field, values[field]);
      if (error) {
        newErrors[field] = error;
        isValid = false;
      }
    }

    setErrors(newErrors);
    return isValid;
  }, [validators, values, validateField]);

  const handleChange = useCallback(
    <K extends keyof T>(field: K, value: T[K]) => {
      setValues((prev) => ({ ...prev, [field]: value }));

      // リアルタイム検証（タッチ済みフィールドのみ）
      if (touched[field]) {
        const error = validateField(field, value);
        setErrors((prev) => ({
          ...prev,
          [field]: error || undefined,
        }));
      }
    },
    [touched, validateField]
  );

  const handleBlur = useCallback(
    <K extends keyof T>(field: K) => {
      setTouched((prev) => ({ ...prev, [field]: true }));

      const error = validateField(field, values[field]);
      setErrors((prev) => ({
        ...prev,
        [field]: error || undefined,
      }));
    },
    [values, validateField]
  );

  const handleSubmit = useCallback(async () => {
    // 全フィールドをタッチ済みにする
    const allTouched = Object.keys(validators).reduce(
      (acc, key) => ({ ...acc, [key]: true }),
      {} as Partial<Record<keyof T, boolean>>
    );
    setTouched(allTouched);

    if (!validateAll()) {
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(values);
    } finally {
      setIsSubmitting(false);
    }
  }, [validateAll, onSubmit, values, validators]);

  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  const isValid = Object.keys(errors).length === 0;

  return {
    values,
    errors,
    touched,
    isSubmitting,
    isValid,
    handleChange,
    handleBlur,
    handleSubmit,
    resetForm,
  };
}

// 使用例
function LoginForm() {
  const form = useFormValidation({
    initialValues: { email: '', password: '' },
    validators: {
      email: validateEmail,
      password: (p) => validatePassword(p)[0] || null,
    },
    onSubmit: async (values) => {
      await authService.login(values.email, values.password);
    },
  });

  return (
    <View>
      <Input
        value={form.values.email}
        onChangeText={(text) => form.handleChange('email', text)}
        onBlur={() => form.handleBlur('email')}
        error={form.touched.email ? form.errors.email : undefined}
        placeholder="メールアドレス"
      />
      <Input
        value={form.values.password}
        onChangeText={(text) => form.handleChange('password', text)}
        onBlur={() => form.handleBlur('password')}
        error={form.touched.password ? form.errors.password : undefined}
        placeholder="パスワード"
        secureTextEntry
      />
      <Button
        title="ログイン"
        onPress={form.handleSubmit}
        loading={form.isSubmitting}
        disabled={!form.isValid}
      />
    </View>
  );
}
```

### SwiftUI フォームバリデーション

```swift
import SwiftUI
import Combine

/// フォーム状態管理
@MainActor
class FormState<T>: ObservableObject {
    @Published var values: T
    @Published var errors: [String: String] = [:]
    @Published var touched: Set<String> = []
    @Published var isSubmitting = false

    private let validators: [String: (T) -> String?]
    private let onSubmit: (T) async throws -> Void

    init(
        initialValues: T,
        validators: [String: (T) -> String?],
        onSubmit: @escaping (T) async throws -> Void
    ) {
        self.values = initialValues
        self.validators = validators
        self.onSubmit = onSubmit
    }

    var isValid: Bool {
        errors.isEmpty
    }

    func validateField(_ name: String) {
        guard let validator = validators[name] else { return }
        errors[name] = validator(values)
    }

    func touch(_ name: String) {
        touched.insert(name)
        validateField(name)
    }

    func validateAll() -> Bool {
        errors.removeAll()
        for (name, validator) in validators {
            if let error = validator(values) {
                errors[name] = error
            }
        }
        return errors.isEmpty
    }

    func submit() async {
        // 全フィールドをタッチ
        for name in validators.keys {
            touched.insert(name)
        }

        guard validateAll() else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await onSubmit(values)
        } catch {
            // エラーハンドリング
            print("Submit error: \(error)")
        }
    }
}

// 使用例
struct LoginFormData {
    var email: String = ""
    var password: String = ""
}

struct LoginFormView: View {
    @StateObject private var form = FormState<LoginFormData>(
        initialValues: LoginFormData(),
        validators: [
            "email": { data in validateEmail(data.email) },
            "password": { data in validatePassword(data.password).first }
        ],
        onSubmit: { data in
            try await AuthService.shared.login(
                email: data.email,
                password: data.password
            )
        }
    )

    var body: some View {
        VStack(spacing: 16) {
            AppTextField(
                text: $form.values.email,
                label: "メールアドレス",
                placeholder: "example@email.com",
                error: form.touched.contains("email") ? form.errors["email"] : nil
            )
            .onChange(of: form.values.email) { _ in
                if form.touched.contains("email") {
                    form.validateField("email")
                }
            }

            AppTextField(
                text: $form.values.password,
                label: "パスワード",
                placeholder: "8文字以上",
                error: form.touched.contains("password") ? form.errors["password"] : nil
            )
            .onChange(of: form.values.password) { _ in
                if form.touched.contains("password") {
                    form.validateField("password")
                }
            }

            AppButton(
                title: "ログイン",
                isLoading: form.isSubmitting,
                isDisabled: !form.isValid
            ) {
                Task {
                    await form.submit()
                }
            }
        }
        .padding()
    }
}
```

---

## サニタイズ

### 入力のサニタイズ

```typescript
// TypeScript
export const Sanitizer = {
  /**
   * 前後の空白を除去
   */
  trim(value: string): string {
    return value.trim();
  },

  /**
   * 連続する空白を1つに
   */
  normalizeWhitespace(value: string): string {
    return value.replace(/\s+/g, ' ').trim();
  },

  /**
   * HTMLタグを除去
   */
  stripHtml(value: string): string {
    return value.replace(/<[^>]*>/g, '');
  },

  /**
   * 制御文字を除去
   */
  stripControlChars(value: string): string {
    return value.replace(/[\x00-\x1F\x7F]/g, '');
  },

  /**
   * メールアドレスを正規化
   */
  normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  },

  /**
   * 電話番号を正規化（数字のみ）
   */
  normalizePhone(phone: string): string {
    return phone.replace(/[^\d]/g, '');
  },
};
```

```swift
// Swift
enum Sanitizer {
    /// 前後の空白を除去
    static func trim(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 連続する空白を1つに
    static func normalizeWhitespace(_ value: String) -> String {
        value.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// HTMLタグを除去
    static func stripHtml(_ value: String) -> String {
        value.replacingOccurrences(
            of: "<[^>]*>",
            with: "",
            options: .regularExpression
        )
    }

    /// メールアドレスを正規化
    static func normalizeEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// 電話番号を正規化（数字のみ）
    static func normalizePhone(_ phone: String) -> String {
        phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
```

---

## エラーメッセージ定数

```typescript
// TypeScript
export const ValidationMessages = {
  required: (field: string) => `${field}を入力してください`,
  minLength: (field: string, min: number) =>
    `${field}は${min}文字以上で入力してください`,
  maxLength: (field: string, max: number) =>
    `${field}は${max}文字以内で入力してください`,
  invalidEmail: 'メールアドレスの形式が正しくありません',
  invalidPassword: 'パスワードは8文字以上で入力してください',
  passwordMismatch: 'パスワードが一致しません',
  invalidFormat: (field: string) => `${field}の形式が正しくありません`,
  selectRequired: (field: string) => `${field}を選択してください`,
} as const;
```

```swift
// Swift
enum ValidationMessages {
    static func required(_ field: String) -> String {
        "\(field)を入力してください"
    }

    static func minLength(_ field: String, min: Int) -> String {
        "\(field)は\(min)文字以上で入力してください"
    }

    static func maxLength(_ field: String, max: Int) -> String {
        "\(field)は\(max)文字以内で入力してください"
    }

    static let invalidEmail = "メールアドレスの形式が正しくありません"
    static let invalidPassword = "パスワードは8文字以上で入力してください"
    static let passwordMismatch = "パスワードが一致しません"

    static func invalidFormat(_ field: String) -> String {
        "\(field)の形式が正しくありません"
    }

    static func selectRequired(_ field: String) -> String {
        "\(field)を選択してください"
    }
}
```

---

## チェックリスト

- [ ] 全入力フィールドにバリデーションが設定されているか
- [ ] エラーメッセージが具体的で解決策を示しているか
- [ ] リアルタイム検証が適切に動作しているか
- [ ] サーバーサイドでも検証を行っているか
- [ ] 入力値のサニタイズを行っているか
- [ ] アクセシビリティ（エラー通知）に対応しているか
