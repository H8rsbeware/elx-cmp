defmodule CMP do
  def tokeniser(input) do
    # Chunks integers and characters not seperated by spaces
    tokenise_function = fn
      (el, chunk = [prev | _]) when el in ?0..?9 ->
        case prev in ?0..?9 do
          true  -> {:cont, [el | chunk]}
          false -> {:cont, chunk, [el]}
        end
      (el, chunk = [prev | _]) when el in ?a..?z ->
        case prev in ?a..?z or prev == ?" do
          true  -> {:cont, [el | chunk]}
          false -> {:cont, chunk,[el]}
        end
      (el, chunk = [prev | _]) when el == ?" ->
        case prev in ?a..?z do
          true  -> {:cont, [el | chunk], []}
          false -> {:cont, chunk, [el]}
        end
      (el, chunk) when el == " " -> {:cont, chunk, []}
      (el, [])    -> {:cont ,[el]}
      (el, chunk) ->
        {:cont, chunk, [el]}
    end

    after_tokenise_function = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    Stream.chunk_while(input, [], tokenise_function, after_tokenise_function)
      |> Stream.reject(fn x -> x == ~c" " end)
      |> Stream.map(fn x ->
          x = Enum.reverse(x)
          cond do
            Enum.all?(x, fn y -> y in ?a..?z end) -> %{:type => :name, :value => x}
            Enum.all?(x, fn y -> y in ?a..?z or y == ?" end) -> %{:type => :string, :value => x}
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

d = '(add "minus" 15 1 2)'
CMP.tokeniser(d) |> IO.inspect()
