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
    "external_key": 123 // Leave it empty to subscribe to general and unregistered topics
  }
}
```

Response status: `200`

**Leave an external key is empty to subscribe to general and unregistered topics**

It can be an empty string, null, or undefined.

Notice that in this case, you will not create any records on the server side.

Pusher creates a mobile device when it receives the device token with an external key and removes the "unregistered" topic.

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
  "payload": {
    "notification": {
      "title": "Test title",
      "body": "Test message"
    },
    "data": {
      "key1": "value1"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "high_importance_channel",
        "sound": "default",
        "icon": "ic_notification",
        "color": "#FF0000"
      }
    },
    "apns": {
      "headers": {
        "apns-priority": "10"
      },
      "payload": {
        "aps": {
          "badge": 2,
          "sound": "default",
          "content-available": 1
        }
      }
    }
  },
  "external_key": "35ccc1b96a2de88cbc33d824e596d7def62753ab145ecb07cf8e4391ddbc28a7",
  "topic": "test_topic" // Don't use the default "general" topic for test purposes
}
```

Response status: `200`

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

## Credentials

### How to edit production credentials

1. Create the production.yml.sec file in the dir "/config/credentials"

2. Open production credentials, add changes, close file.

```bash
VISUAL="code --wait" bin/rails credentials:edit --environment production
```

3. Commit changes.

# Deployment

_Setup_: run only once.

```bash
kamal setup
```

_Deployment_

```bash
kamal deploy
```

_Rails console_

```bash
kamal app exec -i 'bin/rails console'
```
