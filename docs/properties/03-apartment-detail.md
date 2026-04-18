# Get Apartment Detail

## API URL
```
GET https://dev.weel.uz/api/property/apartments/{property_id}/
```

## HTTP Method
`GET`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |

## URL Parameters
| Parameter   | Type | Required | Description       |
|------------|------|----------|-------------------|
| property_id | UUID | Yes      | Apartment GUID    |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/property/apartments/9c0701aa-434c-47b0-bf51-1fbf51a7528c/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
{
  "guid": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
  "title": "TuranWay Apartments 1 NRG U Tower",
  "img": [
    "https://media.weel.uz/weel-media/property/images/9a64903697114b7689b1b6b5a19589f7.jpg",
    "https://media.weel.uz/weel-media/property/images/6f1e418fc9f5487dbe8cf2f393e3b77f.jpg",
    "https://media.weel.uz/weel-media/property/images/a6afcf03b05b49b888f3802e3cdd3b7e.jpg",
    "https://media.weel.uz/weel-media/property/images/0eaf2fc53361440b871512e8de5704e2.jpg"
  ],
  "created_at": "2026-03-16 21:25:16",
  "currency": "USD",
  "price": "850000.00",
  "minimum_weekend_day_stay": false,
  "weekend_only_sunday_inclusive": false,
  "description_en": "Современные апартаменты в самом центре Ташкента...",
  "description_ru": "Современные апартаменты в самом центре Ташкента...",
  "description_uz": "Toshkent shahrining qoq markazida joylashgan zamonaviy Daily Apartment...",
  "comment_count": 0,
  "average_rating": 5.0,
  "is_favorite": false,
  "services": [
    "0bc43648-24f5-451b-8bab-977ba9cc1543",
    "63c39e8a-8252-40b0-bba9-fc5e19d5228b",
    "9abe380d-cd18-4dba-8d6c-27644d4a041a",
    "a50fa7e9-5ae4-4107-ba18-9b1b9006b809",
    "b91db2fd-e2f2-436b-910f-831642a8d6ab",
    "bb5e4ce0-f4b9-4819-87d9-2463f777b896",
    "f41c1095-b8fa-4910-86b0-75f3296e57ce",
    "f6ecdadd-e8c6-44a2-86d2-e5bd8af8f83b"
  ],
  "region_id": null,
  "district_id": null,
  "prefecture_id": null,
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
  "apartment_number": "183",
  "home_number": "1",
  "entrance_number": "1",
  "floor_number": "11",
  "pass_code": "0",
  "check_in": "14:00:00",
  "check_out": "12:00:00",
  "is_allowed_alcohol": false,
  "is_allowed_corporate": false,
  "is_allowed_pets": false,
  "is_quiet_hours": true
}
```
**Status Code:** `200`

### Status 404 - Not Found (real response)
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
