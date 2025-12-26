/**
 * @anthropic/shared-foundation
 * 共有基盤パッケージ
 *
 * koukan-nikki-app と katazuke-app で共通して使用する
 * 型定義、ユーティリティ、定数を提供
 */
export * from './types';
export { DATE_FORMATS, type DateFormatStyle, formatDate, formatRelativeTime, formatDateTime, isToday, isYesterday, startOfDay, getDaysDifference, toDate, toISOString, toTimestamp, } from './utils/date';
export * from './utils/error';
export * from './utils/validation';
export * from './utils/format';
export * from './constants';
//# sourceMappingURL=index.d.ts.map