class Valued::Scope
  def initialize(connection, **data)
    @connection = connection
    @data = data
  end

  def track(event, **data) = @connection.track(event, @data.merge(data))
  def scope(**data) = Valued::Scope.new(@connection, @data.merge(data))
end