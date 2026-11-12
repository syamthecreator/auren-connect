# aurenConnect API Documentation

**Backend:** Node.js, TypeScript, Express  
**Database:** PostgreSQL  
**ORM:** Prisma  
**API Version:** `v1`  
**Production API Base URL:** `https://auren-backend-5weg.onrender.com/api/v1`  
**Development API Base URL:** `http://localhost:5001/api/v1`  
**Frontend Production Hosting:** `https://aurenconnect-hub.web.app` / `https://aurenconnect-hub.firebaseapp.com`  
**Meta App ID:** `1009110748118284` | **Meta Config ID:** `2129576484586654`

---

## 1. Getting Started

### 1.1 Local Development Server
From the `backend` directory, install dependencies and start the development server:

```bash
cd backend
npm install
npm run dev
```

The local development API runs at: `http://localhost:5001/api/v1`.

### 1.2 Health Check Endpoints

#### Server Health
`GET /api/v1/health`

Response (`200 OK`):
```json
{
  "success": true,
  "message": "Server is healthy",
  "timestamp": "2026-11-11T13:00:00.000Z"
}
```

#### Database Health
`GET /api/v1/health/database`

Response (`200 OK`):
```json
{
  "success": true,
  "message": "Database connection is healthy"
}
```

#### Root Status
`GET /`

Response (`200 OK`):
```json
{
  "success": true,
  "message": "aurenConnect API is running"
}
```

---

## 2. Global Standards & Response Format

### 2.1 Success Response Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

### 2.2 Error Response Envelope
```json
{
  "success": false,
  "message": "Description of the error"
}
```

### 2.3 Authentication Header
Protected endpoints require a standard Bearer access token:
```http
Authorization: Bearer <ACCESS_TOKEN>
```

---

