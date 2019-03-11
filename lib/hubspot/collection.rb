class Hubspot::Collection
  def initialize(opts = {}, &block)
    @options = opts
    @fetch_proc = block
    fetch
  end

  def refresh
    fetch
    self
  end

  def resources
    @resources
  end

  def update_all(opts = {})
    return true if empty?

    # This assumes that all resources are the same type
    resource_class = resources.first.class
    unless resource_class.respond_to?(:batch_update)
      raise "#{resource_class} does not support bulk update"
    end

    resource_class.batch_update(resources, opts)
  end

protected
  def fetch
    @resources = @fetch_proc.call(@options)
  end

  def respond_to_missing?(name, include_private = false)
    @resources.respond_to?(name, include_private)
  end

  def method_missing(method, *args, &block)
    @resources.public_send(method, *args, &block)
  end
end