# Supabase Schema Setup Guide

To set up your Supabase database for the Smart UPI Merchant Assistant backend, you need to create the following three tables in the `public` schema.

## 1. Table: `merchants`
This table stores the merchant profiles.

| Column Name | Data Type | Constraints               | Description                             |
| ----------- | --------- | ------------------------- | --------------------------------------- |
| `id`        | uuid      | Primary Key, Default: gen_random_uuid() | Unique identifier for the merchant. |
| `name`      | text      | Nullable                  | The name of the merchant.               |
| `phone`     | text      | Unique, Not Null          | The merchant's phone number (used for login). |
| `created_at`| timestamp | Default: now()            | When the merchant profile was created.  |

---

## 2. Table: `transactions`
This table stores all payment transactions received from the Flutter app.

| Column Name   | Data Type | Constraints               | Description                                   |
| ------------- | --------- | ------------------------- | --------------------------------------------- |
| `id`          | uuid      | Primary Key, Default: gen_random_uuid() | Unique identifier for the transaction.        |
| `merchant_id` | uuid      | Foreign Key (`merchants.id`), Not Null | References the merchant who received the payment.|
| `amount`      | numeric   | Not Null                  | The payment amount.                           |
| `sender`      | text      | Not Null                  | The name or UPI ID of the sender.             |
| `status`      | text      | Not Null                  | Status of the transaction (e.g., `success`, `failed`). |
| `created_at`  | timestamp | Default: now()            | When the transaction was recorded.            |

---

## 3. Table: `device_status`
This table maintains the online/offline status of the ESP32 IoT devices.

| Column Name   | Data Type | Constraints               | Description                                   |
| ------------- | --------- | ------------------------- | --------------------------------------------- |
| `id`          | uuid      | Primary Key, Default: gen_random_uuid() | Unique identifier for the device status record. |
| `merchant_id` | uuid      | Foreign Key (`merchants.id`), Unique, Not Null | References the merchant owning the device.    |
| `status`      | text      | Not Null                  | The current status (`online` or `offline`).   |
| `last_seen`   | timestamp | Nullable                  | Timestamp of the last successful ping.        |

---

### Important Notes:
- Make sure Row Level Security (RLS) policies are correctly configured if you access Supabase directly from the frontend in the future. Since the backend proxy currently uses a Service Role Key, it bypasses RLS.
- For `device_status`, the `merchant_id` column should be marked as **Unique** to allow the `upsert` mechanism to update the existing row rather than creating a new one when the device status changes.
