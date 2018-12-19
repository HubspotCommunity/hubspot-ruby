## 1.0.0 (TBD)

* [#168] `Hubspot.configure` will raise when given none or multiple ways to
  authenticate with the HubSpot API.

[#168]: https://github.com/adimichele/hubspot-ruby/pull/168

* [#167] Updates the endpoints referenced in `CompanyProperties` to match the new
  HubSpot CompanyProperty endpoints.

[#167]: https://github.com/adimichele/hubspot-ruby/pull/167

* [#166] Updates the endpoints referenced in `ContactProperties` to match the new
  HubSpot ContactProperty endpoints.

[#166]: https://github.com/adimichele/hubspot-ruby/pull/166

## 0.6.1 (November 29, 2018)

* [#148] Deprecate the use of the hubspot rake tasks. Deprecating these tasks
  includes deprecating the use of `Hubspot::Utils.dump_properties` and
  `Hubspot::Utils.restore_properties`.

[#148]: https://github.com/adimichele/hubspot-ruby/pull/148

* [#148] Fix backwards compatibility to ensure users can access the hubspot rake
  tasks

[#148]: https://github.com/adimichele/hubspot-ruby/pull/148

## 0.6.0 (November 28, 2018)

* [#141] Add `HubSpot` as an alias of `Hubspot`

[#141]: https://github.com/adimichele/hubspot-ruby/pull/140

* [#134] Add support to find recently created or recently modified Companies

[#134]: https://github.com/adimichele/hubspot-ruby/pull/134
