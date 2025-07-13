defmodule SharedComponentsTest do
  use ExUnit.Case
  doctest SharedComponents

  test "greets the world" do
    assert SharedComponents.hello() == :world
  end
end
