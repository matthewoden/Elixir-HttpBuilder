defmodule HttpBuilder.Adapters.HTTPotionTest do
    use ExUnit.Case
  
    alias HttpBuilder.Adapters
    
    import HttpBuilder
  
    doctest HttpBuilder.Adapters.HTTPotion


    def parse_response(%{body: ""}), do: %{}
    def parse_response(response) do
        Poison.decode!(response.body)
    end

    def client do        
        cast(%{ host: "http://localhost:8080", adapter: Adapters.HTTPotion})
    end

    setup_all do
        :application.ensure_all_started(:httpotion)
        {:ok,  [] }
    end



    test "can make a GET request" do
        
        response = 
            client()
            |> get("/get")
            |> send()
            |> parse_response()

        assert response["url"] == "http://localhost:8080/get"
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

    test "can make a POST request with a custom parser" do
        
      body = 
          client()
          |> post("/post") 
          |> with_json_body(%{ "title" => "foo", "body" => "bar", "userId" => 1 })
          |> with_json_parser(Jason)
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
        params = %{ host: "http://localhost:12345", adapter: Adapters.HTTPotion }
        response = 
            cast(params)
            |> post("/posts") 
            |> with_body("{}")
            |> send()

        assert response == %HTTPotion.ErrorResponse{ message: "econnrefused" }
    end

    test "accepts proxy options" do
        response = 
            client()
            |> get("/get") 
            |> with_options([ibrowse: [{:proxy, 'http://localhost:4001'}] ])
            |> send()
            |> parse_response()

        assert response["url"] == "http://localhost:8080/get"
    end
end