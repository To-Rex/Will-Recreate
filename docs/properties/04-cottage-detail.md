# Get Cottage Detail

## API URL
```
GET https://dev.weel.uz/api/property/cottages/{property_id}/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## URL Parameters
| Parameter   | Type | Required | Description    |
|------------|------|----------|----------------|
| property_id | UUID | Yes      | Cottage GUID   |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/property/cottages/fd213829-4e40-44d1-8fc5-6604d6f3ce02/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
{
  "guid": "fd213829-4e40-44d1-8fc5-6604d6f3ce02",
  "title": "MM Villa",
  "img": [
    "https://media.weel.uz/weel-media/property/images/a210f3d255174a66ac22a6f2ebe2e497.jpg",
    "https://media.weel.uz/weel-media/property/images/d3aa625bdcc64e16873ae3e9a94788e0.jpg",
    "https://media.weel.uz/weel-media/property/images/d4dbcc158bf64fa1bf9e206bfba6c8ac.jpg",
    "https://media.weel.uz/weel-media/property/images/6a2a0d2cdf6149f691a630820550f521.jpg"
  ],
  "created_at": "2026-03-23 13:20:41",
  "currency": "UZS",
  "price_per_person": "100000.00",
  "price_on_working_days": "3000000.00",
  "price_on_weekends": "3500000.00",
  "minimum_weekend_day_stay": false,
  "description": "Сдается Дача на Бочке | ММ Villa\r\nСо всеми удобствами!\r\nАлкоголь строго запрещен.\r\nЦена в Выходные дни обговаривается \r\nТолько для семьи!",
  "comment_count": 0,
  "average_rating": 5.0,
  "is_favorite": false,
  "property_services": [
    "01b69af4-b0c2-46b1-a3a4-3bb9d7345113",
    "05472b57-c78c-42d4-b8d3-afc52358ee05",
    "0967445c-3e91-431d-97ab-97862677cc2f"
  ],
  "property_room": {
    "guid": null,
    "guests": null,
    "rooms": null,
    "beds": null,
    "bathrooms": null
  },
  "region_id": null,
  "district_id": null,
  "prefecture_id": null,
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
  "check_in": "19:00:00",
  "check_out": "17:00:00",
  "is_allowed_alcohol": false,
  "is_allowed_corporate": false,
  "is_allowed_pets": false,
  "is_quiet_hours": false
}
```
**Status Code:** `200`

### Status 404 - Not Found
```json
{
  "errors": [
    {
      "detail": "Property not found",
      "status_code": 404
    }
  ]
}
```
**Status Code:** `404`

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
