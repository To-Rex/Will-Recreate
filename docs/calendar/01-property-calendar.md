# Get Property Calendar

## API URL
```
GET https://dev.weel.uz/api/booking/properties/{property_id}/calendar/?from_date={from}&to_date={to}
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
| property_id | UUID | Yes      | Property GUID     |

## Query Parameters
| Param     | Type | Required | Description    |
|-----------|------|----------|----------------|
| from_date | date | Yes      | Boshlanish sanasi |
| to_date   | date | Yes      | Tugash sanasi     |

## Request BODY
Yo'q

## cURL Example
```bash
curl -X GET "https://dev.weel.uz/api/booking/properties/9c0701aa-434c-47b0-bf51-1fbf51a7528c/calendar/?from_date=2026-04-16&to_date=2026-04-20" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response)
```json
{
  "property_id": "9c0701aa-434c-47b0-bf51-1fbf51a7528c",
  "range": {
    "from_date": "2026-04-16",
    "to_date": "2026-04-20"
  },
  "calendar": [
    { "date": "2026-04-16", "status": "available" },
    { "date": "2026-04-17", "status": "available" },
    { "date": "2026-04-18", "status": "available" },
    { "date": "2026-04-19", "status": "available" },
    { "date": "2026-04-20", "status": "blocked" }
  ]
}
```
**Status Code:** `200`

> **Statuslar:** `available` - mavjud, `blocked` - bloklangan, `held` - ushlab turilgan

### Status 400 - Validation Error (sanalar yo'q, real response)
```json
{
  "errors": [
    {
      "detail": "This field may not be null.",
      "status_code": 400,
      "field": "from_date"
    },
    {
      "detail": "This field may not be null.",
      "status_code": 400,
      "field": "to_date"
    }
  ]
}
```
**Status Code:** `400`

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
