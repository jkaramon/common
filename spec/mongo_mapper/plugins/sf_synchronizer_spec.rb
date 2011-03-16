require 'spec_helper'

describe "MongoMapper::Plugins::SfSynchronizer" do
  class Category
    include MongoMapper::Document
    plugin MongoMapper::Plugins::SfSynchronizer

    key :name, String, :required => true

    def base_synchronize
      synchronize_entity('cars', :category_id, :sf_category, self.name)
    end
  end

  class Car
    include MongoMapper::Document

    key :name, String, :required => true
    key :category_id, ObjectId
    key :sf_category, String
  end

  before(:all) do
    MongoMapper.database = 'rspec-common-test'
    Category.collection.remove
    Car.collection.remove

    @category = Category.new(:name => "Hatchback")
    @category.save!
    Car.new(:name => "Fabia", :category_id => @category.id).save!
    Car.new(:name => "Octavia").save!
  end

  it "should update sf_category on related Car entities" do
    @category.name = "Limousine"
    @category.save!
    my_car = Car.first(:name => "Fabia").sf_category.should == "Limousine"
  end

  it "should not update sf_category on not related Car entities" do
    @category.name = "Pick up"
    @category.save!
    my_car = Car.first(:name => "Octavia").sf_category.should == nil
  end
  
end