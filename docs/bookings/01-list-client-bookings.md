# List Client Bookings

## API URL
```
GET https://dev.weel.uz/api/booking/client/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Query Parameters
| Param  | Type   | Description          |
|--------|--------|----------------------|
| status | string | Status bo'yicha filter |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/booking/client/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response - active bookings yo'q)
```json
[]
```
**Status Code:** `200`

### Status 200 - Success (booking mavjud bo'lganda)
```json
[
  {
    "guid": "uuid-here",
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
    "check_in": "2026-04-20",
    "check_out": "2026-04-22",
    "adults": 2,
    "children": 0,
    "babies": 0,
    "booking_price": "1500000.00",
    "booking_number": "BK-0001"
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
