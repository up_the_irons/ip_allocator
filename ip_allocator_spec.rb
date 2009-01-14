require File.dirname(__FILE__) + '/ip_allocator'
require 'ruby-debug'

describe IPAllocator do
  before do
    @supernet  = NetAddr::CIDR.create('208.79.88.0/21')

    @allocated = [NetAddr::CIDR.create('208.79.89.0/25'), 
                  NetAddr::CIDR.create('208.79.91.0/24')]

    @allocator = IPAllocator.new(@supernet, @allocated)
  end

  describe "Allocations" do
    it "should find 208.79.92.0/23 as first unused /23 block" do
      @allocator.first_unused(23).should == '208.79.92.0/23'
    end

    it "should find 208.79.88.0/24 as first unused /24 block" do
      @allocator.first_unused(24).should == '208.79.88.0/24'
    end
  end

  describe "Edge Cases" do
    it "should not find a block larger than the supernet" do
      # /20 is larger than supernet of /21
      @allocator.first_unused(20).should be_nil
    end
  end

  describe "Methods" do
    describe "available()" do
      it "should return available /23's" do
        @allocator.available(23).should == ['208.79.92.0/23',
                                            '208.79.94.0/23']
      end

      it "should return available /24's" do
        @allocator.available(24).should == ['208.79.88.0/24',
                                            '208.79.90.0/24',
                                            '208.79.92.0/24',
                                            '208.79.94.0/24',
                                            '208.79.93.0/24',
                                            '208.79.95.0/24']
      end

      it "should return available /22's" do
        @allocator.available(22).should == ['208.79.92.0/22']
      end

      it "should return empty set for requested block size larger than supernet" do
        @allocator.available(20).should == []
      end
    end
  end
end
