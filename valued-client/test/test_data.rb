require_relative 'setup'

class TestData < Minitest::Test
  def test_normalize_string
    assert_normalizes "foo.bar", "foo.bar"
    assert_normalizes "Foo Bar", "Foo Bar"
  end

  def test_normalize_string_frozen
    input = "foo.bar"
    assert !input.frozen?
    assert Valued::Data.normalize(input).frozen?
    assert !input.frozen?
  end

  def test_normalize_symbol
    assert_normalizes :foo_bar, "foo_bar"
    assert_normalizes :"Foo Bar", "Foo Bar"
  end

  def test_normalize_boolean
    assert_normalizes true, true
    assert_normalizes false, false
  end

  def test_normalize_integer
    assert_normalizes(1, 1)
    assert_normalizes(-50, -50)
  end
  
  def test_normalize_hash
    assert_normalizes({"foo" => "bar"}, {"foo" => "bar"})
    assert_normalizes({foo: "bar"}, {"foo" => "bar"})
    assert_normalizes({foo: { bar: "baz" }}, {"foo" => { "bar" => "baz" }})
    assert_normalizes({"foo.bar" => "baz" }, {"foo" => { "bar" => "baz" }})
  end

  def test_normalize_hash_frozen
    assert Valued::Data.normalize({"foo" => "bar"}).frozen?
    assert Valued::Data.normalize({"foo.bar" => "baz"})["foo"].frozen?
  end

  def test_normalize_concurrent_map
    map = Concurrent::Map.new
    map[:foo] = "bar"
    map['user.id'] = "15"
    assert_normalizes map, {"foo" => "bar", "user" => {"id" => "15"}}
  end

  def test_normalize_array
    assert_normalizes [1, 2, 3], [1, 2, 3]
    assert_normalizes [1, "foo", { bar: "baz" }], [1, "foo", { "bar" => "baz" }]
  end

  def test_normalize_concurrent_array
    assert_normalizes Concurrent::Array[1, 2, 3], [1, 2, 3]
    assert_normalizes Concurrent::Array[1, "foo", { bar: "baz" }], [1, "foo", { "bar" => "baz" }]
  end

  def test_normalize_time
    time = Time.now
    assert_normalizes time, time.iso8601
  end

  def test_normalize_unknown
    object = Object.new
    assert_normalizes object, object
  end

  def test_normalize_to_valued_data
    assert_normalizes Struct.new(:to_valued_data).new({a: 1}), {"a" => 1}
  end

  def test_normalize_scope
    scope = Valued::Scope.new("token", "user.id" => 12)
    scope[:foo] = "bar"
    assert_normalizes scope, { "user" => { "id" => 12 }, "foo" => "bar" }
  end

  def test_register
    klass = Class.new
    Valued::Data.register(klass) {{ foo: "bar" }}
    assert_normalizes klass.new, { "foo" => "bar" }
  end

  def test_merge
    assert_equal({ a: { b: 1, c: 2 }}, Valued::Data.merge({ a: { b: 1 }}, { a: { c: 2 }}))
  end

  def test_validate
    assert_validation_error "Missing category", {}
    assert_validation_error "Unknown category: foo", {"category" => "foo"}
  end

  private

  def assert_validation_error(error, data)
    errors = []
    Valued::Data.validate(data) { errors << _1 }
    assert_includes errors, error
  end

  def assert_normalizes(data, expected)
    assert_equal expected, Valued::Data.normalize(data)
  end
end