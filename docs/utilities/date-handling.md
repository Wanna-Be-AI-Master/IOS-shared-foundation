# 日付・時間処理ガイド

## 概要

日付・時間の処理に関する標準パターンを定義する。

---

## 基本原則

### 1. タイムゾーン

- **サーバー/DB**: UTC で保存
- **クライアント表示**: ローカルタイムゾーン（デフォルト: Asia/Tokyo）
- **API通信**: ISO 8601形式（UTC）

### 2. フォーマット

| 用途 | フォーマット | 例 |
|------|-------------|-----|
| API通信 | ISO 8601 | `2024-12-26T10:30:00.000Z` |
| DB保存 | TIMESTAMPTZ | `2024-12-26 10:30:00+00` |
| 表示（日本） | 年月日 | `2024年12月26日` |

---

## タイムゾーン設定

### デフォルトタイムゾーン

```typescript
// TypeScript
export const DEFAULT_TIMEZONE = 'Asia/Tokyo';
```

```swift
// Swift
let defaultTimeZone = TimeZone(identifier: "Asia/Tokyo")!
```

### Supabase設定

```sql
-- セッションタイムゾーンを設定
SET timezone = 'Asia/Tokyo';

-- または、アプリで常にUTCを使用し、表示時に変換
```

---

## 日付フォーマット

### 標準フォーマット一覧

| 名前 | パターン | 例 | 用途 |
|------|----------|-----|------|
| `full` | `yyyy年M月d日 (E)` | `2024年12月26日 (木)` | 詳細表示 |
| `long` | `yyyy年M月d日` | `2024年12月26日` | 標準表示 |
| `medium` | `M月d日` | `12月26日` | 年を省略 |
| `short` | `M/d` | `12/26` | コンパクト |
| `time` | `HH:mm` | `10:30` | 時間のみ |
| `datetime` | `M月d日 HH:mm` | `12月26日 10:30` | 日時 |

### TypeScript実装

```typescript
import { format, formatDistanceToNow, isToday, isYesterday } from 'date-fns';
import { ja } from 'date-fns/locale';

// 定数
const TIMEZONE = 'Asia/Tokyo';

// フォーマッター
export const DateFormatter = {
  /**
   * フル形式（2024年12月26日 (木)）
   */
  full(date: Date): string {
    return format(date, 'yyyy年M月d日 (E)', { locale: ja });
  },

  /**
   * 長い形式（2024年12月26日）
   */
  long(date: Date): string {
    return format(date, 'yyyy年M月d日', { locale: ja });
  },

  /**
   * 中間形式（12月26日）
   */
  medium(date: Date): string {
    return format(date, 'M月d日', { locale: ja });
  },

  /**
   * 短い形式（12/26）
   */
  short(date: Date): string {
    return format(date, 'M/d');
  },

  /**
   * 時間のみ（10:30）
   */
  time(date: Date): string {
    return format(date, 'HH:mm');
  },

  /**
   * 日時（12月26日 10:30）
   */
  datetime(date: Date): string {
    return format(date, 'M月d日 HH:mm', { locale: ja });
  },

  /**
   * ISO形式（API用）
   */
  iso(date: Date): string {
    return date.toISOString();
  },
};
```

### Swift実装

```swift
import Foundation

enum DateFormatter {
    private static let jaLocale = Locale(identifier: "ja_JP")
    private static let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!

    /// フル形式（2024年12月26日 (木)）
    static func full(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.locale = jaLocale
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "yyyy年M月d日 (E)"
        return formatter.string(from: date)
    }

    /// 長い形式（2024年12月26日）
    static func long(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.locale = jaLocale
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }

    /// 中間形式（12月26日）
    static func medium(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.locale = jaLocale
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }

    /// 短い形式（12/26）
    static func short(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    /// 時間のみ（10:30）
    static func time(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// 日時（12月26日 10:30）
    static func datetime(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.locale = jaLocale
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }

    /// ISO形式（API用）
    static func iso(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
```

---

## 相対時間表示

### パターン

| 経過時間 | 表示 |
|----------|------|
| 1分未満 | `たった今` |
| 1-59分 | `X分前` |
| 1-23時間 | `X時間前` |
| 昨日 | `昨日` |
| 2-6日 | `X日前` |
| 7日以上 | 日付表示（12月26日） |

### TypeScript実装

```typescript
import {
  differenceInMinutes,
  differenceInHours,
  differenceInDays,
  isToday,
  isYesterday,
} from 'date-fns';

/**
 * 相対時間を取得
 */
export function getRelativeTime(date: Date): string {
  const now = new Date();
  const diffMinutes = differenceInMinutes(now, date);
  const diffHours = differenceInHours(now, date);
  const diffDays = differenceInDays(now, date);

  if (diffMinutes < 1) {
    return 'たった今';
  }

  if (diffMinutes < 60) {
    return `${diffMinutes}分前`;
  }

  if (diffHours < 24 && isToday(date)) {
    return `${diffHours}時間前`;
  }

  if (isYesterday(date)) {
    return '昨日';
  }

  if (diffDays < 7) {
    return `${diffDays}日前`;
  }

  // 7日以上は日付表示
  return DateFormatter.medium(date);
}

/**
 * スマート日時表示（時間も含む）
 */
export function getSmartDateTime(date: Date): string {
  if (isToday(date)) {
    return `今日 ${DateFormatter.time(date)}`;
  }

  if (isYesterday(date)) {
    return `昨日 ${DateFormatter.time(date)}`;
  }

  const diffDays = differenceInDays(new Date(), date);
  if (diffDays < 7) {
    return DateFormatter.datetime(date);
  }

  return DateFormatter.long(date);
}
```

### Swift実装

