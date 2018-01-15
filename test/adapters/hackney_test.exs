defmodule HttpBuilder.Adapters.HackneyTest do
    use ExUnit.Case, async: true
  
    alias HttpBuilder.Adapters
    
    import HttpBuilder
  
    doctest HttpBuilder.Adapters.Hackney

    def parse_response({:ok, _status, _headers, ref}) do
        case :hackney.body(ref) do
            {:ok, body } -> Poison.decode!(body)
            {:error, reason } -> reason
        end
    end


    def client, do: cast(%{ host: "http://localhost:8080", adapter: Adapters.Hackney})

    setup_all do
        :application.ensure_all_started(:hackney)
        {:ok,  [] }
    end



    test "can make a GET request" do
        
        body = 
            client()
            |> get("/get")
            |> send()
            |> parse_response()

        assert body["url"] == "http://localhost:8080/get"
    end

    test "can make a DELETE request" do
        
        body = 
            client()
            |> delete("/delete") 
            |> send()
            |> parse_response()

        assert body["url"] == "http://localhost:8080/delete"
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