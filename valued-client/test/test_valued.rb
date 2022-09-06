require_relative 'setup'

class TestValued < Minitest::Test
  def setup
    @last_event = nil
    Valued.connect { @last_event = _1 }
  end

  def teardown = Valued.disconnect

  def test_client = assert_instance_of(Valued::Client, Valued.client)
  def test_scope = assert_instance_of(Valued::Scope, Valued.scope)

  def test_disconnected_client
    assert_raises do
      Valued.disconnect
      Valued.client
    end
  end

  def test_disconnected_scope
    assert_raises do
      Valued.disconnect
      Valued.scope
    end
  end

  def test_connected
    assert Valued.connected?
    Valued.disconnect
    assert !Valued.connected?
  end

  def test_action
    Valued.action("foo.bar", "user.id" => 1)
    assert_sent_event({"user"=>{"id"=>1}, "key"=>"foo.bar", "category"=>"action"})
  end

  def test_scoping
    Valued.user_id = 1

    Valued.scope do
      Valued.customer_id = 2
      Valued.action("foo.bar")
      assert_equal 2, @last_event.dig("customer", "id")
    end

    Valued.action("foo.bar")
    assert_nil @last_event.dig("customer", "id")
  end

  private

  def assert_sent_event(data)
    yield if block_given?
    assert_instance_of(Hash, @last_event)
    assert_instance_of(Hash, data)
    received = data["occured_at"] ? @last_event : @last_event.except("occured_at")
    assert_equal(data, received)
  end
end
