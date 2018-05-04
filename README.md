# HubSpot REST API wrappers for ruby

Wraps the HubSpot REST API for convenient access from ruby applications.

Documentation for the HubSpot REST API can be found here: https://developers.hubspot.com/docs/endpoints

## Setup

    gem install hubspot-ruby

Or with bundler,

```ruby
gem "hubspot-ruby"
```

Before using the library, you must initialize it with your HubSpot API key. If you're using Rails, put this code in an
initializer:

```ruby
Hubspot.configure(hapikey: "YOUR_API_KEY")
```

If you have a HubSpot account, you can get your api key by logging in and visiting this url: https://app.hubspot.com/keys/get

### Note about authentication

For now, this library only supports authentication with a HubSpot API key (aka "hapikey"). OAuth is not yet supported.

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

All tests can be run with `rake spec`. Isolate fast-running tests with `rake spec:quick`.

GET requests are pretty easy to test with VCR, but for POST/PUT requests, you probably want to update verify the state
of a live HubSpot instance. To do this, please add "live" tests to `spec/live/`, using the rspec label `live: true` in
order to disable VCR.

"Live" tests can be isolated with `rake spec:live`.

## Disclaimer

This project and the code therein was not created by and is not supported by HubSpot, Inc or any of its affiliates.

