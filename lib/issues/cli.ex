defmodule Issues.CLI do
  @default_count 4 

  @moduledoc """
  Handle the command line parsing and the dispatch to the various functions that end up generatinga  table of the last n issues in a github project.
  """
  def run(argv) do 
    parse_args(argv)
  end 

  @doc  """
  'argv' can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally) the number of entries to forma   Return a tuble of {user, project, count } or :help
  """

  def parse_args(argv) do
      parse = OptionParser.parse(argv, switches: [help: :boolean],
                                      aliases: [h: :help])
      case parse do 
        { [ help: true ], _, _ }
          -> :help 
        {_, [user, project, count ], _ }
          -> {user, project, String.to_integer(count) }
        {_, [ user, project ], _ } 
          -> {user, project, @default_count }
        _ -> :help
    end
  end 

  def process({user, project, _count}) do 
    Issues.GithubIssues.fetch(user, project) 
    |> decode_response 
  end
  
  def decode_response({:ok, body}), do: body 

  def decode_response({:error, error}) do 
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2) 
  end  
end

