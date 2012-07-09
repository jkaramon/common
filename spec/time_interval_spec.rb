require 'spec_helper'

describe TimeInterval do
  
  before(:each) do
    @time1 = Time.parse '2010-01-01 1:00 UTC'
    @time2 = Time.parse '2010-01-01 2:00 UTC'
    @time3 = Time.parse '2010-01-01 3:00 UTC'
    @time4 = Time.parse '2010-01-01 4:00 UTC'
  end 
  
  it "should return false whether two interval overlaps" do
    int1 = TimeInterval.new( @time1, @time2)
    int2 = TimeInterval.new( @time3, @time4)
    
    int1.overlaps?(int2).should == false
    int2.overlaps?(int1).should == false
  end
  
  it "should return true whether two interval overlaps" do
    int1 = TimeInterval.new( @time1, @time3)
    int2 = TimeInterval.new( @time2, @time4)
    
    int1.overlaps?(int2).should == true
    int2.overlaps?(int1).should == true
  end

  it "should return true whether two interval overlaps" do
    int1 = TimeInterval.new( @time2, @time3)
    int2 = TimeInterval.new( @time1, @time4)
    
    int1.overlaps?(int2).should == true
    int2.overlaps?(int1).should == true
  end

  it "should merge two interval completely overlaps" do
    int1 = TimeInterval.new( @time2, @time3)
    int2 = TimeInterval.new( @time1, @time4)
    
    int1.merge int2
    int1.from.should == @time1
    int1.to.should == @time4
  end
 
  it "should merge two interval partly overlaps" do
    int1 = TimeInterval.new( @time1, @time3)
    int2 = TimeInterval.new( @time2, @time4)
    
    int1.merge int2
    int1.from.should == @time1
    int1.to.should == @time4
  end
    
end

describe TimeIntervalArray do
  
  before(:each) do
    @time1 = Time.parse '2010-01-01 1:00 UTC'
    @time2 = Time.parse '2010-01-01 2:00 UTC'
    @time3 = Time.parse '2010-01-01 3:00 UTC'
    @time4 = Time.parse '2010-01-01 4:00 UTC'
    @time5 = Time.parse '2010-01-01 5:00 UTC'
    @time6 = Time.parse '2010-01-01 6:00 UTC'
  end 

  it "should return valid array" do
    int1 = TimeInterval.new( @time1, @time2)

    array = TimeIntervalArray.new

    array.add int1

    array.items.count.should == 1
    array.items[0].should == int1    
  end

  it "should return sorted array" do
    int1 = TimeInterval.new( @time1, @time2)
    int2 = TimeInterval.new( @time4, @time5)

    array = TimeIntervalArray.new

    array.add int1
    array.add int2


    array.items.count.should == 2
    array.items[0].should == int1
    array.items[1].should == int2    

    array = TimeIntervalArray.new

    array.add int2
    array.add int1

    array.items.count.should == 2
    array.items.should == [ int1, int2 ]
    array.items[1].should == int2    
  end

  it "should return merged array" do
    int1 = TimeInterval.new( @time1, @time3)
    int2 = TimeInterval.new( @time4, @time6)
    int3 = TimeInterval.new( @time2, @time5)

    array = TimeIntervalArray.new

    array.add int1
    array.add int2

    array.items.count.should == 2
    array.items[0].should == int1    
    array.items[1].should == int2    

    array.add int3

    array.items.count.should == 1
    array.items[0].from.should == @time1
    array.items[0].to.should == @time6
 end

  it "should return merged array" do
    int1 = TimeInterval.new( @time1, @time2)
    int2 = TimeInterval.new( @time2, @time3)
    int3 = TimeInterval.new( @time3, @time4)
    int4 = TimeInterval.new( @time5, @time6)

    array = TimeIntervalArray.new

    array.add int1
    array.add int2
    array.add int3
    array.add int4

    array.items.count.should == 2
    array.items[0].from.should == @time1
    array.items[0].to.should == @time4
    array.items[1].should == int4

    array.add int2

    array.items.count.should == 2
    array.items[0].from.should == @time1
    array.items[0].to.should == @time4
    array.items[1].should == int4

    array.add TimeInterval.new( @time1, @time4)

    array.items.count.should == 2
    array.items[0].from.should == @time1
    array.items[0].to.should == @time4
    array.items[1].should == int4

    array.add TimeInterval.new( @time1, @time6)

    array.items.count.should == 1
    array.items[0].from.should == @time1
    array.items[0].to.should == @time6
  end

  it "should return merged array" do
    int1 = TimeInterval.new( @time1, @time2)
    int2 = TimeInterval.new( @time2, @time3)
    int3 = TimeInterval.new( @time3, @time4)
    int4 = TimeInterval.new( @time5, @time6)

    array1 = TimeIntervalArray.new

    array1.add int1
    array1.add int2

    array2 = TimeIntervalArray.new

    array2.add int3
    array2.add int4

    array1.merge(array2)

    array1.items.count.should == 2
    array1.items[0].from.should == @time1
    array1.items[0].to.should == @time4
    array1.items[1].should == int4

    array3 = TimeIntervalArray.new

    array3.add int2
    array3.add TimeInterval.new( @time1, @time3)
    array3.add TimeInterval.new( @time4, @time5)

    array1.merge(array3)

    array1.items.count.should == 1
    array1.items[0].from.should == @time1
    array1.items[0].to.should == @time6
  end

end 
