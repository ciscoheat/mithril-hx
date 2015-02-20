package webshop;

import haxe.Timer;
import mithril.M;
using Lambda;

enum LoadState {
    Started;
    Delayed;
    Done;
    Error;
}

/**
 * A usability class. A callback runs after a second (default)
 * that can be used to display a loader. During the first second
 * there's no need to display one since the user can keep focus
 * for about that time without thinking that something is wrong.
 *
 * See ProductList for an example how this class is used.
 */
class Loader implements Model {
    @prop public var state : LoadState;

    public function new(untilDelay = 1000, untilError = 5000) {
        var _state = M.prop(Started);

        var delayTimer = Timer.delay(function() state(Delayed), untilDelay);
        var errorTimer = Timer.delay(function() state(Error), untilError);

        this.state = function(?s) { 
            if(s == null) return _state();

            switch(s) {
                case Delayed:
                    delayTimer.stop();
                case Done, Error:
                    delayTimer.stop();
                    errorTimer.stop();
                case _:
            }

            // Need to set state before redraw.
            _state(s);
            M.redraw();

            return s;
        };

    }

    // done and error have an optional parameter so they can be
    // used in ajax callbacks.

    public function done(?_) {
        state(Done);
    }

    public function error(?_) {
        state(Error);
    }
}
