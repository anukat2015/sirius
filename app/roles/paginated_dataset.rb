require 'role_playing'

##
# Handles pagination for a given {Sequel::Dataset}
class PaginatedDataset < RolePlaying::Role

  # @param [Integer] offset to start query from
  # @param [Integer] limit of returned records
  # @return [Sequel::Dataset] modified dataset
  def paginate(offset: 0, limit: 20)
    self.limit(limit).offset(offset)
  end

  # @todo This should send #unlimited first,
  #   also it acutally executes a `COUNT` query
  def total
    self.count
  end
end
