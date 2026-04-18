# Get Booking Detail

## API URL
```
GET https://dev.weel.uz/api/booking/client/{booking_id}/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## URL Parameters
| Parameter  | Type | Required | Description     |
|-----------|------|----------|-----------------|
| booking_id | UUID | Yes      | Booking GUID    |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/booking/client/{booking_id}/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 200 - Success
```json
{
  "guid": "booking-uuid",
  "property": {
    "guid": "property-uuid",
    "title": "Property Title",
    "img": ["https://media.weel.uz/..."]
  },
  "partner": {
    "id": 1,
    "full_name": "Partner Name"
  },
  "status": "PENDING",
  "check_in": "2026-05-01",
  "check_out": "2026-05-03",
  "adults": 2,
  "children": 0,
  "babies": 0,
  "booking_price": "1700000.00",
  "booking_number": "BK-0042",
  "cancellation_reason": null,
  "confirmed_at": null,
  "cancelled_at": null,
  "completed_at": null
}
```
**Status Code:** `200`

### Status 404 - Not Found
```json
{
  "errors": [
    {
      "detail": "Booking not found",
      "status_code": 404
    }
  ]
}
```
**Status Code:** `404`

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
