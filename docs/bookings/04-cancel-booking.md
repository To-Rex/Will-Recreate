# Cancel Booking (Client)

## API URL
```
POST https://dev.weel.uz/api/booking/client/{booking_id}/cancel/
```

## HTTP Method
`POST`

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
curl -X POST "https://dev.weel.uz/api/booking/client/{booking_id}/cancel/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 200 - Success (Booking cancelled)
```json
{
  "guid": "booking-uuid",
  "status": "CANCELLED",
  "cancelled_at": "2026-04-16T10:30:00Z",
  "cancellation_reason": null
}
```
**Status Code:** `200`

### Status 404 - Booking Not Found
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
