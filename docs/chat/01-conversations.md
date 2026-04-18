# Get Chat Conversations

## API URL
```
GET https://dev.weel.uz/api/chat/conversations/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/chat/conversations/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
[
  {
    "counterpart": {
      "id": 2,
      "role": "admin",
      "full_name": "weel@gmail.com",
      "email": "weel@gmail.com",
      "username": "weel",
      "phone_number": ""
    },
    "conversation_id": 60,
    "last_message": {
      "id": 165,
      "conversation_id": 60,
      "sender_id": 2,
      "receiver_id": 267,
      "sender_type": "admin",
      "receiver_type": "client",
      "content": "Nima gap",
      "is_read": true,
      "created_at": "2026-04-14 16:51:09",
      "updated_at": "2026-04-16 02:08:25"
    },
    "unread_count": 0
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
