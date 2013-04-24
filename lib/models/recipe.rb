module CloudManage::Models
  class Recipe < Sequel::Model

    plugin :timestamps, :create => :created_at, :update => :updated_at
    many_to_many :servers

    def sanitized_body
      body.each_line.map { |l| l.strip }.join("\n")
    end

  end
end
