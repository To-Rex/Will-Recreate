# Create Booking

## API URL
```
POST https://dev.weel.uz/api/booking/client/
```

## HTTP Method
`POST`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |
| Content-Type   | application/json         |

## Request BODY
```json
{
  "property_id": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
  "card_id": "card-uuid-here",
  "check_in": "2026-05-01",
  "check_out": "2026-05-03",
  "adults": 2,
  "children": 0,
  "babies": 0
}
```

| Field       | Type    | Required | Constraints           |
|------------|---------|----------|-----------------------|
| property_id | uuid   | Yes      |                       |
| card_id    | string  | Yes      | minLength: 1          |
| check_in   | date    | Yes      |                       |
| check_out  | date    | Yes      |                       |
| adults     | integer | Yes      | minimum: 1            |
| children   | integer | No       | default: 0, minimum: 0|
| babies     | integer | No       | default: 0, max: 5    |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/booking/client/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "property_id": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
    "card_id": "card-uuid-here",
    "check_in": "2026-05-01",
    "check_out": "2026-05-03",
    "adults": 2,
    "children": 0,
    "babies": 0
  }'
```

## Response

### Status 201 - Success (Booking yaratildi)
```json
{
  "guid": "booking-uuid",
  "property": { "...": "..." },
  "status": "PENDING",
  "check_in": "2026-05-01",
  "check_out": "2026-05-03",
  "adults": 2,
  "children": 0,
  "babies": 0,
  "booking_price": "1700000.00",
  "booking_number": "BK-0042"
}
```
**Status Code:** `201`

### Status 400 - Validation Error (real response - empty body)
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400
    }
  ]
}
```
**Status Code:** `400`

### Status 401 - Unauthorized
```json
{
  "errors": [
    {
      "detail": "Authentication credentials were not provided.",
      "status_code": 401
    }
  ]
}
```
**Status Code:** `401`

> **Eslatma:** PENDING booking yaratiladi va to'lov ushlab turiladi (hold).
