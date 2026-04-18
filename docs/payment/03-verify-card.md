# Verify Card

## API URL
```
POST https://dev.weel.uz/api/user/client/cards/verify/
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
  "card_id": "card-uuid",
  "otp_code": "1234"
}
```

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/user/client/cards/verify/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "card_id": "card-uuid",
    "otp_code": "1234"
  }'
```

## Response

### Status 200 - Success
```json
{
  "detail": "Card verified successfully",
  "is_verified": true
}
```
**Status Code:** `200`

### Status 400 - Invalid OTP
```json
{
  "errors": [
    {
      "detail": "Invalid OTP code",
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
