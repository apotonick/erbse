# Erbse

_An updated version of Erubis._



## Added features

* block support a la Rails.



* Always get template file content as string. The outer template abstraction layer, like Tilt, has to take care of caching the Erbse Template instances.

== About Erubis

Erubis is an implementation of eRuby. It has the following features.
* Very fast, almost three times faster than ERB and even 10% faster than eruby
* Multi-language support (Ruby/PHP/C/Java/Scheme/Perl/Javascript)
* Auto escaping support
* Auto trimming spaces around '<% %>'
* Embedded pattern changeable (default '<% %>')
* Enable to handle Processing Instructions (PI) as embedded pattern (ex. '<?rb ... ?>')
* Context object available and easy to combine eRuby template with YAML datafile
* Print statement available
* Easy to extend and customize in subclass
* Ruby on Rails support

Erubis is implemented in pure Ruby.  It requires Ruby 1.8 or higher.
Erubis now supports Ruby 1.9.

See doc/users-guide.html for details.





== Benchmark

'benchmark/erubybenchmark.rb' is a benchmark script of Erubis.
Try 'ruby erubybenchmark.rb' in benchmark directory.



# License

MIT License

# Contributors

* @iazel
* @seuros


# Authors

Copyright 2015 Nick Sutterer <apotonick@gmail.com>
Copyright 2006-2011 makoto kuwata <kwa(at)kuwata-lab.com>
