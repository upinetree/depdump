require "minitest/autorun"
require "depdump"

# TODO: 継承、クラスレベルの評価のテスト
class TestParseText < MiniTest::Unit::TestCase
  def setup
    @client = ::Depdump.new
  end

  def test_blank_class
    @source = <<~SRC
      class A
      end
    SRC

    expected = {
      nodes: [[:A]],
      edges: [],
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_flat_relation_classes
    @source = <<~SRC
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
    assert_equal expected, @client.parse_text(@source)
  end

  def test_reopened_class
    @source = <<~SRC
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
    assert_equal expected, @client.parse_text(@source)
  end

  def test_nested_class
    @source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
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
        { from: [:A, :B], to: [:A, :B, :C] },
      ],
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_qualified_class
    @source = <<~SRC
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
    assert_equal expected, @client.parse_text(@source)
  end

  def test_class_qualified_with_module
    @source = <<~SRC
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
    assert_equal expected, @client.parse_text(@source)
  end

  def test_refenrence_of_top_level_const
    @source = <<~SRC
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
    assert_equal expected, @client.parse_text(@source)
  end

  def test_included_module
    @source = <<~SRC
      module A
        include B
      end
      module B; end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_extended_class
    @source = <<~SRC
      module A
        extend B
      end
      module B; end
    SRC

    expected = {
      nodes: [[:A], [:B]],
      edges: [{ from: [:A], to: [:B] }],
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_inheritance
    @source = <<~SRC
      class A
      end
      class A::B < A
      end
    SRC

    expected = {
      nodes: [[:A], [:A, :B]],
      edges: [{ from: [:A, :B], to: [:A] }],
    }
    assert_equal expected, @client.parse_text(@source)
  end
end
