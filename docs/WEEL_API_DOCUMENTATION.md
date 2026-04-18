# Weel API Documentation

> Base URL: `https://dev.weel.uz/api`
> Auth: Bearer token in `Authorization` header
> Content-Type: `application/json`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Properties](#2-properties)
3. [Bookings](#3-bookings)
4. [Calendar](#4-calendar)
5. [Payment / Cards](#5-payment--cards)
6. [Favorites](#6-favorites)
7. [Chat / Support](#7-chat--support)
8. [Stories](#8-stories)
9. [Notifications](#9-notifications)
10. [Reviews](#10-reviews)
11. [Location / Regions](#11-location--regions)
12. [Admin](#12-admin)
13. [Logs](#13-logs)
14. [Data Models](#14-data-models)

---

## 1. Authentication

The API uses JWT-based authentication with OTP phone verification. Two actor types: **Client** and **Partner**.

### 1.1 Client Registration

**Step 1: Send phone number**

```
POST /user/client/register/
```

| Field        | Type   | Required | Constraints       |
|-------------|--------|----------|-------------------|
| phone_number | string | Yes      | minLength: 1      |
| first_name  | string | No       | minLength: 2, maxLength: 64 |
| last_name   | string | No       | minLength: 2, maxLength: 64 |

**Step 2: Verify OTP**

```
POST /user/client/register/verify/
```

| Field        | Type   | Required | Constraints       |
|-------------|--------|----------|-------------------|
| phone_number | string | Yes      | minLength: 1      |
| otp_code    | string | Yes      | minLength: 4, maxLength: 4 |
| fcm_token   | string | No       | nullable          |
| device_type | string | No       | enum: `ios`, `android` |

**Step 3 (if needed): Resend OTP**

```
POST /user/client/register/resend/
```

| Field        | Type   | Required |
|-------------|--------|----------|
| phone_number | string | Yes      |

### 1.2 Client Login

**Step 1: Send phone number (triggers OTP)**

```
POST /user/client/login/
```

| Field        | Type   | Required |
|-------------|--------|----------|
| phone_number | string | Yes      |

**Step 2: Verify OTP**

```
POST /user/client/login/verify/
```

| Field        | Type   | Required | Constraints       |
|-------------|--------|----------|-------------------|
| phone_number | string | Yes      | minLength: 1      |
| otp_code    | string | Yes      | minLength: 4, maxLength: 4 |
| fcm_token   | string | No       | nullable          |
| device_type | string | No       | enum: `ios`, `android` |

**Response (on success):** Returns JWT `access` and `refresh` tokens.

**Resend OTP:**

```
POST /user/client/login/resend/
```

| Field        | Type   | Required |
|-------------|--------|----------|
| phone_number | string | Yes      |

### 1.3 Partner Registration

**Step 1: Send registration data**

```
POST /user/partner/register/
```

| Field        | Type   | Required | Constraints       |
|-------------|--------|----------|-------------------|
| phone_number | string | Yes      | minLength: 1      |
| username    | string | Yes      | minLength: 2      |
| first_name  | string | Yes      | minLength: 2, maxLength: 64 |
| last_name   | string | Yes      | minLength: 2, maxLength: 64 |
| email       | string | No       | email, minLength: 1 |

**Step 2: Verify OTP**

```
POST /user/partner/register/verify/
```

| Field        | Type   | Required | Constraints       |
|-------------|--------|----------|-------------------|
| phone_number | string | Yes      | minLength: 1      |
| otp_code    | string | Yes      | minLength: 4, maxLength: 4 |
| fcm_token   | string | No       | nullable          |
| device_type | string | No       | enum: `ios`, `android` |

**Resend OTP:**

```
POST /user/partner/register/resend/
```

### 1.4 Partner Login

Same flow as client login but with partner endpoints:

```
POST /user/partner/login/          # Send phone
POST /user/partner/login/verify/   # Verify OTP
POST /user/partner/login/resend/   # Resend OTP
```

### 1.5 Token Refresh

```
POST /user/refresh/
```

| Field   | Type   | Required |
|---------|--------|----------|
| refresh | string | Yes      |

### 1.6 Logout

```
POST /user/client/logout/    # Client logout
POST /user/partner/logout/   # Partner logout
```

### 1.7 Profile

**Get client profile:**

```
GET /user/client/profile/
```

Response: `ClientProfile` (see [Models](#14-data-models))

**Update client profile:**

```
PUT|PATCH /user/client/profile/update/
```

**Get partner profile:**

```
GET /user/partner/profile/
```

Response: `PartnerProfile` (see [Models](#14-data-models))

**Update partner profile:**

```
PUT|PATCH /user/partner/profile/update/
```

### 1.8 Delete Account

```
DELETE /user/account/              # Delete client or partner account (irreversible)
DELETE /user/partner/profile/      # Delete partner account (irreversible)
```

---

## 2. Properties

Properties are the core entity. Two types: **Apartment** and **Cottage**.

### 2.1 List Apartments

```
GET /property/apartments/
```

**Query Parameters:**

| Param       | Type    | Description                                       |
|------------|---------|---------------------------------------------------|
| search     | string  | Text search                                        |
| region_id  | integer | Filter by region                                   |
| district_id| integer | Filter by district                                 |
| corporate  | boolean | Filter corporate-eligible                          |
| min_price  | number  | Minimum price filter                               |
| max_price  | number  | Maximum price filter                               |
| currency   | string  | Currency (`USD`, `UZS`)                           |
| sort       | string  | `price_high`, `price_low`, `rating_high`, `rating_low`, `reviews_high`, `reviews_low`, `title_asc`, `title_desc`, `corporate_yes`, `corporate_no` |
| ordering   | string  | Ordering field                                     |
| from_date  | date    | Availability filter from date                      |
| limit      | integer | Limit results                                      |

Response: Array of `ApartmentList`

### 2.2 List Cottages

```
GET /property/cottages/
```

Same query parameters as apartments.

Response: Array of `CottageList`

### 2.3 Get Apartment Detail

```
GET /property/apartments/{property_id}/
```

Response: Full apartment object with `property_location`, details, images, etc.

### 2.4 Get Cottage Detail

```
GET /property/cottages/{property_id}/
```

### 2.5 Create Apartment (Partner)

```
POST /property/apartments/
```

| Field                        | Type    | Required | Notes                     |
|-----------------------------|---------|----------|---------------------------|
| title                       | string  | No       |                           |
| price                       | decimal | No       |                           |
| currency                    | string  | No       | `USD`, `UZS`             |
| minimum_weekend_day_stay    | boolean | No       | default: false            |
| weekend_only_sunday_inclusive| boolean | No       | default: false            |
| property_location           | object  | No       | Key-value string map      |
| property_detail             | object  | No       | Key-value string map      |
| latitude                    | decimal | No       | nullable                  |
| longitude                   | decimal | No       | nullable                  |
| country                     | string  | No       | nullable                  |
| city                        | string  | No       | nullable                  |
| services                    | array   | No       | Array of nullable strings |
| property_services           | array   | No       | Array of nullable strings |
| region_id                   | string  | No       | nullable                  |
| district_id                 | string  | No       | nullable                  |
| prefecture_id               | uuid    | No       | nullable                  |
| img                         | object  | No       |                           |
| apartment_number            | string  | **Yes**  | minLength: 1              |
| home_number                 | string  | **Yes**  | minLength: 1              |
| entrance_number             | string  | **Yes**  | minLength: 1              |
| floor_number                | string  | **Yes**  | minLength: 1              |
| pass_code                   | string  | **Yes**  | minLength: 1              |

### 2.6 Create Cottage (Partner)

```
POST /property/cottages/
```

| Field                        | Type    | Required | Notes                     |
|-----------------------------|---------|----------|---------------------------|
| title                       | string  | No       |                           |
| price_per_person            | decimal | No       |                           |
| price_on_working_days       | decimal | No       |                           |
| price_on_weekends           | decimal | No       |                           |
| currency                    | string  | No       | `USD`, `UZS`             |
| minimum_weekend_day_stay    | boolean | No       | default: false            |
| weekend_only_sunday_inclusive| boolean | No       | default: false            |
| guests                      | integer | No       | nullable                  |
| rooms                       | integer | No       | nullable                  |
| beds                        | integer | No       | nullable                  |
| bathrooms                   | integer | No       | nullable                  |
| region                      | string  | No       | nullable                  |
| district                    | string  | No       | nullable                  |
| region_id                   | string  | No       | nullable                  |
| district_id                 | string  | No       | nullable                  |
| prefecture_id               | uuid    | No       | nullable                  |
| property_services           | array   | No       |                           |
| property_room               | object  | No       | Key-value string map      |
| img                         | object  | No       |                           |

### 2.7 Update/Delete Property (Partner)

```
PUT    /property/apartments/{property_id}/    # Full update
PATCH  /property/apartments/{property_id}/    # Partial update
DELETE /property/apartments/{property_id}/    # Delete

PUT    /property/cottages/{property_id}/      # Full update
PATCH  /property/cottages/{property_id}/      # Partial update
DELETE /property/cottages/{property_id}/      # Delete
```

### 2.8 Partner Properties

```
GET /property/partner/apartments/     # List partner's apartments
GET /property/partner/cottages/       # List partner's cottages
GET /property/partner/properties/     # List all partner's properties
GET /property/partner/properties/{property_id}/analytics/  # Property analytics
```

### 2.9 Property Images

```
POST   /property/apartments/{property_id}/images/          # Upload image (multipart)
PATCH  /property/apartments/{property_id}/images/{image_id}/  # Update image
DELETE /property/apartments/{property_id}/images/{image_id}/  # Delete image

POST   /property/cottages/{property_id}/images/            # Upload image (multipart)
PATCH  /property/cottages/{property_id}/images/{image_id}/    # Update image
DELETE /property/cottages/{property_id}/images/{image_id}/    # Delete image
```

### 2.10 Property Categories & Types

```
GET /property/categories/                                  # List categories
GET /property/categories/{category_id}/properties/         # Properties by category
GET /property/categories/{category_id}/properties/latest/  # Latest properties by category
GET /property/types/                                       # List property types
GET /property/services/                                    # List property services
```

### 2.11 Recommendations

```
GET /property/recommendations/       # Get property recommendations
POST /property/properties/filter-by-link/  # Filter properties by link
```

### 2.12 General Properties

```
GET  /property/properties/           # List all properties
POST /property/properties/           # Create property
```

---

## 3. Bookings

### 3.1 Client Bookings

**List client bookings:**

```
GET /booking/client/
```

| Param  | Type   | Description           |
|--------|--------|-----------------------|
| status | string | Filter by status      |

Response: Array of `RawClientBookingList`

**Create booking:**

```
POST /booking/client/
```

| Field       | Type    | Required | Constraints           |
|------------|---------|----------|-----------------------|
| property_id | uuid    | Yes      |                       |
| card_id    | string  | Yes      | minLength: 1          |
| check_in   | date    | Yes      |                       |
| check_out  | date    | Yes      |                       |
| adults     | integer | Yes      | minimum: 1            |
| children   | integer | No       | default: 0, minimum: 0|
| babies     | integer | No       | default: 0, max: 5    |

> Creates a PENDING booking and places a payment hold (UZS).

**Get booking details:**

```
GET /booking/client/{booking_id}/
```

**Cancel booking:**

```
POST /booking/client/{booking_id}/cancel/
```

### 3.2 Client Booking History

```
GET /booking/client/history/                     # List history
GET /booking/client/history/{booking_id}/        # History details
```

### 3.3 Partner Bookings

**List partner bookings:**

```
GET /booking/partner/
```

| Param  | Type   | Description      |
|--------|--------|------------------|
| status | string | Filter by status |

**Accept booking:**

```
POST /booking/partner/{booking_id}/accept/
```

**Cancel booking:**

```
POST /booking/partner/{booking_id}/cancel/
```

**Complete booking** (charges 50% of hold price):

```
POST /booking/partner/{booking_id}/complete/
```

**Mark no-show:**

```
POST /booking/partner/{booking_id}/no_show/
```

### 3.4 Admin Bookings

```
GET /booking/admin/bookings/
```

| Param     | Type    | Description                                             |
|-----------|---------|---------------------------------------------------------|
| search    | string  | Search by booking number or client phone                 |
| ordering  | string  | `created_at`, `check_in`, `status`. Prefix `-` for desc  |
| page      | integer | Page number                                              |
| page_size | integer | Results per page                                         |
| status    | string  | Filter by status                                         |

---

## 4. Calendar

### 4.1 Get Property Calendar

```
GET /booking/properties/{property_id}/calendar/
```

Response: Array of `RawCalendarDate`

### 4.2 Hold Dates (30 min)

Temporarily holds dates for a client during booking. Client has 30 minutes to complete payment.

```
POST /booking/properties/{property_id}/calendar/hold/
```

| Field     | Type | Required |
|-----------|------|----------|
| from_date | date | Yes      |
| to_date   | date | No       |

### 4.3 Release Held Dates

```
POST /booking/properties/{property_id}/calendar/unhold/
```

| Field     | Type | Required |
|-----------|------|----------|
| from_date | date | Yes      |
| to_date   | date | No       |

### 4.4 Block Dates (Partner)

```
POST /booking/properties/{property_id}/calendar/block/
```

| Field     | Type | Required |
|-----------|------|----------|
| from_date | date | Yes      |
| to_date   | date | No       |

### 4.5 Unblock Dates (Partner)

```
POST /booking/properties/{property_id}/calendar/unblock/
```

| Field     | Type | Required |
|-----------|------|----------|
| from_date | date | Yes      |
| to_date   | date | No       |

---

## 5. Payment / Cards

### 5.1 List Client Cards

```
GET /user/client/cards/
```

### 5.2 Add Card

```
POST /user/client/cards/
```

### 5.3 Verify Card

```
POST /user/client/cards/verify/
```

### 5.4 Resend Card Verification

```
POST /user/client/cards/resend/
```

### 5.5 Delete Card

```
DELETE /user/client/cards/{id}/
```

---

## 6. Favorites

### 6.1 List Favorites

```
GET /property/properties/favorites/
```

### 6.2 Add to Favorites

```
POST /property/apartments/{property_id}/favorite/
POST /property/cottages/{property_id}/favorite/
```

### 6.3 Remove from Favorites

```
DELETE /property/apartments/{property_id}/favorite/
DELETE /property/cottages/{property_id}/favorite/
```

---

## 7. Chat / Support

### 7.1 Get Conversations

```
GET /chat/conversations/
```

### 7.2 Get Messages with Partner

```
GET /chat/messages/{partner_id}/
```

### 7.3 Send Message

```
POST /chat/send/
```

| Field          | Type     | Required |
|----------------|----------|----------|
| id             | integer  | Yes      |
| conversation_id| integer  | Yes      |
| content        | string   | Yes      |
| created_at     | datetime | Yes      |
| updated_at     | datetime | Yes      |

### 7.4 Mark Messages as Read

```
POST /chat/read/
```

### 7.5 Get Admin Recipient (for Partner)

```
GET /chat/recipient/admin/
```

Returns the single active admin recipient for partner chat.

---

## 8. Stories

### 8.1 Public Stories

```
GET /story/public/stories/
```

> `property_type` parameter required; returns 404 without it.

### 8.2 Client Stories

```
GET /story/stories/
```

> `property_type` is required for clients; returns 404 without it.

### 8.3 Partner Stories

```
GET /story/partner/stories/     # All partner's stories (including unverified)
POST /story/stories/            # Create story (partners only)
DELETE /story/stories/{story_id}/  # Delete story (partners only, own stories)
```

### 8.4 Story Media

```
GET    /story/stories/{story_id}/{media_id}/    # Get media + count view
DELETE /story/stories/{story_id}/{media_id}/    # Delete media (partners only)
```

---

## 9. Notifications

### 9.1 Register FCM Token

**Client:**

```
POST /notification/device/
```

| Field       | Type   | Required | Constraints    |
|------------|--------|----------|----------------|
| fcm_token  | string | Yes      | maxLength: 255 |
| device_type| string | Yes      | `ios`, `android` |

**Partner:**

```
POST /notification/partner/device/
```

Same body as client.

### 9.2 Partner Notifications

**List notifications:**

```
GET /notification/partner/
```

| Param | Type    | Default | Max  |
|-------|---------|---------|------|
| page  | integer | 1       | -    |
| limit | integer | 20      | 100  |

**Mark as read:**

```
POST /notification/partner/read/
```

| Field            | Type          |
|-----------------|---------------|
| notification_ids | string array  |

**Mark all as read:**

```
POST /notification/partner/read-all/
```

---

## 10. Reviews

### 10.1 List Reviews

```
GET /property/apartments/{property_id}/reviews/        # Public reviews
GET /property/cottages/{property_id}/reviews/          # Public reviews
GET /property/apartments/{property_id}/partner/reviews/ # Partner reviews
GET /property/cottages/{property_id}/partner/reviews/   # Partner reviews
```

### 10.2 Create Review

```
POST /property/apartments/{property_id}/reviews/
POST /property/cottages/{property_id}/reviews/
```

---

## 11. Location / Regions

### 11.1 Get Full Location Tree

```
GET /property/location/
```

Response: `RegionsResponse` - nested structure of regions -> districts -> prefectures.

### 11.2 List Regions

```
GET /property/regions/
GET /property/regions/{region_id}/properties/   # Properties by region
```

### 11.3 List Districts

```
GET /property/districts/
```

### 11.4 List Prefectures

```
GET /property/prefectures/
GET /property/ /?district_id={id}&district_guid={guid}  # Prefectures by district
```

---

## 12. Admin

### 12.1 Admin Auth

```
POST /admin-auth/login/              # Admin login (staff/superuser only)
POST /admin-auth/token/refresh/      # Refresh admin tokens
GET  /admin-auth/me/                 # Get current admin info
POST /admin-auth/register/           # Create admin user (superuser only)
GET  /admin-auth/users/clients/      # List all clients
GET  /admin-auth/users/partners/     # List all partners
```

### 12.2 Admin Create User

```
POST /admin-auth/register/
```

| Field         | Type    | Required | Notes           |
|--------------|---------|----------|-----------------|
| email        | email   | Yes      | minLength: 1    |
| password     | string  | Yes      | minLength: 8    |
| first_name   | string  | No       |                 |
| last_name    | string  | No       |                 |
| is_staff     | boolean | No       | default: true   |
| is_superuser | boolean | No       | default: false  |

### 12.3 Partner Documents

```
POST /user/partner/documents/passport/   # Upload passport document
```

---

## 13. Logs

```
POST /logs/frontend/
```

Accepts frontend (browser) logs. Displayed in Grafana/Loki.

---

## 14. Data Models

### ClientProfile

| Field        | Type    | Notes       |
|-------------|---------|-------------|
| id          | integer | readOnly    |
| guid        | string  | readOnly    |
| phone_number| string  | readOnly    |
| first_name  | string  | maxLen: 255 |
| last_name   | string  | maxLen: 255 |
| avatar      | string  | nullable    |

### PartnerProfile

| Field        | Type     | Notes       |
|-------------|----------|-------------|
| id          | integer  | readOnly    |
| guid        | string   | readOnly    |
| username    | string   | maxLen: 255 |
| first_name  | string   | maxLen: 255 |
| last_name   | string   | maxLen: 255 |
| phone_number| string   | readOnly    |
| avatar      | string   | nullable    |
| created_at  | datetime | readOnly    |

### ApartmentList

| Field                | Type    | Notes              |
|---------------------|---------|--------------------|
| guid                | uuid    |                    |
| title               | string  |                    |
| img                 | array   | Array of URLs      |
| price               | decimal | nullable           |
| currency            | string  | nullable           |
| latitude            | string  | nullable           |
| longitude           | string  | nullable           |
| country             | string  | nullable           |
| city                | string  | nullable           |
| property_location   | object  | Nested location    |
| services            | array   |                    |
| region_id           | integer | nullable           |
| district_id         | integer | nullable           |
| prefecture_id       | string  | nullable           |
| guests              | integer | nullable           |
| rooms               | integer | nullable           |
| average_rating      | number  | nullable           |
| is_favorite         | boolean |                    |
| is_allowed_corporate| boolean |                    |
| created_at          | datetime|                    |
| property_type_id    | uuid    |                    |
| property_type       | object  | Key-value          |

### CottageList

Same as `ApartmentList` plus:

| Field                  | Type    | Notes    |
|-----------------------|---------|----------|
| price_per_person      | decimal | nullable |
| price_on_working_days | decimal | nullable |
| price_on_weekends     | decimal | nullable |
| region                | object  | Nested   |
| district              | object  | Nested   |

### RawClientBookingList

| Field   | Type   | Notes           |
|---------|--------|-----------------|
| guid    | uuid   |                 |
| property| object | Nested property |
| partner | object | Nested partner  |
| status  | string |                 |

### RawPartnerBookingList

| Field              | Type     | Notes          |
|--------------------|----------|----------------|
| guid               | uuid     |                |
| property           | object   | Nested         |
| client             | object   | Nested         |
| check_in           | date     |                |
| check_out          | date     |                |
| adults             | integer  |                |
| children           | integer  |                |
| babies             | integer  |                |
| booking_price      | string   |                |
| booking_number     | string   |                |
| status             | string   |                |
| cancellation_reason| string   | nullable       |
| confirmed_at       | datetime | nullable       |
| cancelled_at       | datetime | nullable       |
| completed_at       | datetime | nullable       |

### RawCalendarDate

| Field  | Type   |
|--------|--------|
| date   | date   |
| status | string |

### ChatMessage

| Field           | Type     | Required |
|-----------------|----------|----------|
| id              | integer  | Yes      |
| conversation_id | integer  | Yes      |
| sender_id       | string   | No       |
| receiver_id     | string   | No       |
| sender_type     | string   | No       |
| receiver_type   | string   | No       |
| content         | string   | Yes      |
| is_read         | boolean  | No       |
| created_at      | datetime | Yes      |
| updated_at      | datetime | Yes      |

### RegionsResponse

```
{
  "regions": [
    {
      "id": integer,
      "guid": "uuid",
      "title": "string",
      "districts": [
        {
          "id": integer,
          "guid": "uuid",
          "title": "string",
          "prefectures": [
            {
              "guid": "uuid",
              "title": "string"
            }
          ]
        }
      ]
    }
  ]
}
```

---

## Booking Status Flow

```
PENDING -> CONFIRMED -> COMPLETED
                   |-> NO_SHOW
        |-> CANCELLED
```

- **PENDING**: Initial state after client creates booking
- **CONFIRMED**: Partner accepts the booking
- **COMPLETED**: Partner marks as completed (charges 50% of hold)
- **NO_SHOW**: Partner marks as no-show
- **CANCELLED**: Either client or partner cancels

---

## Common Error Responses

| Status | Meaning                          |
|--------|----------------------------------|
| 400    | Validation error / Bad request   |
| 401    | Unauthorized (missing/invalid token) |
| 403    | Forbidden (insufficient permissions) |
| 404    | Not found                        |
| 500    | Server error                     |

---

## Flutter Project Mapping

| API Domain       | Flutter Feature Directory                  |
|-----------------|--------------------------------------------|
| Auth            | `lib/features/auth/`                       |
| Properties      | `lib/features/home/`                       |
| Bookings        | `lib/features/booking/`                    |
| Booking History | `lib/features/booking_history/`            |
| Payment/Cards   | `lib/features/payment/`                    |
| Favorites       | `lib/features/favorites/`                  |
| Chat/Support    | `lib/features/support/`                    |
| Notifications   | `lib/core/services/notification_service.dart` |
| Location        | `lib/features/home/` (search/filter)       |
