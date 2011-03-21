require 'spec_helper'

describe Rack::I18nJs do

  before(:each) do
    @first_hash = {
      "user" => {
        "name" => "Name",
        "surname" => "Surname",
        "state" => {
          "open" => "Open",
          "closed" => "Closed"
        },
        "contact" => "Contact"
      },
      "person" => "Person"
    }

    @second_hash = {
      "user" => {
        "name" => "Meno",
        "state" => {
          "closed" => "Zatvoreny"
        },
        "contact" => "Kontakt"
      },
      "person" => "Osoba",
      "customer" => "Zakaznik"
    }

    @rack = Rack::I18nJs.new("rspec")
    @rack.deep_merge!(@first_hash, @second_hash)
  end

  it "deep merging should merge second file into the first one recursively" do
    @first_hash.should == {"user"=>
       {
        "name"=>"Meno",
        "surname"=>"Surname",
        "state"=>{"open"=>"Open", "closed"=>"Zatvoreny"},
        "contact"=>"Kontakt"
       },
       "person"=>"Osoba",
       "customer" => "Zakaznik"}

  end


end