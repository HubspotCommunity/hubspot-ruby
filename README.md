# HubSpot REST API wrappers for ruby

[![Build Status](https://travis-ci.org/adimichele/hubspot-ruby.svg?branch=master)](https://travis-ci.org/adimichele/hubspot-ruby)

**This is the master branch and contains unreleased and potentially breaking changes. If you are looking for the most recent stable release you want the [v0-stable branch](https://github.com/adimichele/hubspot-ruby/tree/v0-stable).**

Wraps the HubSpot REST API for convenient access from ruby applications.

Documentation for the HubSpot REST API can be found here: https://developers.hubspot.com/docs/endpoints

## Setup

    gem install hubspot-ruby

Or with bundler,

```ruby
gem "hubspot-ruby"
```

## Getting Started
This library can be configured to use OAuth or an API key. To find the
appropriate values for either approach, please visit the [HubSpot API
Authentication docs].

Below is a complete list of configuration options with the default values:
```ruby
Hubspot.configure({
  hapikey: <HAPIKEY>,
  base_url: "https://api.hubapi.com",
  portal_id: <PORTAL_ID>,
  logger: Logger.new(nil),
  access_token: <ACCESS_TOKEN>,
  client_id: <CLIENT_ID>,
  client_secret: <CLIENT_SECRET>,
  redirect_uri: <REDIRECT_URI>,
  timeout: nil,
})
```

If you're new to using the HubSpot API, visit the [HubSpot Developer Tools] to
learn about topics like "what's a portal id?" and creating a testing
environment.

[HubSpot API Authentication Docs]: https://developers.hubspot.com/docs/methods/auth/oauth-overview
[HubSpot Developer Tools]: https://developers.hubspot.com/docs/devtools

## Authentication with an API key

To set the HubSpot API key, aka `hapikey`, run the following:
```ruby
Hubspot.configure(hapikey: "YOUR_API_KEY")
```

If you have a HubSpot account, you can find your API key by logging in and
visiting: https://app.hubspot.com/keys/get

## Authentication with OAuth 2.0

Configure the library with the client ID and secret from your [HubSpot App](https://developers.hubspot.com/docs/faq/how-do-i-create-an-app-in-hubspot)

```ruby
Hubspot.configure(
    client_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    client_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    redirect_uri: "https://myapp.com/oauth")
```

To initiate an OAuth connection to your app, create a URL with the required scopes:

```ruby
Hubspot::OAuth.authorize_url(["contacts", "content"])
```

After the user accepts the scopes and installs the integration with their HubSpot account, they will be redirected to the URI requested with the query parameter `code` appended to the URL. `code` can then be passed to HubSpot to generate an access token:

```ruby
Hubspot::OAuth.create(params[:code])
```

To use the returned `access_token` string for authentication, you'll need to update the configuration:

```ruby
Hubspot.configure(
    client_id: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    client_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    redirect_uri: "https://myapp.com/oauth",
    access_token: access_token)
```

Now all requests will use the provided access token when querying the API:

```ruby
Hubspot::Contact.all
```

### Refreshing the token

When you create a HubSpot OAuth token, it will have an expiration date given by the `expires_in` field returned from the create API. If you with to continue using the token without needing to create another, you'll need to refresh the token:

```ruby
Hubspot::OAuth.refresh(refresh_token)
```

### A note on OAuth credentials

At this time, OAuth tokens are configured globally rather than on a per-connection basis.

## Usage

Classes have been created that map to Hubspot resource types and attempt to abstract away as much of the API specific details as possible. These classes generally follow the [ActiveRecord](https://en.wikipedia.org/wiki/Active_record_pattern) pattern and general Ruby conventions. Anyone familiar with [Ruby On Rails](https://rubyonrails.org/) should find this API closely maps with familiar concepts.


### Creating a new resource

```ruby
irb(main):001:0> company = Hubspot::Company.new(name: "My Company LLC.")
=> #<Hubspot::Company:0x000055b9219cc068 @changes={"name"=>"My Company LLC."}, @properties={}, @id=nil, @persisted=false, @deleted=false>

irb(main):002:0> company.persisted?
=> false

irb(main):003:0> company.save
=> true

irb(main):004:0> company.persisted?
=> true
```

```ruby
irb(main):001:0> company = Hubspot::Company.create(name: "Second Financial LLC.")
=> #<Hubspot::Company:0x0000557ea7119fb0 @changes={}, @properties={"hs_lastmodifieddate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceId"=>nil, "versions"=>[{"name"=>"hs_lastmodifieddate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "name"=>{"value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"name", "value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "createdate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"createdate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}, {"name"=>"createdate", "value"=>"1552234087467", "timestamp"=>1552234087467, "sourceId"=>"API", "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}}, @id=1726317857, @persisted=true, @deleted=false, @metadata={"portalId"=>62515, "companyId"=>1726317857, "isDeleted"=>false, "additionalDomains"=>[], "stateChanges"=>[], "mergeAudits"=>[]}>

irb(main):002:0> company.persisted?
=> true
```


### Find an existing resource

**Note:** Hubspot uses a combination of different names for the "ID" property of a resource based on what type of resource it is (eg. vid for Contact). This library attempts to abstract that away and generalizes an `id` property for all resources

```ruby
irb(main):001:0> company = Hubspot::Company.find(1726317857)
=> #<Hubspot::Company:0x0000562e4988c9a8 @changes={}, @properties={"hs_lastmodifieddate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceId"=>nil, "versions"=>[{"name"=>"hs_lastmodifieddate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "name"=>{"value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"name", "value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "createdate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"createdate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}}, @id=1726317857, @persisted=true, @deleted=false, @metadata={"portalId"=>62515, "companyId"=>1726317857, "isDeleted"=>false, "additionalDomains"=>[], "stateChanges"=>[], "mergeAudits"=>[]}>

irb(main):002:0> company = Hubspot::Company.find(1)
Traceback (most recent call last):
        6: from /home/chris/projects/hubspot-ruby/bin/console:20:in `<main>'
        5: from (irb):2
        4: from /home/chris/projects/hubspot-ruby/lib/hubspot/resource.rb:17:in `find'
        3: from /home/chris/projects/hubspot-ruby/lib/hubspot/resource.rb:81:in `reload'
        2: from /home/chris/projects/hubspot-ruby/lib/hubspot/connection.rb:10:in `get_json'
        1: from /home/chris/projects/hubspot-ruby/lib/hubspot/connection.rb:52:in `handle_response'
Hubspot::RequestError (Response body: {"status":"error","message":"resource not found","correlationId":"7c8ba50e-16a4-4a52-a304-ff249175a8f1","requestId":"b4898274bf8992924082b4a460b90cbe"})
```


### Updating resource properties

```ruby
irb(main):001:0> company = Hubspot::Company.find(1726317857)
=> #<Hubspot::Company:0x0000563b9f3ee230 @changes={}, @properties={"hs_lastmodifieddate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceId"=>nil, "versions"=>[{"name"=>"hs_lastmodifieddate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"CALCULATED", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "name"=>{"value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"name", "value"=>"Second Financial LLC.", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}, "createdate"=>{"value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceId"=>nil, "versions"=>[{"name"=>"createdate", "value"=>"1552234087467", "timestamp"=>1552234087467, "source"=>"API", "sourceVid"=>[], "requestId"=>"fd45773b-30d0-4d9d-b3b8-a85e01534e46"}]}}, @id=1726317857, @persisted=true, @deleted=false, @metadata={"portalId"=>62515, "companyId"=>1726317857, "isDeleted"=>false, "additionalDomains"=>[], "stateChanges"=>[], "mergeAudits"=>[]}>

irb(main):002:0> company.name
=> "Second Financial LLC."

irb(main):003:0> company.name = "Third Financial LLC."
=> "Third Financial LLC."

irb(main):004:0> company.changed?
=> true

irb(main):005:0> company.changes
=> {:name=>"Third Financial LLC."}

irb(main):006:0> company.save
=> true

irb(main):007:0> company.changed?
=> false

irb(main):008:0> company.changes
=> {}
```

**Note:** Unlike ActiveRecord in Rails, in some cases not all properties of a resource are known. If these properties are not returned by the API then they will not have a getter method defined for them until they've been set first. This may change in the future to improve the user experience and different methods are being tested.

```ruby
irb(main):001:0> company = Hubspot::Company.new
=> #<Hubspot::Company:0x0000561d0a8bdff8 @changes={}, @properties={}, @id=nil, @persisted=false, @deleted=false>

irb(main):002:0> company.name
Traceback (most recent call last):
        3: from /home/chris/projects/hubspot-ruby/bin/console:20:in `<main>'
        2: from (irb):2
        1: from /home/chris/projects/hubspot-ruby/lib/hubspot/resource.rb:215:in `method_missing'
NoMethodError (undefined method `name' for #<Hubspot::Company:0x0000561d0a8bdff8>)

irb(main):003:0> company.name = "Foobar"
=> "Foobar"

irb(main):004:0> company.name
=> "Foobar"
```

### Collections

To make working with API endpoints that return multiple resources easier, the returned instances will be wrapped in a collection instance. Just like in Rails, the collection instance provides helper methods for limiting the number of returned resources, paging through the results, and handles passing the options each time a new API call is made. The collection exposes all Ruby Array methods so you can use things like `size()`, `first()`, `last()`, and `map()`.

```ruby
irb(main):001:0> contacts = Hubspot::Contact.all
=> #<Hubspot::PagedCollection:0x000055ba3c2b55d8 @limit_param="limit", @limit=25, @offset_param="offset", @offset=nil, @options={}, @fetch_proc=#<Proc:0x000055ba3c2b5538@/home/chris/projects/hubspot-ruby/lib/hubspot/contact.rb:18>, @resources=[...snip...], @next_offset=9242374, @has_more=true>

irb(main):002:0> contacts.more?
=> true

irb(main):003:0> contacts.next_offset
=> 9242374

irb(main):004:0> contacts.size
=> 25

irb(main):005:0> contacts.first
=> #<Hubspot::Contact:0x000055ba3c29bac0 @changes={}, @properties={"firstname"=>{"value"=>"My Street X 1551971239 => My Street X 1551971267 => My Street X 1551971279"}, "lastmodifieddate"=>{"value"=>"1551971286841"}, "company"=>{"value"=>"MadKudu"}, "lastname"=>{"value"=>"Test0830181615"}}, @id=9153674, @persisted=true, @deleted=false, @metadata={"addedAt"=>1535664601481, "vid"=>9153674, "canonical-vid"=>9153674, "merged-vids"=>[], "portal-id"=>62515, "is-contact"=>true, "profile-token"=>"AO_T-mPNHk6O7jh8u8D2IlrhZn7GO91w-weZrC93_UaJvdB0U4o6Uc_PkPJ3DOpf15sUplrxMzG9weiTTpPI05Nr04zxnaNYBVcWHOlMbVlJ2Avq1KGoCBVbIoQucOy_YmCBIfOXRtcc", "profile-url"=>"https://app.hubspot.com/contacts/62515/contact/9153674", "form-submissions"=>[], "identity-profiles"=>[{"vid"=>9153674, "saved-at-timestamp"=>1535664601272, "deleted-changed-timestamp"=>0, "identities"=>[{"type"=>"EMAIL", "value"=>"test.0830181615@test.com", "timestamp"=>1535664601151, "is-primary"=>true}, {"type"=>"LEAD_GUID", "value"=>"01a107c4-3872-44e0-ab2e-47061507ffa1", "timestamp"=>1535664601259}]}], "merge-audits"=>[]}>

irb(main):006:0> contacts.next_page
=> #<Hubspot::PagedCollection:0x000055ba3c2b55d8 @limit_param="limit", @limit=25, @offset_param="offset", @offset=9242374, @options={}, @fetch_proc=#<Proc:0x000055ba3c2b5538@/home/chris/projects/hubspot-ruby/lib/hubspot/contact.rb:18>, @resources=[...snip...], @next_offset=9324874, @has_more=true>
```

For Hubspot resources that support batch updates for updating multiple resources, the collection provides an `update_all()` method:

```ruby
irb(main):001:0> companies = Hubspot::Company.all(limit: 5)
=> #<Hubspot::PagedCollection:0x000055d5314fe0c8 @limit_param="limit", @limit=5, @offset_param="offset", @offset=nil, @options={}, @fetch_proc=#<Proc:0x000055d5314fe028@/home/chris/projects/hubspot-ruby/lib/hubspot/company.rb:21>, @resources=[...snip...], @next_offset=116011506, @has_more=true>

irb(main):002:0> companies.size
=> 5

irb(main):003:0> companies.update_all(lifecyclestage: "opportunity")
=> true

irb(main):004:0> companies.refresh
=> #<Hubspot::PagedCollection:0x000055d5314fe0c8 @limit_param="limit", @limit=5, @offset_param="offset", @offset=nil, @options={}, @fetch_proc=#<Proc:0x000055d5314fe028@/home/chris/projects/hubspot-ruby/lib/hubspot/company.rb:21>, @resources=[...snip...], @next_offset=116011506, @has_more=true>
```

### Deleting a resource

```ruby
irb(main):001:0> contact = Hubspot::Contact.find(9324874)
=> #<Hubspot::Contact:0x000055a87c87aee0 ...snip... >

irb(main):002:0> contact.delete
=> true
```

## Resource types

**Note:** These are the currently defined classes the support the new resource API. This list will continue to grow as we update other classes. All existing classes will be updated prior to releasing v1.0.

* Contact -> Hubspot::Contact
* Company -> Hubspot::Company

## Contributing to hubspot-ruby

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

### Testing

This project uses [VCR] to test interactions with the HubSpot API.
VCR records HTTP requests and replays them during future tests.

To run the tests, run `bundle exec rake` or `bundle exec rspec`.

By default, the VCR recording mode is set to `:none`, which allows recorded
requests to be re-played but raises for any new request. This prevents the test
suite from issuing unexpected HTTP requests.

To add a new test or update a VCR recording, run the test with the `VCR_RECORD`
environment variable:

```sh
VCR_RECORD=1 bundle exec rspec spec
```

[VCR]: https://github.com/vcr/vcr

## Disclaimer

This project and the code therein was not created by and is not supported by HubSpot, Inc or any of its affiliates.

