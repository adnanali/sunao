module CouchRest
  module Validation

    ##
    #
    # @author Guy van den Berg
    # @since 0.9
    class ValidationErrors
      def each_with_key
        errors.map.each do |k, v|
          next if v.blank?
          yield(k, v)
        end
      end
    end
  end
end