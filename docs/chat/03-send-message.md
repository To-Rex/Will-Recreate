# Send Chat Message

## API URL
```
POST https://dev.weel.uz/api/chat/send/
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
  "id": 1,
  "conversation_id": 60,
  "content": "Salom!",
  "created_at": "2026-04-16T10:00:00Z",
  "updated_at": "2026-04-16T10:00:00Z"
}
```

| Field           | Type     | Required |
|-----------------|----------|----------|
| id              | integer  | Yes      |
| conversation_id | integer  | Yes      |
| content         | string   | Yes      |
| created_at      | datetime | Yes      |
| updated_at      | datetime | Yes      |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/chat/send/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "conversation_id": 60,
    "content": "Salom!",
    "created_at": "2026-04-16T10:00:00Z",
    "updated_at": "2026-04-16T10:00:00Z"
  }'
```

## Response

### Status 200 - Success
```json
{
  "id": 200,
  "conversation_id": 60,
  "sender_id": 267,
  "receiver_id": 2,
  "sender_type": "client",
  "receiver_type": "admin",
  "content": "Salom!",
  "is_read": false,
  "created_at": "2026-04-16 10:00:00",
  "updated_at": "2026-04-16 10:00:00"
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
      "field": "content"
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
