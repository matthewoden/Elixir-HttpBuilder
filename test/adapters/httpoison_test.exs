defmodule HttpBuilder.Adapters.HTTPoisonTest do
    use ExUnit.Case, async: true
  
    alias HttpBuilder.Adapters
    
    import HttpBuilder
    import ExUnit.CaptureIO

    doctest HttpBuilder.Adapters.HTTPoison

    def parse_response({:ok, response}), do: Poison.decode!(response.body)

    setup_all do
        :application.ensure_all_started(:httpoison)
        {:ok,  [] }
    end

    test "can make a GET request" do
        
        body = 
            cast(%{ host: "http://localhost:8080", adapter: Adapters.HTTPoison})
            |> get("/get")
            |> send()
            |> parse_response()

        assert body["url"] == "http://localhost:8080/get"
    end

    test "can make a DELETE request" do
        
        body = 
            cast(%{ host: "http://localhost:8080", adapter: Adapters.HTTPoison})
            |> delete("/delete") 
            |> send()
            |> parse_response()

        assert body["url"] == "http://localhost:8080/delete"
    end

    test "can make a POST request with a json body" do
        
        body = 
            cast(%{ host: "http://localhost:8080", adapter: Adapters.HTTPoison})
            |> post("/post") 
            |> with_json_body(%{ "title" => "foo", "body" => "bar", "userId" => 1 })
            |> send()
            |> parse_response()            
        
        assert body["json"] == %{ "title" => "foo", "body" => "bar", "userId" => 1 }
    end

    test "can make a form-encoded POST request." do
        body = %{
            "custname" => "test",
            "custtel" => "test",
            "custemail" => "test",
            "delivery" => "test",
            "comments" => "test",
        }

        response_body =
            cast(%{ host: "http://localhost:8080", adapter: Adapters.HTTPoison})
            |> post("/post") 
            |> with_form_encoded_body(body)
            |> send()
            |> parse_response()                        

        assert response_body["form"] ==  body
    end

    test "returns an error on a bad network request" do
        params = %{ host: "http://localhost:12345", adapter: Adapters.HTTPoison }
        response = 
            cast(params)
            |> post("/posts") 
            |> with_body("{}")
            |> send()

        assert response == { :error, %HTTPoison.Error{id: nil, reason: :econnrefused} }
    end

    test "typo module delegates with warning" do
        request = cast(%{ 
            host: "http://localhost:8080", 
            method: :get,
            path: "/get",
            adapter: Adapters.HTTPosion
            })
        
        capture_io(fn -> send(request) end) =~ "`HttpBuilder.Adapters.HTTPosion/1` is deprecated; call `HttpBuilder.Adapters.HTTPoison/2` instead."
    end

end