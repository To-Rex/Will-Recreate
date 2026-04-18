# Client Login - Resend OTP

## API URL
```
POST https://dev.weel.uz/api/user/client/login/resend/
```

## HTTP Method
`POST`

## Request BODY
```json
{
  "phone_number": "998991234567"
}
```

| Field         | Type   | Required |
|--------------|--------|----------|
| phone_number | string | Yes      |

## cURL Example
```bash
curl -X POST https://dev.weel.uz/api/user/client/login/resend/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "998991234567"
  }'
```

## Response

### Status 200 - Success
```json
{
  "message": "OTP resent successfully"
}
```

### Status 400 - Validation Error
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "phone_number"
    }
  ]
}
```
**Status Code:** `400`
