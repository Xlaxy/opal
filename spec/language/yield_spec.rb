require File.expand_path('../fixtures/yield', __FILE__)

describe "The yield call" do
  before :each do
    @y = YieldSpecs::Yielder.new
  end

  describe "taking no arguments" do
    it "raises a LocalJumpError when the method is not passed a block" do
      lambda { @y.z }.should raise_error(LocalJumpError)
    end
  end

  describe "taking a single argument" do
    it "raises a LocalJumpError when the method is not passed a block" do
      lambda { @y.s(1) }.should raise_error(LocalJumpError)
    end

    it "passes an empty Array when the argument is an empty Array" do
      @y.s([]) { |*a| a }.should == [[]]
    end

    it "passes nil as a value" do
      @y.s(nil) { |*a| a }.should == [nil]
    end

    it "passes a single value" do
      @y.s(1) { |*a| a }.should == [1]
    end

    it "passes a single, multi-value Array" do
      @y.s([1, 2, 3]) { |*a| a }.should == [[1, 2, 3]]
    end
  end

  describe "taking multiple arguments" do
    it "raises a LocalJumpError when the method is not passed a block" do
      lambda { @y.m(1, 2, 3) }.should raise_error(LocalJumpError)
    end

    it "passes the arguments to the block" do
      @y.m(1, 2, 3) { |*a| a }.should == [1, 2, 3]
    end
  end

  describe "taking a single splatted argument" do
    it "raises a LocalJumpError when the method is not passed a block" do
      lambda { @y.r(0) }.should raise_error(LocalJumpError)
    end

    it "passes a single value" do
      @y.r(1) { |*a| a }.should == [1]
    end

    it "passes no arguments when the argument is an empty array" do
      @y.r([]) { |*a| a }.should == []
    end

    it "passes the value when the argument is an Array containing a single value" do
      @y.r([1]) { |*a| a }.should == [1]
    end

    it "passes the values of the Array as individual arguments" do
      @y.r([1, 2, 3]) { |*a| a }.should == [1, 2, 3]
    end

    it "passes the element of a single element Array" do
      @y.r([[1, 2]]) { |*a| a }.should == [[1, 2]]
      @y.r([nil]) { |*a| a }.should == [nil]
      @y.r([[]]) { |*a| a }.should == [[]]
    end

    it "passes nil as a value" do
      @y.r(nil) { |*a| a }.should == [nil]
    end
  end

  describe "taking multiple arguments with a splat" do
    it "raises a LocalJumpError when the method is not passed a block" do
      lambda { @y.rs(1, 2, [3, 4]) }.should raise_error(LocalJumpError)
    end

    it "passes the arguments to the block" do
      @y.rs(1, 2, 3) { |*a| a }.should == [1, 2, 3]
    end

    it "does not pass an argument value if the splatted argument is an empty Array" do
      @y.rs(1, 2, []) { |*a| a }.should == [1, 2]
    end

    it "passes the Array elements as arguments if the splatted argument is a non-empty Array" do
      @y.rs(1, 2, [3]) { |*a| a }.should == [1, 2, 3]
      @y.rs(1, 2, [nil]) { |*a| a }.should == [1, 2, nil]
      @y.rs(1, 2, [[]]) { |*a| a }.should == [1, 2, []]
      @y.rs(1, 2, [3, 4, 5]) { |*a| a }.should == [1, 2, 3, 4, 5]
    end

    it "passes nil as the argument value if the splatted argument is nil" do
      @y.rs(1, 2, nil) { |*a| a }.should == [1, 2, nil]
    end
  end
end