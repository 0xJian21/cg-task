ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Temporarily replace a singleton method on +object+ for the duration of the block.
    # Minitest 6 removed Object#stub, so we replicate it here.
    def stub_method(object, method_name, val_or_proc = nil, &block)
      original = object.method(method_name)
      if val_or_proc.is_a?(Proc)
        object.define_singleton_method(method_name, &val_or_proc)
      else
        object.define_singleton_method(method_name) { |*_args| val_or_proc }
      end
      block.call
    ensure
      object.define_singleton_method(method_name, &original)
    end
  end
end
