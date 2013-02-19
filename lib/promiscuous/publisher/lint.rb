module Promiscuous::Publisher::Lint
  def validate(path)
    Promiscuous::Publisher::MockGenerator.generate == File.read(path) && begin
      Promiscuous::Publisher::Model.publishers.all? do |publisher|
        [publisher, publisher.descendants].flatten.all? do |publisher|
          publisher.published_attrs.all? do |attr|
            [attr, "#{attr}="].all? { |method| publisher.instance_methods.include?(method.to_sym) }
          end
        end
      end
    end
  end
end
