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
{% script uglify=true, compress=true, mangle=true %}
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
<script type='text/javascript'>var foo=function(){console.log("bar")};(function(){var o;o=function(){return console.log("qux")}}).call(this);</script>
```

### Tag Params

 - `coffee` - if true you dont need to specify the `type` attribute on the script tags - assumes ALL tags are coffeescript
 - `pretty` - make the output prettier by dedenting it
 - `uglify` - uglify the resulting code. Setting true will make the next few options have effect:
 - `mange`  - if `uglify=true` - also mange the code
 - `compress` - if `uglify=true` - also compress the code

These are all defaulted to false, but you can override that behavior by passing in a map of defaults as a 2nd arg
to the `configure` method:

``` js
scriptTag.configure(env, {uglify:true, compress: true});
```

### More examples

Here we set the defaults to compress and to always expect coffee script which means we can drop the `type` attribute on the script tags

``` js
scriptTag.configure(env, {uglify:true, compress: true, coffee: true});
```

Note that we don't have to pass any args to the script tag; it is using the defaults defined above.
``` html
{% script %}
<script>
    if(!nunjucks.env)
        # If not precompiled, create an environment with an WebLoader
        nunjucks.env = new nunjucks.Environment(new nunjucks.WebLoader('/templates'))

    X.render = (tpl, ctx={}) -> #render a nunjucks template by name. ctx is the object of params to pass to it
        tpl = nunjucks.env.getTemplate(tpl)
        return tpl.render(ctx)

    X.macro = (name, ctx={}, tpl='helpers.html') -> #render a nunjucks macro by name.
        value = null
        nunjucks.env.getTemplate(tpl).getExported((err, obj) ->
            value = obj[name](ctx...).toString()
        )
        return value

    X.flash = (flashes) ->
        $cont = $("body div.flash-container")
        html = X.macro('flash', [flashes])
        $cont.html(html)
        Behavior2.contentChanged('flash')
</script>
{% endscript %}
```

output:

``` html
<script type='text/javascript'>(function(){nunjucks.env||(nunjucks.env=new nunjucks.Environment(new nunjucks.WebLoader("/templates"))),X.render=function(tpl,ctx){return null==ctx&&(ctx={}),tpl=nunjucks.env.getTemplate(tpl),tpl.render(ctx)},X.macro=function(name,ctx,tpl){var value;return null==ctx&&(ctx={}),null==tpl&&(tpl="helpers.html"),value=null,nunjucks.env.getTemplate(tpl).getExported(function(err,obj){return value=obj[name].apply(obj,ctx).toString()}),value},X.flash=function(flashes){var $cont,html;return $cont=$("body div.flash-container"),html=X.macro("flash",[flashes]),$cont.html(html),Behavior2.contentChanged("flash")}}).call(this);</script>
```
