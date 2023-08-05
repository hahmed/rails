# frozen_string_literal: true

require "active_support/core_ext/hash/keys"

module ActiveModel
  module AttributeAssignment
    include ActiveModel::ForbiddenAttributesProtection

    # Allows you to set all the attributes by passing in a hash of attributes with
    # keys matching the attribute names.
    #
    # If the passed hash responds to <tt>permitted?</tt> method and the return value
    # of this method is +false+ an ActiveModel::ForbiddenAttributesError
    # exception is raised.
    #
    #   class Cat
    #     include ActiveModel::AttributeAssignment
    #     attr_accessor :name, :status
    #   end
    #
    #   cat = Cat.new
    #   cat.assign_attributes(name: "Gorby", status: "yawning")
    #   cat.name # => 'Gorby'
    #   cat.status # => 'yawning'
    #   cat.assign_attributes(status: "sleeping")
    #   cat.name # => 'Gorby'
    #   cat.status # => 'sleeping'
    def assign_attributes(new_attributes)
      unless new_attributes.respond_to?(:each_pair)
        raise ArgumentError, "When assigning attributes, you must pass a hash as an argument, #{new_attributes.class} passed."
      end
      return if new_attributes.empty?

      _assign_attributes(sanitize_for_mass_assignment(new_attributes))
    end

    alias attributes= assign_attributes

    private
      def _assign_attributes(attributes)
        invalid_attributes = []
        attributes.each do |k, v|
          setter = :"#{k}="
          if respond_to?(setter)
            public_send(setter, v)
          else
            invalid_attributes << k.to_s
          end
        end

        raise UnknownAttributeError.new(self, invalid_attributes) if invalid_attributes.any?
      end

      def _assign_attribute(k, v)
        setter = :"#{k}="
        if respond_to?(setter)
          public_send(setter, v)
        else
          raise UnknownAttributeError.new(self, k.to_s)
        end
      end
  end
end
