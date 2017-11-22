if Code.ensure_loaded?(Poison) do
    defmodule HttpBuilder.Adapters.JSONParser.Poison do
        
        @behaviour HttpBuilder.Adapter.JSONParser
        
        alias HttpBuilder.Adapter.JSONParser

        @spec encode!(value :: term, options :: Keyword.t) :: JSONParser.encoded
        def encode!(value, opts \\ []), do: Poison.encode!(value, opts)

        @spec decode!(value :: term, options :: Keyword.t) :: JSONParser.decoded
        def decode!(value, opts \\ []), do: Poison.decode!(value, opts)
        
    end
end
