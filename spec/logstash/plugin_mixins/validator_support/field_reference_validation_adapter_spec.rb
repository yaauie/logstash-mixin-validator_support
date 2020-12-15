# encoding: utf-8

require 'logstash/plugin_mixins/validator_support/field_reference_validation_adapter'

describe LogStash::PluginMixins::ValidatorSupport::FieldReferenceValidationAdapter do

  if LOGSTASH_VERSION.start_with?('6.')
    around(:each) do |example|
      begin
        strict = org.logstash.FieldReference::ParsingMode::STRICT
        original_parsing_mode = org.logstash.FieldReference.set_parsing_mode(strict)

        example.call
      ensure
        org.logstash.FieldReference.set_parsing_mode(original_parsing_mode)
      end
    end
  end

  it 'is an instance of NamedValidationAdapter' do
    expect(described_class).to be_a_kind_of LogStash::PluginMixins::ValidatorSupport::NamedValidationAdapter
  end

  context '#validate' do
    [
      ['@timestamp'],
      ['[@timestamp]'],
      ['[@metadata][ssl]'],
      ['[link][0]'],
      ['one'],
      ['[fruit][[bananas][oranges]]'],
      [],
      [nil]
    ].each do |candidate|
      context "valid input `#{candidate.inspect}`" do
        it 'correctly reports the value as valid', :aggregate_failures do
          is_valid_result, coerced_or_error = described_class.validate(candidate)

          expect(is_valid_result).to be true
          expect(coerced_or_error).to eq candidate.first
        end
      end
    end

    [
      ['link[0]'],
      ['][N\\//\\L][D'],
      ["one","two"],
      {"this" => "that"},
      ['[fruit][bananas[oranges]]'],
    ].each do |candidate|
      let(:candidate) { candidate }

      context "invalid input `#{candidate.inspect}`" do
        it 'correctly reports the value as invalid', :aggregate_failures do
          is_valid_result, coerced_or_error = described_class.validate(candidate)

          expect(is_valid_result).to be false
          expect(coerced_or_error).to be_a_kind_of String
          expect(coerced_or_error).to_not include('Unknown validator')
          expect(coerced_or_error).to include('field reference')
        end
      end
    end
  end
end