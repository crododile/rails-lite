class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    @pattern.match(req.path) && @http_method == req.request_method.downcase.to_sym
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    route_params_names = @pattern.match(req.path).names
    route_params_names.map!(&:to_sym)
    route_params_captures = @pattern.match(req.path).captures

    route_params = Hash[route_params_names.zip(route_params_captures)]

    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  [:get, :post, :delete, :put].each do |method|
    define_method(method) do |pattern, controller_class, action_name|
      add_route(pattern, method, controller_class, action_name)
    end
  end


  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    instance_eval(&proc)
  end


  # should return the route that matches this request
  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match(req)
    if route
      route.run(req, res)
    else
      res.status = (404)
    end
  end
end
