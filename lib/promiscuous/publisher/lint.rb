module Promiscuous::Publisher::Lint
  def validate(path)
    valid_mocks?(path) && valid_getters?
  end

  private

  def valid_mocks?(path)
    Promiscuous::Publisher::MockGenerator.generate == File.read(path)
  end

  def valid_getters?
    Promiscuous::Publisher::Model.publishers.all? do |publisher|
      [publisher, publisher.descendants].flatten.all? do |publisher|
        publisher.published_attrs.all? do |attr|
          publisher.instance_methods.include?(attr.to_sym)
        end
      end
    end
  end
end
