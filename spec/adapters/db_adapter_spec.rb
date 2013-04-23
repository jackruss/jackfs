require File.dirname(__FILE__) + '/../spec_helper'


describe "Jackfs Db Adapter" do
  before(:each) do
    File.delete("test.db") if File.exists?("test.db")
    YAML.should_receive(:load_file).and_return("test" => {
      "adapter" => "db",
      "connection" => 'sqlite://test.db',
      "table_name" => 'jackfs'
    })
    
    root = File.dirname(__FILE__) + '/..'
    @dba = Jackfs::DbAdapter.new(root, :test)
  end

  
  it "should save a file to a configured database name" do
    @dba.connection.should == 'sqlite://test.db'
  end


  it "should save a file to a configured table name" do
    @dba.table_name.should == 'jackfs'
  end

  it "should save the file in db using the given name" do
    @dba.store(File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r'),"COOLBEANS").should eq("COOLBEANS")
  end
  
  it "should allow connection string with odd characters" do
    @dba.connection = "sqlite://root:abc!#%@test.db"
    @dba.uri_escape(@dba.connection).should eq("sqlite://root:abc!%23%25@test.db")
  end
  
  it "should throw an error when connection string is bad URI" do
    URI.stub!(:escape).and_raise(Exception)
    $stdout.should_receive(:puts).with('Error encountered when parsing sqlite://test.db - Exception')
    @dba.uri_escape(@dba.connection)    
  end

  # it "should get a file from a configured from db" do
  #   f = File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r')
  #   @dba.store(f, "COOLBEANS")
  #   orig = File.open(File.dirname(__FILE__) + '/../fixtures/test.pdf', 'r')
  #   
  #   @dba.get("COOLBEANS").read.length.should == orig.read.length    
  # end
  
  
end
