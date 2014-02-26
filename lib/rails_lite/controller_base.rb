require 'erb'
require 'active_support/inflector'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'
require 'debugger'

class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req).params
    @already_rendered= false
    @hi = "hi"
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(body, content_type= "text/text")

    @res.content_type=(content_type)
    @res.body = body
    @already_rendered = true
    @res
  end

  def params
    @params
  end


  # helper method to alias @already_rendered
  def already_rendered?
    @already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    raise "already_built_response" if @already_built_response == true
    @res.status =(302)
    @res.header["location"]= ( url)
    @already_built_response = true
    session
    session.store_session(@res)
    @res
  end

  def get_binding
    self.binding
  end


  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def bind_helper
    self.attributes.each
  end

  def render(template_name)
    raise "Already Rendered" if already_rendered?
    @already_rendered = true
    controller_name = self.class.to_s
    controller_name = controller_name.underscore
    full_name = "views/#{ controller_name }/#{ template_name }.html.erb"

    e = ERB.new(File.read(full_name))

    v = get_binding

    @res.body = e.result(b = v)
    session
    session.store_session(@res)
    render_content(@res.body)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end
