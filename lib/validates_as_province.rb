module ActiveRecord
  module Validations
    module ClassMethods

      def validates_as_province(*args)        
        configuration = { :with => nil }
        configuration.update(args.pop) if args.last.is_a?(Hash)

        validates_each(args, configuration) do |record, attr_name, value|
          if configuration[:country].is_a?(String)
            country = configuration[:country]
          elsif configuration[:country].is_a?(Symbol) and record.respond_to?(configuration[:country])
            country = record.send(configuration[:country])
          elsif record.respond_to?(:country)
            country = record.send(:country)
          else
            country = false
          end
          
          next unless country          
          next unless Carmen::states?(country)
          current_province_list = Carmen::state_codes(country)
          next unless current_province_list

          value ||= ''

          unless (configuration[:allow_blank] && value.blank?) || current_province_list.include?(value)
            message = I18n.t("activerecord.errors.models.#{name.underscore}.attributes.#{attr_name}.invalid", 
                                          :default => [:"activerecord.errors.models.#{name.underscore}.invalid", 
                                                      configuration[:message],
                                                      :'activerecord.errors.messages.invalid'])
            record.errors.add(attr_name, message)
          end
        end
      end # validates_as_province

    end    
  end
end
