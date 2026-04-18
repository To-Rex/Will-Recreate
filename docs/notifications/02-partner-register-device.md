# Register FCM Token (Partner)

## API URL
```
POST https://dev.weel.uz/api/notification/partner/device/
```

## HTTP Method
`POST`

## Headers
| Header         | Value                      |
|----------------|----------------------------|
| Authorization  | Bearer `{partner_token}`   |
| Content-Type   | application/json           |

## Request BODY
```json
{
  "fcm_token": "firebase_device_token_here",
  "device_type": "android"
}
```

| Field        | Type   | Required | Constraints              |
|-------------|--------|----------|--------------------------|
| fcm_token   | string | Yes      | maxLength: 255           |
| device_type | string | Yes      | enum: `ios`, `android`   |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/notification/partner/device/" \
  -H "Authorization: Bearer PARTNER_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "firebase_device_token_here",
    "device_type": "android"
  }'
```

## Response

### Status 200 - Success
```json
{
  "detail": "FCM token updated successfully"
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
      "field": "fcm_token"
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
