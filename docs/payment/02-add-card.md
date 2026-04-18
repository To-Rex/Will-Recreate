# Add Card

## API URL
```
POST https://dev.weel.uz/api/user/client/cards/
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
  "card_number": "8600123456789012",
  "expiry_date": "12/28"
}
```

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/user/client/cards/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "card_number": "8600123456789012",
    "expiry_date": "12/28"
  }'
```

## Response

### Status 201 - Success (Karta qo'shildi)
```json
{
  "id": "card-uuid",
  "card_number": "8600****9012",
  "card_type": "UZCARD",
  "is_verified": false,
  "message": "SMS verification sent"
}
```
**Status Code:** `201`

### Status 400 - Validation Error
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "card_number"
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
