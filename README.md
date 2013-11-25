nunjucks-script-tag
===================

Compile coffee-script, uglify inline scripts in nunjucks

### Install

`npm install nunjucks-script-tag`

### Usage

First configure the custom tag:

``` js
var scriptTag = require("nunjucks-script-tag");
var express = require("express");
var nunjucks = require("nunjucks");

var app = express();

var env = nunjucks.configure('views', {
    express: app
});

scriptTag.configure(env); //do this!
```

Now you can use it in your html templates:

``` html
{% script pretty=true %}
<script type='text/javascript'>
    var foo = function(){
        console.log("bar");
    }
</script>

<script type='text/coffeescript'>
    baz = -> console.log 'qux'
</script>
{% endscript %}
```

which will produce the following html:

``` html
<script type='text/javascript'>
var foo = function(){
    console.log("bar");
}
;
(function() {
  var baz;

  baz = function() {
    return console.log('qux');
  };

}).call(this);
</script>
```

### Tag Params

`coffee` - if true you dont need to specify the `type` attribute on the script tags - assumes ALL tags are coffeescript
`pretty` - make the output prettier by dedenting it
`uglify` - uglify the resulting code. Setting true will make the next few options have effect:
`mange`  - if `uglify=true` - also mange the code
`compress` - if `uglify=true` - also compress the code

These are all defaulted to false, but you can override that behavior by passing in a map of defaults as a 2nd arg
to the `configure` method:

``` js
scriptTag.configure(env, {uglify:true, compress: true});
```

