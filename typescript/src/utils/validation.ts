/**
 * バリデーションユーティリティ
 * 入力検証、フォームバリデーション
 */

// ========================================
// 型定義
// ========================================

/**
 * バリデーション結果
 */
export interface ValidationResult {
  /** 有効かどうか */
  isValid: boolean;
  /** エラーメッセージ */
  error: string | null;
}

/**
 * バリデーター関数型
 */
export type Validator<T = string> = (value: T) => ValidationResult;

// ========================================
// 基本バリデーション
// ========================================

/**
 * 成功結果を作成
 */
export function valid(): ValidationResult {
  return { isValid: true, error: null };
}

/**
 * エラー結果を作成
 */
export function invalid(error: string): ValidationResult {
  return { isValid: false, error };
}

/**
 * 必須チェック
 */
export function validateRequired(
  value: string,
  fieldName = 'この項目'
): ValidationResult {
  if (!value || !value.trim()) {
    return invalid(`${fieldName}を入力してください`);
  }
  return valid();
}

/**
 * 文字数チェック
 */
export function validateLength(
  value: string,
  options: {
    min?: number;
    max?: number;
    fieldName?: string;
  }
): ValidationResult {
  const { min, max, fieldName = 'この項目' } = options;
  const length = value.length;

  if (min !== undefined && length < min) {
    return invalid(`${fieldName}は${min}文字以上で入力してください`);
  }

  if (max !== undefined && length > max) {
    return invalid(`${fieldName}は${max}文字以内で入力してください`);
  }

  return valid();
}

/**
 * メールアドレスチェック
 */
export function validateEmail(email: string): ValidationResult {
  if (!email) {
    return invalid('メールアドレスを入力してください');
  }

  // 簡易的なメール形式チェック
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return invalid('正しいメールアドレスを入力してください');
  }

  return valid();
}

// ========================================
// アプリ固有バリデーション
// ========================================

/**
 * 表示名チェック
 */
export function validateDisplayName(
  displayName: string,
  maxLength = 20
): ValidationResult {
  const required = validateRequired(displayName, '表示名');
  if (!required.isValid) return required;

  const length = validateLength(displayName, {
    min: 1,
    max: maxLength,
    fieldName: '表示名',
  });
  if (!length.isValid) return length;

  return valid();
}

/**
 * 招待コードチェック
 */
export function validateInviteCode(
  code: string,
  expectedLength = 6
): ValidationResult {
  const required = validateRequired(code, '招待コード');
  if (!required.isValid) return required;

  // 英数字のみ
  const alphanumericRegex = /^[A-Z0-9]+$/i;
  if (!alphanumericRegex.test(code)) {
    return invalid('招待コードは英数字のみです');
  }

  if (code.length !== expectedLength) {
    return invalid(`招待コードは${expectedLength}文字です`);
  }

  return valid();
}

/**
 * コンテンツ（本文）チェック
 */
export function validateContent(
  content: string,
  options: {
    minLength?: number;
    maxLength?: number;
    fieldName?: string;
  } = {}
): ValidationResult {
  const {
    minLength = 1,
    maxLength = 10000,
    fieldName = '本文',
  } = options;

  const required = validateRequired(content, fieldName);
  if (!required.isValid) return required;

  const length = validateLength(content.trim(), {
    min: minLength,
    max: maxLength,
    fieldName,
  });
  if (!length.isValid) return length;

  return valid();
}

// ========================================
// 複合バリデーション
// ========================================

/**
 * 複数のバリデーターを順番に実行
 */
export function composeValidators<T>(
  ...validators: Validator<T>[]
): Validator<T> {
  return (value: T): ValidationResult => {
    for (const validator of validators) {
      const result = validator(value);
      if (!result.isValid) {
        return result;
      }
    }
    return valid();
  };
}

/**
 * フォーム全体をバリデーション
 */
export function validateForm<T extends Record<string, unknown>>(
  values: T,
  validators: Partial<Record<keyof T, Validator<T[keyof T]>>>
): Record<keyof T, string | null> {
  const errors = {} as Record<keyof T, string | null>;

  for (const key of Object.keys(validators) as Array<keyof T>) {
    const validator = validators[key];
    if (validator) {
      const result = validator(values[key]);
      errors[key] = result.error;
    } else {
      errors[key] = null;
    }
  }

  return errors;
}

/**
 * フォームエラーがあるかどうかを判定
 */
export function hasFormErrors(
  errors: Record<string, string | null>
): boolean {
  return Object.values(errors).some((error) => error !== null);
}
