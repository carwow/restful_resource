# Changelog

2.6.0
---

- Add `X-Client-Timeout` header on requests if a client timeout is set


2.5.3
---

- Raise `RestfulResource::HttpClient::GatewayTimeout` when response status is `504`


2.5.2
---

- Add ability to set `timeout` and `open_timeout` options on connection

2.5.1
---

- Add support for `PATCH` in `RestfulResource::RailsValidation`
- Improved specs for `PATCH` features

2.5.0
---

- Add support for `PATCH`

v2.4.0
---

- Add `faraday_options` to `Base.configure`

v2.1.0
---

- Add `open_timeout` and `timeout` options to `Base.configure` and all request methods

v1.6.0
---
- group ServiceUnavailable, Timeout, and ClientError as subclasses of RetryableError
  [#20](https://github.com/carwow/restful_resource/pull/20)
