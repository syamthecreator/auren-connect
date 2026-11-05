# aurenConnect API Documentation

**Backend:** Node.js, TypeScript, Express\
**Database:** PostgreSQL\
**ORM:** Prisma\
**API version:** `v1`\
**Development base URL:** `http://localhost:5001/api/v1`

This document covers the authentication endpoints currently implemented
in the aurenConnect backend.

## 1. Getting started

From the `backend` directory, start the development server:

``` bash
npm run dev
```

The server runs at `http://localhost:5001`.

### Health check

**GET** `/api/v1/health`

Example response (`200 OK`):

``` json
{
  "success": true,
  "message": "Server is healthy",
  "timestamp": "2026-11-05T10:03:09.164Z"
}
```

The root endpoint `GET http://localhost:5001/` also returns an
API-running message.

## 2. Response format

Successful responses generally follow this structure:

``` json
{
  "success": true,
  "message": "Operation completed",
  "data": {}
}
```

Error responses generally follow this structure:

``` json
{
  "success": false,
  "message": "Description of the error"
}
```

Validation errors may also include an `errors` array containing field
names and validation messages.

## 3. Authentication endpoints

All paths are relative to `http://localhost:5001/api/v1`.

  ------------------------------------------------------------------------
  Method            Endpoint           Authentication    Description
  ----------------- ------------------ ----------------- -----------------
  POST              `/auth/register`   No                Create an account

  POST              `/auth/login`      No                Sign in and
                                                         create a session

  POST              `/auth/refresh`    No                Rotate refresh
                                                         token and issue a
                                                         new access token

  POST              `/auth/logout`     No                Revoke a refresh
                                                         token

  GET               `/auth/me`         Bearer access     Get the current
                                       token             user's profile
  ------------------------------------------------------------------------

### 3.1 Register

Create a user account.

**POST** `/auth/register`

Header:

``` http
Content-Type: application/json
```

Request body:

``` json
{
  "name": "Syam",
  "email": "syam@example.com",
  "password": "YourPassword123"
}
```

Validation: - `name`: required, 2--100 characters after trimming. -
`email`: required, valid email address; converted to lowercase. -
`password`: required, 8--72 characters.

Success response: **201 Created**

``` json
{
  "success": true,
  "message": "Account created successfully",
  "data": {
    "user": {
      "id": "USER_UUID",
      "name": "Syam",
      "email": "syam@example.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-05T10:03:09.164Z"
    }
  }
}
```

Possible errors:

  Status   Meaning
  -------- -------------------------------------------
  `400`    Validation failed
  `409`    An account with this email already exists
  `500`    Unexpected registration error

### 3.2 Login

Authenticate an existing user. A successful login creates a database
session and returns access and refresh tokens.

**POST** `/auth/login`

Header:

``` http
Content-Type: application/json
```

Request body:

``` json
{
  "email": "syam@example.com",
  "password": "YourPassword123"
}
```

Success response: **200 OK**

``` json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "USER_UUID",
      "name": "Syam",
      "email": "syam@example.com",
      "status": "ACTIVE"
    },
    "accessToken": "ACCESS_TOKEN",
    "refreshToken": "REFRESH_TOKEN",
    "tokenType": "Bearer",
    "expiresIn": 900
  }
}
```

`expiresIn` is measured in seconds. The current access-token lifetime is
900 seconds (15 minutes). The refresh-token session is initially valid
for 30 days.

Possible errors:

  Status   Meaning
  -------- ---------------------------
  `400`    Validation failed
  `401`    Invalid email or password
  `403`    Account is not active
  `500`    Unexpected login error

### 3.3 Refresh access token

Use the latest refresh token to obtain a new access token and a rotated
refresh token.

**POST** `/auth/refresh`

Header:

``` http
Content-Type: application/json
```

Request body:

``` json
{
  "refreshToken": "CURRENT_REFRESH_TOKEN"
}
```

Success response: **200 OK**

``` json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "NEW_ACCESS_TOKEN",
    "refreshToken": "NEW_REFRESH_TOKEN",
    "tokenType": "Bearer",
    "expiresIn": 900
  }
}
```

**Important:** Refresh tokens are rotated. Replace the old refresh token
with the new one returned by this endpoint.

Possible errors:

  Status   Meaning
  -------- -----------------------------------------------
  `400`    Validation failed
  `401`    Refresh token is invalid, expired, or revoked
  `403`    Account is not active
  `500`    Unexpected refresh error

### 3.4 Logout

Revoke the supplied refresh token.

**POST** `/auth/logout`

Header:

``` http
Content-Type: application/json
```

Request body:

``` json
{
  "refreshToken": "CURRENT_REFRESH_TOKEN"
}
```

Success response: **200 OK**

``` json
{
  "success": true,
  "message": "Logout successful"
}
```

Possible errors:

  Status   Meaning
  -------- --------------------------
  `400`    Validation failed
  `401`    Refresh token is invalid
  `500`    Unexpected logout error

The current implementation revokes the refresh token. An already-issued
access token can remain usable until it expires; access-token revocation
is not currently implemented.

### 3.5 Get current user profile

Get the profile for the user ID contained in the access token.

