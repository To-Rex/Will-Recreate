# List Cottages

## API URL
```
GET https://dev.weel.uz/api/property/cottages/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Query Parameters
Apartments bilan bir xil parametrlar.

| Param       | Type    | Description                      |
|------------|---------|----------------------------------|
| search     | string  | Matn bo'yicha qidirish           |
| region_id  | integer | Region bo'yicha filter           |
| district_id| integer | District bo'yicha filter         |
| corporate  | boolean | Corporate filter                 |
| min_price  | number  | Minimal narx filter              |
| max_price  | number  | Maksimal narx filter             |
| currency   | string  | Valyuta (`USD`, `UZS`)          |
| sort       | string  | Saralash turi                    |
| from_date  | date    | Mavjudlik filteri                |
| limit      | integer | Natijalar soni                   |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/property/cottages/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response, qisqartirilgan)
```json
[
  {
    "guid": "fd213829-4e40-44d1-8fc5-6604d6f3ce02",
    "title": "MM Villa",
    "img": [
      "https://media.weel.uz/weel-media/property/images/a210f3d255174a66ac22a6f2ebe2e497.jpg",
      "https://media.weel.uz/weel-media/property/images/d3aa625bdcc64e16873ae3e9a94788e0.jpg"
    ],
    "price_per_person": "100000.00",
    "price_on_working_days": "3000000.00",
    "price_on_weekends": "3500000.00",
    "currency": "UZS",
    "latitude": "41.63163100000000",
    "longitude": "69.94943300000000",
    "country": "Узбекистан",
    "city": "городской посёлок Ходжикент",
    "property_location": {
      "latitude": "41.63163100000000",
      "longitude": "69.94943300000000",
      "country": "Узбекистан",
      "city": "городской посёлок Ходжикент",
      "region": null,
      "district": null,
      "prefecture": null
    },
    "services": [
      "01b69af4-b0c2-46b1-a3a4-3bb9d7345113",
      "05472b57-c78c-42d4-b8d3-afc52358ee05"
    ],
    "region": null,
    "district": null,
    "guests": null,
    "rooms": null,
    "average_rating": 5.0,
    "is_favorite": false,
    "is_allowed_corporate": false,
    "created_at": "2026-03-23 13:20:41",
    "property_type_id": "22222222-2222-2222-2222-222222222222",
    "property_type": {
      "guid": "22222222-2222-2222-2222-222222222222",
      "title": "Cottage"
    }
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
