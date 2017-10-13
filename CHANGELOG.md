# Changelog

v2.1.0
---

- Add `open_timeout` and `timeout` options to `Base.configure` and all request methods

v1.6.0
---
- group ServiceUnavailable, Timeout, and ClientError as subclasses of RetryableError
  [#20](https://github.com/carwow/restful_resource/pull/20)
