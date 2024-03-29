class << ActiveRecord::Base
  # PostgreSQL-specific method for retrieving the next id in the
  # sequence. This is not transactional, so rolled-back transactions
  # could leave "holes" in the sequence.
  def next_id
    connection.select_value("SELECT nextval(#{connection.quote(sequence_name)})").to_i
  end
end

class Project < ActiveRecord::Base
  # # name string -- 'riak' or 'riak_ee' or 'riak_cs'
  # validates_uniqueness_of :name
  # default_scope includes(:scorecards)
  # has_many :scorecards
  # has_and_belongs_to_many :tests

  # status boolean -- did it pass or not
  # author string -- who ran it
  # test_id
  # platform_id
  # scorecard_id
  default_scope includes(:test)
  belongs_to :test
  belongs_to :scorecard

  # def status=(val)
  #   case val
  #   when TrueClass, FalseClass
  #     self[:status] = val
  #   when /pass/i
  #     self[:status] = true
  #   else
  #     self[:status] = false
  #   end
  # end

  # def body
  #   Excon.get(log_url).body
  # rescue Excon::Errors::Error
  #   ""
  # end
end
