module Protokoll
  extend ActiveSupport::Concern

  module ClassMethods

    # Class method available in models
    #
    # == Example
    #   class Order < ActiveRecord::Base
    #      protokoll :number
    #   end
    #
    def protokoll(column, _options = {})
      options = { :pattern       => "%Y%m#####",
                  :number_symbol => "#",
                  :column        => column,
                  :start         => 0,
                  :save          => true,
                  :on_create     => true,
                  :scope         => nil }

      options.merge!(_options)

      # Defining custom methods
      send :define_method, "reserve_#{options[:column]}!".to_sym do
        self[column] = Counter.next(self, options)
      end

      send :define_method, "reserve_#{options[:column]}".to_sym do
        self[column] = Counter.next(self, options.merge(save: false))
      end

      # Signing before_create
      before_create do |record|
        unless record[column].present?
          record[column] = Counter.next(self, options) if options[:on_create]
        end
      end
    end
  end

end
