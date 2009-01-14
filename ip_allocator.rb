require 'rubygems'
require 'netaddr'

# All CIDR objects belong to the NetAddr module.  Where CIDR is referenced,
# the complete object path is NetAddr::CIDR.

class IPAllocator
  # supernet: a CIDR object describing a block of IPs from which allocations
  #           can be made.
  #
  # assignments: an array of CIDR objects defining which IP blocks are 
  #              already allocated and not eligible for assignment.
  #
  #              Naturally, all assignments should be a proper subset of 
  #              the supernet.
  #
  # Example:
  #
  #   @supernet  = NetAddr::CIDR.create('208.79.88.0/21')
  #
  #   @allocated = [NetAddr::CIDR.create('208.79.89.0/25'),
  #                 NetAddr::CIDR.create('208.79.91.0/24')]
  #
  #   @allocator = IPAllocator.new(@supernet, @allocated)
  def initialize(supernet, allocated)
    @supernet  = supernet
    @allocated = allocated
  end

  # Synopsis:
  #
  #   Find the first unused block, per RFC 3531
  #
  # Arguments:
  #
  #   * size of the block to find, expressed in number of bits in the netmask.
  #     For example::
  #
  #       24 = 256 IP block
  #       25 = 128 IP block
  #       ...
  #       30 = 4 IP block
  #
  #   * options to pass to CIDR#allocate_rfc3531().
  #       
  # Returns:
  #
  #   NetAddr::CIDR object of first unused block found.  False otherwise.
  def first_unused(size, opts = {})
    if size < @supernet.bits
      return false
    end

    defaults = { :Objectify => true,
                 :Strategy  => :centermost }

    @candidates = @supernet.allocate_rfc3531(size, defaults.merge(opts))

    @available = @candidates.select do |candidate_block|
      @allocated.each do |allocated_block|
        if candidate_block.contains?(allocated_block)
          break false
        end
      end
    end

    @available.first
  end
end
