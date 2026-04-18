# Client Booking History

## API URL
```
GET https://dev.weel.uz/api/booking/client/history/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/booking/client/history/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response - history yo'q)
```json
[]
```
**Status Code:** `200`

### Status 200 - Success (history mavjud bo'lganda)
```json
[
  {
    "guid": "booking-uuid",
    "property": {
      "guid": "property-uuid",
      "title": "Property Title"
    },
    "status": "COMPLETED",
    "check_in": "2026-03-20",
    "check_out": "2026-03-22",
    "booking_price": "1500000.00",
    "booking_number": "BK-0015",
    "completed_at": "2026-03-22T12:00:00Z"
  }
]
```

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
