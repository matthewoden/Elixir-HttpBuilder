defmodule HttpBuilder.Adapters.IBrowseTest do
    use ExUnit.Case
  
    alias HttpBuilder.Adapters
    
    import HttpBuilder
  
    doctest HttpBuilder.Adapters.IBrowse

    def parse_response({:ok, _status, _headers, body}) do
        Poison.decode!(body)
    end

    def client do        
        cast(%{ host: "http://httpbin.org", adapter: Adapters.IBrowse})
    end

    setup_all do
        Application.ensure_all_started(:ibrowse)
        
        {:ok,  [] }
    end

    test "can make a GET request" do
        
        response = 
            client()
            |> get("/get")
            |> send()
            |> parse_response()

        assert response["url"] == "http://httpbin.org/get"
    end

    test "can make a DELETE request" do
        
        body = 
            client()
            |> delete("/delete") 
            |> send()
            |> parse_response()

        assert body["url"] == "http://httpbin.org/delete"
    end

    test "can make a POST request with a json body" do
        
        body = 
            client()
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
            client()
            |> post("/post") 
            |> with_form_encoded_body(body)
            |> send()
            |> parse_response()                        

        assert response_body["form"] ==  body
    end

    test "returns an error on a bad network request" do
        params = %{ host: "http://localhost:12345", adapter: Adapters.Hackney }
        response = 
            cast(params)
            |> post("/posts") 
            |> with_body(%{ "title" => "foo", "body" => "bar", "userId" => 1 })
            |> with_headers(%{"Content-type" => "application/json; charset=UTF-8"})
            |> send()

        assert response == { :error, :econnrefused}
    end
end