Xcodebot is a non-official cross-platform tool for managing Xcode server on *any server environment* (only Ruby is required).

This repo lets you a solution for calling Xcode server on ANY CI server (ex: Jenkins) hosted on ANY non-MacOS machine.

Where Xcode API was ASYNCHRONOUS, the following bot can be used completely SYNCHRONOUSLY.

Some ideas for using it :

- bidirectionnal communication between XcodeServer and CI server
- call Xcodebot on any environment with or without Xcode
- display Xcodebot results easier than in an huge JSON
- ...

Feel free to open issues / open PRs.

$ gem install xcodebot

## References

### API Reference

- An outdated (but official) [Apple documentation](https://developer.apple.com/library/content/documentation/Xcode/Conceptual/XcodeServerAPIReference/Bots.html#//apple_ref/doc/uid/TP40016472-CH2-SW1)
- A more detailled (unofficial) doc from [Buildasaurs/XcodeServer-API-Docs](https://github.com/buildasaurs/XcodeServer-API-Docs).


### Outdated but awesome repo

These (outdated) repositories have been a great source of inspiration for creating this repo. Great thanks to them.

- https://github.com/buildasaurs/XcodeServer-API-Docs
- https://github.com/buildasaurs/xcskarel
- https://github.com/oarrabi/xserverpy

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhanzo/xcodebot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
