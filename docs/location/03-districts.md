# List Districts

## API URL
```
GET https://dev.weel.uz/api/property/districts/
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
curl -X GET "https://dev.weel.uz/api/property/districts/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response, qisqartirilgan)
```json
[
  {
    "id": 30,
    "guid": "8886bfeb-c2ea-46bc-b403-868dafd6e104",
    "title": "Andijon",
    "region": {
      "id": 1,
      "guid": "732fbc4e-1670-49e5-94b0-6dfb5d8a5154",
      "title": "Andijon"
    }
  },
  {
    "id": 31,
    "guid": "8474f6b7-600b-428b-af83-fb7c37f45279",
    "title": "Asaka",
    "region": {
      "id": 1,
      "guid": "732fbc4e-1670-49e5-94b0-6dfb5d8a5154",
      "title": "Andijon"
    }
  },
  {
    "id": 72,
    "guid": "cf5a8ad4-f087-494f-aa44-7457bcd308cd",
    "title": "Angren",
    "region": {
      "id": 13,
      "guid": "3f2359f6-3d4b-4689-8b6a-2d36612b6e02",
      "title": "Toshkent"
    }
  },
  {
    "id": 85,
    "guid": "feb6f10e-afcd-4c2e-ac6d-0ddd667f1537",
    "title": "Toshkent",
    "region": {
      "id": 13,
      "guid": "3f2359f6-3d4b-4689-8b6a-2d36612b6e02",
      "title": "Toshkent"
    }
  }
]
```
**Status Code:** `200`

> Jami 140+ ta district (tuman) mavjud.

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
