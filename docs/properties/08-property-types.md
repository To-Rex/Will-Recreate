# List Property Types

## API URL
```
GET https://dev.weel.uz/api/property/types/
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
curl -X GET "https://dev.weel.uz/api/property/types/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbS1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
[
  {
    "guid": "11111111-1111-1111-1111-111111111111",
    "title": "Apartment",
    "icon_url": null
  },
  {
    "guid": "22222222-2222-2222-2222-222222222222",
    "title": "Cottage",
    "icon_url": null
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
