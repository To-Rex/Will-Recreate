# List Prefectures

## API URL
```
GET https://dev.weel.uz/api/property/prefectures/
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
curl -X GET "https://dev.weel.uz/api/property/prefectures/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response, qisqartirilgan)
```json
[
  {
    "guid": "a04a3704-afde-488b-9c6f-aea2f2ec879d",
    "title": "Abay",
    "district": {
      "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
      "title": "Boʻstonliq"
    }
  },
  {
    "guid": "742d2945-98b0-49c4-904d-eb79b45e338b",
    "title": "Amirsoy",
    "district": {
      "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
      "title": "Boʻstonliq"
    }
  },
  {
    "guid": "1742b22e-b222-48c5-9157-2941bda4bb85",
    "title": "Chorvoq",
    "district": {
      "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
      "title": "Boʻstonliq"
    }
  },
  {
    "guid": "98250871-2028-4f27-83f2-aa583d525d8f",
    "title": "Chimyon",
    "district": {
      "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
      "title": "Boʻstonliq"
    }
  },
  {
    "guid": "74ad7b09-151c-460e-99c5-bccf095f812a",
    "title": "G'azalkent",
    "district": {
      "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
      "title": "Boʻstonliq"
    }
  }
]
```
**Status Code:** `200`

> Prefectures faqat Bo'stonliq va Parkent tumanlarida mavjud (jami ~40 ta).

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
