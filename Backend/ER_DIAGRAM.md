# Smart UPI Merchant Assistant - ER Diagram

This document illustrates the Entity-Relationship (ER) diagram for the Supabase database.

```mermaid
erDiagram
    merchants {
        uuid id PK "Default: gen_random_uuid()"
        text name "Nullable"
        text phone "Unique, Not Null"
        timestamp created_at "Default: now()"
    }

    transactions {
        uuid id PK "Default: gen_random_uuid()"
        uuid merchant_id FK "Not Null"
        numeric amount "Not Null"
        text sender "Not Null"
        text status "Not Null"
        timestamp created_at "Default: now()"
    }

    device_status {
        uuid id PK "Default: gen_random_uuid()"
        uuid merchant_id FK "Unique, Not Null"
        text status "Not Null"
        timestamp last_seen "Nullable"
    }

    %% Relationships
    merchants ||--o{ transactions : "receives"
    merchants ||--|| device_status : "owns"

```

### Relationship Breakdown:
1. **merchants ↔ transactions**
   - **One-to-Many**: A single `merchant` can have many `transactions`.
   - The `merchant_id` in `transactions` is a foreign key referencing `merchants.id`.

2. **merchants ↔ device_status**
   - **One-to-One**: A single `merchant` currently maps to exactly one active `device_status` row tracking their ESP32 soundbox.
   - The `merchant_id` in `device_status` is a unique foreign key referencing `merchants.id`.
