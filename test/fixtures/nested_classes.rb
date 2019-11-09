class NestedParent
  def new
    @child = NestedChild.new
  end

  class NestedChild
    def new
      @child = NestedGrandchild.new
    end

    class NestedGrandchild
    end
  end
end
