require "yaml"

class MergeAssets
  def initialize
    @config = YAML.load_file(File.join(File.dirname(__FILE__), "../config/merge_assets_config.yml"))

    merge_javascripts
    compile_javascripts
    compile_sass
  end

  def merge_javascripts
    # set up
    File.write(File.join(File.dirname(__FILE__), "./newline.txt"), "\n")
    files = ""

    # build command
    @config["js-files-to-compile"].each_with_index do |file, index|
      if index != @config["js-files-to-compile"].length - 1
        files << "#{File.join(File.dirname(__FILE__), @config["js-input-dir"] + file)} #{File.join(File.dirname(__FILE__), "./newline.txt")} "
      else
        files << "#{File.join(File.dirname(__FILE__), @config["js-input-dir"] + file)} "
      end
    end

    # execute compile
    system("(cat #{files}) > #{File.join(File.dirname(__FILE__), @config["js-output-dir"] + "compiled_materialize.js")}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), "./newline.txt"))
  end

  def compile_javascripts
    # set up
    closure_compiler = File.join(File.dirname(__FILE__), @config["closure-compiler-path"])
    from_file = File.join(File.dirname(__FILE__), @config["js-output-dir"] + "compiled_materialize.js")
    to_file = File.join(File.dirname(__FILE__), @config["js-output-dir"] + "compiled_materialize.min.js")

    # execute minify to new file
    # system("java -jar #{closure_compiler} --js #{from_file} --js_output_file #{to_file}")

    # execute minify to same file
    system("java -jar #{closure_compiler} --js #{from_file} --js_output_file #{from_file}")
  end

  def compile_sass
    # set up
    materialize_sass = File.join(File.dirname(__FILE__), @config["materialize-sass-file"])
    compiled_css = File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.css")

    # execute compile
    system("sass #{materialize_sass} #{compiled_css}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), @config["css-output-dir"] + "compiled_materialize.css.map"))
  end
end

MergeAssets.new()
