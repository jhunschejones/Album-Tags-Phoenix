require "yaml"

class AssetBuilder
  def initialize(user_input)
    @params = setup_params(user_input)
    @config = YAML.load_file(absolute_path("../config/asset_builder_config.yml"))

    if @params[:assets] == "materialize"
      compile_and_minify_materialize_js unless ["scss", "css"].include?(@params[:mode])
      compile_and_minify_sass_file unless @params[:mode] == "js"
    else
      if !["scss", "css"].include?(@params[:mode])
        file_name = @params[:assets] + ".js"
        minified_file = minify_single_js_file(
          file_path: absolute_path(@config["custom-js-input-dir"] + file_name),
          file_name: file_name
        )
        system("mv #{minified_file} #{@config["js-output-dir"] + file_name.split('.')[0] + ".min.js"}")
      end
      minify_css_file unless ["js", "scss"].include?(@params[:mode])
      compile_and_minify_sass_file unless ["js", "css"].include?(@params[:mode])
    end
  end

  private

  def compile_and_minify_materialize_js
    # set up
    File.write(absolute_path("./newline.txt"), "\n")
    newline = absolute_path("/newline.txt")
    customjs = absolute_path(
      minify_single_js_file(
        file_path: "./js/site.js",
        file_name: "site.js"
      )
    )
    phoenixjs = absolute_path(
      minify_single_js_file(
        file_path: "./js/phoenix_html.js",
        file_name: "phoenix_html.js"
      )
    )
    output_file = absolute_path(@config["js-output-dir"] + "compiled_materialize.js")
    temp_files = []
    input_files_list = ""

    # build command
    @config["js-files-to-compile"].each_with_index do |file, index|
      # show progress
      print "."

      # set up file info
      file_info = {
        file_path: "../assets/materialize/js/" + file,
        file_name: file
      }
      # avoiding minifying files that are already minified
      minified_file = case file.include?(".min.js") 
                      when true
                        "./assets/materialize/js/#{file_info[:file_name]}"
                      when false
                        absolute_path(minify_single_js_file(file_info))
                      end

      # put together system command with correct spacing and order
      if index != @config["js-files-to-compile"].length - 1
        input_files_list << (minified_file + " " + newline + " ")
      else
        input_files_list << (minified_file + " " + newline + " " + customjs + " " + newline + " " + phoenixjs)
        temp_files.push(customjs)
        temp_files.push(phoenixjs)
      end

      # keep track temp files to delete later
      temp_files.push(minified_file) unless file.include?(".min.js")
    end

    # execute compile
    system("(cat #{input_files_list}) > #{output_file}")

    # clean up
    File.delete(absolute_path("./newline.txt"))
    temp_files.each {|t| File.delete(t)}
    # finish progress
    puts "."
  end

  def minify_single_js_file(file_name:, file_path:)
    # set up
    minified_name = @params[:assets] == "materialize" ? "minimized-#{file_name}" : "#{@params[:assets]}.min.js"
    to = @config["js-output-dir"] + minified_name

    # execute minify from appropriate directory
    if Dir.pwd.include? "assets"
      system("FROM=#{file_path} TO=#{to} npm run --silent minify-js")
    else
      system("cd assets && FROM=#{file_path} TO=#{to} npm run --silent minify-js")
    end

    to
  end

  def compile_and_minify_sass_file
    # set up
    if @params[:assets] == "materialize"
      from = "../assets/materialize/sass/materialize.scss" 
      to = @config["css-output-dir"] + "compiled_materialize.css"
    else
      from = @config["custom-styles-input-dir"] + @params[:assets] + ".scss"
      to = @config["css-output-dir"] + @params[:assets] + ".min.css"
    end

    # # execute compile and minimize from the correct directory
    if Dir.pwd.include? "assets"
      system("FROM=#{from} TO=#{to} npm run --silent compile-scss")
    else
      system("cd assets && FROM=#{from} TO=#{to} npm run --silent compile-scss")
    end
  end

  def minify_css_file
    # execute minify command
    from = @config["custom-styles-input-dir"] + @params[:assets] + ".css"
    to = @config["css-output-dir"] + @params[:assets] + ".min.css"

    # minimize from the correct directory
    if Dir.pwd.include? "assets"
      system("FROM=#{from} TO=#{to} npm run --silent minify-css")
    else
      system("cd assets && FROM=#{from} TO=#{to} npm run --silent minify-css")
    end
  end

  def absolute_path(file)
    File.join(File.dirname(__FILE__), file)
  end

  def setup_params(user_input)
    params = {}
    if user_input.length == 0
      params[:mode] = "all"
      params[:assets] = "materialize"
    elsif user_input.length == 1
      params[:mode] = "all"
      params[:assets] = user_input[0]
    elsif user_input.length == 2
      params[:assets] = user_input[0]
      params[:mode] = user_input[1]
    else
      throw "Unrecognized argument configuration"
    end

    params
  end
end

AssetBuilder.new(ARGV)
