class ProjectSerializer < ActiveModel::Serializer
  attributes :name
  # attributes :name, :scorecard_ids
  # has_many :tests

  # def include_tests?
  #   scope == :filtered
  # end
end
