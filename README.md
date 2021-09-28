# Feeb 🥩

Fibonacci REST JSON API

# API

1. `GET /:n`

> An endpoint that returns the value from the Fibonacci sequence for a given number.

Params:

  - `:n` (non negative integer) - the requested Nth Fibonacci number

Request: `curl http://localhost:4001/6`

Response: `{"result": 8}`

2. `GET /list/:n?next_key=:k&size=:s`

> An endpoint that returns a list of numbers and the corresponding values from the Fibonacci sequence from 1 to N with support for pagination. Page size should be parameterized with a default of 100.

Params:

  - `:n` (non negative integer) - the requested Nth Fibonacci number
  - `:k` (non negative integer) - optional (default: `0`) value of the next Nth number for pagination
  - `:s` (non negative integer) - optional (default: `100`) value of the number of results per one page

Request: `curl http://localhost:4001/list/42?next_key=2&size=3`

Response: `{"result": [1, 2, 3], "next_key": 5}`

3. `PUT /blacklist/:n`

> An endpoint to blacklist a number to permanently stop it from being shown in Fibonacci results when requested. The blacklisted numbers should persist in application state.

  - `:n` (non negative integer) - the Nth Fibonacci number

Request: `curl PUT http://localhost:4001/blacklist/42`

Response: `204 No Content`

4. `DELETE /blacklist/:n`

> An endpoint to remove a number from the blacklist.

  - `:n` (non negative integer) - the Nth Fibonacci number

Request: `curl DELETE http://localhost:4001/blacklist/42`

Response: `204 No Content`

# Tests

To run tests, make sure elixir is installed and run

```
make tests
```
