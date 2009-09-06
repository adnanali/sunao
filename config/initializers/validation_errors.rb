module CouchRest
  module Validation
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