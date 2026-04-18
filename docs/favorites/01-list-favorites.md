# List Favorites

## API URL
```
GET https://dev.weel.uz/api/property/properties/favorites/
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
curl -X GET "https://dev.weel.uz/api/property/properties/favorites/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response - sevimlilar yo'q)
```json
[]
```
**Status Code:** `200`

### Status 200 - Success (sevimlilar mavjud bo'lganda)
```json
[
  {
    "guid": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
    "title": "TuranWay Apartments 1 NRG U Tower",
    "img": [
      "https://media.weel.uz/weel-media/property/images/9a64903697114b7689b1b6b5a19589f7.jpg"
    ],
    "price": "850000.00",
    "currency": "USD",
    "average_rating": 5.0,
    "is_favorite": true,
    "property_type": {
      "guid": "11111111-1111-1111-1111-111111111111",
      "title": "Apartment"
    }
  }
]
```

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
