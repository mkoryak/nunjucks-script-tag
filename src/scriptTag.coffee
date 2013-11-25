nunjucks = require("nunjucks")
htmlparser = require("htmlparser2")
_ = require("underscore")
cs = require("coffee-script")
uglify = require("uglify-js");

###
  Tag lets you compile coffeescript into javascript right in your html. Transforms multiple script tags into a single tag
  containing javascript that may also be uglified.

  See the `defaults` object for options

  Usage:
    {% script uglify=true, mangle=true, compress=true%}
    <script type="text/javascript">
        alert("javascript rocks!");
    </script>
    <script type="text/coffeescript">
        alerter = ->
            alert("#{1 + 1} coffees for me")
        alerter()
    </script>
    {% endscript %}
  Outout:
    `<script type='text/javascript'>alert("javascript rocks!"),function(){var r;r=function(){return alert("2 coffees for me")},r()}.call(this);</script>`
###

exports.configure = (env, defaults={}) ->
  # This sets the defaults for every time you use the tag. You can still overrides these defaults by passing them as attrs to the tag
  defaults = _.defaults(defaults,
    coffee:   false   # if true you dont need to specify the `type` attribute on the script tags - assumes ALL tags are coffeescript
    pretty:   false   # make the output prettier by dedenting it
    uglify:   false   # uglify the resulting code. Setting true will make the next few options have effect:
    mange:    false   # if `uglify=true` - also mange the code
    compress: false   # if `uglify=true` - also compress the code
  )

  throw new Error("You must provide the nunjucks environment as the first arg to the ScriptExtension configure method") if not env

  handler = new htmlparser.DomHandler()
  parser = new htmlparser.Parser(handler)

  class ScriptExtension
    tags: ["script"]
    parse: (parser, nodes) ->
      tok = parser.nextToken()
      args = parser.parseSignature(null, true)
      parser.advanceAfterBlockEnd(tok.value)
      body = parser.parseUntilBlocks("endscript")
      parser.advanceAfterBlockEnd()
      new nodes.CallExtension(this, "run", args, [body])
    run: (context, args, body) ->
      args = _.defaults(args, defaults)
      parser.parseComplete(body())
      fullCode = []
      _.each(handler.dom, (node) ->
        if node.type == 'script'
          code = node.children[0].data
          if args.pretty
            code = dedent(code)
          if args.coffee or node.attribs.type.toLowerCase() == "text/coffeescript"
            code = cs.compile(code)
          fullCode.push(code)
      )
      if args.uglify
        result = uglify.minify(fullCode, fromString: true, mangle: args.mangle, compress: args.compress).code
      else
        result = fullCode.join(';\n')
      return new nunjucks.runtime.SafeString("#{if args.pretty then '\n' else ''}<script type='text/javascript'>#{result}</script>")

  env.addExtension('ScriptExtension', new ScriptExtension())

dedent = (text) -> # https://gist.github.com/mkoryak/5095028
  leadingWhitespaceRE = /(^[ \t]*)(?:[^ \t\n])/
  margin = null
  i = undefined
  text = text.replace(/^[ \t]+$/m, "")
  lines = text.split("\n")
  i = 0
  while i < lines.length
    line = lines[i]
    if leadingWhitespaceRE.exec(line)
      indent = RegExp.$1
      unless margin?
        margin = indent
      else if indent.match(new RegExp("^" + margin))
        # Current line more deeply indented than previous winner:
        # no change (previous winner is still on top).
      else if margin.match(new RegExp("^" + indent))
        # Current line consistent with and no deeper than previous winner:
        # it's the new winner.
        margin = indent
      else
        # Current line and previous winner have no common whitespace:
        # there is no margin
        margin = ""
        break
    i++
  if margin
    i = 0
    while i < lines.length
      lines[i] = lines[i].replace(new RegExp("^" + margin), "")
      i++
    text = lines.join("\n")
  return text
