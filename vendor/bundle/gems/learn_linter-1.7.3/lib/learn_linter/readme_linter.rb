class ReadmeLinter

  def self.parse_file(file, learn_error)
    if has_code_snippets?(file)
      lines = collect_lines(file)
      validate_snippets(lines, learn_error)
    else
       green_light(learn_error)
    end
  end

  def self.green_light(learn_error)
    learn_error.readme_error[:valid_readme] = true
    learn_error.valid_readme = {message: "valid readme", color: :green}
  end

  def self.has_code_snippets?(file)
    file_content = File.open(file).read
    file_content.match(/``/)
  end

  def self.collect_lines(file)
    lines = {}
    File.foreach(file) do |line_content|
      lines["#{$.}"] = line_content
    end
    lines
  end

  def self.validate_snippets(lines, learn_error)
    lint_lines(lines, learn_error)
    total_errors?(learn_error)
  end

  def self.lint_lines(lines, learn_error)
    lines.each do |line_num, line_content|
      if line_content.match(/``/)
        if !(line_content.match(/^```(ruby|bash|swift|html|erb|js|javascript|objc|java|sql|css|text)?$/)) 
          learn_error.valid_readme[:message] << "INVALID CODE SNIPPET - line #{line_num}: #{line_content}"
        end
      end
    end
  end

  def self.total_errors?(learn_error)
    if error_free?(learn_error)
        green_light(learn_error)
    end
  end

  def self.error_free?(learn_error)
    learn_error.valid_readme[:message].empty?
  end
end


    