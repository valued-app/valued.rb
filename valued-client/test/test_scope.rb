require_relative 'setup'

class TestScope < Minitest::Test
  def setup
    @last_event = nil
    @client = Valued::Client.new { @last_event = _1 }
  end

  def test_defaults
    scope = Valued::Scope.new(@client, a: 1)
    assert_equal({ "a" => 1 }, scope.to_h)

    scope.with(b: 2) do
      assert_equal({ "a" => 1, "b" => 2 }, scope.to_h)
    end

    assert_equal({ "a" => 1 }, scope.to_h)
  end

  def test_scope_as_payload
    scope = Valued::Scope.new(@client, "user.id" => 42)
    @client.page_view("https://example.com", scope)
    assert_sent_event({
      "user" => {"id" => 42},
      "attributes" => {
        "source" => {"url" => "https://example.com"}
      },
      "category" => "pageview"
    })
  end

  def test_scope_action
    scope = Valued::Scope.new(@client, "user.id" => 42)
    scope.action("product.view")
    assert_sent_event({
      "user" => {"id" => 42},
      "key" => "product.view",
      "category" => "action"
    })
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
