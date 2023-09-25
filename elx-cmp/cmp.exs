defmodule CMP do
  def tokeniser(input) do
    # Chunks integers and characters not seperated by spaces
    tokenise_function = fn
      # If its a number, then we need to check if there was a number previously or not, if there is they are chunked together
      # ie -   "10 1" becomes [10, 1]
      (el, chunk = [prev | _]) when el in ?0..?9 ->
        case prev in ?0..?9 do
          true  -> {:cont, [el | chunk]}
          false -> {:cont, chunk, [el]}
        end
      # Same goes for letters, however we also have to handle strings.
      # We check for " which is kept in the chunk
      # ie - ` "string" string` becomes ["string", string]
      (el, chunk = [prev | _]) when el in ?a..?z ->
        first = Enum.take(chunk, -1)
        if first == '"' and prev == ?\s do
          {:cont, [el | chunk]}
        else
          case prev in ?a..?z or prev == ?" do
            true  -> {:cont, [el | chunk]}
            false -> {:cont, chunk,[el]}
          end
        end
      # End and start of string check.
      # ! Strings must only be characters from a-z ;-;
      (el, chunk = [prev | _]) when el == ?" ->
        case prev in ?a..?z do
          true  -> {:cont, [el | chunk], []}
          false -> {:cont, chunk, [el]}
        end
      # Checks the first character of the chunk, as string detection, if its " then we add the space to the chunk
      # ? probably the solution to the a-z string issue
      (el, chunk) when el == ?\s ->
        first = Enum.take(chunk, -1)
        case first == '"' do
          true  -> {:cont, [el | chunk]}
          false -> {:cont, chunk, []}
        end
      # Nothing in the chunk, then start a new one
      (el, [])    -> {:cont ,[el]}
      # If its something else, then just make it its own element
      (el, chunk) ->
        {:cont, chunk, [el]}
    end

    after_tokenise_function = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    Stream.chunk_while(input, [], tokenise_function, after_tokenise_function)
      |> Stream.reject(fn x -> x == ~c" " end)
      |> Stream.reject(fn x -> x == [] end)
      |> Stream.map(fn x ->
          # for each token, we gotta reverse (prepending is faster)
          x = Enum.reverse(x)
          cond do
            # Creates an array of maps, containing each token and there identifer
            # ! Will also have to alter when fixing a-z string issue
            Enum.all?(x, fn y -> y in ?a..?z end) -> %{:type => :name, :value => x}
            Enum.all?(x, fn y -> y in ?a..?z or y == ?" or y == ?\s end) -> %{:type => :string, :value => x}
            Enum.all?(x, fn y -> y in ?0..?9 end) -> %{:type => :int , :value => x}
            x == ~c"(" or x == ~c")" -> %{:type => :paran, :value => x}
            true -> raise "Something went wrong with token #{x}"
          end
        end)
      |> Enum.to_list()
  end

  def token_to_ast_parse(token_list) do
    # Create the tree that can be executed
    # recursively walk through parens until the next one is found

    # (
    # call
    #  (
    #   call
    #   3
    #   4
    #  )
    #  2
    # )
  end
end

d = '(add "min us" 15 1 2)'
# CMP.tokeniser(d) |> Enum.map(fn x ->
#   if Enum.count(x.value) != 1 do
#     [first | _] = x.value
#     first
#   else
#     x.value
#   end
# end) |>IO.inspect()

CMP.tokeniser(d) |> IO.inspect()
