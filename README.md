# MorpherJS

MorpherJS is an JavaScript image morphing library. It uses HTML 5 canvas element.

I've extracted it from my [FruitLabour](http://fruit-labour.nibynic.com/) project, which allows you to mix fruits and create new species.

MorpherJS comes along with [GUI] which helps you to configure your own Morpher instance (add images, define geometry, etc.).

# Features

* Unlimited images count &mdash; use as many as you need,
* Custom blend functions,
* Animation with jQuery easing support.

# Usage

* Use [GUI] to configure your own morpher,
* Export JSON code with your configuration,
* Include [morpher.js] file on your page,
* Create Morpher instance:

        var json = {}; // the code you've exported from the GUI
        var morpher = new Morpher(json);
    

* Add morpher's canvas to the DOM:

        document.body.appendChild(morpher.canvas);

* Animate it!

        morpher.set([1, 0]);
        morpher.animate([0, 1], 200);

Check out [demos page] for an inspiration.

## Events

You can listen to events using typical `on` and `off` methods:

        var morpher = new Morpher(/* some JSON */);
        morpher.on("load", function(morpher, canvas) {
            // do something
        });

* `load`: `(morpher, canvas)` – all images are loaded and ready to morph
* `change`: `(morpher, canvas)` – any change in geometry happened
* `draw`: `(morpher, canvas)` – new frame (image) was drawn
* `resize`: `(morpher, canvas)` – canvas was resized
* `animation:start`: `(moprher)`
* `animation:complete`: `(moprher)`
* `image:add`: `(morpher, image)`
* `image:remove`: `(morpher, image)`
* `point:add`: `(morpher)`
* `point:remove`: `(morpher)`
* `triangle:add`: `(morpher)`
* `triangle:remove`: `(morpher)`

# License

Copyright (c) 2012 Paweł Bator. MIT License, see [LICENSE] for details.

[GUI]: http://jembezmamy.github.io/morpher-js/
[morpher.js]: http://jembezmamy.github.io/morpher-js/javascripts/morpher/morpher.js
[demos page]: http://jembezmamy.github.io/morpher-js/demos.html
[LICENSE]: https://github.com/jembezmamy/morpher-js/blob/master/LICENSE

