class FakeGit
  def clone(source, name, path:)
    FileUtils.mkdir_p("#{path}/#{name}")
    case name
    when "jupyter_lab", "python_lab"
      FileUtils.touch("#{path}/#{name}/requirements.txt")
    when "ios_lab"
      FileUtils.touch("#{path}/#{name}/project.xcodeproj")
    when "ios_with_workspace_lab"
      FileUtils.touch("#{path}/#{name}/project.xcworkspace")
    when "ruby_lab"
      FileUtils.touch("#{path}/#{name}/Gemfile")
    when "node_lab"
      FileUtils.touch("#{path}/#{name}/package.json")
    else
       nil
    end
  end
end

