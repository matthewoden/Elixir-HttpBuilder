# HttpBuilder

A DSL for building chainable, composable HTTP requests. API structure taken from
the lovely [elm-http-builder](https://github.com/lukewestby/elm-http-builder). 

Currently comes with a single adapter for `HTTPoison`. Feedback welcome

``` elixir
defmodule MyApp.APIClient do

  import HttpBuilder

  @adapter Application.get_env(:my_app, :http_adapter)
  @config Application.get_env(:my_app, :api_config)


  defp client() do
    HttpBuilder.new("https://some-api.org", @adapter)
    |> with_headers(%{
        "Client-Id" => config["client_id"],
        "Client-Secret" => config["client_secret"],
        "Content-Type" => "application/json"
      })
    
  end

  def submit_widget(body) do 
    client()
    |> post("/v1/path/to/submit")
    |> with_body(body)
    |> send()
  end

  def get_widget do
    client()
    |> get("/v1/path/to/fetch")
    |> with_query_params(%{"offset" => 10, "limit" => 5})
    |> with_request_timeout(10 * 1000)
    |> with_recieve_timeout(5 * 1000)
    |> send()
  end

end
```

## TODO
- add support for streaming and chunked requests
- add support for multipart form requests
- move integration tests to local api server, rather than httpbin


## Installation

>(Still a WIP. Not yet available on hex)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `http_builder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:http_builder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/http_builder](https://hexdocs.pm/http_builder).

