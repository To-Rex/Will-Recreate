# List Property Services

## API URL
```
GET https://dev.weel.uz/api/property/services/
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
curl -X GET "https://dev.weel.uz/api/property/services/" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc2MzIxNDYwLCJpYXQiOjE3NzYzMTc4NjAsImp0aSI6IjYxMTY5YzJkYTBkYjQ1ZTU5N2NjZGMzNzgwZDk2NjZhIiwic3ViIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMTBiIiwiaXNzIjoid2VlbC1iYWNrZW5kIiwidXNlcl90eXBlIjoiY2xpZW50In0.6uunnfb70rCMc8R2NRUn5s5h_Big3u8TJJbl2kmU7Mk"
```

## Response

### Status 200 - Success (real response, qisqartirilgan)
```json
[
  {
    "guid": "9c59ad31-f7cb-4796-b7c8-066e0d970f58",
    "title": "Air conditioner",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/iconoir_air-conditioner.svg"
  },
  {
    "guid": "806d4eb2-90a0-4509-a44d-9b837b7fd33f",
    "title": "A microwave",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/Group_5.svg"
  },
  {
    "guid": "b0da4f13-b2a5-4ad8-9e3b-40560a20aada",
    "title": "Barbecue",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/default_EGCzCyk.svg"
  },
  {
    "guid": "28f9ee0c-549c-492f-b6b6-426eaf4d7096",
    "title": "Bed linen",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/bed.svg"
  },
  {
    "guid": "31192b41-8c36-48e4-bbd0-05e379d9e4c1",
    "title": "Jacuzzi",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/mynaui_bubbles.svg"
  },
  {
    "guid": "01b69af4-b0c2-46b1-a3a4-3bb9d7345113",
    "title": "Wi-Fi",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/Group.svg"
  },
  {
    "guid": "605e1cc9-561d-477c-902d-3a5ad5ca8097",
    "title": "Summer pool",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/Vector_9.svg"
  },
  {
    "guid": "67af7187-4faf-4139-8151-5cec20c80bac",
    "title": "Smart TV",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/device-tv.svg"
  },
  {
    "guid": "7e725501-3e3d-42a0-8849-60855c37bfb7",
    "title": "Fridge",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/hugeicons_fridge.svg"
  },
  {
    "guid": "6ff1d617-37d1-4444-bfcf-7da8b7932dbe",
    "title": "Gym",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/Group_13.svg"
  },
  {
    "guid": "956cd54f-90a2-40a1-93d1-26c3eafac7c3",
    "title": "Winter pool",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/pool.svg"
  },
  {
    "guid": "114283f5-fb71-4449-b9e3-0c36f571aca0",
    "title": "Fireplace",
    "icon_url": "https://media.weel.uz/weel-media/property/icons/Vector_1.svg"
  }
]
```
**Status Code:** `200`

> Jami 60+ service mavjud. Yuqorida eng ko'p ishlatiladiganlari ko'rsatilgan.

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
