# Update Client Profile

## API URL
```
PATCH https://dev.weel.uz/api/user/client/profile/update/
```

## HTTP Method
`PATCH` (yoki `PUT`)

## Headers
| Header          | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |
| Content-Type   | application/json         |

## Request BODY
```json
{
  "first_name": "Dilshod",
  "last_name": "Haydar",
  "avatar": null
}
```

| Field       | Type   | Required |
|------------|--------|----------|
| first_name | string | No       |
| last_name  | string | No       |
| avatar     | string | No       |

## cURL Example
```bash
curl -X PATCH https://dev.weel.uz/api/user/client/profile/update/ \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Dilshod",
    "last_name": "Haydar"
  }'
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
