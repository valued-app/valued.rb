require_relative 'setup'

class TestConnection < Minitest::Test
  def test_executor_in_test
    assert_instance_of(Concurrent::ImmediateExecutor, Valued::Connection.executor)
  end

  def test_executor_in_development
    ENV["VALUED_ENV"] = "development"
    Valued::Connection.executor = nil
    assert_instance_of(Concurrent::SingleThreadExecutor, Valued::Connection.executor)
  ensure
    ENV["VALUED_ENV"] = "test"
    Valued::Connection.executor = nil
  end

  def test_executor_in_production
    ENV["VALUED_ENV"] = "production"
    Valued::Connection.executor = nil
    assert_instance_of(Concurrent::ThreadPoolExecutor, Valued::Connection.executor)
  ensure
    ENV["VALUED_ENV"] = "test"
    Valued::Connection.executor = nil
  end

  def test_build_with_token
    connection = Valued::Connection.build("token")
    assert_instance_of(Valued::Connection, connection)
    assert_equal("token", connection.token)
    assert_equal(URI("https://ingres.valued.app/events"), connection.endpoint)
  end

  def test_build_with_token_and_uri
    connection = Valued::Connection.build("token", "https://example.com")
    assert_instance_of(Valued::Connection, connection)
    assert_equal("token", connection.token)
    assert_equal(URI("https://example.com"), connection.endpoint)
  end

  def test_build_with_proc
    callback = Proc.new { }
    assert_equal callback, Valued::Connection.build(callback)
  end

  def test_endpoint
    assert_equal URI("https://ingres.valued.app/events"), Valued::Connection.build("token").endpoint
    assert_equal URI("https://example.com"), Valued::Connection.build("token", "https://example.com").endpoint
  end

  def test_headers
    headers = Valued::Connection.build("token").headers
    assert_equal "application/json", headers["Content-Type"]
    assert_equal "Bearer token", headers["Authorization"]
  end

  def test_headers
  end
end