## 3. Endpoints Overview

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| **GET** | `/health` | No | Server health check |
| **GET** | `/health/database` | No | Database connection health check |
| **POST** | `/auth/register` | No | Register a new user account |
| **POST** | `/auth/login` | No | Authenticate user & issue tokens |
| **POST** | `/auth/refresh` | No | Rotate refresh token & issue new access token |
| **POST** | `/auth/logout` | No | Revoke active refresh token session |
| **GET** | `/auth/me` | **Bearer Token** | Retrieve current user profile |
| **GET** | `/instagram/connect` | **Bearer Token** | Generate Meta Unified Login OAuth authorization URL |
| **GET** | `/instagram/callback` | No (Public) | Meta OAuth redirect callback & zero-delay frontend return |
| **GET** | `/instagram/accounts` | **Bearer Token** | List all connected Instagram Professional channels |
| **DELETE** | `/instagram/accounts/:channelId` | **Bearer Token** | Disconnect and unlink an Instagram channel |
| **GET** | `/instagram/webhook` | No (Meta) | Meta webhook verification handshake (`hub.challenge`) |
| **POST** | `/instagram/webhook` | No (Meta Signature) | Receive verified Instagram Direct webhook events & trigger automations |
| **GET** | `/automations` | **Bearer Token** | List user automations with filters (`channelId`, `status`, `triggerType`, `search`) |
| **POST** | `/automations` | **Bearer Token** | Create a new automation flow with triggers and steps |
| **GET** | `/automations/:id` | **Bearer Token** | Retrieve detailed automation configuration and steps |
| **PUT** | `/automations/:id` | **Bearer Token** | Update existing automation configuration and steps |
| **PATCH** | `/automations/:id/toggle` | **Bearer Token** | Toggle automation status between `ACTIVE` and `PAUSED` |
| **DELETE** | `/automations/:id` | **Bearer Token** | Permanently delete an automation |
| **GET** | `/automations/:id/logs` | **Bearer Token** | Get execution history and error logs for an automation |
| **GET** | `/automations/analytics/overview` | **Bearer Token** | Get aggregated analytics overview (total runs, success rate, triggers) |
| **GET** | `/inbox/stats` | **Bearer Token** | Retrieve real-time inbox statistics (unread counts, today's messages) |
| **GET** | `/inbox/conversations` | **Bearer Token** | List conversations (Instagram contacts) with search, status, and tag filters |
| **GET** | `/inbox/conversations/:contactId` | **Bearer Token** | Get conversation profile details, tags, and CRM notes |
| **PATCH** | `/inbox/conversations/:contactId` | **Bearer Token** | Update conversation flags (archive, pin, CRM tags, notes) |
| **GET** | `/inbox/conversations/:contactId/messages` | **Bearer Token** | Paginated message history (text, voice, image, video) |
| **POST** | `/inbox/conversations/:contactId/messages` | **Bearer Token** | Send live Instagram DM (text, emoji, voice note, image, video, buttons) |
| **POST** | `/inbox/conversations/:contactId/action` | **Bearer Token** | Send Meta sender action (`mark_seen`, `typing_on`, `typing_off`) |
| **POST** | `/inbox/upload` | **Bearer Token** | Upload base64 voice note recording, photo, or video |

---

## 4. Authentication Endpoints

Base path: `/api/v1/auth`

### 4.1 Register User
Create a new user account in aurenConnect.

- **Method:** `POST`
- **Path:** `/auth/register`
- **Headers:** `Content-Type: application/json`

**Request Body:**
```json
{
  "name": "Syam",
  "email": "syam@example.com",
  "password": "YourStrongPassword123"
}
```

**Validation:**
* `name`: Required, 2–100 characters.
* `email`: Required, valid email format (automatically converted to lowercase).
* `password`: Required, minimum 8 characters, maximum 72 characters.

**Success Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Syam",
      "email": "syam@example.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-05T10:03:09.164Z"
    }
  }
}
```

**Errors:**
* `400 Bad Request`: Validation failure.
* `409 Conflict`: An account with this email already exists.
* `500 Internal Server Error`: Server failure.

---

### 4.2 Login
Authenticate an existing user. Creates a database session and returns short-lived JWT access token and long-lived refresh token.

- **Method:** `POST`
- **Path:** `/auth/login`
- **Headers:** `Content-Type: application/json`

**Request Body:**
```json
{
  "email": "aurenthecreator@gmail.com",
  "password": "auren 123"
}
```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Auren Creator",
      "email": "aurenthecreator@gmail.com",
      "status": "ACTIVE"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "7c9e01f2a38b4c5d6e7f8091a2b3c4d5...",
    "tokenType": "Bearer",
    "expiresIn": 900
  }
}
```

* `accessToken`: Signed JWT (15-minute lifetime / 900 seconds).
* `refreshToken`: High-entropy random hex token stored as SHA-256 hash in PostgreSQL (30-day lifetime).

**Errors:**
* `400 Bad Request`: Missing email or password.
* `401 Unauthorized`: Invalid credentials.
* `403 Forbidden`: Account status is not `ACTIVE`.

---

### 4.3 Refresh Access Token
Exchange an existing refresh token for a newly rotated refresh token and fresh access token.

- **Method:** `POST`
- **Path:** `/auth/refresh`
- **Headers:** `Content-Type: application/json`

