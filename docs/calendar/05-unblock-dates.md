# Unblock Calendar Dates (Partner)

## API URL
```
POST https://dev.weel.uz/api/booking/properties/{property_id}/calendar/unblock/
```

## HTTP Method
`POST`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Authorization  | Bearer `{partner_token}` |
| Content-Type   | application/json         |

## URL Parameters
| Parameter   | Type | Required | Description       |
|------------|------|----------|-------------------|
| property_id | UUID | Yes      | Property GUID     |

## Request BODY
```json
{
  "from_date": "2026-05-01",
  "to_date": "2026-05-03"
}
```

| Field     | Type | Required |
|-----------|------|----------|
| from_date | date | Yes      |
| to_date   | date | No       |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/booking/properties/{property_id}/calendar/unblock/" \
  -H "Authorization: Bearer PARTNER_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "from_date": "2026-05-01",
    "to_date": "2026-05-03"
  }'
```

## Response

### Status 200 - Success
```json
{
  "detail": "Dates unblocked successfully"
}
```
**Status Code:** `200`

### Status 400 - Validation Error
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "from_date"
    }
  ]
}
```
**Status Code:** `400`

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
