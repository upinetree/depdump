require 'minitest/autorun'
require 'depdump'

class TestTracer < MiniTest::Unit::TestCase
  def setup
    @tracer = ::Depdump::Tracer.new
  end

  def test_registry_tree_generation
    nested_class_source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
        end

        class B
          def world
            B::C.new.say
            D.new.say
          end

          class C
            def say
              p 'world'
            end
          end
        end

        class D
          def say
            p '!!'
          end
        end
      end
    SRC
    ast = Parser::CurrentRuby.parse(nested_class_source)

    @tracer.trace_node(ast)

    assert_equal 1, @tracer.registry.root.children.size

    node_a = @tracer.registry.root.children.first
    assert_equal [:A], node_a.namespaces
    assert_equal 2, node_a.children.size
    assert_equal 1, node_a.relations.size
    assert_equal [:A, :B], node_a.relations.first.reference

    node_b = node_a.children.first
    assert_equal [:A, :B], node_b.namespaces
    assert_equal 1, node_b.children.size
    assert_equal 2, node_b.relations.size
    assert_equal [:B, :C], node_b.relations.first.reference
    assert_equal [:D], node_b.relations.last.reference

    node_c = node_b.children.first
    assert_equal [:A, :B, :C], node_c.namespaces
    assert_equal 0, node_c.children.size
    assert_equal 0, node_c.relations.size

    node_d = node_a.children.last
    assert_equal [:A, :D], node_d.namespaces
    assert_equal 0, node_d.children.size
    assert_equal 0, node_d.relations.size
  end

  def test_resolve_relations
    nested_class_source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
        end

        class B
          def world
            B::C.new.say
            D.new.say
          end

          class C
            def say
              p 'world'
            end
          end
        end

        class D
          def say
            p '!!'
          end
        end
      end
    SRC
    ast = Parser::CurrentRuby.parse(nested_class_source)

    @tracer.trace_node(ast)
    @tracer.resolve_relations

    assert_equal [:A, :B], @tracer.relations.to_a[0].resolved_reference
    assert_equal [:A, :B, :C], @tracer.relations.to_a[1].resolved_reference
    assert_equal [:A, :D], @tracer.relations.to_a[2].resolved_reference
  end
end
