# Get Full Location Tree

## API URL
```
GET https://dev.weel.uz/api/property/location/
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
curl -X GET "https://dev.weel.uz/api/property/location/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response, qisqartirilgan)
```json
{
  "regions": [
    {
      "id": 1,
      "guid": "732fbc4e-1670-49e5-94b0-6dfb5d8a5154",
      "title": "Andijon",
      "districts": [
        {
          "id": 30,
          "guid": "8886bfeb-c2ea-46bc-b403-868dafd6e104",
          "title": "Andijon",
          "prefectures": []
        },
        {
          "id": 31,
          "guid": "8474f6b7-600b-428b-af83-fb7c37f45279",
          "title": "Asaka",
          "prefectures": []
        }
      ]
    },
    {
      "id": 13,
      "guid": "3f2359f6-3d4b-4689-8b6a-2d36612b6e02",
      "title": "Toshkent",
      "districts": [
        {
          "id": 75,
          "guid": "3a89b738-63ff-46b6-82ee-170ac4e11ccd",
          "title": "Boʻstonliq",
          "prefectures": [
            {
              "guid": "a04a3704-afde-488b-9c6f-aea2f2ec879d",
              "title": "Abay"
            },
            {
              "guid": "742d2945-98b0-49c4-904d-eb79b45e338b",
              "title": "Amirsoy"
            },
            {
              "guid": "1742b22e-b222-48c5-9157-2941bda4bb85",
              "title": "Chorvoq"
            }
          ]
        },
        {
          "id": 85,
          "guid": "feb6f10e-afcd-4c2e-ac6d-0ddd667f1537",
          "title": "Toshkent",
          "prefectures": []
        }
      ]
    }
  ]
}
```
**Status Code:** `200`

> Jami 12 ta region (viloyat), har birida bir nechta districtlar va prefecturelar mavjud.

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