**Request Body:**
```json
{
  "refreshToken": "7c9e01f2a38b4c5d6e7f8091a2b3c4d5..."
}
```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "NEW_ACCESS_TOKEN_JWT",
    "refreshToken": "NEW_ROTATED_REFRESH_TOKEN",
    "tokenType": "Bearer",
    "expiresIn": 900
  }
}
```

---

### 4.4 Logout
Revoke the active database session for the supplied refresh token.

- **Method:** `POST`
- **Path:** `/auth/logout`
- **Headers:** `Content-Type: application/json`

**Request Body:**
```json
{
  "refreshToken": "CURRENT_REFRESH_TOKEN"
}
```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

### 4.5 Get Current User Profile
Retrieve the authenticated user's profile based on the Bearer access token.

- **Method:** `GET`
- **Path:** `/auth/me`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  ```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "c1f7a01a-6d63-490f-90e6-12166a9d20c5",
      "name": "Auren Creator",
      "email": "aurenthecreator@gmail.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-05T10:03:09.164Z"
    }
  }
}
```

---

## 5. Instagram & Meta Channel Integration

Base path: `/api/v1/instagram`

### 5.1 Initialize Instagram Connect
Generates the official Meta Unified Login OAuth URL matching ManyChat's exact parameters.

- **Method:** `GET`
- **Path:** `/instagram/connect`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  ```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "authorizationUrl": "https://business.facebook.com/business/loginpage/?next=https%3A%2F%2Fbusiness.facebook.com%2Fdialog%2Foauth%3Fclient_id%3D1009110748118284%26config_id%3D2129576484586654%26response_type%3Dcode%26override_default_response_type%3D1%26state%3D...%26redirect_uri%3Dhttps%253A%252F%252Fauren-backend-5weg.onrender.com%252Fapi%252Fv1%252Finstagram%252Fcallback%26display%3Dpopup&login_options%5B0%5D=IG&app=436761779744620&cma_account_switch=1&is_ig_oidc_with_redirect=1&display=popup&full_page_redirect_experimental=1&show_back_button=0"
  }
}
```

#### Meta Unified Login Architecture:
* **Tier 1 (Inner Dialog):** `https://business.facebook.com/dialog/oauth` with `client_id`, `config_id`, `state`, and `redirect_uri`.
* **Tier 2 (Outer Gateway):** `https://business.facebook.com/business/loginpage/` passing `login_options[0]=IG`, `app=436761779744620`, `cma_account_switch=1`, `is_ig_oidc_with_redirect=1`, and `full_page_redirect_experimental=1`.
* **State Verification:** Stored as SHA-256 hash in `instagram_oauth_states` with a 10-minute expiry window.

---

### 5.2 Meta OAuth Callback
The endpoint Meta redirects the browser popup window to after the user authorizes their business assets.

- **Method:** `GET`
- **Path:** `/instagram/callback`
- **Query Parameters:**
  * `code`: Meta authorization code.
  * `state`: The state string issued during connect initialization.

**Backend Execution Flow:**
1. Validates the state hash against `instagram_oauth_states`.
2. Exchanges `code` for a Meta access token via `https://graph.facebook.com/v21.0/oauth/access_token`.
3. Discovers authorized Instagram accounts using a multi-strategy lookup:
   * Strategy 1: `me/assigned_instagram_accounts?fields=id,username`
   * Strategy 2: `me/accounts?fields=id,name,instagram_business_account{id,username}`
   * Strategy 3: `me?fields=id,username,instagram_business_account{id,username}`
4. Encrypts the Meta user access token with AES-256-GCM before saving to PostgreSQL.
5. Saves/upserts the record in `instagram_channels` with scopes `['instagram_basic', 'instagram_manage_messages']`.
6. **Zero-Delay Frontend Return:** Sends an immediate `0s` HTML refresh redirect back to the client application:
   ```html
   <meta http-equiv="refresh" content="0;url=https://aurenconnect-hub.firebaseapp.com/?tab=channel&connected=true">
   <script>
     if (window.opener && !window.opener.closed) {
       window.opener.postMessage('AUREN_INSTAGRAM_CONNECTED', '*');
       window.opener.postMessage({ type: 'AUREN_INSTAGRAM_CONNECTED', account: "@handle" }, '*');
       window.opener.focus();
       window.close();
     }
     window.location.replace("https://aurenconnect-hub.firebaseapp.com/?tab=channel&connected=true");
   </script>
   ```

---

### 5.3 Get Connected Instagram Accounts
Fetches all Instagram Professional channels linked to the authenticated user.

