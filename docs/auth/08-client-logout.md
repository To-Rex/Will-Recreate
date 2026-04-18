# Client Logout

## API URL
```
POST https://dev.weel.uz/api/user/client/logout/
```

## HTTP Method
`POST`

## Headers
| Header          | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Request BODY
Yo'q (No body required)

## cURL Example
```bash
curl -X POST https://dev.weel.uz/api/user/client/logout/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Response

### Status 200 - Success
```json
{
  "message": "Logged out successfully"
}
```

### Status 401 - Unauthorized (no token)
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
