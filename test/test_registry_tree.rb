require "minitest/autorun"
require "depdump"

class TestRegistryTree < MiniTest::Unit::TestCase
  def test_find_or_create_node
    tree = Depdump::Registry::Tree.new
    tree.find_or_create_node([:A], tree.root)
    tree.find_or_create_node([:A], tree.root)
    tree.find_or_create_node([:A, :B], tree.root.children.first)

    assert_equal 1, tree.root.children.size
    assert_equal [:A], tree.root.children.first.namespaces
    assert_equal [:A, :B], tree.root.children.first.children.first.namespaces
  end
end