- **Method:** `GET`
- **Path:** `/instagram/accounts`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  ```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "accounts": [
      {
        "id": "e9a8f4c2-9012-4c55-87d4-e65b4c102a99",
        "instagramUserId": "17841461983186073",
        "username": "_shyam_designs_",
        "connectedAt": "2026-11-09T07:45:20.120Z",
        "tokenExpiresAt": "2027-01-08T07:45:20.120Z"
      }
    ]
  }
}
```

---

### 5.4 Disconnect Instagram Account
Unlinks an Instagram channel from the authenticated user's workspace.

- **Method:** `DELETE`
- **Path:** `/instagram/accounts/:channelId`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  ```

**Success Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Instagram account disconnected successfully"
}
```

**Errors:**
* `400 Bad Request`: Invalid or missing channel ID.
* `404 Not Found`: Account does not belong to the user or was already removed.

---

### 5.5 Meta Webhook Handshake (Verification)
Endpoint registered in Meta App Dashboard for Instagram Webhooks.

- **Method:** `GET`
- **Path:** `/instagram/webhook`
- **Query Parameters:**
  * `hub.mode`: Expected value `subscribe`.
  * `hub.verify_token`: Verified against `META_WEBHOOK_VERIFY_TOKEN`.
  * `hub.challenge`: Echoed back with status `200` to verify handshake.

**Response (`200 OK`):**
Returns the plain text `hub.challenge` string.

---

### 5.6 Meta Webhook Event Receiver
Receives live message notifications and Instagram interactions from Meta.

- **Method:** `POST`
- **Path:** `/instagram/webhook`
- **Headers:**
  ```http
  X-Hub-Signature-256: sha256=<HMAC_SHA256_HEX>
  Content-Type: application/json
  ```

**Security Verification:**
The endpoint uses the raw request body buffer and `META_APP_SECRET` to verify the HMAC-SHA256 signature using constant-time comparison (`timingSafeEqual`) to prevent timing attacks.

**Response (`200 OK`):**
Acknowledge receipt immediately with HTTP `200`.

---

## 6. Instagram Messaging Automation Engine & Endpoints

Base path: `/api/v1/automations`

### 6.1 Automation Architecture & Capabilities
aurenConnect provides an enterprise-grade automation engine built directly on Meta's official Graph API v21.0, enabling creator and business workflows identical to ManyChat.

#### Supported Trigger Types
1. **`COMMENT_KEYWORD` (Comment-to-DM):** Triggers when an Instagram user comments on a Reel or Feed Post. Matches against specified keywords (or wildcard `*` for any comment).
   - Can optionally target a specific `targetPostId` (Instagram Media ID / Reel ID) or run across all posts.
   - Executes public comment reply (with randomized rotation to prevent spam flagging) AND direct DM reply to the commenter.
2. **`DM_KEYWORD` (Keyword Auto-responder):** Triggers when a contact sends a direct message containing or matching configured keywords.
3. **`STORY_REPLY`:** Triggers when a follower replies to an active Instagram Story.
4. **`STORY_MENTION`:** Triggers when someone mentions the business Instagram account (`@username`) in their Story.
5. **`WELCOME_MESSAGE`:** Automatically greets first-time contacts when they initiate their first conversation.
6. **`FALLBACK_DEFAULT`:** Catches all messages that do not match any keyword automation, ensuring 100% response coverage.

#### Keyword Match Types
- `CONTAINS`: Inbound message or comment contains the keyword as a substring (case-insensitive).
- `EXACT`: Inbound text matches the keyword exactly.
- `STARTS_WITH`: Inbound text begins with the keyword.
- `ALL`: Inbound text contains all specified keywords.

