# Frontend Logs

## API URL
```
POST https://dev.weel.uz/api/logs/frontend/
```

## HTTP Method
`POST`

## Headers
| Header         | Value                    |
|----------------|--------------------------|
| Content-Type   | application/json         |

## Request BODY
```json
{
  "level": "info",
  "message": "Test log message"
}
```

| Field   | Type   | Required |
|---------|--------|----------|
| level   | string | No       |
| message | string | No       |

## cURL Example
```bash
curl -X POST "https://dev.weel.uz/api/logs/frontend/" \
  -H "Content-Type: application/json" \
  -d '{
    "level": "info",
    "message": "Test log message"
  }'
```

## Response

### Status 201 - Success (real response)
```json
{
  "ok": true
}
```
**Status Code:** `201`

> Bu endpoint frontend (browser) loglarini yozish uchun. Grafana/Loki da ko'rinadi. Autentifikatsiya talab qilinmaydi.
