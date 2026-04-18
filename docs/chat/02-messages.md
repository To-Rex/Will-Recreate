# Get Chat Messages with Partner/Admin

## API URL
```
GET https://dev.weel.uz/api/chat/messages/{partner_id}/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## URL Parameters
| Parameter  | Type    | Required | Description         |
|-----------|---------|----------|---------------------|
| partner_id | integer | Yes      | Partner/Admin ID    |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/chat/messages/2/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
[
  {
    "id": 149,
    "conversation_id": 60,
    "sender_id": 2,
    "receiver_id": 267,
    "sender_type": "admin",
    "receiver_type": "client",
    "content": "Hello",
    "is_read": true,
    "created_at": "2026-04-11 21:27:54",
    "updated_at": "2026-04-12 20:19:35"
  },
  {
    "id": 150,
    "conversation_id": 60,
    "sender_id": 267,
    "receiver_id": 2,
    "sender_type": "client",
    "receiver_type": "admin",
    "content": "salon",
    "is_read": true,
    "created_at": "2026-04-12 07:12:57",
    "updated_at": "2026-04-12 12:03:24"
  },
  {
    "id": 151,
    "conversation_id": 60,
    "sender_id": 267,
    "receiver_id": 2,
    "sender_type": "client",
    "receiver_type": "admin",
    "content": "hi",
    "is_read": true,
    "created_at": "2026-04-12 07:13:15",
    "updated_at": "2026-04-12 12:03:24"
  },
  {
    "id": 152,
    "conversation_id": 60,
    "sender_id": 267,
    "receiver_id": 2,
    "sender_type": "client",
    "receiver_type": "admin",
    "content": "salom",
    "is_read": true,
    "created_at": "2026-04-12 08:19:31",
    "updated_at": "2026-04-12 12:03:24"
  }
]
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
