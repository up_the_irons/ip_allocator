require File.dirname(__FILE__) + '/ip_allocator'

describe IPAllocator do
  before do
    @supernet = IPAddr.new('208.79.88.0/21')

    @assignments = [IPAddr.new('208.79.89.0/25'), 
                    IPAddr.new('208.79.91.0/24')]

    @ip_allocator = IPAllocator.new(@supernet, @assignments)
  end

  it "should find 208.79.92.0/23 as first unused /23 block" do
    pending
  end

  it "should find 208.79.88.0/24 as first unused /24 block" do
    pending
  end
end
