/**
 * バリデーションユーティリティ
 * 入力検証、フォームバリデーション
 */
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
/**
 * 成功結果を作成
 */
export declare function valid(): ValidationResult;
/**
 * エラー結果を作成
 */
export declare function invalid(error: string): ValidationResult;
/**
 * 必須チェック
 */
export declare function validateRequired(value: string, fieldName?: string): ValidationResult;
/**
 * 文字数チェック
 */
export declare function validateLength(value: string, options: {
    min?: number;
    max?: number;
    fieldName?: string;
}): ValidationResult;
/**
 * メールアドレスチェック
 */
export declare function validateEmail(email: string): ValidationResult;
/**
 * 表示名チェック
 */
export declare function validateDisplayName(displayName: string, maxLength?: number): ValidationResult;
/**
 * 招待コードチェック
 */
export declare function validateInviteCode(code: string, expectedLength?: number): ValidationResult;
/**
 * コンテンツ（本文）チェック
 */
export declare function validateContent(content: string, options?: {
    minLength?: number;
    maxLength?: number;
    fieldName?: string;
}): ValidationResult;
/**
 * 複数のバリデーターを順番に実行
 */
export declare function composeValidators<T>(...validators: Validator<T>[]): Validator<T>;
/**
 * フォーム全体をバリデーション
 */
export declare function validateForm<T extends Record<string, unknown>>(values: T, validators: Partial<Record<keyof T, Validator<T[keyof T]>>>): Record<keyof T, string | null>;
/**
 * フォームエラーがあるかどうかを判定
 */
export declare function hasFormErrors(errors: Record<string, string | null>): boolean;
//# sourceMappingURL=validation.d.ts.map