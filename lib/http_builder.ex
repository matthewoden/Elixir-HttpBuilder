defmodule HttpBuilder do
  
    @moduledoc """
    HttpBuilder is a library that provides a DSL for composable HTTP Requests.

    Each method provided builds and updates a `HTTPBuilder.Request` object,
    until passed into `send`, which calls the adapter to invoke the request.
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
    @spec new(host, adapter) :: request
    def new(host, adapter) when is_binary(host) and is_atom(adapter) do
        %HttpRequest{ host: host, adapter: adapter }
    end

    def new(_, _) do
      raise ArgumentError, message: "HttpBuilder.New requires a host (string), and an adapter (atom)."
    end

    
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
    def options(request, path \\ ""), do:  %{ request | method: :options, path: path }        
    
    @doc """
    Sets the connect method on the request.

    Takes an optional path, to be added onto the host of the request.
    """
    @spec options(request, path) :: request      
    def connect(request, path \\ ""), do:  %{ request | method: :connect, path: path }        


    @doc """
    Sets either a list of two-item tuples, or map of query params on the request.
    """
    @spec with_query_params(request, [String.t] | map) :: request
    def with_query_params(request, query_params) when is_list(query_params) do
        %{ request | query_params: query_params ++ request.query_params }                
    end

    def with_query_params(request, query_params) when is_map(query_params) do
      with_query_params(request, Map.to_list(query_params))
    end    


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
    """
    @spec with_body(request, term) :: request            
    def with_body(request, body) do
        %{request | body: body }
    end


    @doc """
    Marks a body as a streaming upload.
    
    Takes a list of enumerables, and adds a tuple of `{:stream, enumerable}`
    to the body of the request.
    """
    @spec with_stream_body(request, Enumerable.t) :: request
    def with_stream_body(request, enumerable) when is_list(enumerable) do
      %{ request | body: {:stream, enumerable}}
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
    adds a tuple of `{:form, [{"key", "value"} ...]}` to the body of the request.
    """
    @spec with_form_encoded_body(request, [String.t] | map) :: request            
    def with_form_encoded_body(request, body) when is_list(body) do
        %{request | body: {:form, body } }        
    end        

    def with_form_encoded_body(request, body) when is_map(body) do
        with_form_encoded_body(request, Map.to_list(body))
    end

    @doc """
    Sets the request timeout of the request.

    A request timeout is how long the overall request should take.
    """
    @spec with_request_timeout(request, integer) :: request                  
    def with_request_timeout(request, timeout) do
        %{ request | req_timeout: timeout }
    end


    @doc """
    Sets the recieve timeout of the request.

    A recieve timeout is how long until the request recieves a response.
    """
    @spec with_recieve_timeout(request, integer) :: request                        
    def with_recieve_timeout(request, timeout) do
        %{ request | rec_timeout: timeout }
    end

    @doc """
    Sets the number of times to retry the request on failure.
    """
    @spec with_retry(request, integer) :: request                              
    def with_retry(request, retry_amount) do
        %{ request | retry: retry_amount}
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