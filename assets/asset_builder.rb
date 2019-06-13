require "yaml"

class AssetBuilder
  def initialize(user_input)
    @params = {}
    if user_input.length == 0
      @params[:mode] = "all"
      @params[:assets] = "materialize"
    elsif user_input.length == 1
      @params[:mode] = "all"
      @params[:assets] = user_input[0]
    elsif user_input.length == 2
      @params[:assets] = user_input[0]
      @params[:mode] = user_input[1]
    else
      throw "Unrecognized argument configuration"
    end

    @config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/asset_builder_config.yml"))

    if @params[:assets] == "materialize"
      compile_and_minify_materialize_javascripts unless @params[:mode] == "scss" || @params[:mode] == "css"
      compile_materialize_sass unless @params[:mode] == "js"
      minify_materialize_css unless @params[:mode] == "js"
    else
      file_name = @params[:assets] + ".js"
      minify_single_js_file(
        file_path: File.join(File.dirname(__FILE__), @config["custom-js-input-dir"] + file_name),
        file_name: file_name,
        output_dir: @config["js-output-dir"]
      ) unless @params[:mode] == "scss" || @params[:mode] == "css"
      minify_page_css unless @params[:mode] == "js"
    end
    # finish progress meter
    puts "."
  end

  private

  def compile_and_minify_materialize_javascripts
    # set up
    temp_files = []
    File.write(File.join(File.dirname(__FILE__), "./newline.txt"), "\n")
    newline = File.join(File.dirname(__FILE__), "/newline.txt")
    customjs = minify_single_js_file(
      file_path: File.join(File.dirname(__FILE__), "./js/site.js"),
      file_name: "site.js",
      output_dir: "../assets/js/"
    )
    phoenixjs = minify_single_js_file(
      file_path: File.join(File.dirname(__FILE__), "./js/phoenix_html.js"),
      file_name: "phoenix_html.js",
      output_dir: "../assets/js/"
    )
    output_file = File.join(File.dirname(__FILE__), @config["js-output-dir"] + "compiled_materialize.js")
    files = ""

    # build command
    @config["js-files-to-compile"].each_with_index do |file, index|
      # show progress
      print "."

      # set up file info
      file_info = {
        file_path: File.join(File.dirname(__FILE__), @config["materialize-js-input-dir"] + file),
        file_name: file,
        output_dir: @config["materialize-js-input-dir"]
      }
      # avoiding minifying files that are already minified
      minified_file = file.include?(".min.js") ? file_info[:file_path] : minify_single_js_file(file_info)

      # put together system command with correct spacing and order
      if index != @config["js-files-to-compile"].length - 1
        files << (minified_file + " " + newline + " ")
      else
        files << (minified_file + " " + newline + " " + customjs + " " + newline + " " + phoenixjs)
        temp_files.push(customjs)
        temp_files.push(phoenixjs)
      end

      # keep track of file paths to delete later
      temp_files.push(minified_file) unless file.include?(".min.js")
    end

    # execute compile
    system("(cat #{files}) > #{output_file}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), "./newline.txt"))
    temp_files.each do |temp_file|
      File.delete(temp_file)
    end
  end

  def minify_single_js_file(file_name:, file_path:, output_dir:)
    # set up
    closure_compiler = File.join(File.dirname(__FILE__), @config["closure-compiler-path"])
    minified_name = @params[:assets] == "materialize" ? "minimized-" + file_name : @params[:assets] + ".min.js"
    to_file = File.join(File.dirname(__FILE__), output_dir + minified_name)

    # execute minify to same file
    system("java -jar #{closure_compiler} --jscomp_off=misplacedTypeAnnotation --js #{file_path} --js_output_file #{to_file}")

    to_file
  end

  def compile_materialize_sass
    # show progress
    print "."

    # set up
    materialize_sass = File.join(File.dirname(__FILE__), @config["materialize-sass-file"])
    compiled_css = File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.css")

    # execute compile
    system("sass #{materialize_sass} #{compiled_css}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.css.map"))
  end

  def minify_materialize_css
    # show progress
    print "."

    # execute minify command
    from = "../priv/static/css/compiled_materialize.css"
    to = "../priv/static/css/compiled_materialize.min.css"
    system("cd assets && FROM=#{from} TO=#{to} npm run --silent minify-css")

    # clean up
    final_file = File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.css")
    temp_file = File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.min.css")
    system("mv #{temp_file} #{final_file}")
  end

  def minify_page_css
    # show progress
    print "."

    # execute minify command
    from = @config["custom-css-input-dir"] + @params[:assets] + ".css"
    to = "../priv/static/css/#{@params[:assets]}.min.css"
    system("cd assets && FROM=#{from} TO=#{to} npm run --silent minify-css")
  end
end

AssetBuilder.new(ARGV)
