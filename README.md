# Erbse

_An updated version of Erubis._

Erbse compiles an ERB string to a string of Ruby.

## API

The API is one public method.

```ruby
Erbse::Engine.new.call("<% ... %>") #=> string of compiled ruby.
```

The returned string can then be `eval`uated in a certain context.

## Block Yielding

Erbse supports blocks à la Rails.

You may pass any mix of text/ERB via blocks to Ruby methods.

```erb
<%= form do %>
  <em>Please fill out all fields!</em>
  <%= input :email %>
  <button type="submit">
<% end %>
```

Here, the `form` method receives a block of compiled Ruby.

When `yield`ed, the block simply returns its evaluated content as a string. It's your job to assign it to an output buffer, **no instance variables are used**.

```ruby
def form(&block)
  content = yield
  "<form>#{content}</form>"
end
```
Usually, returning the content from the helper will be sufficient.

However, you can totally pass that block to a completely different object and yield it there. Since there's no global state as in ERB, this will work.

## Removed Features

Erbse does *not* support any tags other than `<% %>` and `<%= %>`. Tags such as `<%% %>`, `<%== %>`, `<%- %>` or `<% -%>` will be reduced to the supported tags.

## TODO

* Block comments
* Add newlines in compiled Ruby.

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

## Users

Erbse is the ERB engine in [Cells](https://github.com/apotonick/cells).

## License

MIT License

## Contributors

* Special thanks to [Aman Gupta](https://github.com/tmm1) for [performance tweaks](https://github.com/rails/rails/pull/9555) that are merged in Erbse.
* @iazel
* @seuros


# Authors

* Copyright 2015 Nick Sutterer <apotonick@gmail.com>
* Copyright 2006-2011 makoto kuwata <kwa(at)kuwata-lab.com>
