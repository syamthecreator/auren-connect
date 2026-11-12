# aurenConnect API Reference & Quick Guide

A clean, modern, and developer-friendly reference for all **Authentication**, **Channel Connection (Instagram)**, and **Messaging Automation** endpoints.

---

## ⚡ Quick Configuration

| Environment | Base URL |
|---|---|
| **Production API** | `https://auren-backend-5weg.onrender.com/api/v1` |
| **Local Development** | `http://localhost:5001/api/v1` |
| **Frontend Web App** | `https://aurenconnect-hub.web.app` |

### Common Headers
* **JSON Requests:** `Content-Type: application/json`
* **Protected Endpoints:** `Authorization: Bearer <ACCESS_TOKEN>`

---

## 🧭 Master Quick Reference Table

| Module | Method | Endpoint | Auth | Description |
|---|---|---|:---:|---|
| **Auth** | `POST` | [`/auth/register`](#11-register-user) | No | Create a new user account |
| **Auth** | `POST` | [`/auth/login`](#12-login-user) | No | Authenticate user & get access/refresh tokens |
| **Auth** | `POST` | [`/auth/refresh`](#13-refresh-access-token) | No | Rotate refresh token & get new access token |
| **Auth** | `GET` | [`/auth/me`](#14-get-current-user-profile) | **Bearer** | Retrieve logged-in user profile |
| **Auth** | `POST` | [`/auth/logout`](#15-logout-user) | No | Invalidate refresh token session |
| **Channel** | `GET` | [`/instagram/connect`](#21-connect-instagram-account) | **Bearer** | Get Meta OAuth authorization URL |
| **Channel** | `GET` | [`/instagram/callback`](#22-meta-oauth-callback) | No | Meta OAuth redirect handler & token exchange |
| **Channel** | `GET` | [`/instagram/accounts`](#23-get-connected-instagram-accounts) | **Bearer** | List all connected Instagram channels |
| **Channel** | `DELETE` | [`/instagram/accounts/:channelId`](#24-disconnect-instagram-account) | **Bearer** | Unlink and disconnect an Instagram channel |
| **Channel** | `GET` | [`/instagram/webhook`](#25-meta-webhook-handshake) | No | Meta webhook verification challenge (`hub.challenge`) |
| **Channel** | `POST` | [`/instagram/webhook`](#26-meta-webhook-event-receiver) | Signature | Inbound webhook events (comments, DMs, story mentions) |
| **Automation** | `GET` | [`/automations`](#31-list-automations) | **Bearer** | List user automations (filter by channel, trigger, status) |
| **Automation** | `POST` | [`/automations`](#32-create-automation) | **Bearer** | Create a multi-step automation workflow |
| **Automation** | `GET` | [`/automations/:id`](#33-get-automation-by-id) | **Bearer** | Retrieve automation details with steps and logs |
| **Automation** | `PUT` | [`/automations/:id`](#34-update-automation) | **Bearer** | Update automation triggers, keywords, or steps |
| **Automation** | `PATCH` | [`/automations/:id/toggle`](#35-toggle-automation-status) | **Bearer** | Quickly toggle status between `ACTIVE` and `PAUSED` |
| **Automation** | `DELETE` | [`/automations/:id`](#36-delete-automation) | **Bearer** | Permanently delete an automation |
| **Automation** | `GET` | [`/automations/:id/logs`](#37-get-automation-execution-logs) | **Bearer** | Paginated execution audit trail and error logs |
| **Automation** | `GET` | [`/automations/analytics/overview`](#38-get-automation-analytics-overview) | **Bearer** | Aggregated performance metrics (total runs, success rate) |
| **Inbox** | `GET` | [`/inbox/stats`](#41-get-inbox-stats) | **Bearer** | Live inbox stats (unread count, today's messages) |
| **Inbox** | `GET` | [`/inbox/conversations`](#42-list-conversations) | **Bearer** | List conversations (filter by status, search, tag) |
| **Inbox** | `GET` | [`/inbox/conversations/:contactId`](#43-get-conversation-by-id) | **Bearer** | Retrieve conversation contact profile and tags |
| **Inbox** | `PATCH` | [`/inbox/conversations/:contactId`](#44-update-conversation) | **Bearer** | Update conversation status (archive, pin, CRM tags, notes) |
| **Inbox** | `GET` | [`/inbox/conversations/:contactId/messages`](#45-get-conversation-messages) | **Bearer** | Paginated message history (text, audio, image, video) |
| **Inbox** | `POST` | [`/inbox/conversations/:contactId/messages`](#46-send-direct-message) | **Bearer** | Send real Instagram DM (text, audio note, image, video, buttons) |
| **Inbox** | `POST` | [`/inbox/conversations/:contactId/action`](#47-send-sender-action) | **Bearer** | Send `mark_seen`, `typing_on`, `typing_off` indicators |
| **Inbox** | `POST` | [`/inbox/upload`](#48-upload-media-attachment) | **Bearer** | Upload voice note, image, or video for messaging |

---

## 🔐 1. Authentication Endpoints

Base path: `/api/v1/auth`

### 1.1 Register User
Register a new creator or business account in aurenConnect.

- **Method:** `POST`
- **Path:** `/api/v1/auth/register`
- **Auth Required:** No

#### Request Body
```json
{
  "name": "Auren Creator",
  "email": "creator@aurenconnect.com",
  "password": "StrongPassword123"
}
```

| Field | Type | Required | Description |
|---|---|:---:|---|
| `name` | `string` | Yes | 2 to 100 characters |
| `email` | `string` | Yes | Valid email address (case-insensitive) |
| `password` | `string` | Yes | 8 to 72 characters |

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Auren Creator",
      "email": "creator@aurenconnect.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-12T10:00:00.000Z"
    }
  }
}
```

#### Common Error Codes
* `400 Bad Request`: Validation failure (short password, invalid email format).
* `409 Conflict`: Email is already registered.

---

### 1.2 Login User
Authenticate an existing user, returning a JWT access token and a refresh token.

- **Method:** `POST`
- **Path:** `/api/v1/auth/login`
- **Auth Required:** No

#### Request Body
```json
{
  "email": "creator@aurenconnect.com",
  "password": "StrongPassword123"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Auren Creator",
      "email": "creator@aurenconnect.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-12T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "4d1f2a3c-8b9e-4f01-9a2c-3d4e5f6a7b8c",
      "expiresIn": 900
    }
  }
}
```

#### Common Error Codes
* `401 Unauthorized`: Invalid email or password.

---

### 1.3 Refresh Access Token
Rotate an active refresh token to obtain a fresh short-lived access token without re-logging in.

- **Method:** `POST`
- **Path:** `/api/v1/auth/refresh`
- **Auth Required:** No

#### Request Body
```json
{
  "refreshToken": "4d1f2a3c-8b9e-4f01-9a2c-3d4e5f6a7b8c"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "9e2c4f01-8b9e-4a3c-7b8c-1a2b3c4d5e6f",
      "expiresIn": 900
    }
  }
}
```

#### Common Error Codes
* `401 Unauthorized`: Refresh token is expired, revoked, or invalid.

---

### 1.4 Get Current User Profile
Fetch account profile information for the authenticated session.

- **Method:** `GET`
- **Path:** `/api/v1/auth/me`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Auren Creator",
      "email": "creator@aurenconnect.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-12T10:00:00.000Z"
    }
  }
}
```

---

### 1.5 Logout User
Revoke the active refresh token session from the database.

- **Method:** `POST`
- **Path:** `/api/v1/auth/logout`
- **Auth Required:** No

#### Request Body
```json
{
  "refreshToken": "9e2c4f01-8b9e-4a3c-7b8c-1a2b3c4d5e6f"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 📱 2. Channel Connection (Instagram) Endpoints

Base path: `/api/v1/instagram`

### 2.1 Connect Instagram Account
Generates a secure Meta Unified Login OAuth URL using the official Facebook Login Dialog with configuration ID `2129576484586654`.

- **Method:** `GET`
- **Path:** `/api/v1/instagram/connect`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "authorizationUrl": "https://www.facebook.com/v21.0/dialog/oauth?client_id=1009110748118284&redirect_uri=https%3A%2F%2Fauren-backend-5weg.onrender.com%2Fapi%2Fv1%2Finstagram%2Fcallback&config_id=2129576484586654&state=secure-random-state-hash&response_type=code"
  }
}
```

---

### 2.2 Meta OAuth Callback
Public redirect endpoint where Meta returns after the user authorizes their Instagram Professional account.
1. Exchanges authorization code for long-lived page token.
2. Discovers linked Instagram Professional Account ID (`IGSID`) and username.
3. AES-256 encrypts the token and stores it in PostgreSQL.
4. Returns an HTML landing page that closes the popup or redirects to `https://aurenconnect-hub.web.app/?tab=channel&connected=true`.

- **Method:** `GET`
- **Path:** `/api/v1/instagram/callback?code=...&state=...`
- **Auth Required:** No (browser redirect)

---

### 2.3 Get Connected Instagram Accounts
Fetches all currently connected Instagram accounts owned by the authenticated user.

- **Method:** `GET`
- **Path:** `/api/v1/instagram/accounts`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "accounts": [
      {
        "id": "4a715fbc-1234-4567-89ab-cdef01234567",
        "instagramUserId": "17841415634351143",
        "username": "aurenessence.in",
        "scopes": [
          "instagram_basic",
          "instagram_manage_messages",
          "pages_show_list",
          "pages_read_engagement"
        ],
        "connectedAt": "2026-11-12T11:00:00.000Z"
      }
    ]
  }
}
```

---

### 2.4 Disconnect Instagram Account
Disconnects and removes the Instagram channel from aurenConnect.

- **Method:** `DELETE`
- **Path:** `/api/v1/instagram/accounts/:channelId`
- **Auth Required:** Yes (`Bearer <ACCESS_TOKEN>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Instagram account disconnected successfully"
}
```

#### Common Error Codes
* `400 Bad Request`: Invalid or missing channel ID.
* `404 Not Found`: Account does not exist or does not belong to the user.

---

### 2.5 Meta Webhook Handshake
Meta App Dashboard verification challenge. Echoes back `hub.challenge` when `hub.verify_token` matches.

- **Method:** `GET`
- **Path:** `/api/v1/instagram/webhook?hub.mode=subscribe&hub.verify_token=...&hub.challenge=123456`
- **Auth Required:** No (Meta Handshake)

#### Success Response (`200 OK`)
Returns plain text challenge: `123456`.

---

### 2.6 Meta Webhook Event Receiver
Receives live message, comment, and story interaction events from Meta.
- Validates the `X-Hub-Signature-256` HMAC header using constant-time comparison.
- Passes incoming events asynchronously into the `automationEngine`.
- Immediately responds `200 OK` to Meta within milliseconds.

- **Method:** `POST`
- **Path:** `/api/v1/instagram/webhook`
- **Headers:** `X-Hub-Signature-256: sha256=<HMAC_HEX>`
- **Auth Required:** Meta Signature Verified

#### Success Response (`200 OK`)
HTTP Status `200 OK`.

---

## 🤖 3. Messaging Automation Endpoints

Base path: `/api/v1/automations`  
*(All endpoints require `Authorization: Bearer <ACCESS_TOKEN>`)*

### 💡 Core Automation Concepts

#### Trigger Types (`triggerType`)
| Trigger | Description | Typical Use Case |
|---|---|---|
| `COMMENT_KEYWORD` | User comments on a Reel or Post | **Comment-to-DM:** Public comment reply + instant private DM lead magnet |
| `DM_KEYWORD` | User sends a DM matching keyword | **DM Auto-responder:** FAQs, pricing, opening hours |
| `STORY_REPLY` | User replies to an Instagram Story | Instant engagement response to story views |
| `STORY_MENTION` | User mentions `@yourbrand` in their Story | Thank-you gift or discount coupon flow |
| `WELCOME_MESSAGE` | First message from a new contact | Brand greeting & interactive menu buttons |
| `FALLBACK_DEFAULT` | No other keyword automation matched | Default customer care / routing message |

#### Keyword Match Types (`matchType`)
* `CONTAINS`: Input message contains the keyword substring (e.g. "What is your **price**?").
* `EXACT`: Input message matches keyword exactly (e.g. "**PRICE**").
* `STARTS_WITH`: Input message begins with keyword (e.g. "**Hi** there").
* `ALL`: Input message contains all specified keywords.

#### Action Step Types (`stepType`)
* `SEND_DM`: Sends a private text message to contact's Instagram Direct inbox.
* `REPLY_COMMENT`: Posts a public comment reply. Supports a list of randomized templates in `content.replies` to prevent Meta anti-spam flagging.
* `QUICK_REPLIES`: Sends a DM with interactive CTA buttons.
* `DELAY`: Pauses execution for `delaySeconds` (e.g. 2s to 5s) to simulate natural human typing.
* `ADD_TAG`: Attaches a CRM tag (`content.tag`) to the contact's database record.

---

### 3.1 List Automations
Retrieve all automations created by the user with optional filters.

- **Method:** `GET`
- **Path:** `/api/v1/automations`
- **Query Parameters:**
  * `channelId` *(optional)*: Filter by connected Instagram channel UUID.
  * `status` *(optional)*: `ACTIVE`, `PAUSED`, or `DRAFT`.
  * `triggerType` *(optional)*: e.g. `COMMENT_KEYWORD`, `DM_KEYWORD`, `STORY_MENTION`.
  * `search` *(optional)*: Search string matching name or description.

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "automations": [
      {
        "id": "e4b2d5a1-7c98-4c31-9f20-1a2b3c4d5e6f",
        "userId": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
        "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
        "name": "Reel Comment-to-DM Lead Magnet",
        "description": "Sends free ebook link when user comments PRICE on any reel",
        "triggerType": "COMMENT_KEYWORD",
        "matchType": "CONTAINS",
        "keywords": ["price", "link", "guide"],
        "targetPostId": null,
        "status": "ACTIVE",
        "totalRuns": 142,
        "successRuns": 139,
        "failedRuns": 3,
        "createdAt": "2026-11-12T13:30:00.000Z",
        "updatedAt": "2026-11-12T13:30:00.000Z",
        "channel": {
          "id": "4a715fbc-1234-4567-89ab-cdef01234567",
          "instagramUserId": "17841415634351143",
          "username": "aurenessence.in"
        },
        "steps": [
          {
            "id": "step-1",
            "order": 0,
            "stepType": "REPLY_COMMENT",
            "content": {
              "replies": [
                "Check your DMs! 🚀",
                "Sent to your inbox! Check your DMs 📩",
                "Just sent you the link! ✨"
              ]
            }
          },
          {
            "id": "step-2",
            "order": 1,
            "stepType": "DELAY",
            "content": {
              "delaySeconds": 2
            }
          },
          {
            "id": "step-3",
            "order": 2,
            "stepType": "SEND_DM",
            "content": {
              "text": "Hey! Here is your free guide: https://aurenessence.in/guide"
            }
          },
          {
            "id": "step-4",
            "order": 3,
            "stepType": "ADD_TAG",
            "content": {
              "tag": "lead_magnet_claimed"
            }
          }
        ],
        "_count": {
          "logs": 142
        }
      }
    ],
    "count": 1
  }
}
```

---

### 3.2 Create Automation
Create a new automation workflow with ordered action steps.

- **Method:** `POST`
- **Path:** `/api/v1/automations`

#### Request Body
```json
{
  "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
  "name": "Story Mention Auto-Discount Flow",
  "description": "Send instant 15% discount coupon when tagged in a story",
  "triggerType": "STORY_MENTION",
  "matchType": "CONTAINS",
  "keywords": [],
  "status": "ACTIVE",
  "steps": [
    {
      "order": 0,
      "stepType": "SEND_DM",
      "content": {
        "text": "Thank you so much for tagging us in your Story! Here is an exclusive 15% discount code for your next order: AUREN15"
      }
    },
    {
      "order": 1,
      "stepType": "DELAY",
      "content": {
        "delaySeconds": 2
      }
    },
    {
      "order": 2,
      "stepType": "QUICK_REPLIES",
      "content": {
        "text": "What would you like to explore next?",
        "buttons": [
          { "title": "View Catalog", "payload": "CATALOG" },
          { "title": "Contact Support", "payload": "SUPPORT" }
        ]
      }
    },
    {
      "order": 3,
      "stepType": "ADD_TAG",
      "content": {
        "tag": "story_advocate"
      }
    }
  ]
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Automation created successfully",
  "data": {
    "automation": {
      "id": "b7834fc0-1111-2222-3333-444455556666",
      "userId": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Story Mention Auto-Discount Flow",
      "triggerType": "STORY_MENTION",
      "status": "ACTIVE",
      "steps": [...]
    }
  }
}
```

---

### 3.3 Get Automation by ID
Retrieve full configuration, ordered steps, and channel info for a single automation.

- **Method:** `GET`
- **Path:** `/api/v1/automations/:id`

#### Success Response (`200 OK`)
Returns the automation object with attached `channel`, `steps`, and recent `logs`.

---

### 3.4 Update Automation
Update configuration details, trigger settings, target post, or action steps.

- **Method:** `PUT`
- **Path:** `/api/v1/automations/:id`

#### Request Body
```json
{
  "name": "Updated Story Mention Flow",
  "status": "ACTIVE",
  "keywords": ["promo", "discount"],
  "steps": [
    {
      "order": 0,
      "stepType": "SEND_DM",
      "content": {
        "text": "Updated thank you message!"
      }
    }
  ]
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Automation updated successfully",
  "data": {
    "automation": { ... }
  }
}
```

---

### 3.5 Toggle Automation Status
Toggle an automation between `ACTIVE` and `PAUSED` with a single tap.

- **Method:** `PATCH`
- **Path:** `/api/v1/automations/:id/toggle`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Automation paused successfully",
  "data": {
    "id": "e4b2d5a1-7c98-4c31-9f20-1a2b3c4d5e6f",
    "status": "PAUSED"
  }
}
```

---

### 3.6 Delete Automation
Permanently deletes an automation and all its associated steps from the database.

- **Method:** `DELETE`
- **Path:** `/api/v1/automations/:id`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Automation deleted successfully"
}
```

---

### 3.7 Get Automation Execution Logs
Retrieve execution audit logs to verify trigger firing and Meta Graph API responses.

- **Method:** `GET`
- **Path:** `/api/v1/automations/:id/logs?limit=50&offset=0`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-001",
        "automationId": "e4b2d5a1-7c98-4c31-9f20-1a2b3c4d5e6f",
        "contactId": "17841400000000000",
        "eventData": {
          "commentId": "18012345678901234",
          "text": "Can I get the price please?"
        },
        "status": "SUCCESS",
        "errorMessage": null,
        "executedAt": "2026-11-12T13:35:10.000Z"
      }
    ],
    "total": 1,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 3.8 Get Automation Analytics Overview
Get aggregated analytics across all automations owned by the user.

- **Method:** `GET`
- **Path:** `/api/v1/automations/analytics/overview`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "totalAutomations": 6,
    "activeAutomations": 5,
    "pausedAutomations": 1,
    "totalRuns": 1284,
    "successRuns": 1276,
    "failedRuns": 8,
    "successRate": "99.38%",
    "byTriggerType": {
      "COMMENT_KEYWORD": 4,
      "DM_KEYWORD": 1,
      "STORY_MENTION": 1
    }
  }
}
```

---

## 💬 4. Live Instagram Messaging Inbox Endpoints

Base path: `/api/v1/inbox`  
*(All endpoints require `Authorization: Bearer <ACCESS_TOKEN>`)*

### 💡 Core Inbox Capabilities & Architecture
The aurenConnect Inbox provides a full real-time Instagram Direct Messaging client powered directly by Meta Graph API v21.0:
* **All Message Types**: Text, Emojis, Audio voice notes (`.m4a`, `.aac`, `.wav`), Images (`.jpg`, `.png`), Videos (`.mp4`), Story mentions, Story replies, and interactive Quick Reply pills.
* **Bi-directional Live Sync**: Receives incoming DMs and comments via Meta Webhooks, and syncs outbound echoes (messages sent from the Instagram mobile app or Meta Business Suite).
* **Meta Sender Actions**: Send `mark_seen` (read receipts), `typing_on`, and `typing_off` indicators.
* **CRM Metadata**: Star/pin important conversations, archive inactive threads, assign custom CRM tags (e.g. `VIP`, `Lead`, `Follow-up`), and record internal team notes.
* **Media Upload**: Built-in `/inbox/upload` endpoint allowing clients to record voice memos or select gallery photos/videos and send them instantly.

---

### 4.1 Get Inbox Stats
Retrieve statistical overview of conversations, unread messages, and today's activity.

- **Method:** `GET`
- **Path:** `/api/v1/inbox/stats`
- **Query Parameters:**
  * `channelId` *(optional)*: Filter stats for a specific Instagram channel.

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "totalConversations": 18,
    "unreadConversations": 3,
    "totalMessagesToday": 42,
    "totalUnreadMessages": 7
  }
}
```

---

### 4.2 List Conversations
Retrieve conversations (Instagram contacts) sorted by pinned status and latest interaction.

- **Method:** `GET`
- **Path:** `/api/v1/inbox/conversations`
- **Query Parameters:**
  * `channelId` *(optional)*: Filter by connected channel UUID.
  * `status` *(optional)*: `all`, `unread`, or `archived` (default: unarchived active).
  * `search` *(optional)*: Case-insensitive search on username, full name, or last message text.
  * `tag` *(optional)*: Filter by custom CRM tag.
  * `limit` *(optional, default 50)*: Pagination page size (max 100).
  * `offset` *(optional, default 0)*: Pagination offset.

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "conversations": [
      {
        "id": "c7f1a234-5678-90ab-cdef-112233445566",
        "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
        "instagramScopedId": "17841400000000000",
        "username": "alex_creator",
        "name": "Alex Mercer",
        "profilePic": "https://scontent.cdninstagram.com/...",
        "tags": ["VIP", "Interested in Pricing"],
        "unreadCount": 2,
        "lastMessageText": "Can you send the product video? 🎥",
        "lastMessageType": "TEXT",
        "lastMessageAt": "2026-11-12T19:30:00.000Z",
        "isArchived": false,
        "isPinned": true,
        "notes": "Looking for custom enterprise tier",
        "channel": {
          "id": "4a715fbc-1234-4567-89ab-cdef01234567",
          "username": "aurenessence.in",
          "instagramUserId": "17841415634351143"
        },
        "_count": {
          "messages": 14
        }
      }
    ],
    "count": 1,
    "limit": 50,
    "offset": 0
  }
}
```

---

### 4.3 Get Conversation by ID
Fetch full contact profile and conversation details.

- **Method:** `GET`
- **Path:** `/api/v1/inbox/conversations/:contactId`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "conversation": {
      "id": "c7f1a234-5678-90ab-cdef-112233445566",
      "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
      "instagramScopedId": "17841400000000000",
      "username": "alex_creator",
      "name": "Alex Mercer",
      "tags": ["VIP"],
      "unreadCount": 0,
      "notes": "Interested in annual subscription",
      "channel": {
        "id": "4a715fbc-1234-4567-89ab-cdef01234567",
        "username": "aurenessence.in"
      }
    }
  }
}
```

---

### 4.4 Update Conversation
Update contact flags, CRM tags, and internal notes.

- **Method:** `PATCH`
- **Path:** `/api/v1/inbox/conversations/:contactId`

#### Request Body
```json
{
  "isArchived": false,
  "isPinned": true,
  "tags": ["VIP", "Closed Deal"],
  "notes": "Follow up next Monday on WhatsApp"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Conversation updated successfully",
  "data": {
    "conversation": { ... }
  }
}
```

---

### 4.5 Get Conversation Messages
Retrieve chronological message history for a conversation.

- **Method:** `GET`
- **Path:** `/api/v1/inbox/conversations/:contactId/messages?limit=50&before=2026-11-12T19:00:00.000Z`

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "messages": [
      {
        "id": "msg-001",
        "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
        "contactId": "c7f1a234-5678-90ab-cdef-112233445566",
        "direction": "INBOUND",
        "messageType": "TEXT",
        "text": "Hi! Do you have a demo video?",
        "mediaUrl": null,
        "mediaType": null,
        "status": "READ",
        "metaMessageId": "aWdfbWVzc2FnZToxMDA...",
        "replyToMetaMessageId": null,
        "readAt": "2026-11-12T19:35:00.000Z",
        "sentAt": "2026-11-12T19:30:10.000Z"
      },
      {
        "id": "msg-002",
        "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
        "contactId": "c7f1a234-5678-90ab-cdef-112233445566",
        "direction": "OUTBOUND",
        "messageType": "VIDEO",
        "text": "[VIDEO]",
        "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/demo.mp4",
        "mediaType": "video",
        "status": "DELIVERED",
        "metaMessageId": "aWdfbWVzc2FnZToxMDE...",
        "replyToMetaMessageId": "aWdfbWVzc2FnZToxMDA...",
        "sentAt": "2026-11-12T19:32:00.000Z"
      }
    ],
    "count": 2
  }
}
```

---

### 4.6 Send Direct Message
Send a live Instagram message to the contact's inbox via Meta Graph API v21.0.

- **Method:** `POST`
- **Path:** `/api/v1/inbox/conversations/:contactId/messages`

#### Request Body (Text with Emojis & Optional Quoted Reply)
```json
{
  "text": "Hey Alex! Here are the details you requested 🔥✨",
  "replyToMetaMessageId": "aWdfbWVzc2FnZToxMDA..."
}
```

#### Request Body (Audio Voice Note / Recording)
```json
{
  "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/voice_recording_1.m4a",
  "mediaType": "audio"
}
```

#### Request Body (Image Attachment)
```json
{
  "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/product_photo.jpg",
  "mediaType": "image"
}
```

#### Request Body (With Quick Replies)
```json
{
  "text": "What is the best way to contact you?",
  "quickReplies": [
    { "title": "Instagram DM", "payload": "CHANNEL_IG" },
    { "title": "WhatsApp", "payload": "CHANNEL_WA" }
  ]
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Message sent successfully",
  "data": {
    "message": {
      "id": "msg-003",
      "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
      "contactId": "c7f1a234-5678-90ab-cdef-112233445566",
      "direction": "OUTBOUND",
      "messageType": "TEXT",
      "text": "Hey Alex! Here are the details you requested 🔥✨",
      "status": "DELIVERED",
      "metaMessageId": "mid.$cAA...",
      "sentAt": "2026-11-12T19:35:12.000Z"
    }
  }
}
```

---

### 4.7 Send Sender Action
Send live indicators to the Instagram user's Direct app (mark message as seen or show typing bubbles).

- **Method:** `POST`
- **Path:** `/api/v1/inbox/conversations/:contactId/action`

#### Request Body
```json
{
  "action": "mark_seen"
}
```
*(Allowed values: `mark_seen`, `typing_on`, `typing_off`)*

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "success": true,
    "action": "mark_seen"
  }
}
```

---

### 4.8 Upload Media Attachment
Upload a base64 encoded audio voice note, picture, or video file to the server and receive a publicly accessible URL for sending in chat.

- **Method:** `POST`
- **Path:** `/api/v1/inbox/upload`

#### Request Body
```json
{
  "fileBase64": "data:audio/m4a;base64,GkXfo59ChoEBQveBAULygQRC84EIQoKEd2VibUK...",
  "filename": "voice_memo.m4a",
  "mimeType": "audio/m4a"
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Media uploaded successfully",
  "data": {
    "url": "https://auren-backend-5weg.onrender.com/uploads/uuid_voice_memo.m4a",
    "filename": "uuid_voice_memo.m4a",
    "mimeType": "audio/m4a",
    "mediaType": "audio"
  }
}
```

---

## 🧪 5. Complete cURL Cheat Sheet

Quick commands for testing directly in your terminal. Replace `<ACCESS_TOKEN>`, `<CHANNEL_ID>`, `<AUTOMATION_ID>`, and `<CONTACT_ID>` with your real values.

### 4.1 Auth Commands

```bash
# Register
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Auren Creator","email":"creator@aurenconnect.com","password":"StrongPassword123"}'

# Login
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"creator@aurenconnect.com","password":"StrongPassword123"}'

# Refresh Token
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}'

# Get Profile
curl https://auren-backend-5weg.onrender.com/api/v1/auth/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Logout
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<REFRESH_TOKEN>"}'
```

---

### 4.2 Channel Connection Commands

```bash
# Get Meta OAuth URL
curl https://auren-backend-5weg.onrender.com/api/v1/instagram/connect \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# List Connected Instagram Channels
curl https://auren-backend-5weg.onrender.com/api/v1/instagram/accounts \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Disconnect Instagram Channel
curl -X DELETE https://auren-backend-5weg.onrender.com/api/v1/instagram/accounts/<CHANNEL_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

### 4.3 Automation Commands

```bash
# Get Analytics Overview
curl https://auren-backend-5weg.onrender.com/api/v1/automations/analytics/overview \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# List All Automations
curl https://auren-backend-5weg.onrender.com/api/v1/automations \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Filter Active Comment-to-DM Automations
curl "https://auren-backend-5weg.onrender.com/api/v1/automations?triggerType=COMMENT_KEYWORD&status=ACTIVE" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Create Comment-to-DM Automation
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/automations \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Reel Comment Price Auto-DM",
    "triggerType": "COMMENT_KEYWORD",
    "matchType": "CONTAINS",
    "keywords": ["price", "cost"],
    "status": "ACTIVE",
    "steps": [
      {
        "order": 0,
        "stepType": "REPLY_COMMENT",
        "content": {
          "replies": ["Sent to your DM! ✨", "Check your inbox 🚀"]
        }
      },
      {
        "order": 1,
        "stepType": "SEND_DM",
        "content": {
          "text": "Hi! You requested our pricing details: https://aurenessence.in/pricing"
        }
      }
    ]
  }'

# Get Single Automation by ID
curl https://auren-backend-5weg.onrender.com/api/v1/automations/<AUTOMATION_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Toggle Status (Active <-> Paused)
curl -X PATCH https://auren-backend-5weg.onrender.com/api/v1/automations/<AUTOMATION_ID>/toggle \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# View Execution Logs
curl "https://auren-backend-5weg.onrender.com/api/v1/automations/<AUTOMATION_ID>/logs?limit=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Delete Automation
curl -X DELETE https://auren-backend-5weg.onrender.com/api/v1/automations/<AUTOMATION_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

---

### 5.4 Live Inbox Commands

```bash
# Get Inbox Stats
curl https://auren-backend-5weg.onrender.com/api/v1/inbox/stats \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# List Conversations (Active)
curl "https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations?limit=20" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Filter Unread Conversations
curl "https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations?status=unread" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Search Conversations by Username or Name
curl "https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations?search=alex" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Get Single Conversation Details
curl https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Get Chronological Messages for Conversation
curl "https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages?limit=50" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Send Text Message with Emojis
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello! How can we help your business grow today? 🚀✨"
  }'

# Send Quoted / Reply-To Message
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Yes, our prices start at $29/mo!",
    "replyToMetaMessageId": "<META_MESSAGE_ID>"
  }'

# Send Audio Voice Note
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/voice_sample.m4a",
    "mediaType": "audio"
  }'

# Send Image / Photo
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/product_catalog.jpg",
    "mediaType": "image"
  }'

# Send Video Clip
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/messages \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrl": "https://auren-backend-5weg.onrender.com/uploads/product_demo.mp4",
    "mediaType": "video"
  }'

# Send Mark As Seen (Read Receipt)
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/action \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "mark_seen"
  }'

# Send Typing Indicator On
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID>/action \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "typing_on"
  }'

# Update Conversation (Pin, CRM Tags, Notes)
curl -X PATCH https://auren-backend-5weg.onrender.com/api/v1/inbox/conversations/<CONTACT_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "isPinned": true,
    "tags": ["VIP", "High Intent"],
    "notes": "Interested in annual plan"
  }'

# Upload Base64 Audio / Image / Video File
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/inbox/upload \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "fileBase64": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "filename": "sample.png",
    "mimeType": "image/png"
  }'
```

