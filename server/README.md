# Budget Tracker Backend (Spring Boot)

## Requirements
- Java 17+
- Maven 3.9+
- PostgreSQL

## Configuration
Edit `server/src/main/resources/application.yml`:
```
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/budget_db
    username: postgres
    password: postgres
app:
  jwt:
    secret: <base64-encoded-random-secret>
    expiration-ms: 2592000000
```
Generate a strong Base64 secret, e.g. 64+ bytes.

## Run
```
# from C:\Users\lawio\budget_tracker\server
mvn spring-boot:run
```
App runs on `http://localhost:8080`.

## API
- POST `/api/auth/register` { name, email, password }
- POST `/api/auth/login` { email, password } -> { token, user }
- GET `/api/users/me` (Authorization: Bearer <token>)
- PUT `/api/users/me` { name?, balance?, currency? }
- GET `/api/currency/convert?amount=100&from=USD&to=EUR`

## Notes
- Passwords stored using BCrypt.
- JWT used for auth.
- Currency conversion uses exchangerate.host.
