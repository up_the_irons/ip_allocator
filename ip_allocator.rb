require 'rubygems'
require 'netaddr'

# IPAllocator
#
# Synopsis:
#
#   A class that helps ISP's subnet their IPv4 and IPv6 address space.
#
#   Example uses include:
#
#     * Allocating IPs to customers
#     * Allocating subnets to downstream networks
#     * Allocating subnets for internal use
#
# Notes:
#
#   All CIDR objects belong to the NetAddr module.  Where CIDR is referenced,
#   the complete object path is NetAddr::CIDR.
#
# Requirements:
#
#   * RubyGems
#   * NetAddr gem
#
class IPAllocator
  # initialize()
  #
  # Synopsis:
  #
  #   Constructor.
  #
  # Arguments:
  #
  #   * supernet: a CIDR object describing a block of IPs from which allocations
  #               can be made.
  #
  #   * assignments: an array of CIDR objects defining which IP blocks are 
  #                  already allocated and not eligible for assignment.
  #
  #                  Naturally, all assignments should be a proper subset of 
  #                  the supernet.
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

  # first_unused()
  #
  # Synopsis:
  #
  #   Find the first available block for allocation.
  #
  #   See available() for more information. 
  #
  # Arguments:
  # 
  #   Takes same arguments as available()
  #
  # Returns:
  #
  #   NetAddr::CIDR object of first available block for allocation.  nil if no
  #   block is found.
  def first_unused(size, opts = {})
    available(size, opts).first
  end

  # available()
  #
  # Synopsis:
  #
  #   Find available blocks for allocation, arranged by the order in which they
  #   should be allocated, as described in RFC 3531.
  #
  #   Available blocks are defined as blocks that are not included in 
  #   @allocated or a subnet of a member of @allocated.
  #
  #   RFC 3531 is a generalization of RFC 1219 ("On the Assignment of Subnet 
  #   Numbers").  Its first intended use is for IPv6, but can be used for any
  #   bit length addressing scheme (e.g. IPv4).
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
  #   An array of NetAddr::CIDR objects of available blocks.
  def available(size, opts = {})
    if size < @supernet.bits
      return []
    end

    defaults = { :Objectify => true,
                 :Strategy  => :centermost }

    @candidates = @supernet.allocate_rfc3531(size, defaults.merge(opts))

    @available = @candidates.select do |candidate_block|
      @allocated.each do |allocated_block|
        if candidate_block == allocated_block
          break false
        end

        if candidate_block.contains?(allocated_block)
          break false
        end

        if allocated_block.contains?(candidate_block)
          break false
        end
      end
    end

    @available
  end
end
