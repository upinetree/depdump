require "minitest/autorun"
require "depdump"

class TestDependencyGraph < MiniTest::Test
  def build_dependency_graph(source)
    tracer = Depdump::Tracer.new
    ast = ::Parser::CurrentRuby.parse(source)
    tracer.trace_node(ast)

    graph = Depdump::DependencyGraph.new(tracer.registry_tree)

    {
      nodes: graph.nodes.map(&:namespaces),
      edges: graph.edges.to_a,
    }
  end

  def test_blank_class
    source = <<~SRC
      class A
      end
    SRC

    expected = {
      nodes: [[:A]],
      edges: [],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_flat_relation_classes
    source = <<~SRC
      class A
        def hello
          p 'hello, '
          B.new.world
        end
      end

      class B
        def world
          p 'world'
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_reopened_class
    source = <<~SRC
      class A
        def hoge
          B.new
        end
      end

      class B; end
      class C; end

      class A
        def reopened
          C.new
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:B], [:C]],
      edges: [
        { from: [:A], to: [:B] },
        { from: [:A], to: [:C] },
      ],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_nested_class
    source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
          B::C.new.say
        end

        class B
          def world
            B::C.new.say
          end

          class C
            def say
              p 'world'
            end
          end
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:A, :B], [:A, :B, :C]],
      edges: [
        { from: [:A], to: [:A, :B] },
        { from: [:A], to: [:A, :B, :C] },
        { from: [:A, :B], to: [:A, :B, :C] },
      ],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_qualified_class
    source = <<~SRC
      class A
        def hello
          p 'hello, '
          B::C.new.world
        end

        class B::C
          def world
            p 'world'
          end
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:A, :B, :C]],
      edges: [{ from: [:A], to: [:A, :B, :C] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_class_qualified_with_module
    source = <<~SRC
      module A
        def hello
          p 'hello, '
          B::C.new.world
        end

        class B::C
          def world
            p 'world'
          end
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:A, :B, :C]],
      edges: [{ from: [:A], to: [:A, :B, :C] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_refenrence_of_top_level_const
    source = <<~SRC
      module A
        def hello
          ::B.new
        end

        class B; end
      end
      class B; end
    SRC

    expected = {
      nodes: [[:A], [:A, :B], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_top_level_const_difinition_in_lazy
    source = <<~SRC
      module A
        after_initialize do
          class ::B
          end
        end

        def b
          B.new
        end
      end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_included_module
    source = <<~SRC
      module A
        include B
      end
      module B; end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_extended_class
    source = <<~SRC
      module A
        extend B
      end
      module B; end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_inheritance
    source = <<~SRC
      class A
      end
      class A::B < A
      end
    SRC

    expected = {
      nodes: [[:A], [:A, :B]],
      edges: [{ from: [:A, :B], to: [:A] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  def test_class_level_references
    source = <<~SRC
      class A
        B.new
      end
      class B; end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, build_dependency_graph(source)
  end

  # TODO: This is just a limitation. For resolve this problem,
  #       Tracer should have functionality of handling :casgn expression
  def test_const_definition_isnt_supported
    source = <<~SRC
      class A
        B = 1
      end
      class C
        D = A::B
      end
    SRC

    expected = {
      nodes: [[:A], [:C]],
      edges: [],
    }
    assert_equal expected, build_dependency_graph(source)
  end
end
