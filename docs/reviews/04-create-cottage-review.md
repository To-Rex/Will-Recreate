# Create Cottage Review

## API URL
```
POST https://dev.weel.uz/api/property/cottages/{property_id}/reviews/
```

## HTTP Method
`POST`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{access_token}`  |
| Content-Type   | application/json         |

## URL Parameters
| Parameter   | Type | Required | Description    |
|------------|------|----------|----------------|
| property_id | UUID | Yes      | Cottage GUID   |

## Request BODY
```json
{
  "rating": 4,
  "comment": "Yaxshi joy, pool ajoyib!"
}
```

| Field   | Type    | Required |
|---------|---------|----------|
| rating  | integer | Yes      |
| comment | string  | Yes      |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/property/cottages/{property_id}/reviews/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 4,
    "comment": "Yaxshi joy, pool ajoyib!"
  }'
```

## Response

### Status 201 - Success
```json
{
  "id": 2,
  "property": "cottage-uuid",
  "user": {
    "id": 267,
    "full_name": "Dilshod Haydar",
    "avatar": null
  },
  "rating": 4,
  "comment": "Yaxshi joy, pool ajoyib!",
  "created_at": "2026-04-16T10:00:00Z"
}
```
**Status Code:** `201`

### Status 400 - Validation Error
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "rating"
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
