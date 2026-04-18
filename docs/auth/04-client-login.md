# Client Login - Step 1: Send Phone Number

## API URL
```
POST https://dev.weel.uz/api/user/client/login/
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
curl -X POST https://dev.weel.uz/api/user/client/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "998991234567"
  }'
```

## Response

### Status 200 - Success (OTP sent)
```json
{
  "message": "OTP sent successfully"
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
