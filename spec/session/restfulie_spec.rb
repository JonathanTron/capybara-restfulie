require 'spec_helper'

describe Capybara::Session do
  def extract_results(session)
    $stdout.puts Nokogiri::HTML(session.body).inspect
    YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  end

  after do
    @session.reset!
  end
  
  
  context 'with restfulie driver' do
    before do
      @session = Capybara::Session.new(:restfulie, TestApp)
    end

    describe '#driver' do
      it "should be a restfulie driver" do
        @session.driver.should be_an_instance_of(Capybara::Driver::Restfulie)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :restfulie
      end
    end


    describe '#click_link' do
      it "should use data-method if available" do
        @session.visit "/with_html"
        @session.click_link "A link with data-method"
        @session.body.should == 'The requested object was deleted'
      end
    end

    # We do not support all session possibilities
    # we only import thoses we should support
    it_should_behave_like "click_link"
    it_should_behave_like "find_button"
    it_should_behave_like "find_field"
    it_should_behave_like "find_link"
    it_should_behave_like "find_by_id"
    it_should_behave_like "find"
    it_should_behave_like "has_content"
    it_should_behave_like "has_css"
    it_should_behave_like "has_css"
    it_should_behave_like "has_selector"
    it_should_behave_like "has_xpath"
    it_should_behave_like "has_link"
    it_should_behave_like "has_button"
    it_should_behave_like "has_field"
    it_should_behave_like "has_select"
    it_should_behave_like "has_table"
    it_should_behave_like "within"
    it_should_behave_like "current_url"
    
    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end