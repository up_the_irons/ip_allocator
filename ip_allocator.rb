require 'ipaddr'

class IPAllocator
  # supernet: a IPAddr object describing a block of IPs from which allocations
  #           can be made.
  #
  # assignments: an array of IPAddr objects defining which IP blocks are 
  #              already allocated and not eligible for assignment.
  #
  #              Naturally, all assignments should be a proper subset of 
  #              the supernet.
  #
  # Example:
  #
  #   IPAllocator.new(IPAddr.new('208.79.88.0/21'), [IPAddr.new('208.79.89.0/25'),
  #                                                  IPAddr.new('208.79.91.0/24')])
  def initialize(supernet, assignments)
  end

  # TODO: re-word this to be more clear
  # Returns an IPAddr object of the first unused block of length 'size'
  def first_unused(size)
  end
end