#### Action Step Types
- `SEND_DM`: Sends a private text message to the contact's Instagram Direct inbox.
- `REPLY_COMMENT`: Posts a public reply to the user's comment on the Reel or Post. Supports an array of reply templates in `content.replies` which are picked at random to prevent spam detection.
- `QUICK_REPLIES`: Sends a DM message accompanied by interactive quick-reply buttons (e.g. `[{"title": "Pricing", "payload": "PRICING"}, {"title": "Book Call", "payload": "BOOK"}]`).
- `DELAY`: Pauses execution for a specified duration in seconds (`content.delaySeconds`) to simulate natural human typing cadence.
- `ADD_TAG`: Attaches a CRM tag (`content.tag`) to the contact's profile in the database for audience segmentation.

#### Webhook Deduplication & Anti-Spam Safety
- **Idempotency:** Every Meta incoming message ID (`mid`) and comment ID is stored in `processed_webhook_events`. Duplicated webhook events from Meta are automatically skipped.
- **24-Hour Messaging Window Compliance:** Respects Meta's 24-hour messaging policy for standard messaging, and uses private comment reply endpoints (`/v21.0/{comment_id}` -> `POST /v21.0/me/messages` with `recipient.comment_id`) within the 7-day window.
- **Asynchronous Execution:** The webhook endpoint verifies HMAC-SHA256 and responds with HTTP `200` in milliseconds, while the automation engine processes the pipeline asynchronously.

---

### 6.2 List Automations
Retrieve all automations belonging to the authenticated user with optional filtering.

- **Method:** `GET`
- **Path:** `/automations`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`
- **Query Parameters:**
  * `channelId` (optional): Filter automations for a specific Instagram channel.
  * `status` (optional): Filter by status (`ACTIVE`, `PAUSED`, `DRAFT`).
  * `triggerType` (optional): Filter by trigger type (`COMMENT_KEYWORD`, `DM_KEYWORD`, etc.).
  * `search` (optional): Search by name or description.

**Response (`200 OK`):**
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

### 6.3 Create Automation
Create a new automation workflow with triggers and steps.

- **Method:** `POST`
- **Path:** `/automations`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  Content-Type: application/json
  ```

**Request Body:**
```json
{
  "channelId": "4a715fbc-1234-4567-89ab-cdef01234567",
  "name": "Story Mention Auto-Thank You",
  "description": "Send instant coupon when someone mentions us in their story",
  "triggerType": "STORY_MENTION",
  "matchType": "CONTAINS",
  "keywords": [],
  "status": "ACTIVE",
  "steps": [
    {
      "order": 0,
      "stepType": "SEND_DM",
      "content": {
        "text": "Thank you so much for the story mention! Here is a 15% discount code for your next order: AUREN15"
      }
    },
    {
      "order": 1,
      "stepType": "QUICK_REPLIES",
      "content": {
        "text": "What would you like to explore next?",
        "quickReplies": [
          { "title": "View Catalog", "payload": "CATALOG" },
          { "title": "Contact Support", "payload": "SUPPORT" }
        ]
      }
    }
  ]
}
```

**Success Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Automation created successfully",
  "data": {
    "automation": {
      "id": "b7834fc0-1111-2222-3333-444455556666",
      "name": "Story Mention Auto-Thank You",
      "triggerType": "STORY_MENTION",
      "status": "ACTIVE",
      "steps": []
    }
  }
}
```

---

### 6.4 Get Automation Details
Retrieve a single automation by its UUID including all ordered steps and execution counts.

- **Method:** `GET`
- **Path:** `/automations/:id`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

**Response (`200 OK`):**
Returns the automation object with `channel`, `steps`, and recent `logs`.

---

### 6.5 Update Automation
Update an existing automation's details, triggers, keywords, status, and steps.

- **Method:** `PUT`
- **Path:** `/automations/:id`
- **Headers:**
  ```http
  Authorization: Bearer <ACCESS_TOKEN>
  Content-Type: application/json
  ```

**Request Body:**
```json
{
  "name": "Updated Automation Name",
  "keywords": ["new_keyword", "promo"],
  "status": "ACTIVE",
  "steps": [
    {
      "order": 0,
      "stepType": "SEND_DM",
      "content": {
        "text": "Updated auto-response text!"
      }
    }
  ]
}
```

**Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Automation updated successfully",
  "data": {
    "automation": {}
  }
}
```

