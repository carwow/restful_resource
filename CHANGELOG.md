# Changelog

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
