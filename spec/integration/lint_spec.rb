require 'spec_helper'

if ORM.has(:mongoid)
  describe Promiscuous, "#lint" do
    let(:mocks) { <<-MOCKS
        module TestPublisher::Publishers
          class PublisherModel
            include Promiscuous::Publisher::Model::Mock
            publish :to => '/publisher_model'

            publish :field_1
            publish :field_2
            publish :field_3
          end
          class PublisherModelChild < PublisherModel
            publish :child_field_1
            publish :child_field_2
            publish :child_field_3
          end
          class PublisherAnotherModel
            include Promiscuous::Publisher::Model::Mock
            publish :to => 'crowdtap/publisher_model'

            publish :field_1
          end
        end
                  MOCKS
    }

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

        it "lints" do
          Promiscuous::Publisher::Lint.with(StringIO.new(mocks)) do |linter|
            expect { linter.ensure_valid }.to_not raise_error
          end
        end
      end

      context "with a publisher with an incorrect field in the parent" do
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

        it "lints" do
          Promiscuous::Publisher::Lint.with(StringIO.new(mocks)) do |linter|
            expect { linter.ensure_valid }.to raise_error(ArgumentError)
          end
        end
      end

      context "with a publisher with an incorrect field in a child" do
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
              field :invalid
            end
          end
        end

        it "lints" do
          Promiscuous::Publisher::Lint.with(StringIO.new(mocks)) do |linter|
            expect { linter.ensure_valid }.to raise_error(ArgumentError)
          end
        end
      end
    end

    describe "subscriber" do
    end
  end
end
