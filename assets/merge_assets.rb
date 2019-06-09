require 'yaml'

class MergeAssets
  def initialize
    @config = YAML.load_file(File.join(File.dirname(__FILE__), '../config/merge_assets_config.yml'))

    merge_javascripts
    compile_sass
  end

  def merge_javascripts
    # set up
    File.write(File.join(File.dirname(__FILE__), './newline.txt'), "\n")
    files = ""

    # build command
    @config["js-files-to-compile"].each_with_index do |file, index|
      puts "Adding: #{file}"
      if index != @config["js-files-to-compile"].length - 1
        files << "#{File.join(File.dirname(__FILE__), '../assets/materialize/js/' + file)} #{File.join(File.dirname(__FILE__), './newline.txt')} "
      else
        files << "#{File.join(File.dirname(__FILE__), '../assets/materialize/js/' + file)} "
      end
    end

    # execute compile
    system("(cat #{files}) > #{File.join(File.dirname(__FILE__), '../priv/static/js/compiled_materialize.js')}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), './newline.txt'))
  end

  def compile_sass
    # set up
    materialize_sass = File.join(File.dirname(__FILE__), '../assets/materialize/sass/materialize.scss')
    compiled_css = File.join(File.dirname(__FILE__), '../priv/static/css/compiled_materialize.css')

    # execute compile
    system("sass #{materialize_sass} #{compiled_css}")

    # clean up
    File.delete(File.join(File.dirname(__FILE__), '../priv/static/css/compiled_materialize.css.map'))
  end
end

MergeAssets.new()
