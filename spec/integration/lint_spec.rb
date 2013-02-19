require 'spec_helper'

if ORM.has(:mongoid)
  describe Promiscuous::Publisher, "#validate" do
    let(:mocks) { <<-MOCKS
# ---------------------------------
# Auto-generated file. Do not edit.
# ---------------------------------

module Test::Publishers

  # ------------------------------------------------------------------

  class PublisherModel
    include Promiscuous::Publisher::Model::Mock
    publish :to => 'Test/publisher_model'
    mock    :id => :bson

    publish :field_1
    publish :field_2
    publish :field_3
  end
  class PublisherModelChild < PublisherModel
    publish :child_field_1
    publish :child_field_2
    publish :child_field_3
  end

  # ------------------------------------------------------------------

  class PublisherAnotherModel
    include Promiscuous::Publisher::Model::Mock
    publish :to => 'crowdtap/publisher_model'
    mock    :id => :bson

    publish :field_1
  end
end
                  MOCKS
    }
    let(:mock_file) {
      @mock_file = Tempfile.new('mocks')
      @mock_file.write(mocks)
      @mock_file.close
      @mock_file.path
    }
    after { @mock_file.unlink }

    before do
      Promiscuous::Config.app = "Test"
    end

    describe "publisher" do
      context "with a publisher that matches the mocks" do
        before do
          define_constant :TestPublisher
          define_constant :PublisherModel do
            include Mongoid::Document
            include Promiscuous::Publisher

            publish do
              field :field_1
              field :field_2
              field :field_3
            end
          end
          define_constant :PublisherModelChild, PublisherModel do
            publish do
              field :child_field_1
              field :child_field_2
              field :child_field_3
            end
          end
          define_constant :PublisherAnotherModel do
            include Mongoid::Document
            include Promiscuous::Publisher

            publish :to => 'crowdtap/publisher_model' do
              field :field_1
            end
          end
        end

        it "validates" do
          Promiscuous::Publisher.validate(mock_file).should be_true
        end
      end

      context "with a publisher with that doesn't match" do
        before do
          define_constant :TestPublisher
          define_constant :PublisherModel do
            include Mongoid::Document
            include Promiscuous::Publisher

            publish do
              field :invalid
              field :field_2
              field :field_3
            end
          end
        end

        it "validates" do
          Promiscuous::Publisher.validate(mock_file).should be_false
        end
      end

      context "with a publisher that is missing an attributes" do
        before do
          define_constant :TestPublisher
          define_constant :PublisherModel do
            include Mongoid::Document
            include Promiscuous::Publisher

            field :field_1

            publish :field_1, :field_2, :field_3
          end
          define_constant :PublisherModelChild, PublisherModel do
            field :child_field_1

            publish :child_field_1, :child_field_2, :child_field_3
          end
          define_constant :PublisherAnotherModel do
            include Mongoid::Document
            include Promiscuous::Publisher

            publish :to => 'crowdtap/publisher_model' do
              field :field_1
            end
          end
        end

        it "validates" do
          Promiscuous::Publisher.validate(mock_file).should be_false
        end
      end
    end

    describe "subscriber" do
      context "with a subscriber that matches the mocks" do
        before do
          define_constant :SubscriberModel do
            include Mongoid::Document
            include Promiscuous::Subscriber

            subscribe do
              field :field_1
              field :field_2
              field :field_3
            end
          end
          define_constant :SubscriberModelChild, SubscriberModel do
            subscribe do
              field :child_field_1
              field :child_field_2
              field :child_field_3
            end
          end
          define_constant :SubscribeAnotherModel do
            include Mongoid::Document
            include Promiscuous::Subscriber

            subscribe :to => 'crowdtap/publisher_model' do
              field :field_1
            end
          end
        end

        it "validates" do
          Promiscuous::Subscriber.validate.should be_true
        end
      end
    end
  end
end
