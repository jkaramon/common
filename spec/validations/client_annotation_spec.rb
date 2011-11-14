require 'spec_helper'

class ClientAnnotationStub
  include MongoMapper::Document
  key :name, String, :required => true
  key :email, String
  key :serial_number, Integer
  validates :email, :format => { :with => /regex/, :on => :create }
  validates :serial_number, :inclusion => { :in => 0..9, :if => lambda { true } }
  validates_length_of :name, :email, :maximum => 250
  def self.i18n_scope
    :activemodel
  end
  
end

describe "Validations::ClientAnnotation" do
  before(:all) do
    I18n.backend.store_translations(:en, {
      :activemodel => {
        :attributes => { 
          :client_annotation_stub => {
            :email  => 'Email',
            :name   => 'Name'
          }
        },
        :hints => {
          :client_annotation_stub => {
            :email => 'Provide a valid email'
          }
        }
      }
    })
    @model = ClientAnnotationStub.new
    @annotation = Validations::ClientAnnotation.new(@model)
  end

  describe "validations_on" do


    it "name should be required" do
      @annotation.validations_on(:name).first.should include(
        :kind => :presence,
        :attr=>:name,
        :error=>"can't be blank"
      )
    end

    it "name should have one length constraint" do
      length_annotations = @annotation.validations_on(:name, :kind => :length)
      length_annotations.should have(1).item
    end


    it "email should have format set" do
      @annotation.validations_on(:email).first.should include(
        :on=>:create,
        :attr=>:email,
        :attr_display_name=> "Email",
        :kind=>:format,
        :with=>/regex/
      )
    end

    it "serial_number should have range set" do
      @annotation.validations_on(:serial_number).first.should include(
        :in=>0..9,
        :attr => :serial_number,
        :kind=>:inclusion,
        :error=>"is not included in the list"
      )
    end
  end

  describe "Required" do
    it { @annotation.required?(:name).should be_true }
    it { @annotation.required?(:email).should be_false }
  end

 describe "Hint" do
    it { @annotation.hint(:name).should be_nil }
    it { @annotation.hint(:email).should == "Provide a valid email" }
  end

    

end
