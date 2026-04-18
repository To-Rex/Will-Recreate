# Client Registration - Step 1: Send Phone Number

## API URL
```
POST https://dev.weel.uz/api/user/client/register/
```

## HTTP Method
`POST`

## Request BODY
```json
{
  "phone_number": "998991234567",
  "first_name": "Ism",
  "last_name": "Familiya"
}
```

| Field         | Type   | Required | Constraints              |
|--------------|--------|----------|--------------------------|
| phone_number | string | Yes      | minLength: 1             |
| first_name   | string | No       | minLength: 2, maxLength: 64 |
| last_name    | string | No       | minLength: 2, maxLength: 64 |

## cURL Example
```bash
curl -X POST https://dev.weel.uz/api/user/client/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "998991234567",
    "first_name": "Ism",
    "last_name": "Familiya"
  }'
```

## Response

### Status 200 - Success
```json
{
  "message": "OTP sent successfully"
}
```

### Status 400 - Validation Error (empty body)
```json
{
  "errors": [
    {
      "detail": "This field is required.",
      "status_code": 400,
      "field": "phone_number"
    }
  ]
}
```
**Status Code:** `400`
