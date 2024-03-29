# RestfulResource ![build status](https://circleci.com/gh/carwow/restful_resource.svg?style=shield&circle-token=0558310359000e8786d1fe42774b0e30b2b0e12c) [![Maintainability](https://api.codeclimate.com/v1/badges/61c85db718d559aa97c5/maintainability)](https://codeclimate.com/github/carwow/restful_resource/maintainability)

Provides an ActiveResource like interface to JSON API's

## Caching

Caching using [faraday-http-cache](https://github.com/plataformatec/faraday-http-cache)

Enabled by passing an initialsed cache object (eg Rails.cache)

```
RestfulResource::Base.configure(
  base_url: "http://my.api.com/",
  cache_store: Rails.cache
)
```

### Bypassing the cache

To make requests that bypass the local HTTP cache use the `no_cache: true` option eg:

```
Object.find(1, no_cache: true)
```


## Metrics

### HTTP Metrics

Http requests are automatically instrumented using ActiveSupport::Notifications

A Metrics class can be provided that RestfulResource will use to emit metrics. This class needs to respond to `count, sample, measure` methods.

eg

```
RestfulResource::Base.configure(
  base_url: "http://my.api.com/",
  instrumentation: {
    metric_class: Metrics,  # Required
    app_name: 'rails_site', # Required
    api_name: 'api'         # Optional, defaults to 'api'
  }
)
```

Where the `Metrics` class has in interface like:

```
class Metrics
  module_function

  def count(name, i)
  end

  def sample(name, i)
  end

  def measure(name, i)
  end
end
```

This will call the methods on the Metrics class with:
```
Metrics.measure('rails_site.api.time', 215.161237) # Time taken
Metrics.sample('rails_site.api.status', 200) # HTTP status code
Metrics.count('rails_site.api.called, 1)
```

Note: To customize the names we can specify `:app_name` and `:api_name` options to `RestfulResource::Base.configure`

### HTTP Cache Metrics

Enable Http caching:

```
RestfulResource::Base.configure(
  base_url: "http://my.api.com/",
  cache_store: Rails.cache,
  instrumentation: {
    metric_class: Metrics,
    app_name: 'rails_site',
    api_name: 'api'
  }
)
```

This will call the methods on the Metrics class with:
```
Metrics.sample('rails_site.api.cache_hit', 1) # When a request is served from the cache
Metrics.sample('rails_site.api.cache_miss', 1) # When a request is fetched from the remote API
Metrics.sample('rails_site.api.cache_bypass', 1) # When a request did not go through the cache at all
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Releasing new version

1. Amend the `version.rb` to your desired version on your Pull Request & get it merged
2. Pull latest `main` & create a matching tag e.g.: `git tag -a v2.15.0 -m "Bump Faraday to a minimum 1.10"`
3. Push the tag e.g.: ` git push origin v2.15.0`
4. Run `bundle exec rake release`
    - You'll need to authenticate with RubyGems, the credentials are in [Bitwarden](https://vault.bitwarden.com/#/vault?search=ruby&itemId=54601528-29be-494f-ba3c-aa3300d5dd18)

## Planned Features

### Core
  - Test that has_many and has_one pick correct class for children (if defined)
  - Make base_url resilient when missing trailing slash
  - Implement http authentication

### Active record style validation

### Constraints(mandatory fields)
