class Poltergeist.Browser
  constructor: (@owner, width, height) ->
    @width   = width || 1024
    @height  = height || 768
    @state   = 'default'
    @page_id = 0

    this.resetPage()

  resetPage: ->
    @page.release() if @page?
    @page = new Poltergeist.WebPage(@width, @height)

    @page.onLoadStarted = =>
      @state = 'loading' if @state == 'clicked'

    @page.onNavigationRequested = (url, navigation) =>
      @state = 'loading' if @state == 'clicked' && navigation == 'FormSubmitted'

    @page.onLoadFinished = (status) =>
      if @state == 'loading'
        this.sendResponse(status)
        @state = 'default'

    @page.onInitialized = =>
      @page_id += 1

  sendResponse: (response) ->
    errors = @page.errors()

    if errors.length > 0
      @page.clearErrors()
      throw new Poltergeist.JavascriptError(errors)
    else
      @owner.sendResponse(response)

  node: (page_id, id) ->
    if page_id == @page_id
      @page.get(id)
    else
      throw new Poltergeist.ObsoleteNode

  visit: (url, headers) ->
    @state = 'loading'
    @page.open(url, operation: "get", headers: headers)

  current_url: ->
    this.sendResponse @page.currentUrl()

  status_code: ->
    this.sendResponse @page.statusCode()

  body: ->
    this.sendResponse @page.content()

  source: ->
    this.sendResponse @page.source()

  find: (selector) ->
    this.sendResponse(page_id: @page_id, ids: @page.find(selector))

  find_within: (page_id, id, selector) ->
    this.sendResponse this.node(page_id, id).find(selector)

  text: (page_id, id) ->
    this.sendResponse this.node(page_id, id).text()

  attribute: (page_id, id, name) ->
    this.sendResponse this.node(page_id, id).getAttribute(name)

  value: (page_id, id) ->
    this.sendResponse this.node(page_id, id).value()

  set: (page_id, id, value) ->
    this.node(page_id, id).set(value)
    this.sendResponse(true)

  # PhantomJS only allows us to reference the element by CSS selector, not XPath,
  # so we have to add an attribute to the element to identify it, then remove it
  # afterwards.
  select_file: (page_id, id, value) ->
    node     = this.node(page_id, id)

    node.setAttribute('_poltergeist_selected', '')
    @page.uploadFile('[_poltergeist_selected]', value)
    node.removeAttribute('_poltergeist_selected')

    this.sendResponse(true)

  select: (page_id, id, value) ->
    this.sendResponse this.node(page_id, id).select(value)

  tag_name: (page_id, id) ->
    this.sendResponse this.node(page_id, id).tagName()

  visible: (page_id, id) ->
    this.sendResponse this.node(page_id, id).isVisible()

  evaluate: (script) ->
    this.sendResponse @page.evaluate("function() { return #{script} }")

  execute: (script) ->
    @page.execute("function() { #{script} }")
    this.sendResponse(true)

  push_frame: (id) ->
    @page.pushFrame(id)
    this.sendResponse(true)

  pop_frame: ->
    @page.popFrame()
    this.sendResponse(true)

  click: (page_id, id) ->
    # Get the node before changing state, in case there is an exception
    node = this.node(page_id, id)

    # If the click event triggers onNavigationRequested, we will transition to the 'loading'
    # state and wait for onLoadFinished before sending a response.
    @state = 'clicked'

    node.click()

    if @state != 'loading'
      @state = 'default'
      this.sendResponse(true)

  drag: (page_id, id, other_id) ->
    this.node(page_id, id).dragTo this.node(page_id, other_id)
    this.sendResponse(true)

  trigger: (page_id, id, event) ->
    this.node(page_id, id).trigger(event)
    this.sendResponse(event)

  equals: (page_id, id, other_id) ->
    this.sendResponse this.node(page_id, id).isEqual(this.node(page_id, other_id))

  reset: ->
    this.resetPage()
    this.sendResponse(true)

  render: (path, full) ->
    dimensions = @page.validatedDimensions()
    document   = dimensions.document
    viewport   = dimensions.viewport

    if full
      @page.setScrollPosition(left: 0, top: 0)
      @page.setClipRect(left: 0, top: 0, width: document.width, height: document.height)
      @page.render(path)
      @page.setScrollPosition(left: dimensions.left, top: dimensions.top)
    else
      @page.setClipRect(left: 0, top: 0, width: viewport.width, height: viewport.height)
      @page.render(path)

    this.sendResponse(true)

  resize: (width, height) ->
    @page.setViewportSize(width: width, height: height)
    this.sendResponse(true)

  network_traffic: ->
    this.sendResponse(@page.networkTraffic())

  exit: ->
    phantom.exit()

  noop: ->
    # NOOOOOOP!

  # This command is purely for testing error handling
  browser_error: ->
    throw new Error('zomg')
