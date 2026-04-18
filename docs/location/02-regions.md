# List Regions

## API URL
```
GET https://dev.weel.uz/api/property/regions/
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
curl -X GET "https://dev.weel.uz/api/property/regions/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
[
  {
    "id": 1,
    "guid": "732fbc4e-1670-49e5-94b0-6dfb5d8a5154",
    "title": "Andijon",
    "img": "https://media.weel.uz/weel-media/property/regions/Andijon.jpg"
  },
  {
    "id": 2,
    "guid": "ba15e620-6f00-467b-a09b-dc7f64bd3cef",
    "title": "Buxoro",
    "img": "https://media.weel.uz/weel-media/property/regions/Buxoro.png"
  },
  {
    "id": 3,
    "guid": "bdc0f2b1-fcff-419b-a5c2-c74257e122c7",
    "title": "Fargʻona",
    "img": "https://media.weel.uz/weel-media/property/regions/Ferghana.jpg"
  },
  {
    "id": 4,
    "guid": "d1c3905c-8e9e-40b4-989d-0465fe5cb498",
    "title": "Jizzax",
    "img": "https://media.weel.uz/weel-media/property/regions/Jizzah.jpeg"
  },
  {
    "id": 5,
    "guid": "42007f7f-6039-44de-bdcd-5402c5e3e31f",
    "title": "Namangan",
    "img": "https://media.weel.uz/weel-media/property/regions/Namangan.jpg"
  },
  {
    "id": 6,
    "guid": "51f011af-6bf4-425c-95d5-b7c18c21e2e6",
    "title": "Navoiy",
    "img": "https://media.weel.uz/weel-media/property/regions/Navoiy.jpg"
  },
  {
    "id": 8,
    "guid": "6765b451-c116-4eb6-bf64-bcae6b228036",
    "title": "Qashqadaryo",
    "img": "https://media.weel.uz/weel-media/property/regions/Qashqadaryo.jpg"
  },
  {
    "id": 10,
    "guid": "f8736ea8-da89-4ea4-a56a-402eb51876bb",
    "title": "Samarqand",
    "img": "https://media.weel.uz/weel-media/property/regions/Samarqand.png"
  },
  {
    "id": 11,
    "guid": "ee2b657f-0ead-439c-87d0-aa21a5da115a",
    "title": "Sirdaryo",
    "img": "https://media.weel.uz/weel-media/property/regions/Sirdaryo.jpg"
  },
  {
    "id": 12,
    "guid": "75504f72-7170-4dc5-9dac-164da360755f",
    "title": "Surxondaryo",
    "img": "https://media.weel.uz/weel-media/property/regions/Surxandaryo.jpg"
  },
  {
    "id": 13,
    "guid": "3f2359f6-3d4b-4689-8b6a-2d36612b6e02",
    "title": "Toshkent",
    "img": "https://media.weel.uz/weel-media/property/regions/ChatGPT_Image_3_апр._2026_г._16_03_15.png"
  },
  {
    "id": 15,
    "guid": "edfe4040-94af-43bf-bf0c-242d8705edbe",
    "title": "Xorazm",
    "img": "https://media.weel.uz/weel-media/property/regions/Xorazm.jpg"
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
