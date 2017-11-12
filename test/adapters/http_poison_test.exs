defmodule HttpBuilder.Adapters.HTTPosionTest do
    use ExUnit.Case, async: true
  
    alias HttpBuilder.Adapters
    
    import HttpBuilder
  
    doctest HttpBuilder.Adapters.HTTPosion

    setup_all do
        HTTPoison.start()
        {:ok,  [] }
    end

    test "can make a GET request" do
        
        {:ok, response} = 
            new("https://httpbin.org", Adapters.HTTPosion)
            |> get("/get")
            |> send()


        assert response["url"] == "https://httpbin.org/get"
    end

    test "can make a DELETE request" do
        
        {:ok, response} = 
            new("https://httpbin.org", Adapters.HTTPosion)
            |> delete("/delete") 
            |> send()

        assert response["url"] == "https://httpbin.org/delete"
    end

    test "can make a POST request with a standard body" do
        
        {:ok, response } = 
            new("https://httpbin.org", Adapters.HTTPosion)
            |> post("/post") 
            |> with_body(%{ "title" => "foo", "body" => "bar", "userId" => 1 })
            |> send()

        assert response["json"] == %{ "title" => "foo", "body" => "bar", "userId" => 1 }
    end

    test "can make a form-encoded POST request." do
        body = %{
            "custname" => "test",
            "custtel" => "test",
            "custemail" => "test",
            "delivery" => "test",
            "comments" => "test",
        }

        {:ok, response } = 
            new("https://httpbin.org", Adapters.HTTPosion)
            |> post("/post") 
            |> with_form_encoded_body(body)
            |> send()

        assert response["form"] ==  body
    end

    # test "can make a streaming POST request" do
    #     expected = %{"some" => "bytes"}
        
    #     body = Poison.encode!(expected) |> String.split("")

    #     response = 
    #         new("https://httpbin.org", Adapters.HTTPosion)
    #         |> post("/post") 
    #         |> with_stream_body(body)
    #         |> with_headers(%{"Content-Length" => length(body) })
    #         |> send()
    
    #     assert response ==  body
    
    # end

    test "returns an error on a bad request" do

        response = 
            new("http://localhost:12345", Adapters.HTTPosion)
            |> post("/posts") 
            |> with_body(%{ "title" => "foo", "body" => "bar", "userId" => 1 })
            |> with_headers(%{"Content-type" => "application/json; charset=UTF-8"})
            |> send()

        assert response == { :error, :econnrefused }
    end
end