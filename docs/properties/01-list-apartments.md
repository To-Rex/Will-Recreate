# List Apartments

## API URL
```
GET https://dev.weel.uz/api/property/apartments/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## Query Parameters

| Param       | Type    | Description                                       |
|------------|---------|---------------------------------------------------|
| search     | string  | Matn bo'yicha qidirish                             |
| region_id  | integer | Region bo'yicha filter                             |
| district_id| integer | District bo'yicha filter                           |
| corporate  | boolean | Corporate filter                                   |
| min_price  | number  | Minimal narx filter                                |
| max_price  | number  | Maksimal narx filter                               |
| currency   | string  | Valyuta (`USD`, `UZS`)                            |
| sort       | string  | `price_high`, `price_low`, `rating_high`, `rating_low`, `reviews_high`, `reviews_low`, `title_asc`, `title_desc` |
| from_date  | date    | Mavjudlik filteri (dan)                            |
| limit      | integer | Natijalar soni                                     |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/property/apartments/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
[
  {
    "guid": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
    "title": "TuranWay Apartments 1 NRG U Tower",
    "img": [
      "https://media.weel.uz/weel-media/property/images/9a64903697114b7689b1b6b5a19589f7.jpg",
      "https://media.weel.uz/weel-media/property/images/6f1e418fc9f5487dbe8cf2f393e3b77f.jpg",
      "https://media.weel.uz/weel-media/property/images/a6afcf03b05b49b888f3802e3cdd3b7e.jpg"
    ],
    "price": "850000.00",
    "currency": "USD",
    "latitude": "41.31123800000000",
    "longitude": "69.23949600000000",
    "country": "Узбекистан",
    "city": "Ташкент",
    "property_location": {
      "latitude": "41.31123800000000",
      "longitude": "69.23949600000000",
      "country": "Узбекистан",
      "city": "Ташкент",
      "region": null,
      "district": null,
      "prefecture": null
    },
    "services": [
      "0bc43648-24f5-451b-8bab-977ba9cc1543",
      "63c39e8a-8252-40b0-bba9-fc5e19d5228b",
      "9abe380d-cd18-4dba-8d6c-27644d4a041a"
    ],
    "region_id": null,
    "district_id": null,
    "prefecture_id": null,
    "guests": null,
    "rooms": null,
    "average_rating": 5.0,
    "is_favorite": false,
    "is_allowed_corporate": false,
    "created_at": "2026-03-16 21:25:16",
    "property_type_id": "11111111-1111-1111-1111-111111111111",
    "property_type": {
      "guid": "11111111-1111-1111-1111-111111111111",
      "title": "Apartment"
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
