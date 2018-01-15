defmodule HttpBuilder do
  
    @moduledoc """
    HttpBuilder is a library that provides a DSL for composable HTTP Requests.

    Each method provided builds and updates a `HTTPBuilder.Request` object,
    until passed into `send`, which calls the adapter to invoke the request.

    ## Example
    Here's an example of a complete request chain:

        HTTPBuilder.new()
        |> with_adapter(HttpBuilder.Adapters.HTTPoison)
        |> post("http://httparrot.com/post/1")
        |> with_headers(%{"Authorization" => "Bearer token"})
        |> with_json_body(%{"test" => "true"})
        |> with_request_timeout(10_000)
        |> with_receive_timeout(5_000)
        |> send() # kicks off the request.
    
    
    This can also be broken down into composable parts, allowing you to easily
    write declarative pipelines for your API calls.

        defmodule MyAPIClient do
            alias HttpBuilder.Adapters

            @adapter Application.get_env(:my_api_client, :client, Adapters.HTTPoison)

            def client do
                HTTPBuilder.new() 
                |> with_adapter()
                |> with_host("http://httparrot.com/")
                |> with_headers(%{"Authorization" => "Bearer token"})
                |> with_request_timeout(10_000)
                |> with_receive_timeout(5_000)
            end

            def create(params) do
                client()
                |> post("/new")
                |> with_json_body(params)
                |> send()
            end

            def update(id, params) do
                client()
                |> put("/item/\#{id}")
                |> with_json_body(params)
                |> send()
            end

            def list(limit, offset) do
                client()
                |> get("/items")
                |> with_query_params(%{"limit" => limit, "offset" => offset})
                |> send()
            end

            def delete(id) do
                client()
                |> delete("/item/\#{id}")
                |> send()
            end

        end

    Sometimes, you don't want to make a call against a service. By putting your 
    adapter in your config, you can also easily switch to a test HTTP adapter. 
    By pattern matching against the request object, you can handle exact request
    scenarios.

        defmodule MyAPIClient.TestAdapter do

            @behaviour HttpBuilder.Adapter

            def send(%{method: :post, path: "/new"}), do: {:ok, new_placeholder_data }
            def send(%{method: :get, path: "/items"}), do: {:ok, items_placeholder_data }

            # ... other request options.
        end
        
    """

    alias HttpBuilder.HttpRequest

    @type request :: HttpRequest.t
    @type path :: String.t
    @type host :: String.t
    @type adapter :: atom

    @doc """
    Creates a new request.
    
    Takes in a host, providing the base path for http requests, and an adapter
    module to eventually run the request.
    """
    @spec new() :: request
    def new(), do: %HttpRequest{}

    @doc """
    Casts a map of predefined options to a `HttpBuilder.Request` struct.
    """
    def cast(map) when is_map(map), do: Map.merge(%HttpRequest{}, map)

    @doc """
    Sets the host for the request. 
    
    Can be used for host/path composition to create a client library for 
    an API.
    """
    def with_host(request, host) when is_binary(host), 
        do: %{ request | host: host }

    @doc """
    Sets the adapter for the request.

    Takes an atom, representing a module that conforms to the 
    `HttpBuilder.Adapter` behaviour.
    """
    @spec with_adapter(request, atom) :: request
    def with_adapter(request, adapter) when is_atom(adapter), 
        do: %{request | adapter: adapter }

    
    @doc """
    Sets the delete method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec delete(request, path) :: request
    def delete(request, path \\ ""), do:  %{ request | method: :delete, path: path }        
    
    
    @doc """
    Sets the get method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec get(request, path) :: request
    def get(request, path \\ ""), do: %{ request | method: :get, path: path }        

    
    @doc """
    Sets the head method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec head(request, path) :: request      
    def head(request, path \\ ""), do:  %{ request | method: :head, path: path }


    @doc """
    Sets the patch method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec patch(request, path) :: request      
    def patch(request, path \\ ""), do: %{ request | method: :patch, path: path }        


    @doc """
    Sets the post method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec post(request, path) :: request      
    def post(request, path \\ ""), do: %{ request | method: :post, path: path }        


    @doc """
    Sets the put method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec put(request, path) :: request      
    def put(request, path \\ ""), do: %{ request | method: :put, path: path }        

    @doc """
    Sets the options method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec options(request, path) :: request      
    def options(request, path \\ ""), 
        do:  %{ request | method: :options, path: path }        
    
    @doc """
    Sets the connect method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec options(request, path) :: request      
    def connect(request, path \\ ""), 
        do:  %{ request | method: :connect, path: path }        


    @doc """
    Sets either a list of two-item tuples, or map of query params on the request.
    """
    @spec with_query_params(request, [String.t] | map) :: request
    def with_query_params(request, query_params) when is_list(query_params),
        do:  %{ request | query_params: query_params ++ request.query_params }                

    def with_query_params(request, query_params) when is_map(query_params),
        do: with_query_params(request, Map.to_list(query_params))
    

    @doc """
    Sets either a list of two-item tuples, or map of headers on the request.
    """
    @spec with_headers(request, [String.t] | map) :: request      
    def with_headers(request, headers) when is_list(headers) do
        %{ request | headers: headers ++ request.headers }                        
    end

    def with_headers(request, headers) when is_map(headers) do
        with_headers(request, Map.to_list(headers))
    end


    @doc """
    Adds a body to the request, with no special notation of type. 
    
    This body should be used to handle requests not explicitly covered
    by HTTPBuilder, or the adapter.
    """
    @spec with_body(request, term) :: request            
    def with_body(request, body) do
        %{request | body: {:other, body } }
    end

    @doc """
    Marks a body to be sent as JSON. 
    
    Takes the value passed in, and adds a tuple of `{:json, body}` to the request,
    and adds `application/json` as `Content-Type headers`

    The adapter will be responsible for encoding the value.
    """
    @spec with_json_body(request, list | map) :: request
    def with_json_body(request, body) do
        %{ request | body: {:json, body}} |> with_headers(%{"Content-Type" => "application/json"})
    end

    @doc """
    Marks a body to be sent as a string. 

    Takes a string, and adds a tuple of `{:string, body}` to the request.
    """
    @spec with_string_body(request, list | map) :: request
    def with_string_body(request, body) when is_binary(body) do
        %{ request | body: {:string, body}}
    end

    @doc """
    Marks a body as a file upload.
    
    Takes a filepath, and adds a tuple of `{:file, filepath}` to the body of the
    request.
    """
    @spec with_file_body(request, path) :: request
    def with_file_body(request, path) do
      %{request | body: {:file, path}}
    end
    

    @doc """
    Marks a body as a form-encoded upload. 
    
    Takes either a list of two-item tuples, or a map of key-value pairs, and
    adds a tuple of `{:form, [{"key", "value"} ...]}` to the body of the request,
    and sets the Content-Type to "application/x-www-form-urlencoded".
    """
    @spec with_form_encoded_body(request, [String.t] | map) :: request            
    def with_form_encoded_body(request, body) when is_list(body) do
        %{request | body: {:form, body } }        
        |> with_headers([{"Content-Type", "application/x-www-form-urlencoded"}])
    end        

    def with_form_encoded_body(request, body) when is_map(body) do
        with_form_encoded_body(request, Map.to_list(body))
    end

    @doc """
    Sets the request timeout of the request.

    A request timeout is how long the overall request should take. A request
    has a default value of `8000`.
    """
    @spec with_request_timeout(request, integer) :: request                  
    def with_request_timeout(request, timeout) do
        %{ request | req_timeout: timeout }
    end


    @doc """
    Sets the receive timeout of the request.

    A receive timeout is how long until the request recieves a response. A request
    has a default value of `5000`.
    """
    @spec with_receive_timeout(request, integer) :: request                        
    def with_receive_timeout(request, timeout) do
        %{ request | rec_timeout: timeout }
    end

    @doc """
    Sets additional options for the request that may not be handled
    by this DSL.
    """
    @spec with_options(request, list | term) :: request
    def with_options(request, list) when is_list(list) do
      %{ request | options: list ++ request.options }
    end

    def with_options(request, item) do
      %{ request | options: [item] ++ request.options }
    end

    @doc """
    Executes a request, with the provided adapter
    """
    @spec send(HttpRequest.t) :: {:ok, term } | { :error, String.t }
    def send(%{adapter: adapter} = request) do
        adapter.send(request)
    end

    def send(_) do
      raise ArgumentError, message: "No adapter set!"
    end

  end
