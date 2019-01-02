defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  # marks the test as distributed so it wont be tested unless the node is started
  @tag :distributed
  test "route requests across nodes" do
    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@tau-pc"
    assert KV.Router.route("world", Kernel, :node, []) == :"bar@tau-pc"
  end
  
  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end

end