---

### 6.6 Toggle Automation Status
Quickly switch an automation between `ACTIVE` and `PAUSED`.

- **Method:** `PATCH`
- **Path:** `/automations/:id/toggle`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

**Response (`200 OK`):**
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

### 6.7 Delete Automation
Permanently delete an automation and its configured steps.

- **Method:** `DELETE`
- **Path:** `/automations/:id`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

**Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Automation deleted successfully"
}
```

---

### 6.8 Get Automation Execution Logs
Retrieve execution audit logs for a specific automation.

- **Method:** `GET`
- **Path:** `/automations/:id/logs?limit=50&offset=0`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

**Response (`200 OK`):**
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

### 6.9 Get Automation Analytics Overview
Aggregated performance metrics across all automations for the authenticated user.

- **Method:** `GET`
- **Path:** `/automations/analytics/overview`
- **Headers:** `Authorization: Bearer <ACCESS_TOKEN>`

**Response (`200 OK`):**
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

## 7. Frontend Integration Details (Flutter Web)

### 7.1 Architecture Overview
* **HTTP Client (`ApiClient`):** Wraps all requests, automatically injects `Authorization: Bearer <token>`, and handles automatic 401 token refresh retry.
* **Token Storage (`AuthTokenManager`):** Safely persists access and refresh tokens in browser `SharedPreferences`.
* **State Controllers:**
  * `AuthController`: Manages user authentication lifecycle, registration, login, and single-tap instant logout.
  * `ChannelController`: Manages Instagram channel discovery, initiating Meta connect, and disconnecting channels.
* **Deep-Link Navigation:**
  * When the Meta OAuth popup finishes and returns `?tab=channel&connected=true`, `SplashScreen` inspects `Uri.base` and forwards `arguments: NavDestination.channel` to `AppRouter.dashboard`.
  * `AppShell` receives `initialDestination: NavDestination.channel` and renders `ChannelScreen` directly without falling back to Overview.

### 7.2 Channel Screen Real Data Mapping
[`ChannelScreen`](file:///Users/syamkumar/auren_connect/lib/features/channel/presentation/screens/channel_screen.dart) renders strictly real values populated by `ChannelController.instagramAccounts`:
* **Real Handle:** `account.displayHandle` (e.g. `@aurenessence.in`).
* **Real Meta ID:** `account.instagramUserId` with one-tap copy button.
* **Real Link Date:** Formatted `account.connectedAt`.
* **Real Scopes:** Displayed as permission chips (`instagram_basic`, `instagram_manage_messages`).
* **WhatsApp Card:** Transparently shows "Coming Soon" with zero mock toggles or dummy metrics.

---

## 8. Database Schema (Prisma PostgreSQL)

```prisma
model User {
  id                      String                  @id @default(uuid())
  name                    String
  email                   String                  @unique
  password                String
  status                  UserStatus              @default(ACTIVE)

  sessions                Session[]
  emailVerificationTokens EmailVerificationToken[]
  passwordResetTokens     PasswordResetToken[]
  instagramChannels       InstagramChannel[]
  instagramOAuthStates    InstagramOAuthState[]
  automations             Automation[]

  createdAt               DateTime                @default(now())
  updatedAt               DateTime                @updatedAt

  @@map("users")
}

model Session {
  id               String    @id @default(uuid())
  userId           String
  refreshTokenHash String    @unique
  expiresAt        DateTime
  revokedAt        DateTime?

  user             User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt        DateTime  @default(now())

  @@index([userId])
  @@map("sessions")
}

