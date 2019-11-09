require "minitest/autorun"
require "depdump"

class TesteParser < MiniTest::Test
  def setup
    @parser = Depdump::Parser.new
  end

  def fixture_path(*paths)
    paths.map do |path|
      File.expand_path("fixtures/#{path}", __dir__)
    end
  end

  def parse_and_generate_graph(files)
    @parser.parse(files)
    @parser.dependency_graph
  end

  def test_parse_multiple_files
    files = fixture_path("flat_relation_classes.rb", "nested_classes.rb")
    graph = parse_and_generate_graph(files)

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
    graph = parse_and_generate_graph(fixture_path("dir"))

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
