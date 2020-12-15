# encoding: utf-8

require 'logstash/plugin_mixins/validator_support'

module LogStash
  module PluginMixins
    module ValidatorSupport
      def self.valid_field_reference?(candidate)
        org.logstash.FieldReference.from(candidate) && true
      rescue org.logstash.FieldReference::IllegalSyntaxException => e
        false
      end

      FieldReferenceValidationAdapter = NamedValidationAdapter.new(:field_reference) do |value|
        break ValidationResult.failure("Expected exactly one field reference, got `#{value.inspect}`") unless value.kind_of?(Array) && value.size <= 1
        break ValidationResult.success(nil) if value.empty? || value.first.nil?

        candidate = value.first

        break ValidationResult.failure("Expected a valid field reference, got `#{candidate.inspect}`") unless ValidatorSupport.valid_field_reference?(candidate)

        break ValidationResult.success(candidate)
      end
    end
  end
end
