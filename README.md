# Launchpad Step Sequencer

This will be a step sequencer for [Renoise](http://www.renoise.com/)
using the [Launchpad](http://novationmusic.de/midi-controllers-digital-dj/launchpad).

* [Download newest version](http://mrvandalo.github.io/stepp0r/)
* [Download at renoise.com](http://www.renoise.com/tools/stepp0r)

## How to release new version

> git flow release start <version>

* remove all print functions (comment them out)
* update version in `manifest.xml` and `Rakefile`

> rake package

* copy xrnx to renoise

> git flow release finish <version>

## Structure

### Layer

Layers should represent something that exists and you can talk to.
Like the `Launchpad` or an `OscClient`.

### Data

Should prevent you from [magic numbers](http://en.wikipedia.org/wiki/Magic_number_\(programming\)).

### Init

Should hold all the stuff you need to set up the system.
Everything from `main.lua` will call stuff from in here.

### Module

A module is something that is used by other Modules.
Most of the time that is something that writes something to the Launchpad.

### Sub-Module

Sub-Modules are no real data-type. Because Modules become hard to manage over time, I split them up in multiple files.
The folder always has a file-named like the folder `require`-ing all the other sub-module.
Every Sub-Module should have a `__init_SUBMODULE` `__activate_SUBMODULE` and `__deactivate_SUBMODULE` function, even if
they are empty. These functions will be called in the Modules `init` `_activate` and `_deactivate` function.

### Mode

Is some kind of abstract Module, to toggle other module on and off.

#### Module fields

`self.is_active` and `self.is_not_active` will give you information if this module is activated or not.
Use them in your notifies and callbacks!

`self.is_first_run` and `self.first_run` will always be true till the first time `self._activate()` is called.
After `self._activate()` has finished, those values will be false.
While the first time `self._activate()` is called those values will be true.
Use them to control the wiring against notifies.

### Data

Modules have them too, and the convention is `<ModuleName>Data`.
It holds the Constant values for the module or this artifact (`Color` or `Note` for example).
Its a dictionary (table).
For more complex objects it has a access key (containing the indices to access parts of the complex object)

### Observables

It would be best to use the native `Observables` but they are strictly bound to a type.
In a lot of cases we want to publish changes of whole objects, like in the Pagination module.
So we stick to the manual callback process. Here is a brief description on how this is to implement.

#### Example Callback setup (Manuel)

You have two objects `LayerObject` and `ModuleObject`.
The `LayerObject` holds variables which should trigger update routines in the `ModuleObject` if changing.

Create the callback hook.

```
  function LayerObject:__init( )
    ...
    self.update_callbacks = {}
  end

  function LayerObject:register_update_callback( callback )
    table.insert( self.update_callbacks, callback )
  end
```

and the update function

```
  function LayerObject:update_callbacks( )
    local myUpdate = {
      foo = self.value_1,
      bar = self.value_2,
    }
    for _, callback in ipairs(self.update_callbacks) do
        callback(myUpdate)
    end
  end
```

After that you can hook in the `LayerObject`

```
  function ModuleObject:hook( layerObject )
    local callback = function ( update )
      print( update.foo )
      print( update.bar )
    end
    layerObject:register_update_callback( callback )
  end
```

#### Pros and Cons

It is a lot of work you have to do to set something up like this.
But you can pass around object, which is in most cases more readable.
It might be possible that you dont need that at all, and you are fine with just the
`Observables` given for primitive data types.


#### Example Callback setup (ObservableBang)

(much more readable)
```
function LayerObject:__init()
    self.value = {
        foo = "foo",
        bar = "baz"
    }
    self.value_observable = renoise.Document.ObservableBang
end

function LayerObject:change()
    self.value = {
        foo = "bar",
        bar = "baz"
    }
    self.value_observable:bang()
end
```

Hook to it

```
function ModuleObject:wire_layer(layer)
    self.layer = layer
    add_notifier( self.layer.value_observable, function()
        print(self.layer.value.foo)
        print(self.layer.value.bar)
    end)
end
```
PRO
# LED AND BUTTON NUMBERS IN RAW MODE (DEC)
# WITH LAUNCHPAD IN "LIVE MODE" (PRESS SETUP, top-left GREEN).
#
# Notice that the fine manual doesn't know that mode.
# According to what's written there, the numbering used
# refers to the "PROGRAMMING MODE", which actually does
# not react to any of those notes (or numbers).
#
#        +---+---+---+---+---+---+---+---+
#        | 91|   |   |   |   |   |   | 98|
#        +---+---+---+---+---+---+---+---+
#         
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 80|  | 81|   |   |   |   |   |   |   |  | 89|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 70|  |   |   |   |   |   |   |   |   |  | 79|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 60|  |   |   |   |   |   |   | 67|   |  | 69|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 50|  |   |   |   |   |   |   |   |   |  | 59|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 40|  |   |   |   |   |   |   |   |   |  | 49|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 30|  |   |   |   |   |   |   |   |   |  | 39|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 20|  |   |   | 23|   |   |   |   |   |  | 29|
# +---+  +---+---+---+---+---+---+---+---+  +---+
# | 10|  |   |   |   |   |   |   |   |   |  | 19|
# +---+  +---+---+---+---+---+---+---+---+  +---+
#       
#        +---+---+---+---+---+---+---+---+
#        |  1|  2|   |   |   |   |   |  8|
#        +---+---+---+---+---+---+---+---+
#
#
# LED AND BUTTON NUMBERS IN XY CLASSIC MODE (X/Y)
#
#   9      0   1   2   3   4   5   6   7      8   
#        +---+---+---+---+---+---+---+---+
#        |0/0|   |2/0|   |   |   |   |   |         0
#        +---+---+---+---+---+---+---+---+
#         
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |0/1|   |   |   |   |   |   |   |  |   |  1
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |9/2|  |   |   |   |   |   |   |   |   |  |   |  2
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |5/3|   |   |  |   |  3
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  4
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  5
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |4/6|   |   |   |  |   |  6
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  7
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |9/8|  |   |   |   |   |   |   |   |   |  |8/8|  8
# +---+  +---+---+---+---+---+---+---+---+  +---+
#       
#        +---+---+---+---+---+---+---+---+
#        |   |1/9|   |   |   |   |   |   |         9
#        +---+---+---+---+---+---+---+---+
#
#
# LED AND BUTTON NUMBERS IN XY PRO MODE (X/Y)
#
#   0      1   2   3   4   5   6   7   8      9
#        +---+---+---+---+---+---+---+---+
#        |1/0|   |3/0|   |   |   |   |   |         0
#        +---+---+---+---+---+---+---+---+
#         
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |1/1|   |   |   |   |   |   |   |  |   |  1
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |0/2|  |   |   |   |   |   |   |   |   |  |   |  2
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |6/3|   |   |  |   |  3
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  4
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  5
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |5/6|   |   |   |  |   |  6
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |   |  |   |   |   |   |   |   |   |   |  |   |  7
# +---+  +---+---+---+---+---+---+---+---+  +---+
# |0/8|  |   |   |   |   |   |   |   |   |  |9/8|  8
# +---+  +---+---+---+---+---+---+---+---+  +---+
#       
#        +---+---+---+---+---+---+---+---+
#        |   |2/9|   |   |   |   |   |   |         9
#        +---+---+---+---+---+---+---+---+
#

MK2
  # LED AND BUTTON NUMBERS IN RAW MODE (DEC)
	#
	# Notice that the fine manual doesn't know that mode.
	# According to what's written there, the numbering used
	# refers to the "PROGRAMMING MODE", which actually does
	# not react to any of those notes (or numbers).
	#
	#        +---+---+---+---+---+---+---+---+
	#        |104|   |106|   |   |   |   |111|
	#        +---+---+---+---+---+---+---+---+
	#         
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 81|   |   |   |   |   |   |   |  | 89|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 71|   |   |   |   |   |   |   |  | 79|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 61|   |   |   |   |   | 67|   |  | 69|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 51|   |   |   |   |   |   |   |  | 59|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 41|   |   |   |   |   |   |   |  | 49|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 31|   |   |   |   |   |   |   |  | 39|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 21|   | 23|   |   |   |   |   |  | 29|
	#        +---+---+---+---+---+---+---+---+  +---+
	#        | 11|   |   |   |   |   |   |   |  | 19|
	#        +---+---+---+---+---+---+---+---+  +---+
	#       
	#
	#
	# LED AND BUTTON NUMBERS IN XY MODE (X/Y)
	#
	#          0   1   2   3   4   5   6   7      8   
	#        +---+---+---+---+---+---+---+---+
	#        |0/0|   |2/0|   |   |   |   |   |         0
	#        +---+---+---+---+---+---+---+---+
	#         
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |0/1|   |   |   |   |   |   |   |  |   |  1
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |   |   |   |  |   |  2
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |5/3|   |   |  |   |  3
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |   |   |   |  |   |  4
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |   |   |   |  |   |  5
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |4/6|   |   |   |  |   |  6
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |   |   |   |  |   |  7
	#        +---+---+---+---+---+---+---+---+  +---+
	#        |   |   |   |   |   |   |   |   |  |8/8|  8
	#        +---+---+---+---+---+---+---+---+  +---+
	#       