model InstagramChannel {
  id                   String    @id @default(uuid())
  userId               String
  instagramUserId      String    @unique
  username             String?
  accessTokenEncrypted String    @db.Text
  tokenExpiresAt       DateTime?
  scopes               String[]  @default([])
  connectedAt          DateTime  @default(now())
  updatedAt            DateTime  @updatedAt

  user                 User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  automations          Automation[]
  contacts             InstagramContact[]
  messages             InstagramMessage[]

  @@index([userId])
  @@map("instagram_channels")
}

model InstagramOAuthState {
  id        String    @id @default(uuid())
  userId    String
  stateHash String    @unique
  expiresAt DateTime
  usedAt    DateTime?

  user      User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt DateTime  @default(now())

  @@index([userId])
  @@index([expiresAt])
  @@map("instagram_oauth_states")
}

model Automation {
  id           String             @id @default(uuid())
  userId       String
  channelId    String?
  name         String
  description  String?
  triggerType  String             // COMMENT_KEYWORD, DM_KEYWORD, STORY_REPLY, STORY_MENTION, WELCOME_MESSAGE, FALLBACK_DEFAULT
  matchType    String             @default("CONTAINS") // EXACT, CONTAINS, STARTS_WITH, ALL
  keywords     String[]           @default([])
  targetPostId String?            // Specific Instagram Media ID or Reel ID (null = any post)
  status       String             @default("ACTIVE")   // ACTIVE, PAUSED, DRAFT
  totalRuns    Int                @default(0)
  successRuns  Int                @default(0)
  failedRuns   Int                @default(0)

  user         User               @relation(fields: [userId], references: [id], onDelete: Cascade)
  channel      InstagramChannel?  @relation(fields: [channelId], references: [id], onDelete: SetNull)
  steps        AutomationStep[]
  logs         AutomationLog[]

  createdAt    DateTime           @default(now())
  updatedAt    DateTime           @updatedAt

  @@index([userId])
  @@index([channelId])
  @@index([triggerType])
  @@map("automations")
}

model AutomationStep {
  id           String     @id @default(uuid())
  automationId String
  order        Int        // 0, 1, 2...
  stepType     String     // SEND_DM, REPLY_COMMENT, QUICK_REPLIES, DELAY, ADD_TAG
  content      Json       // { text: "...", buttons?: [...], replies?: [...], delaySeconds?: 5, tag?: "lead" }

  automation   Automation @relation(fields: [automationId], references: [id], onDelete: Cascade)
  createdAt    DateTime   @default(now())
  updatedAt    DateTime   @updatedAt

  @@index([automationId])
  @@map("automation_steps")
}

model AutomationLog {
  id           String     @id @default(uuid())
  automationId String
  contactId    String?    // Meta IGSID or handle
  eventData    Json?      // snippet of incoming message/comment
  status       String     // SUCCESS, FAILED, SKIPPED
  errorMessage String?
  executedAt   DateTime   @default(now())

  automation   Automation @relation(fields: [automationId], references: [id], onDelete: Cascade)

  @@index([automationId])
  @@index([executedAt])
  @@map("automation_logs")
}

model ProcessedWebhookEvent {
  id          String   @id // Meta mid or comment ID
  processedAt DateTime @default(now())

  @@map("processed_webhook_events")
}

model InstagramContact {
  id                 String           @id @default(uuid())
  channelId          String
  instagramScopedId  String           // Meta IGSID
  username           String?
  name               String?
  profilePic         String?
  tags               String[]         @default([])
  unreadCount        Int              @default(0)
  lastMessageText    String?          @db.Text
  lastMessageType    String?
  lastMessageAt      DateTime         @default(now())
  isArchived         Boolean          @default(false)
  isPinned           Boolean          @default(false)
  notes              String?          @db.Text
  lastInteractionAt  DateTime         @default(now())
  createdAt          DateTime         @default(now())
  updatedAt          DateTime         @updatedAt

  channel            InstagramChannel @relation(fields: [channelId], references: [id], onDelete: Cascade)
  messages           InstagramMessage[]

  @@unique([channelId, instagramScopedId])
  @@index([channelId])
  @@index([channelId, lastMessageAt])
  @@map("instagram_contacts")
}

