# encoding: utf-8
# Copyright © 2013 Jon Williams. See LICENSE.txt for details.
require 'cgi'

module CepaHealth

  class Middleware
    DEFAULT_PATH = /\A\/healthy(\.html|\.json|\.txt)?\z/

    def initialize(app, options={})
      @app  = app
      @path = options.fetch(:path, DEFAULT_PATH)
    end

    def call(env)
      path = env['PATH_INFO']
      path_matches?(path) ? process(path, env) : @app.call(env)
    end

    protected

    def determine_mime_type(path)
      case path.split('.').last.downcase
      when 'json' then 'application/json'
      when 'txt' then 'text/plain'
      else 'text/html'
      end
    end

    def process(path, env)
      query = env['QUERY_STRING']
      params = Rack::Utils.parse_nested_query(query)
      filters = params['filters']
      result = CepaHealth.execute(*(filters || []))
      
      mime = determine_mime_type(path)

      body = case mime
      when 'text/plain' then render_text(result)
      else render_html(result)
      end

      [result.success? ? 200: 500, { 'Content-Type' => "#{mime}; charset=utf-8" }, [body]]
    end

    def path_matches?(path)
      case @path
      when Proc then @path.call(path)
      when Regexp then path =~ @path
      else @path.to_s == path
      end
    end

    def render_html(result)
      rows = result.records.map do |name, status, comment|
        stat = status ? "<td class='status ok'>OK</td>" : "<td class='status fail'>FAIL</td>"
        "<tr>#{stat}<td class='name'>#{CGI::escapeHTML(name)}</td><td>#{CGI::escapeHTML(comment)}</td></tr>"
      end
      <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>Health Check</title>
    <style type='text/css'>
      body {
        font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
      }
      div.container {
        margin: 0 auto;
        width: 960px;
      }
      
      h1 { font-size: 20px; font-weight: bold; }
      h2 { font-size: 22px; font-weight: bold; }
      h2 span { font-size: 36px; }
      
      table {
        border-bottom: 1px solid #999;
        border-top: 1px solid #999;
        margin-top: 10px;
        width: 100%;
      }

      td { 
        font-size: 14px; 
        padding: 5px; 
      }
      td.name { background: #f7f7f7; font-weight: bold; width: 200px; }
      td.status { font-weight: bold;  text-align: center; width: 50px; }
      td.status.fail { background: #fdd; color: #c00; }
      td.status.ok { background: #dfd; color: #0c0; }

      .fail h2 { color: #600; }
      .fail span { color: #c00; text-shadow: 2px 2px 0 #600; }
      .ok h2 { color: #060; }
      .ok span { color: #0c0; text-shadow: 2px 2px 0 #060; }

    </style>
  </head>
  <body class='#{ result.success? ? 'ok' : 'fail'}'>
    <div class='container'>
      <h1>Health Check</h1>
      <h2>#{ result.success? ? "<span>✔</span> Great, the Application is Healthy" : "<span>✘</span> Damn, something is broken"}</h2>
      <table>#{ rows * "\n" }</table>
    </div>
  </body>
</html>
      HTML
    end

    def render_text(result)
      body = "#Entry\t#Status\t#Comment\n"
      body << (result.success? ? "Overall\tSuccess\n" : "Overall\tFailure\n")
      body + result.records.map { |a,b,c| "#{a}\t#{b ? "Success" : "Failure"}\t#{c}" } * "\n"
    end

  end

end
