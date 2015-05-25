# Erbse

_An updated version of Erubis._

Erbse compiles an ERB string to a string of Ruby. It is completely decoupled from any framework and does only one thing. Pretty boring, I know.

## Added features

* Block support a la Rails.

  ```erb
  <%= form_tag .. do |f| %>
    <%= f.fields_for do %>
     ...
    <% end %>
  <% end %>
  ```

## API

The API is extremely simple.

```ruby
Erbse::Template.new("<% ... %>").call #=> string of compiled ruby.
```

Template only accepts a content string which is the ERB template. The only public `#call` method returns a string of the compiled template that can then be evaluated in a context.

The user layer, like Tilt, has to take care of caching the `Erbse::Template` instances.


# License

MIT License

# Contributors

* @iazel
* @seuros


# Authors

* Copyright 2015 Nick Sutterer <apotonick@gmail.com>
* Copyright 2006-2011 makoto kuwata <kwa(at)kuwata-lab.com>
