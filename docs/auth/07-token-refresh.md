# Token Refresh

## API URL
```
POST https://dev.weel.uz/api/user/refresh/
```

## HTTP Method
`POST`

## Request BODY
```json
{
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Field   | Type   | Required |
|---------|--------|----------|
| refresh | string | Yes      |

## cURL Example
```bash
curl -X POST https://dev.weel.uz/api/user/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "your_refresh_token_here"
  }'
```

## Response

### Status 200 - Success
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Status 400 - Invalid Refresh Token (real response)
```json
{
  "detail": "Token refresh failed"
}
```
**Status Code:** `400`
