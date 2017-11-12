defmodule HttpBuilder.Adapters.HTTPosion do

    alias HttpBuilder.HttpRequest
    
    @behaviour HttpBuilder.Adapter

    @spec send(HttpRequest) :: {:ok, term } | { :error, String.t }

    def send(%{retry: retries} = request) do
        options = create_options(request)

        converted_request = 
            HTTPoison.request(
                request.method,
                request.host <> request.path,
                format_body(request.body),
                request.headers,
                options
            )
            
        case converted_request do
            {:ok, %{status_code: code, body: body}} when code < 400 and code >= 200 ->
                {:ok, Poison.decode!(body) }
    
            {:ok, %{status_code: status }} when 500 < status and retries > 0 ->
                send(%{ request | retry: retries - 1 })
    
            {:ok, %{status_code: status, body: body }}  ->
                {:error, %{status_code: status, body: body }}
    
            {:error, %HTTPoison.Error{reason: reason}} ->
                {:error, reason }

            other ->
                {:error, "Could not complete request: #{inspect(other)}" }
                
        end        
    end

    def format_body({atom, body}), do: {atom, body}

    def format_body(body), do: Poison.encode!(body)   

    defp create_options(request) do
        timeout_options = [ 
            timeout: request.req_timeout, 
            recv_timeout: request.rec_timeout,
        ]

        params_options = if length(request.query_params) != 0, 
            do: [params: request.query_params], else: []

        Enum.concat(request.options, [timeout_options, params_options])
    end

end