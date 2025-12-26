// SharedFoundation
// iOS共通基盤ライブラリ
//
// かろやか（katazuke-app）とむすび（koukan-nikki-app）で共有する
// 共通コンポーネントを提供します。
//
// ## 使い方
//
// ```swift
// import SharedFoundation
//
// // モデル
// let user = User.createAnonymous()
//
// // 日付フォーマット
// let dateString = DateUtils.format(Date(), format: .fullDate)
//
// // バリデーション
// let result = ValidationUtils.displayName("ユーザー名")
//
// // 制限チェック
// let limit = AppLimits.Record.dailyLimit(for: .free)
//
// // デザイントークン
// let color = DesignTokens.Colors.primaryKaroyaka
// ```

import Foundation

// MARK: - Public Exports

// Models
@_exported import struct Foundation.UUID
@_exported import struct Foundation.Date

// このファイルはモジュールのエントリーポイントです。
// 各コンポーネントは個別のファイルで定義されています：
//
// Models/
//   - BaseEntity.swift: 基底エンティティプロトコル
//   - User.swift: ユーザーモデル
//
// Utils/
//   - AppError.swift: 共通エラー定義
//   - DateUtils.swift: 日付ユーティリティ
//   - ValidationUtils.swift: バリデーションユーティリティ
//
// Constants/
//   - AppLimits.swift: 機能制限値
//   - DesignTokens.swift: デザイントークン
