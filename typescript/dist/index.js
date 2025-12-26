/**
 * @anthropic/shared-foundation
 * 共有基盤パッケージ
 *
 * koukan-nikki-app と katazuke-app で共通して使用する
 * 型定義、ユーティリティ、定数を提供
 */
// Types
export * from './types';
// Utils (TIMEZONEは定数からのみエクスポート)
export { DATE_FORMATS, formatDate, formatRelativeTime, formatDateTime, isToday, isYesterday, startOfDay, getDaysDifference, toDate, toISOString, toTimestamp, } from './utils/date';
export * from './utils/error';
export * from './utils/validation';
export * from './utils/format';
// Constants
export * from './constants';
//# sourceMappingURL=index.js.map