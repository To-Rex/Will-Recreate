# Register FCM Token (Client)

## API URL
```
POST https://dev.weel.uz/api/notification/device/
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
curl -X POST "https://dev.weel.uz/api/notification/device/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk" \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "test_token",
    "device_type": "android"
  }'
```

## Response

### Status 200 - Success (real response)
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
