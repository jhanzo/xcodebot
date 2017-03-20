Xcode Bot is a feature of XcodeServer app and brings a convenient way to manage your server automatically.

Unfortunately, the only solution Apple provides us to manage this bot is through their API. But sometimes for any ~strange~ reason you decide to run your CI server (like Jenkins) on a non-MacOS machine.

*So how to have a bidirectionnal communication between XcodeServer and Jenkins-like server ?
How to detect when your bot starts/stopped/failed/... ?*

For all these reasons, this **unofficial** **Xcodebot** project has been created. It's just a convenient wrapper to use XcodeServer API. Feel free to open issues / open PRs.

For more information about the API, because of [Apple doc](https://developer.apple.com/library/content/documentation/Xcode/Conceptual/XcodeServerAPIReference/Bots.html#//apple_ref/doc/uid/TP40016472-CH2-SW1) is not maintained anymore, you can visit this unofficial doc : https://github.com/buildasaurs/XcodeServer-API-Docs.

## Installation

    $ gem install xcodebot

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhanzo/xcodebot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
