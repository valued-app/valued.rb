require_relative 'setup'

class TestHelpers < Minitest::Test
  def setup
    @last_event = nil
    @client     = Valued::Client.new { @last_event = _1 }
    @scope      = Valued::Scope.new(@client)
    @helpers    = Struct.new(:scope) { include Valued::Helpers }.new(@scope)
  end

  def test_user_getter
    @scope.scope("user.id" => 1)
    assert_equal 1, @helpers["user"]["id"]
    assert_equal 1, @helpers["user", "id"]
    assert_equal 1, @helpers[:user, :id]
    assert_equal 1, @helpers["user.id"]
    assert_equal 1, @helpers.user_id
    assert_equal 1, @helpers.user["id"]
  end

  def test_user_setter
    @helpers.user = { id: 2 }
    assert_equal 2, @helpers["user"]["id"]
    assert_equal 2, @helpers["user", "id"]
    assert_equal 2, @helpers[:user, :id]
    assert_equal 2, @helpers["user.id"]
    assert_equal 2, @helpers.user_id
    assert_equal 2, @helpers.user["id"]
  end

  def test_user_id_setter
    @helpers.user_id = 2
    assert_equal 2, @helpers["user"]["id"]
    assert_equal 2, @helpers["user", "id"]
    assert_equal 2, @helpers[:user, :id]
    assert_equal 2, @helpers["user.id"]
    assert_equal 2, @helpers.user_id
    assert_equal 2, @helpers.user["id"]
  end

  def test_customer_getter
    @scope.scope("customer.id" => 1)
    assert_equal 1, @helpers["customer"]["id"]
    assert_equal 1, @helpers["customer", "id"]
    assert_equal 1, @helpers[:customer, :id]
    assert_equal 1, @helpers["customer.id"]
    assert_equal 1, @helpers.customer_id
    assert_equal 1, @helpers.customer["id"]
  end

  def test_customer_setter
    @helpers.customer = { id: 2 }
    assert_equal 2, @helpers["customer"]["id"]
    assert_equal 2, @helpers["customer", "id"]
    assert_equal 2, @helpers[:customer, :id]
    assert_equal 2, @helpers["customer.id"]
    assert_equal 2, @helpers.customer_id
    assert_equal 2, @helpers.customer["id"]
  end

  def test_customer_id_setter
    @helpers.customer_id = 2
    assert_equal 2, @helpers["customer"]["id"]
    assert_equal 2, @helpers["customer", "id"]
    assert_equal 2, @helpers[:customer, :id]
    assert_equal 2, @helpers["customer.id"]
    assert_equal 2, @helpers.customer_id
    assert_equal 2, @helpers.customer["id"]
  end

  def test_pageview
    @helpers.user = { id: 1 }
    @helpers.pageview("https://example.com")
    assert_sent_event({
      "user" => {"id" => 1},
      "attributes" => {"source" => {"url" => "https://example.com"}},
      "category" => "pageview"
    })
  end

  def test_action
    @helpers.user = { id: 1 }
    @helpers.action("foo.bar", "customer.id" => 2)
    assert_sent_event({"user"=>{"id"=>1}, "customer"=>{"id"=>2}, "key"=>"foo.bar", "category"=>"action"})
  end

  def test_sync
    @helpers.user = { id: 1, email: "foo@bar.com" }
    @helpers.sync
    assert_sent_event({"user"=>{"id"=>1, "email"=>"foo@bar.com"}, "category"=>"sync"})
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