require 'minitest/autorun'
require 'depdump'

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
      classes: [[:A]],
      relations: []
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
      classes: [[:A], [:B]],
      relations: [{ from: [:A], to: [:B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_reopened_class
    @source = <<~SRC
      class A
      end

      class A
        def reopened
          p 'reopend class'
        end
      end
    SRC

    expected = {
      classes: [[:A]],
      relations: []
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
      classes: [[:A], [:A, :B], [:A, :B, :C]],
      relations: [
        { from: [:A], to: [:A, :B] },
        { from: [:A, :B], to: [:B, :C] }
      ]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_qualified_class
    @source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
        end

        class B::C
          def world
            p 'world'
          end
        end
      end
    SRC

    expected = {
      classes: [[:A], [:A, :B, :C]],
      relations: [{ from: [:A], to: [:A, :B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_class_qualified_with_module
    @source = <<~SRC
      module A
        def hello
          p 'hello, '
          A::B.new.world
        end

        class B::C
          def world
            p 'world'
          end
        end
      end
    SRC

    expected = {
      classes: [[:A], [:A, :B, :C]],
      relations: [{ from: [:A], to: [:A, :B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_refenrence_of_top_level_const
    @source = <<~SRC
      module A
        def hello
          ::B.new.world
        end
      end
    SRC

    expected = {
      classes: [[:A]],
      relations: [{ from: [:A], to: [:B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_included_module
    @source = <<~SRC
      module A
        include B
      end
    SRC

    expected = {
      classes: [[:A]],
      relations: [{ from: [:A], to: [:B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_extended_class
    @source = <<~SRC
      module A
        extend B
      end
    SRC

    expected = {
      classes: [[:A]],
      relations: [{ from: [:A], to: [:B] }]
    }
    assert_equal expected, @client.parse_text(@source)
  end
end
