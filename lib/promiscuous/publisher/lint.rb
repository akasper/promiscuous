module Promiscuous::Publisher::Lint
  def self.with(file, &block)
    @mocks = file.read
    instance_eval(@mocks)
    block.call self
  end

  def self.ensure_valid
    mocks = {}
    Promiscuous::Publisher::Model.publishers.each do |mock|
      [mock, mock.descendants].flatten.each do |mock|
        mocks[mock.publish_as] = mock if mock.ancestors.include?(Promiscuous::Publisher::Model::Mock)
      end
    end

    Promiscuous::Publisher::Model.publishers.each do |publisher|
      [publisher, publisher.descendants].flatten.each do |model|
        mock = mocks[model.publish_as]
        raise_if("#{model.publish_as} not included in mocks. Regenerate your mocks.") { mock.nil? }
        raise_if("#{model.publish_as} doesn't match #{mock.published_attrs} in mock. Regenerate your mocks.") { model.published_attrs != mock.published_attrs }
      end

      mock = mocks[publisher.publish_as]
      raise_if(":to => #{publisher.publish_to} doesn't match #{mock.publish_as}. Regenerate your mocks.") { publisher.publish_to != mock.publish_to }
    end
  end

  private

  def self.raise_if(msg, &block)
    raise ArgumentError.new(msg) if block.call
  end
end
