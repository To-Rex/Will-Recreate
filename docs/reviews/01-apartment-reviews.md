# List Apartment Reviews

## API URL
```
GET https://dev.weel.uz/api/property/apartments/{property_id}/reviews/
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
curl -X GET "https://dev.weel.uz/api/property/apartments/9c0701aa-434c-47b0-bf51-1fbf51a7528c/reviews/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response - sharhlar yo'q)
```json
[]
```
**Status Code:** `200`

### Status 200 - Success (sharhlar mavjud bo'lganda)
```json
[
  {
    "id": 1,
    "property": "property-uuid",
    "user": {
      "id": 267,
      "full_name": "Dilshod Haydar",
      "avatar": null
    },
    "rating": 5,
    "comment": "Ajoyib joy!",
    "created_at": "2026-04-15T10:00:00Z"
  }
]
```

### Status 404 - Property Not Found
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
