# Get Client Profile

## API URL
```
GET https://dev.weel.uz/api/user/client/profile/
```

## HTTP Method
`GET`

## Headers
| Header          | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Request BODY
Yo'q (No body required)

## cURL Example
```bash
curl -X GET https://dev.weel.uz/api/user/client/profile/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 200 - Success (real response)
```json
{
  "id": 267,
  "guid": "00000000-0000-0000-0000-00000000010b",
  "phone_number": "998995340313",
  "first_name": "Dilshod",
  "last_name": "Haydar",
  "avatar": null
}
```
**Status Code:** `200`

### Status 401 - Unauthorized (no token, real response)
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

### Status 401 - Invalid Token (real response)
```json
{
  "errors": [
    {
      "detail": "Given token not valid for any token type",
      "status_code": 401,
      "hint": "Use the Access token (from login/verify). If expired, use POST /api/users/refresh/ with Refresh token to get new tokens."
    }
  ]
}
```
**Status Code:** `401`
