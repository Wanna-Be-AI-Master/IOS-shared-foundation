/**
 * 型定義エクスポート
 */

// User
export type {
  BaseUser,
  PremiumInfo,
  Timestamps,
  AppearanceMode,
  BaseUserSettings,
  UserCreateInput,
  UserUpdateInput,
} from './user';
export { isPremiumActive, getDisplayNameOrDefault } from './user';

// Auth
export type {
  AuthState,
  AppleAuthCredential,
  Session,
  AuthErrorCode,
} from './auth';
export { isSessionValid, getFullNameFromCredential } from './auth';

// API
export type {
  ApiResponse,
  ApiError,
  PaginatedResponse,
  PaginationInfo,
  ErrorCode,
} from './api';
export {
  createSuccessResponse,
  createErrorResponse,
  isSuccess,
  isError,
} from './api';

// Purchase
export type {
  SubscriptionPlan,
  PurchaseInfo,
  PricingInfo,
  ProductIds,
} from './purchase';
export {
  calculateYearlyDiscount,
  formatPrice,
  isPurchaseActive,
} from './purchase';
