module Promiscuous::Subscriber::Lint
  def validate
    validate_setters_and_classes
    validate_subscribed_attributes
  end

  private

  def validate_setters_and_classes
    errors = []

    subscribers.all? do |subscriber|
      subscriber.subscribed_attrs.all? do |attr|
        unless subscriber.instance_methods.include?("#{attr}=".to_sym)
          errors << "#{subscriber} doesn't include #{attr} setter"
        end
      end
    end

    raise_if errors
  end

  def validate_subscribed_attributes
    mocks = {}
    errors = []

    Promiscuous::Publisher::Model.publishers.each do |mock|
      [mock, mock.descendants].flatten.each do |mock|
        mocks[mock.publish_to] = mock if mock.ancestors.include?(Promiscuous::Publisher::Model::Mock)
      end
    end

    subscribers.each do |subscriber|
      mock = mocks[subscriber.subscribe_from]

      unless mock.nil?
        subscriber.subscribed_attrs.each do |attr|
          errors << "#{subscriber}.#{attr} is not in the publisher definition" if !mock.published_attrs.include?(attr)
        end
      else
        errors << "#{subscriber} doesn't match a class in the publisher definition"
      end
    end

    raise_if errors
  end

  private

  def subscribers
    Promiscuous::Subscriber::Model.mapping.values.reject { |sub| sub.subscribe_from =~ /__promiscuous__/ }.map do |subscriber|
      [subscriber, subscriber.descendants]
    end.flatten
  end

  def raise_if(errors)
    raise Exception.new(errors.join(". ")) unless errors.empty?
  end
end
