# Json::Schema::Subset::DSL

Yet another JSON Schema subset DSL.

Useful when writing a simple JSON schema.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json-schema-subset-dsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-schema-subset-dsl

## Usage

```ruby
dsl = Json::Schema::Subset::DSL.new do
  title! "Example"
  id :integer
  name :string, minLength: 1, optional: true
  items :array, optional: true do
  end
  other_names :array, optional: true do
    string!
    null!
  end
  meta :object do
    description :string
    params :array do
      ref! "#/components/Param"
    end
    opt_params :array do
      cref! "OptParam"
    end
    uuid :ref, "#/UUID", optional: true
  end
end

dsl.compile! == {
  "type" => "object",
  "properties" => {
    "id" => { "type" => "integer" },
    "name" => { "minLength" => 1, "type" => "string" },
    "items" => { "items" => { "type" => "object", "properties" => {} }, "type" => "array" },
    "other_names" => { "items" => { "type" => %w[string null] }, "type" => "array" },
    "meta" => {
      "type" => "object",
      "properties" => {
        "description" => { "type" => "string" },
        "params" => { "items" => { "$ref" => "#/components/Param" }, "type" => "array" },
        "opt_params" => { "items" => { "$ref" => "#/components/OptParam" }, "type" => "array" },
        "uuid" => { "$ref" => "#/UUID" },
      },
      "required" => %w[description params opt_params],
    },
  },
  "required" => %w[id meta],
  "title" => "Example",
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Narazaka/json-schema-subset-dsl.
