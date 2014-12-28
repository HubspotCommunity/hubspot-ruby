# Releasing to Rubygems

1. Update version in `lib/hubspot/version.rb`.
2. Regenerate gemspec with `rake gemspec:generate`.
3. Commiti & push `version.rb` and `hubspot-ruby.gemspec`.
4. Build the gem with `gem build hubspot-ruby.gemspec`.
5. Push the resulting .gem file to Rubygems with `gem push`
