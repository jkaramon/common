require 'spec_helper'

describe "MongoMapper::Plugins::SearchFieldItems" do
  class Car
    include MongoMapper::Document
    plugin MongoMapper::Plugins::SearchFieldItems

    key :name, String, :required => true
    key :category_id, ObjectId

    belongs_to :category
  end

  class Category
    include MongoMapper::Document

    key :name, String, :required => true

    def display_name
      name
    end
  end

  before(:all) do
    MongoMapper.database = 'rspec-common-test'
    Category.collection.remove
    Car.collection.remove

    @hatchback_category = Category.new(:name => "Hatchback")
    @hatchback_category.save!
    @limousine_category = Category.new(:name => "Limousine")
    @limousine_category.save!
    @my_car = Car.new(:name => "Fabia", :category_id => @hatchback_category.id)
    @my_car.save!
  end

  it "should update sf_category if car's category has been changed" do
    @my_car.category = @limousine_category
    @my_car.update_search_fields
    @my_car.save!
    @my_car.reload
    @my_car.sf_category.should == "Limousine"
  end

  it "should update sf_category using dirent_update" do
    @my_car.category = @hatchback_category
    @my_car.sf_direct_update('cars')
    @my_car.reload
    @my_car.sf_category.should == "Hatchback"
  end

end