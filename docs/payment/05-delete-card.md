# Delete Card

## API URL
```
DELETE https://dev.weel.uz/api/user/client/cards/{card_id}/
```

## HTTP Method
`DELETE`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## URL Parameters
| Parameter | Type | Required | Description |
|----------|------|----------|-------------|
| card_id  | UUID | Yes      | Card ID     |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X DELETE "https://dev.weel.uz/api/user/client/cards/{card_id}/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 204 - Success (Karta o'chirildi)
```
(No content)
```
**Status Code:** `204`

### Status 404 - Card Not Found
```json
{
  "errors": [
    {
      "detail": "Card not found",
      "status_code": 404
    }
  ]
}
```
**Status Code:** `404`

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
