# FakeHome

It manipulates and restores your environment variable $HOME. I recommend to use it in your test suite.

## Installation

Add this line to your application's Gemfile:

    gem 'fake_home'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fake_home

## Usage

``` ruby
include FakeHome

Home.new("/tmp/fake_home").fake_home do |new_home|
  new_home == ENV["HOME"]
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