**GET** `/auth/me`

Headers:

``` http
Authorization: Bearer ACCESS_TOKEN
Accept: application/json
```

No request body is required.

Success response: **200 OK**

``` json
{
  "success": true,
  "data": {
    "user": {
      "id": "USER_UUID",
      "name": "Syam",
      "email": "syam@example.com",
      "status": "ACTIVE",
      "createdAt": "2026-11-05T10:03:09.164Z"
    }
  }
}
```

Possible errors:

  Status   Meaning
  -------- ----------------------------------------------
  `401`    Access token is missing, invalid, or expired
  `500`    Unable to retrieve the user profile

The authentication middleware verifies the Bearer access token and
attaches its subject (user ID) to the request. The profile endpoint then
loads the active user from PostgreSQL.

## 4. Authentication flow

1.  The user submits email and password to `POST /auth/login`.
2.  The backend validates the request.
3.  The backend finds the user in PostgreSQL and compares the password
    with its bcrypt hash.
4.  The backend creates a session and returns an access token and
    refresh token.
5.  The client sends the access token in the `Authorization: Bearer ...`
    header for protected endpoints such as `/auth/me`.
6.  When the access token expires, the client sends the refresh token to
    `POST /auth/refresh`.
7.  The client replaces both stored tokens with the newly returned
    tokens.
8.  On logout, the client calls `POST /auth/logout` with its current
    refresh token and clears its local authentication state.

## 5. Testing with curl

Replace the sample email and password with the account you registered.

### Register

``` bash
curl -X POST http://localhost:5001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Syam",
    "email": "syam@example.com",
    "password": "YourPassword123"
  }'
```

### Login

``` bash
curl -X POST http://localhost:5001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "syam@example.com",
    "password": "YourPassword123"
  }'
```

### Get profile

``` bash
curl http://localhost:5001/api/v1/auth/me \
  -H "Authorization: Bearer ACCESS_TOKEN"
```

### Refresh token

``` bash
curl -X POST http://localhost:5001/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "CURRENT_REFRESH_TOKEN"
  }'
```

### Logout

``` bash
curl -X POST http://localhost:5001/api/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "CURRENT_REFRESH_TOKEN"
  }'
```

## 6. Flutter integration notes

For Flutter Web running on the same computer as the backend:

``` dart
const baseUrl = 'http://localhost:5001/api/v1';
```

Login sends a JSON POST request to:

``` text
$baseUrl/auth/login
```

For protected requests, include:

``` http
Authorization: Bearer <accessToken>
```

Keep HTTP requests in a service class instead of putting request code
directly inside widgets. Keep authentication state in the existing
`AuthController`.

**Platform note:** `localhost` refers to the device or environment
running Flutter. It works for Flutter Web when the browser and backend
run on the same computer. An Android emulator or physical device needs
an address that can reach the development computer. Production must use
the deployed API URL.

## 7. Current implementation notes and limitations

-   Passwords are hashed with bcrypt before storage.
-   Refresh tokens are stored in PostgreSQL as SHA-256 hashes, not in
    their original form.
-   Access tokens are JWTs and currently expire after 15 minutes.
-   Refresh-token sessions are initially set to expire after 30 days.
-   Refresh tokens are rotated by the refresh endpoint.
-   User status is checked during login, refresh, and profile retrieval.
-   Registration creates an account but does not currently send an email
    verification message.
-   Forgot-password and OTP flows are not included in the current
    backend endpoints.
-   Access-token revocation on logout is not currently implemented.
-   The documented base URL is for local development. Configure the
    deployed URL and production environment variables before production
    use.

## 8. Environment configuration

The backend reads configuration from `backend/.env`. The current setup
includes:

``` env
DATABASE_URL="postgresql://..."
PORT=5001
JWT_ACCESS_SECRET="your-secret-value"
JWT_ACCESS_EXPIRES_IN="15m"
```

Do not commit `.env` files, database credentials, or JWT secrets to Git.
Use strong private secrets and configure production values in your
hosting provider's environment settings.

## 9. API summary

  Method   Development URL                                Description
  -------- ---------------------------------------------- ------------------
  GET      `http://localhost:5001/api/v1/health`          Health check
  POST     `http://localhost:5001/api/v1/auth/register`   Register user
  POST     `http://localhost:5001/api/v1/auth/login`      Login
  POST     `http://localhost:5001/api/v1/auth/refresh`    Refresh tokens
  POST     `http://localhost:5001/api/v1/auth/logout`     Logout
  GET      `http://localhost:5001/api/v1/auth/me`         Get current user


## 10. Current development login credentials

Use these credentials to sign in to the current aurenConnect development account:

| Field | Value |
|---|---|
| Email | `aurenthecreator@gmail.com` |
| Password | `auren 123` |

Login endpoint:

```http
POST http://localhost:5001/api/v1/auth/login
```

Request body:

```json
{
  "email": "aurenthecreator@gmail.com",
  "password": "auren 123"
}
```

> **Security note:** These are development credentials. Do not commit this document with the password to a public Git repository, share it publicly, or reuse this password for other services. For production, remove this section and use a secure password manager.
