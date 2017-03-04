require 'singleton'
require 'araignee/architecture/repository'
require 'araignee/architecture/services/service'
require 'araignee/architecture/services/validator'

module Araignee
  module Architecture
    # Forward declaration to solve circular dependencies
    module Service
    end

    # Creator service part of Clean Architecture.
    # Base class to create an entity and return a result object.
    class Creator
      include Singleton
      include Service

      attr_reader :attributes

      def create(klass: nil, attributes: {})
        raise ArgumentError, 'klass invalid' unless klass
        raise ArgumentError, 'attributes empty' if attributes.empty?

        entity = create_entity(klass, attributes)

        validation = validate_entity(klass, entity)

        save_entity(klass, entity) if validation.successful?

        Result.new(klass, entity, validation.messages)
      end

      protected

      def create_entity(klass, attributes)
        klass.new(attributes)
      end

      def save_entity(klass, entity)
        storage(klass).create(entity)
      end

      def validate_entity(klass, entity)
        validator(klass).validate(klass: klass, entity: entity)
      end

      # Result class for Creator
      class Result
        attr_reader :entity, :messages

        def initialize(klass, entity, messages = [])
          raise ArgumentError, 'klass must be set' unless klass

          @klass = klass
          @entity = entity
          @messages = messages
        end

        def successful?
          @messages.empty?
        end
      end
    end
  end
end
