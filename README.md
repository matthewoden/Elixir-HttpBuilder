![](https://i.imgur.com/4xZNmrH.png)

# HttpBuilder

A DSL for building chainable, composable HTTP requests. API structure taken from
the lovely [elm-http-builder](https://github.com/lukewestby/elm-http-builder).

Currently comes with adapters for `HTTPoison`, `HTTPotion`, `Hackney` and
`IBrowse`. JSON parsers are configurable, but defaults to `Poison` if present.

Documentation can be found at
[https://hexdocs.pm/http_builder](https://hexdocs.pm/http_builder).

It's early days still. Feedback welcome!

## Example Usage

```elixir
defmodule MyApp.APIClient do

  import HttpBuilder

  @adapter Application.get_env(:my_app, :http_adapter)

  def client() do
    # Alternatively - use HttpBuilder.cast/1 with a map of options.
    HttpBuilder.new()
    |> with_host("https://some-api.org")
    |> with_adapter(@adapter)
    |> with_headers(%{
        "Authorization" => "Bearer #{MyApp.getToken()}",
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
    |> with_receive_timeout(5 * 1000)
    |> send()
  end

end
```

## Installation

```elixir
def deps do
  [
    {:http_builder, "~> 0.4.0"}
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
[https://hexdocs.pm/http_builder](https://hexdocs.pm/http_builder).
