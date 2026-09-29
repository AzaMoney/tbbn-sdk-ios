# Changelog

## 0.3.0 — 2026-09-29

### Breaking

- Billing is per Business: `billing.getSubscription`, `changeTier`, `cancelSubscription` and
  `usageSummary` take `businessId:`, and `createSubscription` takes a `businessId`.
- Removed `sellers.requestLinkOtp`, `verifyEmail` and `verifyPhone` — seller linking is
  `sellers.verify` plus the OAuth flow in `oauthLink`.
- `webhooks.disableSubscription(id:)` no longer takes a merchant id, and
  `webhooks.listDeliveries(subscriptionId:)` requires the subscription id.

### Added

- `businesses`, `branches` (including `bulkUpsert`) and `businessMerchantLinks`.
- `space` — search, Space details, booking terms and bookings (create, list, payment info,
  cancel, reschedule, host cancel).
- `billing`: `changePlan`, `suspension`, `completeCheckout`, `wallet`, `topUp`,
  `usageBreakdown`, `statement`.
- Business (TBBN Space) webhooks on `webhooks`.
- `tradeSessions`: close unreciprocated, confirm/fail scheduling, excuse fulfilment, acknowledge
  hold terms, and Space proposals.
- `oauthClients`, `oauthLink`, `merchantFeed`, `reviews`, `status`, `sellers.createHeadless` and
  `sellers.listForMerchant`.
- `TbbnApiError.details`.

### Fixed

- Errors carry the API's real message instead of "Unknown error".

## 0.2.0 — 2026-09-15

- Removed the `reservations` resource group. Reservations are managed by the platform for the duration of a trade session and are no longer reachable through the public API.
- Added a LICENSE (MIT), this changelog, and a runnable example under `example/`.

## 0.1.0

Initial release — a client for every public resource group of the TBBN Platform API, plus `verifyWebhookSignature`.