```swift
import Foundation

/// 相対時間を取得
func getRelativeTime(_ date: Date) -> String {
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents(
        [.minute, .hour, .day],
        from: date,
        to: now
    )

    let minutes = components.minute ?? 0
    let hours = components.hour ?? 0
    let days = components.day ?? 0

    if minutes < 1 && hours == 0 && days == 0 {
        return "たった今"
    }

    if hours == 0 && days == 0 {
        return "\(minutes)分前"
    }

    if days == 0 {
        return "\(hours)時間前"
    }

    if calendar.isDateInYesterday(date) {
        return "昨日"
    }

    if days < 7 {
        return "\(days)日前"
    }

    return DateFormatter.medium(date)
}

/// スマート日時表示
func getSmartDateTime(_ date: Date) -> String {
    let calendar = Calendar.current

    if calendar.isDateInToday(date) {
        return "今日 \(DateFormatter.time(date))"
    }

    if calendar.isDateInYesterday(date) {
        return "昨日 \(DateFormatter.time(date))"
    }

    let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
    if days < 7 {
        return DateFormatter.datetime(date)
    }

    return DateFormatter.long(date)
}
```

---

## 日付計算

### 連続日数（ストリーク）計算

```typescript
/**
 * 連続記録日数を計算
 */
export function calculateStreak(dates: Date[]): number {
  if (dates.length === 0) return 0;

  // 日付を降順ソート
  const sortedDates = [...dates].sort((a, b) => b.getTime() - a.getTime());

  // 今日または昨日から始まっているか確認
  const today = startOfDay(new Date());
  const latestDate = startOfDay(sortedDates[0]);
  const daysDiff = differenceInDays(today, latestDate);

  if (daysDiff > 1) return 0; // 連続が途切れている

  let streak = 1;
  let currentDate = latestDate;

  for (let i = 1; i < sortedDates.length; i++) {
    const prevDate = startOfDay(sortedDates[i]);
    const diff = differenceInDays(currentDate, prevDate);

    if (diff === 1) {
      streak++;
      currentDate = prevDate;
    } else if (diff > 1) {
      break;
    }
    // diff === 0 の場合は同じ日なのでスキップ
  }

  return streak;
}
```

### 月初・月末

```typescript
import { startOfMonth, endOfMonth, format } from 'date-fns';

// 月初
const firstDay = startOfMonth(new Date());

// 月末
const lastDay = endOfMonth(new Date());

// 今月のラベル
const monthLabel = format(new Date(), 'yyyy年M月', { locale: ja });
```

```swift
// 月初
let firstDay = Calendar.current.date(
    from: Calendar.current.dateComponents([.year, .month], from: Date())
)!

// 月末
let lastDay = Calendar.current.date(
    byAdding: DateComponents(month: 1, day: -1),
    to: firstDay
)!
```

---

## 日付のパース

### ISO文字列からDateへ

```typescript
/**
 * ISO文字列をDateに変換
 */
export function parseISO(isoString: string): Date {
  return new Date(isoString);
}

/**
 * Supabaseのタイムスタンプを変換
 */
export function parseTimestamp(timestamp: string): Date {
  return new Date(timestamp);
}
```

```swift
/// ISO文字列をDateに変換
func parseISO(_ isoString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: isoString)
}
```

### snake_case → camelCase 変換

```typescript
/**
 * Supabaseレスポンスの日付フィールドを変換
 */
export function transformDates<T extends Record<string, unknown>>(
  data: T,
  dateFields: string[]
): T {
  const result = { ...data };

  for (const field of dateFields) {
    const value = result[field];
    if (typeof value === 'string') {
      result[field] = new Date(value) as T[keyof T];
    }
  }

  return result;
}

// 使用例
const user = transformDates(rawUser, ['created_at', 'updated_at']);
```

---

## 通知時間の処理

### 時間文字列のパース

```typescript
/**
 * "HH:mm" 形式を分解
 */
export function parseTimeString(timeString: string): { hour: number; minute: number } {
  const [hour, minute] = timeString.split(':').map(Number);
  return { hour, minute };
}

/**
 * 次の通知日時を計算
 */
export function getNextNotificationDate(timeString: string): Date {
  const { hour, minute } = parseTimeString(timeString);
  const now = new Date();
  const notification = new Date();

  notification.setHours(hour, minute, 0, 0);

  // 既に過ぎていたら翌日
  if (notification <= now) {
    notification.setDate(notification.getDate() + 1);
  }

  return notification;
}
```

```swift
/// 時間文字列をパース
func parseTimeString(_ timeString: String) -> (hour: Int, minute: Int)? {
    let components = timeString.split(separator: ":").compactMap { Int($0) }
    guard components.count == 2 else { return nil }
    return (hour: components[0], minute: components[1])
}

/// 次の通知日時を計算
func getNextNotificationDate(timeString: String) -> Date? {
    guard let (hour, minute) = parseTimeString(timeString) else { return nil }

    let now = Date()
    var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
    components.hour = hour
    components.minute = minute
    components.second = 0

    guard var notification = Calendar.current.date(from: components) else { return nil }

    if notification <= now {
        notification = Calendar.current.date(byAdding: .day, value: 1, to: notification)!
    }

    return notification
}
```

---

## ライブラリ推奨

### TypeScript

| ライブラリ | 用途 | サイズ |
|-----------|------|--------|
| `date-fns` | 日付操作全般 | Tree-shakable |
| `date-fns-tz` | タイムゾーン | 追加モジュール |

### Swift

標準の `Foundation` で十分対応可能

---

## チェックリスト

- [ ] タイムゾーン処理が適切か
- [ ] API通信はUTC/ISO8601を使用しているか
- [ ] 表示時にローカライズされているか
- [ ] 相対時間表示が実装されているか
- [ ] 日付パースでエラーハンドリングしているか
