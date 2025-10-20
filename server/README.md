# Budget Tracker Backend (Spring Boot)

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
