/**
 * バリデーションユーティリティ
 * 入力検証、フォームバリデーション
 */
// ========================================
// 基本バリデーション
// ========================================
/**
 * 成功結果を作成
 */
export function valid() {
    return { isValid: true, error: null };
}
/**
 * エラー結果を作成
 */
export function invalid(error) {
    return { isValid: false, error };
}
/**
 * 必須チェック
 */
export function validateRequired(value, fieldName = 'この項目') {
    if (!value || !value.trim()) {
        return invalid(`${fieldName}を入力してください`);
    }
    return valid();
}
/**
 * 文字数チェック
 */
export function validateLength(value, options) {
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
export function validateEmail(email) {
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
export function validateDisplayName(displayName, maxLength = 20) {
    const required = validateRequired(displayName, '表示名');
    if (!required.isValid)
        return required;
    const length = validateLength(displayName, {
        min: 1,
        max: maxLength,
        fieldName: '表示名',
    });
    if (!length.isValid)
        return length;
    return valid();
}
/**
 * 招待コードチェック
 */
export function validateInviteCode(code, expectedLength = 6) {
    const required = validateRequired(code, '招待コード');
    if (!required.isValid)
        return required;
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
export function validateContent(content, options = {}) {
    const { minLength = 1, maxLength = 10000, fieldName = '本文', } = options;
    const required = validateRequired(content, fieldName);
    if (!required.isValid)
        return required;
    const length = validateLength(content.trim(), {
        min: minLength,
        max: maxLength,
        fieldName,
    });
    if (!length.isValid)
        return length;
    return valid();
}
// ========================================
// 複合バリデーション
// ========================================
/**
 * 複数のバリデーターを順番に実行
 */
export function composeValidators(...validators) {
    return (value) => {
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
export function validateForm(values, validators) {
    const errors = {};
    for (const key of Object.keys(validators)) {
        const validator = validators[key];
        if (validator) {
            const result = validator(values[key]);
            errors[key] = result.error;
        }
        else {
            errors[key] = null;
        }
    }
    return errors;
}
/**
 * フォームエラーがあるかどうかを判定
 */
export function hasFormErrors(errors) {
    return Object.values(errors).some((error) => error !== null);
}
//# sourceMappingURL=validation.js.map