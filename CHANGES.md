# 0.1.0

* Internally, we're parsing the ERB template into a SEXP structure and let [Temple](https://github.com/judofyr/temple) compile it to Ruby. Many thanks to the Temple team! 😘
* Yielding ERB blocks will simply return the content, no output buffering with instance variables will happen.
    This allows to pass ERB blocks around and yield them in other objects without having it output twice as in 0.0.2.
* No instance variables are used anymore, output buffering always happens via locals the way [Slim](https://github.com/slim-template/slim) does it. This might result in a minimal speed decrease but cleans up the code and architecture immensely.
* Removed `Erbse::Template`, it was completely unnecessary code.

# 0.0.2

* First release. No escaping is happening and I'm not sure how capture works, yet. But: it's great!
