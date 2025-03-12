# Changelog
2.19.0
---
- Remove resolv-replace dependency


2.18.2
---

- Update rack to `~ 3.0` to resolve security vulnerabilities

2.18.1
---

- Explicitly require 'ostruct' to prevent load error

2.18
---

- Configure Faraday's default adapter as `net_http`
- Fix `X-Client-Start` & `X-Client-Timeout` headers to be strings not integers

2.17
---

- Re-add deprecation for :dig and :[] since they are still used by some clients

2.16
---

- Remove deprecation for :dig and :[]

2.15
---

- Bump `faraday` to a minimum of `1.10` to resolve dependency issues

2.14
---

- Added support for default headers when configuring a `RestfulResource::Base`

2.13.4
---

- Support passing a an instance of `RestfulResource::Response` to the constructor for a `RestfulResource::HttpClient::HttpError`

2.13.3
---

- Added double splat operator to resolve failures when fetching data from finance app

2.13.2
---

- Added double splat operator to resolve failures when fetching data from other projects

2.13.1
---

- Update activesupport requirement from ~> 6.0 to >= 6, < 8 (#152)

2.13.0
---

- Require ruby >= 2.7

2.10.0
---

- Support Faraday v1 (#85)

2.9.0
---

- Add support for DELETE in RestfulResource::RailsValidations (#73)

2.8.1
---

- Looser Faraday requirement >= 0.15, < 1.1

2.8.0
---

- Make params hash in methods consistent, and always optional (#61)

2.7.0
---

- Add `X-Client-Start` header on request containing milliseconds since unix epoch

2.6.1
---

- Support only `faraday-0.15.x`
    - `0.16.x` breaks `faraday-http-cache`

2.6.0 (yanked)
---

- Upgrade to `faraday-0.16.x`
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
