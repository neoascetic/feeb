defmodule FeebTest do
  use ExUnit.Case
  doctest Feeb

  test "greets the world" do
    assert Feeb.hello() == :world
  end
end
