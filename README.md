# Erbse

_An updated version of Erubis._

Erbse compiles an ERB string to a string of Ruby. It is completely decoupled from any framework and does only one thing. Pretty boring, I know.

## TODO

* Block comments
* Add newlines in compiled Ruby.


## Added features

* Block support à la Rails.

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


## Planned

Block inheritance.

```erb
<h1><%= title %></h1>

<% fragment :subheader do %>
  Or: <%= subheader %>
<% end %>
```

This fragment could then be overridden.

Feel free to contribute!!!


## Used where?

Erbse is the ERB engine in [Cells 4](https://github.com/apotonick/cells) in combination with Tilt..

It also hopefully gets used in Rails 5/6, so we can remove those horrible hacks from AV.


# License

MIT License

# Contributors

* Special thanks to [Aman Gupta](https://github.com/tmm1) for [performance tweaks](https://github.com/rails/rails/pull/9555) that are merged in Erbse.
* @iazel
* @seuros


# Authors

* Copyright 2015 Nick Sutterer <apotonick@gmail.com>
* Copyright 2006-2011 makoto kuwata <kwa(at)kuwata-lab.com>
