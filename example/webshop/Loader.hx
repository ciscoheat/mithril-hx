package webshop;

import haxe.Timer;
import mithril.M;

using Lambda;

enum LoadState {
    Started; Delayed; Done; Error;
}

/**
 * A usability class. A callback runs after a second (default)
 * that can be used to display a loader. During the first second
 * there's no need to display one since the user can keep focus
 * for about that time without thinking that something is wrong.
 *
 * See ProductList for an example how this class is used.
 */
class Loader {
    var _state = Started;

    var untilDelay : Int;
    var untilError : Int;

    var delayTimer : Timer;
    var errorTimer : Timer;

    function setState(s : LoadState) {
        if(s == _state) return;
        if(s != Started && (_state == Done || _state == Error)) return;

        //trace('Loader: $_state changing to $s');
        _state = s;
        M.redraw();
    }

    public function new(untilDelay = 1000, untilError = 5000) {
        this.untilDelay = untilDelay;
        this.untilError = untilError;
    }

    public function start() {
        setState(Started);

        if(delayTimer != null) delayTimer.stop();
        if(errorTimer != null) errorTimer.stop();

        delayTimer = new Timer(untilDelay);
        delayTimer.run = function() setState(Delayed);

        errorTimer = new Timer(untilError);
        errorTimer.run = function() setState(Error);
    }

    // done and error have an optional parameter so they can be
    // used in ajax callbacks.
    public function done(?_) setState(Done);
    public function error(?_) setState(Error);
    
    public function state() return _state;
}
