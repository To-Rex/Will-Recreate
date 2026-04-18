# Resend Card Verification

## API URL
```
POST https://dev.weel.uz/api/user/client/cards/resend/
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
  "card_id": "card-uuid"
}
```

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/user/client/cards/resend/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "card_id": "card-uuid"
  }'
```

## Response

### Status 200 - Success
```json
{
  "detail": "Verification SMS resent"
}
```
**Status Code:** `200`

### Status 400 - Validation Error
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "card_id"
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
