# Feeb

Fibonacci REST JSON API

1. `GET /:n` An endpoint that returns the value from the Fibonacci sequence for a given number.

2. `GET /list/:n?last_key=:k&size=:s` An endpoint that returns a list of numbers and the corresponding values from the Fibonacci sequence from 1 to N with support for pagination. Page size should be parameterized with a default
of 100.

3. `PUT /blacklist/:n` An endpoint to blacklist a number to permanently stop it from being shown in Fibonacci results
when requested. The blacklisted numbers should persist in application state.

4. `DELETE /blacklist/:n` An endpoint to remove a number from the blacklist.

