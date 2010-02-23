
require 'sinatra/base'


module Sinatra
  
  # :stopdoc:
  ##
  # Add :sinatra_settings_for_inspection setting to base, so that it's 
  # always available
  # 
  class Base
    
    set :sinatra_settings_for_inspection, %w(
      app_file bind clean_trace dump_errors environment lock 
      logging method_override port public raise_errors reload_templates
      root run running server sessions show_exceptions static views
    )
    
  end #/class Base
  
  # :startdoc:
  
  module Settings
    
    VERSION = '0.1.0' unless const_defined?(:VERSION)
    def self.version; "Sinatra::Settings v#{VERSION}"; end
    
    
    module Helpers
      
      # Add Rack::Utils if not already present
      unless respond_to?(:h)
        include Rack::Utils
        alias_method :h, :escape_html
      end
      
      
      ##
      # Convenience helper method that returns a Hash, nicely
      # formatted with all 'registered' settings in the app.
      # 
      # Mainly used in the HTML output of :show_settings_output? method,
      # but can be used for other debug purposes.
      #  
      # ==== Examples
      # 
      #   settings_inspect => {...} # a Hash with settings.
      # 
      # 
      # @api public
      def settings_inspect 
        out = {}
        settings.sinatra_settings_for_inspection.uniq.each do |s|
          out[s.to_sym] = self.class.respond_to?(s.to_sym) ? self.class.send(s) : nil
        end
        out
      end
      
      
      ##
      # Add settings debug output to the page. 
      # Controlled by the following configurations:
      # 
      # * set :show_settings_output, (boolean) => turns output On / Off
      # * set :show_settings_environment, (symbol) :development/:production => turns output On in the given environment
      #  
      # ==== Examples
      # 
      #   <%= show_settings_output? %>  => will output the settings debug if enabled.
      # 
      # @api public/private
      def show_settings_output?
        if _show_settings_output?
          erb(TEMPLATE, :layout => false)
        else
          "<!-- :show_settings is [#{settings.show_settings ? 'ON' : 'OFF'}]  -->"
        end
      end
      
      
      protected
        
        # :stopdoc:
        
        def _show_settings_output?
          return (
            settings.show_settings === true && 
            ( settings.show_settings_environment == (settings.environment || :development) )
          )
        end
      
      
