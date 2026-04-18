# Delete Client Account

## API URL
```
DELETE https://dev.weel.uz/api/user/account/
```

## HTTP Method
`DELETE`

## Headers
| Header          | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Request BODY
Yo'q (No body required)

## cURL Example
```bash
curl -X DELETE https://dev.weel.uz/api/user/account/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 204 - Success (Account deleted)
```
(No content)
```
**Status Code:** `204`

> **Ogohlantirish:** Bu amal qaytarib bo'lmaydi (irreversible). Hisob butunlay o'chiriladi.

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