model InstagramMessage {
  id                    String           @id @default(uuid())
  channelId             String
  contactId             String
  direction             String           // INBOUND, OUTBOUND
  messageType           String           // TEXT, IMAGE, VIDEO, AUDIO, VOICE, FILE, SHARE, STORY_REPLY, STORY_MENTION, QUICK_REPLY, COMMENT
  text                  String?          @db.Text
  mediaUrl              String?          @db.Text
  mediaType             String?          // image, video, audio, voice, file, share
  status                String           @default("DELIVERED") // PENDING, SENT, DELIVERED, READ, FAILED
  metaMessageId         String?
  replyToMetaMessageId  String?
  rawPayload            Json?
  readAt                DateTime?
  sentAt                DateTime         @default(now())

  channel               InstagramChannel @relation(fields: [channelId], references: [id], onDelete: Cascade)
  contact               InstagramContact @relation(fields: [contactId], references: [id], onDelete: Cascade)

  @@index([channelId])
  @@index([contactId])
  @@index([contactId, sentAt])
  @@map("instagram_messages")
}
```

---

## 9. Environment Variables Reference

### Backend (`backend/.env`)
```env
# Application
PORT=5001
NODE_ENV=production
FRONTEND_URL="https://aurenconnect-hub.web.app"

# Database
DATABASE_URL="postgresql://user:password@host:5432/aurenconnect?sslmode=require"

# JWT Authentication
JWT_ACCESS_SECRET="your-secure-access-secret"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN_DAYS=30

# Encryption (for Meta Access Tokens)
TOKEN_ENCRYPTION_KEY="32-byte-hex-encoded-secret-key"

# Meta Graph API & Unified Login
META_APP_ID="1009110748118284"
META_APP_SECRET="your-meta-app-secret"
META_CONFIG_ID="2129576484586654"
META_REDIRECT_URI="https://auren-backend-5weg.onrender.com/api/v1/instagram/callback"
META_WEBHOOK_VERIFY_TOKEN="your-webhook-verification-token"
```

### Frontend (`lib/core/network/api_constants.dart`)
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://auren-backend-5weg.onrender.com/api/v1',
);
```

---

## 10. cURL Examples for Testing

### Register
```bash
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Auren Creator",
    "email": "creator@aurenconnect.com",
    "password": "Password123"
  }'
```

### Login
```bash
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "aurenthecreator@gmail.com",
    "password": "auren 123"
  }'
```

### Get Profile
```bash
curl https://auren-backend-5weg.onrender.com/api/v1/auth/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Get Instagram Connect Authorization URL
```bash
curl https://auren-backend-5weg.onrender.com/api/v1/instagram/connect \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### List Connected Instagram Accounts
```bash
curl https://auren-backend-5weg.onrender.com/api/v1/instagram/accounts \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Disconnect Instagram Account
```bash
curl -X DELETE https://auren-backend-5weg.onrender.com/api/v1/instagram/accounts/<CHANNEL_ID> \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### List Automations
```bash
curl "https://auren-backend-5weg.onrender.com/api/v1/automations" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Create Comment-to-DM Automation
```bash
curl -X POST "https://auren-backend-5weg.onrender.com/api/v1/automations" \
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
```

### Toggle Automation Status
```bash
curl -X PATCH "https://auren-backend-5weg.onrender.com/api/v1/automations/<AUTOMATION_ID>/toggle" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Get Automation Analytics
```bash
curl "https://auren-backend-5weg.onrender.com/api/v1/automations/analytics/overview" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Refresh Token
```bash
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "<REFRESH_TOKEN>"
  }'
```

### Logout
```bash
curl -X POST https://auren-backend-5weg.onrender.com/api/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "<REFRESH_TOKEN>"
  }'
```