TEMPLATE = <<HTML
<style type="text/css" media="screen">
  #debug { border: 1px solid #ccc; background: #fff; width: 870px; margin: 2em auto; font-family: 'Lucida Grande', 'Lucida Sans Unicode', 'Garuda';}
  #debug h2 { text-align: center; border-bottom: 1px solid #ccc; background-color: #eee; font-size: 1.4em; }
  #explanation { text-align: center; }
  #debug h3 { margin: 1em 0 0.2em 0.4em; }
  #settings, #params, #get, #post, #cookies, #sessions, #rack { width: 860px; margin: 0 auto 10px auto;}
  p.no-data {padding-top: 2px; color: #666; margin: -1.8em 0 0.8em 10em; }
  table.req { width: 850px; text-align: left; color: #666; padding: 0; border-spacing: 0; border: 1px solid #eee; border-bottom: 0; border-left: 0; margin: 0 auto;}
   table.req tr th { padding: 2px 10px; font-weight: bold; background: #F7F7F7; border-bottom: 1px solid #eee; border-left: 1px solid #eee;}
   table.req tr td { padding: 2px 20px 2px 10px; border-bottom: 1px solid #eee;  border-left: 1px solid #eee; }
   table.req tr td.key  {vertical-align: top; width: 150px;}  
   /* table.req tr td.code { white-space: pre-wrap; word-wrap: break-word; } */
   table.req tr td.key { width: 200px; overflow:hidden; } 
   table.req tr td.code div { width: 650px; overflow:hidden; } 

</style>

<div id="debug">

  <h2>PAGE DEBUG</h2>

  <div id="get">
   <h3>GET</h3>
   <% unless request.GET.empty? %>
     <table class="req">
       <tr>
         <th>Variable</th>
         <th>Value</th>
       </tr>
        <% request.GET.sort_by { |k, v| k.to_s }.each { |key, val| %>
       <tr>
         <td class="key"><%=h key %></td>
         <td class="code"><div><%=h val.inspect %></div></td>
       </tr>
       <% } %>
     </table>
   <% else %>
     <p class="no-data">No GET data.</p>
   <% end %>
   <div class="clear"></div>
  </div> <!-- /GET -->

  <hr>

  <div id="params">
    <h3>PARAMS</h3>
    <% unless params.empty? %>
      <table class="req">
        <tr>
          <th>Variable</th>
          <th>Value</th>
        </tr>
         <% params.sort_by { |k, v| k.to_s }.each { |key, val| %>
         <tr>
           <td class="key"><%=h key %></td>
           <td class="code"><div><%=h val %></div></td>
         </tr>
         <% } %>
      </table>
    <% else %>
      <p class="no-data">No PARAMS data.</p>
    <% end %>
    <div class="clear"></div>
  </div> <!-- /PARAMS -->

  <hr>

  <div id="sessions">
    <h3>SESSIONS</h3>
    <% unless session.empty? %>
      <table class="req">
        <tr>
          <th>Variable</th>
          <th>Value</th>
        </tr>
         <% session.sort_by { |k, v| k.to_s }.each { |key, val| %>
         <tr>
           <td class="key"><%=h key %></td>
           <td class="code"><div><%=h val.inspect %></div></td>
         </tr>
         <% } %>
      </table>
    <% else %>
      <p class="no-data">No SESSION data.</p>
    <% end %>
    <div class="clear"></div>
  </div> <!-- /SESSIONS -->

  <hr>

  <div id="cookies">
    <h3>COOKIES</h3>
    <% unless request.cookies.empty? %>
      <table class="req">
        <tr>
          <th>Variable</th>
          <th>Value</th>
        </tr>
        <% request.cookies.each { |key, val| %>
          <tr>
            <td class="key"><%=h key %></td>
            <td class="code"><div><%= nl2br(val) %></div></td>
          </tr>
        <% } %>
      </table>
    <% else %>
      <p class="no-data">No COOKIE data.</p>
    <% end %>
    <div class="clear"></div>
  </div> <!-- /COOKIES -->

  <hr>

  <div id="routes">
    <h3>ROUTES</h3>
    <% r = self.methods.sort.reject { |i|  i !~ /^(DELETE|GET|POST|PUT)\s/ } %>
    <% unless r.empty? %>
      <table class="req">
        <tr>
          <th>Verb</th>
          <th>Path</th>
        </tr>
        <% r.each { |route| %>
          <tr>
            <td class="key"><%=h route.split(' ').first %></td>
            <td class="code"><div><%= request.script_name %><%=h route.split(' ')[1] %></div></td>
          </tr>
        <% } %>
      </table>
    <% else %>
      <p class="no-data">No ROUTES declared.</p>
    <% end %>
    <div class="clear"></div>
  </div> <!-- /ROUTES -->

  <hr>

  <div id="settings">
    <h3>SETTINGS</h3>
    <table class="req">
      <tr>
        <th>Variable</th>
        <th>Value</th>
      </tr>
       <% settings_inspect.sort_by { |k, v| k.to_s }.each { |key, val| %>
       <tr>
         <td class="key"><%=h key %></td>
         <% if !val.is_a?(String) %>
            <% if( key == :sass) %>
            <%# val[:load_paths] = val[:load_paths].uniq! %>
            <td class="code">SASS
              <div><%= h val.inspect %></div>
            </td>
          <% else %>
            <td class="code"><div><%=h val.inspect %></div></td>
          <% end %>
         <% else %>
          <td class="code"><div><%=h val %></div></td>
         <% end %>
       </tr>
       <% } %>
    </table>
    <div class="clear"></div>
  </div> <!-- /SETTINGS -->

  <hr>

  <div id="rack"> 
    <h3 id="env-info">Rack ENV</h3>
    <table class="req">
      <tr>
        <th>Variable</th>
        <th>Value</th>
      </tr>
       <% env.sort_by { |k, v| k.to_s }.each { |key, val| %>
       <tr>
         <td class="key"><%=h key %></td>
         <% unless val.is_a?(String) %>
         <td class="code"><div><%=h(val.inspect).gsub('\n','<br>').gsub('%0A','<br>') %></div></td>
         <% else %>
         <td class="code"><div><%=h(val).gsub('\n','<br>').gsub('%0A','<br>') %></div></td>
         <% end %>
       </tr>
       <% } %>
    </table>
    <div class="clear"></div>
  </div> <!-- /RACK ENV -->

  <p id="explanation">You're seeing this output because you have enabled the <code>show_settings</code> option.</p>


</div>
HTML
      
      # :startdoc:
      
    end #/module Helpers
    
    
    
    def self.registered(app)
      app.helpers Sinatra::Settings::Helpers
      
      # don't show settings by default
      app.set :show_settings, false
      # only show the settings in development mode.
      app.set :show_settings_environment, :development
      
      ## add the extension specific settings to those inspectable by the :settings_inspect method
      if app.respond_to?(:sinatra_settings_for_inspection)
        %w(show_settings show_settings_environment).each do |s|
          app.sinatra_settings_for_inspection << s
        end
      end
      
    end
    
    
  end #/module Settings
  
end #/module Sinatra

