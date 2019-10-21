require_relative './depdump'
require 'minitest/autorun'

MiniTest::Unit.autorun

class TestFoo < MiniTest::Unit::TestCase
  def setup
    @client = Depdump.new
  end

  def test_blank_class
    @source = <<~SRC
      class A
      end
    SRC

    expected = { classes: [[:A]] }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_parsing_reopened_class
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

      class A
        def reopened
          p 'reopend class'
        end
      end
    SRC

    expected = { classes: [[:A], [:B]] }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_parsing_nested_class
    @source = <<~SRC
      class A
        def hello
          p 'hello, '
          A::B.new.world
        end

        class B
          def world
            p 'world'
          end

          class C
          end
        end
      end
    SRC

    expected = { classes: [[:A], [:A, :B], [:A, :B, :C]] }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_parsing_qualified_class
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

    expected = { classes: [[:A], [:A, :B, :C]] }
    assert_equal expected, @client.parse_text(@source)
  end

  def test_parsing_class_qualified_with_module
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

    expected = { classes: [[:A], [:A, :B, :C]] }
    assert_equal expected, @client.parse_text(@source)
  end
end
