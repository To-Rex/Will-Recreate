# Client Login - Step 2: Verify OTP

## API URL
```
POST https://dev.weel.uz/api/user/client/login/verify/
```

## HTTP Method
`POST`

## Request BODY
```json
{
  "phone_number": "998991234567",
  "otp_code": "1234",
  "fcm_token": "firebase_token_here",
  "device_type": "android"
}
```

| Field        | Type   | Required | Constraints               |
|-------------|--------|----------|---------------------------|
| phone_number | string | Yes      | minLength: 1              |
| otp_code    | string | Yes      | minLength: 4, maxLength: 4 |
| fcm_token   | string | No       | nullable                  |
| device_type | string | No       | enum: `ios`, `android`    |

## cURL Example
```bash
curl -X POST https://dev.weel.uz/api/user/client/login/verify/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "998991234567",
    "otp_code": "1234",
    "fcm_token": "firebase_token_here",
    "device_type": "android"
  }'
```

## Response

### Status 200 - Success (tokens returned)
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Status 400 - Validation Error (empty body)
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "phone_number"
    },
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "otp_code"
    }
  ]
}
```
**Status Code:** `400`
