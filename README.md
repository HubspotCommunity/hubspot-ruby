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
)}
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

Here's what you can do for now:

### Create a contact

```ruby
Hubspot::Contact.create!("email@address.com", {firstname: "First", lastname: "Last"})
```

#### In batches

```ruby
Hubspot::Contact.create_or_update!([{email: 'smith@example.com', firstname: 'First', lastname: 'Last'}])
```

### Find a contact

These methods will return a `Hubspot::Contact` object if successful, `nil` otherwise:

```ruby
Hubspot::Contact.find_by_email("email@address.com")
Hubspot::Contact.find_by_id(12345) # Pass the contact VID
```

### Update a contact

Given an instance of `Hubspot::Contact`, update its attributes with:

```ruby
contact.update!({firstname: "First", lastname: "Last"})
```

#### In batches

```ruby
Hubspot::Contact.create_or_update!([{vid: '12345', firstname: 'First', lastname: 'Last'}])
```

### Create a deal

```ruby
Hubspot::Deal.create!(nil, [company.vid], [contact.vid], pipeline: 'default', dealstage: 'initial_contact')
```

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

