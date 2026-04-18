# List Cottage Reviews

## API URL
```
GET https://dev.weel.uz/api/property/cottages/{property_id}/reviews/
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
curl -X GET "https://dev.weel.uz/api/property/cottages/fd213829-4e40-44d1-8fc5-6604d6f3ce02/reviews/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Response

### Status 200 - Success
```json
[]
```
**Status Code:** `200`

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
