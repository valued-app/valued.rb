require_relative 'setup'

class TestClient < Minitest::Test
  def setup
    @last_event = nil
    @client = Valued::Client.new { @last_event = _1 }
  end

  def test_page_view
    @client.page_view("https://example.com", "user.id" => 42)
    assert_sent_event({
      "category" => "pageview",
      "user" => { "id" => 42 },
      "attributes" => { "source" => { "url" => "https://example.com" } }
    })
  end

  def test_action
    time = Time.now
    @client.action("product.view", "user.id" => 42, "occured_at" => time.iso8601)
    assert_sent_event({
      "user" => {"id" => 42},
      "key" => "product.view",
      "category" => "action",
      "occured_at" => time.iso8601
    })
  end

  def test_sync
    @client.sync("user.id" => 42)
    assert_sent_event("user" => {"id" => 42}, "category" => "sync")
  end

  def test_sync_user
    @client.sync_user("id" => 42)
    assert_sent_event("user" => {"id" => 42}, "category" => "sync")
  end

  def test_sync_customer
    @client.sync_customer("id" => 42)
    assert_sent_event("customer" => {"id" => 42}, "category" => "sync")
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
