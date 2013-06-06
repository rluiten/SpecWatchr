require "./watcher_dot_net"

describe NSpecRunner do
  before(:each) do
    @test_runner = NSpecRunner.new "." 
    stub_stack_trace_output
    $stdout.stub!(:puts) { }
  end

  def stub_stack_trace_output
    @test_runner.stub!(:write_stack_trace) do |output|
      @written_stack_trace = output
    end
  end

  describe "failure report written to stacktrace.txt" do
    before(:each) do
      @sh = mock("CommandShell")
      CommandShell.stub!(:new).and_return(@sh)
      @sh.stub!(:execute).and_return("")
      @test_runner = NSpecRunner.new "."
      stub_stack_trace_output
    end

    it "writes failures from each dll run" do
      @test_runner.stub!(:test_dlls).and_return(["./test1.dll", "./test2.dll" ])

      @test_runner.execute "SomeTestSpec"

      test_output_dll1 = <<-OUTPUT.gsub(/^ {8}/, '')
        borrowed games
          games controller
            wanted games
              wanting game
                marks the game as requested
              deleting wanted game
                other requests are unchanged

        **** FAILURES ****

        nspec.  borrowed games.  games controller. wanted games. wanting game. marks the game as requested.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
            at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152

        nspec.  borrowed games.  games controller. wanted games. deleting wanted game. other requests are unchanged.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
            at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152
      OUTPUT

      given_output "./test1.dll", test_output_dll1

      test_output_dll2 = <<-OUTPUT.gsub(/^ {8}/, '')
        borrowed games
          games controller
            wanted games
              deleting wanted game
                is no longer requested

        **** FAILURES ****

        nspec.  borrowed games.  games controller. wanted games. deleting wanted game. is no longer requested.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
           at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152
      OUTPUT

      given_output "./test2.dll", test_output_dll2

      @test_runner.execute "SomeTestSpec"

      expected = <<-HERE.gsub(/^ {8}/, '')
        nspec.  borrowed games.  games controller. wanted games. wanting game. marks the game as requested.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
            at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152

        nspec.  borrowed games.  games controller. wanted games. deleting wanted game. other requests are unchanged.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
            at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152

        nspec.  borrowed games.  games controller. wanted games. deleting wanted game. is no longer requested.
        'BorrowedGames.Models.User' does not contain a definition for 'Wantss'
           at BorrowedGames.Models.User.GameIsWanted(Object game) in Sample\\BorrowedGames\\Models\\User.cs:line 152

      HERE

      @written_stack_trace.should eq expected
    end
  end

  def given_output(dll_name, output)
    @test_runner.stub!(:test_cmd)
                .with(dll_name, "SomeTestSpec")
                .and_return(dll_name)

    @sh.stub!(:execute).with(dll_name).and_return(output)
  end
end
