Xcode Bot is a feature of XcodeServer app and brings a convenient way to manage your server automatically.

Unfortunately, the only solution Apple provides us to manage this bot is through their API (https://127.0.0.1:20343/api). But sometimes for any ~strange~ reason you decide to run your CI server (like Jenkins) on a non-MacOS machine.

*So how to have a bidirectionnal communication between XcodeServer and Jenkins-like server ? 
How to detect when your bot starts/stopped/failed/... ?*

For all these reasons, this **unofficial** **Xcodebot** project has been created. It's just a convenient wrapper to use XcodeServer API. Feel free to bring any support.

## Installation

    $ gem install xcodebot

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhanzo/xcodebot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
