# README

## API

## Endpoints

- [POST /api/mobile_devices](#create-mobile-device)
- [DELETE /api/mobile_device/:push_token](#remove-mobile-device)
- [POST /api/push_notifications](#create-push-notifications)

Auth headers:

```json
{ "Authorization": "Bearer client_token" }
```

### Create mobile device

_Run this method every time after starting a mobile application._

POST `/api/mobile_devices`
Params:

```json
{
  "mobile_device": {
    "device_token": "xxx",
    "user_info": "Put here the user ID, Phone, Email. It will help to find all user's mobile devices",
    "device_info": "iOS/Andoid, Samsung Galaxy s25",
    "external_key": 123
  }
}
```

Response status: `200`

### Remove mobile device

_Run this method when the user logout._

DELETE `/api/mobile_device/:push_token`

Response status: `200`

### Create push notifications

_Run this method on the server side_

POST `/api/notifications`
Params:

```json
{
  "notification": {
    "data": {}, // You can find the data example below
    "external_key": "user123",
    "topic": "test_topic" // Don't use the default "general" topic for test purposes
  }
}
```

Response status: `200`

### Data example

<details>
  <summary>Open the data example</summary>
  
```js
{
  'data': {
    payload: {
      data: {
        id: 1
      }
    }
  },
  'notification': {
    title: notification.title_th,
    body: notification.body_th
  },
  'android': {
    priority: 'high'
  },
  'apns': {
    payload: {
      aps: {
        sound: "default",
        category: "category"
      }
    }
  },
  'fcm_options': {
    analytics_label: 'Label'
  }
}
```
</details>

## Development mode

1. Install VSCode

2. Open DevContainer

3. Run the Rails server

```bash
bin/rails server
```

4. Run the Tailwind process

```bash
bin/rails tailwindcss:watch
```

5. Extract the production DB

```bash
rails db:schema:load

pg_restore --verbose --clean --no-acl --no-owner -h postgres -p 5432 -U postgres -d pusher_development < rpush
```
