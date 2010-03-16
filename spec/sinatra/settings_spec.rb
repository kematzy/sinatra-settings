
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe "Sinatra" do 
  
  class MyTestApp
    register Sinatra::Settings
  end
  
  before(:each) do 
    @sinatra_default_settings = %w(
      app_file bind clean_trace dump_errors environment lock 
      logging method_override port public raise_errors reload_templates
      root run running server sessions show_exceptions static views
    )
  end
  
  describe "Base" do 
    
    describe "#sinatra_settings_for_inspection" do 
      
      it "should be an Array" do 
        Sinatra::Base.sinatra_settings_for_inspection.should be_a_kind_of(Array)
      end
      
      it "should include all the default Sinatra configuration settings" do 
        @sinatra_default_settings.each do |s|
          Sinatra::Base.sinatra_settings_for_inspection.should include(s)
        end
      end
      
    end #/ #sinatra_settings_for_inspection
    
  end #/ Base
  
  describe "Settings" do 
    
    before(:each) do 
      class ::Test::Unit::TestCase 
        def app; ::MyTestApp.new ; end
      end
      @app = app
    end
    
    after(:each) do 
      class ::Test::Unit::TestCase 
        def app; nil ; end
      end
      @app = nil
    end
    
    describe "VERSION" do 
      
      it "should return the VERSION string" do 
        Sinatra::Settings::VERSION.should be_a_kind_of(String)
        Sinatra::Settings::VERSION.should match(/\d\.\d+\.\d+(\.\d)?/)
      end
      
    end #/ VERSION
    
    describe "#self.version" do 
      
      it "should return a string with the version number" do 
        Sinatra::Settings.version.should match(/Sinatra::Settings v\d\.\d\.\d/)
      end
      
    end #/ #version
    
    describe "Configuration" do 
      
      it "should set :show_settings to FALSE" do 
        MyTestApp.show_settings.should == false
        app.settings.show_settings.should == false
      end
      
      it "should set :show_settings_environment to :development" do 
        MyTestApp.show_settings_environment.should == :development
        app.settings.show_settings_environment.should == :development
      end
      
    end #/ Configuration
    
    describe "#sinatra_settings_for_inspection" do 
      
      it "should return an Array of Sinatra configuration settings" do 
        app.settings.sinatra_settings_for_inspection.should be_a_kind_of(Array)
      end
      
      it "should include all the Sinatra default configuration settings" do 
        @sinatra_default_settings.each do |s|
          MyTestApp.sinatra_settings_for_inspection.should include(s)
          app.settings.sinatra_settings_for_inspection.should include(s)
        end
      end
      
      it "should include the settings from this extension" do 
        %w( show_settings show_settings_environment ).each do |s|
          MyTestApp.sinatra_settings_for_inspection.should include(s)
          app.settings.sinatra_settings_for_inspection.should include(s)
        end
      end
      
      it "should not duplicate settings in the array" do 
        pending %Q{ allows duplicate values in array }
        # TODO: This is not a big issue, since we do .uniq on the output in :settings_inspect,
        # which is where it's important, but still it would be nice to not have it from the start
        
        %w(foo bar foo bar).each do |s|
          app.settings.sinatra_settings_for_inspection << s
        end
        app.settings.sinatra_settings_for_inspection.should == app.settings.sinatra_settings_for_inspection.uniq
      end
      
    end #/ #sinatra_settings_for_inspection
    
    describe "Helpers" do 
      
      describe "#settings_inspect" do 
        
        it "should return a Hash" do 
          app.settings_inspect.should be_a_kind_of(Hash)
        end
        
        it "should contain the Sinatra default configurations" do 
          @sinatra_default_settings.each do |s|
            app.settings_inspect.keys.should include(s.to_sym)
            # app.settings.sinatra_settings_for_inspection.should include(s)
          end
        end
        
        it "should contain no duplicates" do 
          app.settings_inspect.keys.map(&:to_s).sort.should == 
            app.settings.sinatra_settings_for_inspection.uniq.sort
        end
        
      end #/ #settings_inspect
      
      describe "#show_settings_output?" do 
        
        describe "with :show_settings disabled" do 
          
          it "should show the :show_settings HTML comment output" do 
            erb_app "<%= show_settings_output? %>"
            body.should == '<!-- :show_settings is [OFF]  -->'
          end
          
        end #/ with :show_settings disabled
        
        describe "with :show_settings enabled" do 
          
          class MyCustomTestApp < Sinatra::Base
            set :app_dir, "#{fixtures_path}/app"
            set :public, "#{public_fixtures_path}"
            set :views, "#{app_dir}/views"
            register(Sinatra::Tests)
            register(Sinatra::Settings)
            
            enable :show_settings
            set :show_settings_environment, :test
            enable :raise_errors
          end
          
          before(:each) do 
            class ::Test::Unit::TestCase 
              def app; ::MyCustomTestApp.new ; end
            end
            @app = app
          end
          
          after(:each) do 
            class ::Test::Unit::TestCase 
              def app; nil ; end
            end
            @app = nil
          end
          
          it "should show the full HTML output" do 
            erb_app "<%= show_settings_output? %>"
            # body.should have_tag(:debug)
            body.should have_tag('div#debug') do |div| 
              div.should have_tag('h2', 'APP INFORMATION')
              div.should have_tag('div#get > table.req')
              
              div.should have_tag('div#params > table.req')
              
              div.should have_tag('div#sessions > h3','SESSIONS')
              
              div.should have_tag('div#cookies > h3','COOKIES')
              
              div.should have_tag('div#routes > h3','ROUTES')
              
              div.should have_tag('div#settings') do |settings_div|
                settings_div.should have_tag('h3', 'SETTINGS')
                settings_div.should have_tag('table.req') do |table|
                  table.should have_tag('tr > td.key', 'show_settings')
                  table.should have_tag('tr > td.code > div', 'true')
                  
                  table.should have_tag('tr > td.key', 'show_settings_environment')
                  table.should have_tag('tr > td.code > div', ':test')
                end
              end 
              div.should have_tag('div#rack > h3#env-info','Rack ENV')
            end
          end
          
        end #/ with :show_settings enabled
        
      end #/ #show_settings_output?
      
    end #/ Helpers
    
  end #/ Settings
  
end #/ Sinatra
