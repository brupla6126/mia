require 'araignee/ai/core/repeater'

module Araignee
  # Module for gathering AI classes
  module Ai
    module Core
      # Defines attributes and methods to repeat node
      # processing n times
      class RepeaterNumberTimes < Repeater
        protected

        def default_attributes
          super().merge(
            times: 1
          )
        end

        def repeat(child, entity, world)
          raise ArgumentError, 'times must be > 0' unless times.positive?

          child.start! unless child.running?

          (1..times).each do
            child.process(entity, world)
          end
        end
      end
    end
  end
end
