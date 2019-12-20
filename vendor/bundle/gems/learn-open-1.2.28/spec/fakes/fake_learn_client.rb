require 'ostruct'
class FakeLearnClient
  attr_reader :token
  def initialize(token:)
    @token = token
  end
  def current_lesson
    OpenStruct.new({:id=>31322,
     :title=>"Tic Tac Toe Board",
     :link=>"https://learn.co/lessons/31322",
     :github_repo=>"ttt-2-board-rb-v-000",
     :forked_repo=>"StevenNunez/ttt-2-board-rb-v-000",
     :clone_repo=>"StevenNunez/ttt-2-board-rb-v-000",
     :git_server=>"github.com",
     :dot_learn=>{:tags=>["variables", "arrays", "tictactoe"], :languages=>["ruby"], :resources=>0},
     :lab=>true,
     :ios_lab=>false,
     :ruby_lab=>true,
     :use_student_fork=>true,
     :assessments=>
    [{:type=>"fork", :passing=>true, :failing=>false, :started=>true, :message=>"You forked this lab."},
     {:type=>"local_build", :passing=>false, :failing=>true, :started=>true, :message=>"Build failures."},
     {:type=>"pull_request", :passing=>false, :failing=>false, :started=>false, :message=>"Submit a pull request on Github when you're done."}]})
  end

  def fork_repo(repo_name: ); :noop; end

  def validate_repo_slug(repo_slug:)
    case repo_slug
    when "ios_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/ios_lab",
        :repo_name=>"ios_lab",
        :repo_slug=>"StevenNunez/ios_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :git_server=>"github.com",
        :use_student_fork=>true,
        :dot_learn=>{
          :tags=>[
            "UIView"
          ],
          :languages=>["swift"],
          :resources=>0}
      })
    when "ios_with_workspace_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/ios_with_workspace_lab",
        :repo_name=>"ios_with_workspace_lab",
        :repo_slug=>"StevenNunez/ios_with_workspace_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :use_student_fork=>true,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "UIView"
          ],
          :languages=>["swift"],
          :resources=>0}
      })
    when "jupyter_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/jupyter_lab",
        :repo_name=>"jupyter_lab",
        :repo_slug=>"StevenNunez/jupyter_lab",
        :lab=>true,
        :lesson_id=>31322,
        :use_student_fork=>true,
        :later_lesson=>false,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "jupyter_notebook"
          ],
          :languages=>["python"],
          :jupyter_notebook => true,
          :resources=>0}
      })
    when "ruby_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/ruby_lab",
        :repo_name=>"ruby_lab",
        :repo_slug=>"StevenNunez/ruby_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :use_student_fork=>true,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "arrays"
          ],
          :languages=>["ruby"],
          :resources=>0}
      })
    when "node_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/node_lab",
        :repo_name=>"node_lab",
        :repo_slug=>"StevenNunez/node_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :use_student_fork=>true,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "arrays"
          ],
          :languages=>["javascript"],
          :resources=>0}
      })
    when "python_lab"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/python_lab",
        :repo_name=>"python_lab",
        :repo_slug=>"StevenNunez/python_lab",
        :lab=>true,
        :lesson_id=>31322,
        :later_lesson=>false,
        :use_student_fork=>true,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "arrays"
          ],
          :languages=>["python"],
          :resources=>0}
      })
    when "readme"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/readme",
        :repo_name=>"readme",
        :repo_slug=>"StevenNunez/readme",
        :lab=>false,
        :lesson_id=>31322,
        :later_lesson=>false,
        :use_student_fork=>true,
        :git_server=>"github.com",
        :dot_learn=>{
          :tags=>[
            "Reading things"
          ],
          :languages=>["ruby"],
          :resources=>0}
      })
    when "later_lesson"
      OpenStruct.new({
        :clone_repo=>"StevenNunez/later_lesson",
        :repo_name=>"later_lesson",
        :repo_slug=>"StevenNunez/later_lesson",
        :lab=>false,
        :lesson_id=>31322,
        :later_lesson=>true,
        :git_server=>"github.com",
        :use_student_fork=>true,
        :dot_learn=>{
          :tags=>[
            "Readable things"
          ],
          :languages=>["english"],
          :resources=>0}
      })
    else
      raise "Specify lab type"
    end
  end

  def next_lesson
    OpenStruct.new({
      :id=>21304,
      :title=>"Rails Dynamic Request Lab",
      :link=>"https://learn.co/lessons/21304",
      :github_repo=>"rails-dynamic-request-lab-cb-000",
      :forked_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
      :clone_repo=>"StevenNunez/rails-dynamic-request-lab-cb-000",
      :git_server=>"github.com",
      :use_student_fork=>true,
      :dot_learn=>
      {
        :tags=>[
          "dynamic routes",
          "controllers",
          "rspec",
          "capybara",
          "mvc"
        ],
        :languages=>["ruby"],
        :type=>["lab"],
        :resources=>2},
        :lab=>true,
        :ios_lab=>false,
        :ruby_lab=>true,
        :assessments=>
        [
          {
            :type=>"fork",
            :passing=>true,
            :failing=>false,
            :started=>true,
            :message=>"You forked this lab."
          },
          {
            :type=>"local_build",
            :passing=>false,
            :failing=>false,
            :started=>false,
            :message=>"Run your tests locally to test your lab."
          },
          {
            :type=>"pull_request",
            :passing=>false,
            :failing=>false,
            :started=>false,
            :message=>"Submit a pull request on Github when you're done."
          }
        ],
        :later_lesson=>false
    })
  end
end
