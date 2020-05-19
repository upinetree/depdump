require "minitest/autorun"
require "depdump"

class TestParser < MiniTest::Test
  def setup
    @parser = Depdump::Parser.new
  end

  def fixture_path(*paths)
    paths.map do |path|
      File.expand_path("fixtures/#{path}", __dir__)
    end
  end

  def test_parse_multiple_files
    files = fixture_path("flat_relation_classes.rb", "nested_classes.rb")
    graph = @parser.parse(files)

    expected_nodes = [
      [:FlatRelationA],
      [:FlatRelationB],
      [:NestedParent],
      [:NestedParent, :NestedChild],
      [:NestedParent, :NestedChild, :NestedGrandchild],
    ]
    expected_edges = [
      { from: [:FlatRelationA], to: [:FlatRelationB] },
      { from: [:NestedParent], to: [:NestedParent, :NestedChild] },
      { from: [:NestedParent, :NestedChild], to: [:NestedParent, :NestedChild, :NestedGrandchild] },
    ]
    assert_equal expected_nodes, graph.nodes.map(&:namespaces)
    assert_equal expected_edges, graph.edges.to_a
  end

  def test_parse_directory
    files = fixture_path("dir")
    graph = @parser.parse(files)

    expected_nodes = [
      [:DirContentA],
      [:DirContentB],
      [:DirInner],
      [:DirInner, :DirContentC],
    ]
    expected_edges = [
      { from: [:DirContentA], to: [:DirContentB] },
      { from: [:DirContentB], to: [:DirInner, :DirContentC] },
    ]
    assert_equal expected_nodes, graph.nodes.map(&:namespaces)
    assert_equal expected_edges, graph.edges.to_a
  end
end
