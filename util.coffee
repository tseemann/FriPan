@our_log = (o) ->
    if console? && console.log?
        console.log.apply(console, if !!arguments.length then arguments else [this])
    else if opera? && opera.postError?
        opera.postError(o || this)

@log_info = (o) -> log_msg("INFO", arguments)
@log_warn = (o) -> log_msg("WARN", arguments)
@log_error = (o) -> log_msg("ERROR", arguments)
@log_debug = (o) ->
    log_msg("DEBUG", arguments) if window.debug?

# Our internal log allowing a log type
log_msg = (msg,rest) ->
    args = Array.prototype.slice.call(rest)
    r = [msg].concat(args)
    window.our_log.apply(window, r)

html_warning = """
    <div class='browser-warning'>
      <button type="button" class="close" onclick="$('.browser-warning').hide();">x</button>
      <h1>Internet Explorer is not supported</h1>
      <p>Please use <a href='http://www.mozilla.org/en-US/firefox/new/'>Firefox</a> or <a href='http://www.google.com/chrome/'>Chrome</a></p>
    </div>
    """

# Display a popup warning, or fill in a warning box if using IE
@add_browser_warning = () ->
    if window.navigator.userAgent.indexOf("MSIE ")>=0
        outer = $('.browser-warning-outer')
        if outer.length==0
            # No container found, let's create a popup one
            $('body').prepend('<div class="warning-popover browser-warning-outer"></div>')
            outer = $('.browser-warning-outer')
        outer.append(html_warning)

@get_url_params = () ->
    hash = window.location.search
    hash.substring(1)               # remove '?'


# ------------------------------------------------------------
# SVG Downloading
#
class SVG
    # Recursively call copyStyle
    @copyStyleDeep = (src,dest) ->
        SVG.copyStyle(src, dest)

        sChildren = src.node().childNodes
        dChildren = dest.node().childNodes
        console.log "Mismatch number of children!" if sChildren.length != dChildren.length
        for i in [0...sChildren.length]
            if sChildren[i].nodeType == Node.ELEMENT_NODE
                SVG.copyStyleDeep(d3.select(sChildren[i]), d3.select(dChildren[i]))

   # Copy the style of the src nodes.  Just the styles that are important
    @copyStyle = (src, dest) ->
            # Hide any "visibilty" hidden nodes.  Necessary for InkScape
            if (src.style('visibility') == 'hidden')
               dest.style('display','none')
            else if src.node().tagName == 'text'
                ['font-size','font-family'].forEach((a) ->
                    dest.style(a, src.style(a))
                )
            else  if src.node().tagName in ['rect','line','path']
                ['fill','stroke','fill-opacity'].forEach((a) ->
                    dest.style(a, src.style(a))
                )

    # Download an SVG element.  Expects the passed element selector to have an
    # attribute 'data-for' that is a selector for the SVG to download
    @download_svg = (e) ->
        svg_elem = d3.select(d3.select(e).attr('data-for'))
        node = svg_elem.node().cloneNode(true)
        SVG.copyStyleDeep(svg_elem, d3.select(node))

        d3.select(node)
          .attr("version", 1.1)
          .attr("xmlns", "http://www.w3.org/2000/svg")

        wrapper = document.createElement('div')
        wrapper.appendChild(node)
        html = wrapper.innerHTML
        d3.select(e)
          .attr("href-lang", "image/svg+xml")
          .attr("href", "data:image/svg+xml;base64,\n" + btoa(html))

@download_svg = SVG.download_svg
# ------------------------------------------------------------
