global.Document = Document
global.Node     = Node
global.Element  = Element
global.Comment  = Comment
global.Text     = Text
global.document = new Document()

var ClassList = require('class-list')

function Document() {}

Document.prototype.createTextNode = function(v) {
    var n = new Text();
    n.textContent = v;
    n.nodeName = '#text'
    n.nodeType = 3
    return n;
}

Document.prototype.createElement = function(nodeName) {
    var el = new Element();
    el.nodeName = nodeName;
    return el;
}

Document.prototype.createComment = function(data) {
    var el = new Comment()
    el.data = data
    return el;
}


function Node () {}

Text.prototype = new Node()

Element.prototype = new Node()

Comment.prototype = new Node()


function Style (el) {
  this.el = el;
  this.styles = [];
}

Style.prototype.setProperty = function (n,v) {
    this.el._setProperty(this.styles, {name: n, value:v});
}

Style.prototype.getProperty = function(n) {    
    return this.el._getProperty(this.styles, n);
}

Style.prototype.__defineGetter__('cssText', function () {
    var stylified = '';
    this.styles.forEach(function(s){
      stylified+=s.name+':'+s.value+';';
    })
    return stylified;
})

Style.prototype.__defineSetter__('cssText', function (v) {
    this.styles.length = 0

    // parse cssText and set style attributes
    v.split(';').forEach(function(part){
      var splitPoint = part.indexOf(':')
      if (splitPoint){
        var key = part.slice(0, splitPoint).trim()
        var value = part.slice(splitPoint+1).trim()
        this.setProperty(key, value)
      }
    }, this)
})

function Attribute(name, value){  
  if (name) {
    this.name = name;
    this.value = value ? value : '';
  }  
}


function Element() {
    var self = this;

    this.style = new Style(this)
    this.classList = ClassList(this);
    this.childNodes = [];
    this.attributes = [];
    this.dataset = {};
    this.className = '';

    this._setProperty = function(arr, obj, key, val) {
      var p = self._getProperty(arr, key);      
      if (p) {
        p.value = val;
        return;
      }
      arr.push('function' === typeof obj ? new obj(key.toLowerCase(),val) : obj);
    }

    this._getProperty = function(arr, key) {
      if (!key) return;
      key = key.toLowerCase();
      for (var i=0;i<arr.length;i++) {
        if (key == arr[i].name) return arr[i];
      }
    }
}

Element.prototype.nodeType = 1;

Element.prototype.appendChild = function(child) {
    child.parentElement = this;
    this.childNodes.push(child);
    return child;
}

Element.prototype.setAttribute = function (n, v) {
  if (n == 'style'){
    this.style.cssText = v
  } else {
    this._setProperty(this.attributes, Attribute, n, v);
  }
}

Element.prototype.getAttribute = function(n) {
  if (n == 'style'){
    return this.style.cssText
  } else {
    return this._getProperty(this.attributes, n);
  }
}

Element.prototype.replaceChild = function(newChild, oldChild) {
    var self = this;
    var replaced = false;
    this.childNodes.forEach(function(child, index){
        if (child === oldChild) {
            self.childNodes[index] = newChild;
            replaced = true;
        }
    });
    if (replaced) return oldChild;
}

Element.prototype.removeChild = function(rChild) {
    var self = this;
    var removed = true;
    this.childNodes.forEach(function(child, index){
        if (child === rChild) {
            delete self.childNodes[index];
            removed = true;
        }
    })
    if (removed) return rChild;
}

Element.prototype.insertBefore = function(newChild, existingChild) {
    var self = this;
    this.childNodes.forEach(function(child, index){      
      if (child === existingChild) {
        index === 0 ?  self.childNodes.unshift(newChild)
                    :  self.childNodes.splice(index, 0, newChild);
      }  
    })
    return newChild;
}

Element.prototype.addEventListener = function(type, listener, useCapture, wantsUntrusted) {
  // https://developer.mozilla.org/en-US/docs/Web/API/EventTarget.addEventListener
  // There is an implementation there but probably not worth it.
}

Element.prototype.removeEventListener = function(type, listener, useCapture) {
  // https://developer.mozilla.org/en/docs/Web/API/EventTarget.removeEventListener
  // There is an implementation there but probably not worth it.
}

Element.prototype.insertAdjacentHTML = function(position, text) {
  // https://developer.mozilla.org/en-US/docs/Web/API/Element.insertAdjacentHTML
  // Not too much work to implement similar to innerHTML below.
}

Element.prototype.__defineGetter__('innerHTML', function () {
    // regurgitate set innerHTML
    var s = this.childNodes.html || ''
    this.childNodes.forEach(function (e) {
      s += (e.outerHTML || e.textContent)
    })
    return s
})

Element.prototype.__defineSetter__('innerHTML', function (v) {
    //only handle this simple case that doesn't need parsing
    //this case is useful... parsing is hard and will need added deps!
    this.childNodes.length = 0

    // hack to preserve set innerHTML - no parsing just regurgitation
    this.childNodes.html = v
})


Element.prototype.__defineGetter__('outerHTML', function () {
  var a = [],  self = this;
  
  function _stringify(arr) {
    var attr = [], value;        
    arr.forEach(function(a){
      value = ('style' != a.name) ? a.value : self.style.cssText;
      attr.push(a.name+'='+'\"'+escapeAttribute(value)+'\"');
    })
    return attr.length ? ' '+attr.join(" ") : '';
  }

  function _dataify(data) {      
    var attr = [], value;  
    Object.keys(data).forEach(function(name){
      attr.push('data-'+name+'='+'\"'+escapeAttribute(data[name])+'\"');
    })
    return attr.length ? ' '+attr.join(" ") : '';
  }

   function _propertify() {
    var props = [];
    for (var key in self) {            
      _isProperty(key) && props.push({name: key, value:self[key]});
    }    
    // special className case, if className property is define while 'class' attribute is not then
    // include class attribute in output
    self.className.length && !self.getAttribute('class') && props.push({name:'class', value: self.className})   
    return props ? _stringify(props) : '';
  }

  function _isProperty(key) {          
      var types = ['string','boolean','number']      
      for (var i=0; i<=types.length;i++) {        
        if (self.hasOwnProperty(key) && 
            types[i] === typeof self[key] &&
            key !== 'nodeName' &&
            key !== 'nodeType' &&
            key !== 'className'
            ) return true;
      }      
  }

  a.push('<'+this.nodeName + _propertify() + _stringify(this.attributes) + _dataify(this.dataset) +'>')

  a.push(this.innerHTML)

  a.push('</'+this.nodeName+'>')

  return a.join('')
})

Element.prototype.__defineGetter__('textContent', function () {
  var s = ''
  this.childNodes.forEach(function (e) {
    s += e.textContent
  })
  return s
})

Element.prototype.addEventListener = function(t, l) {}

function escapeHTML(s) {
  return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
}

function escapeAttribute(s) {
  return escapeHTML(s).replace(/"/g, '&quot;')
}

function Text(){}

Text.prototype.nodeType = 3;

Text.prototype.nodeName = '#text';

Text.prototype.__defineGetter__('textContent', function() {
  return escapeHTML(this.value || '');
})

Text.prototype.__defineSetter__('textContent', function(v) {
  this.value = v
})


function Comment(){}

Comment.prototype.nodeType = 8;

Comment.prototype.nodeName = '#comment';

Comment.prototype.__defineGetter__('data', function() {
  return this.value
})

Comment.prototype.__defineSetter__('data', function(v) {
  this.value = v
})

Comment.prototype.__defineGetter__('outerHTML', function() {
  return '<!--' + escapeHTML(this.value || '') + '-->'
})
