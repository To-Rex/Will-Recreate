# Add to Favorites (Cottage)

## API URL
```
POST https://dev.weel.uz/api/property/cottages/{property_id}/favorite/
```

## HTTP Method
`POST`

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
curl -X POST "https://dev.weel.uz/api/property/cottages/fd213829-4e40-44d1-8fc5-6604d6f3ce02/favorite/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 201 - Success
```json
{
  "detail": "Added to favorites",
  "is_favorite": true
}
```
**Status Code:** `201`

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
